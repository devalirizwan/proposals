class SubmittedProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_proposals, only: %i[index download_csv]
  before_action :set_proposal, except: %i[index download_csv]
  
  def index; end

  def show; end

  def download_csv
    send_data @proposals.to_csv, filename: "submitted_proposals.csv"
  end

  def edit_flow
    params[:ids]&.split(',')&.each do |id|
      @proposal = Proposal.find_by(id: id.to_i)
      curl_request
    end

    respond_to do |format|
      format.js { render js: "window.location='/submitted_proposals'" }
      format.html { redirect_to submitted_proposals_path, notice: 'Successfully sent proposal(s) to EditFlow!' }
    end
  end

  def staff_discussion
    @staff_discussion = StaffDiscussion.new
    discussion = params[:discussion]
    if @staff_discussion.update(discussion: discussion,
                                proposal_id: @proposal.id)
      redirect_to submitted_proposal_url(@proposal),
                  notice: "Your comment was added!"
    else
      redirect_to submitted_proposal_url(@proposal),
                  alert: @staff_discussion.errors.full_messages
    end
  end

  def send_emails
    @email = Email.new(email_params.merge(proposal_id: @proposal.id))
    if @email.save
      @email.email_organizers
      redirect_to submitted_proposal_url(@proposal),
                  notice: "Sent email to proposal organizers."
    else
      redirect_to submitted_proposal_url(@proposal),
                  alert: @email.errors.full_messages
    end
  end

  def destroy
    @proposal.destroy
    respond_to do |format|
      format.html { redirect_to submitted_proposals_url,
                    notice: "Proposal was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def approve_status
    @proposal.update(status: 'approved')
    redirect_to submitted_proposals_url(@proposal),
                notice: "Proposal has been approved."
  end

  def decline_status
    @proposal.update(status: 'declined')
    redirect_to submitted_proposals_url(@proposal),
                notice: "Proposal has been declined."
  end

  private

  def query_params?
    params.values.any?(&:present?)
  end

  def email_params
    params.permit(:subject, :body, :revision)
  end

  def set_proposals
    @proposals = Proposal.order(:created_at)
    if query_params?
      @proposals = ProposalFiltersQuery.new(@proposals).find(params)
    end
  end

  def latex_temp_file
    "propfile-#{current_user.id}-#{@proposal.id}.tex"
  end

  def file_path
    ProposalPdfService.new(@proposal.id, latex_temp_file, 'all').pdf
    @year = @proposal&.year || Date.current.year.to_i + 2
    fh = File.open("#{Rails.root}/tmp/#{latex_temp_file}")
    @latex_input = fh.read

    pdf = render_to_string layout: "application", inline: "#{@latex_input}", formats: [:pdf]

    @pdf_path = "#{Rails.root}/tmp/submit-#{DateTime.now.to_i}.pdf"
    upload = File.open(@pdf_path, 'w:binary') do |file|
      file.write(pdf)
    end
  end

  def curl_request
    file_path

    country_code = Country.find_country_by_name(@proposal.lead_organizer.country)
    co_organizers = @proposal.invites.where(invited_as: 'Co Organizer')
    country_code_organizers = Country.find_country_by_name(co_organizers.first.person.country)
    query = <<END_STRING
            mutation {
              article: submitArticle(data: {
                authors: [{
                  email: "#{@proposal.lead_organizer.email}"
                  givenName: "#{@proposal.lead_organizer.firstname}"
                  familyName: "#{@proposal.lead_organizer.lastname}"
                  nameInOriginalScript: "日暮 ひぐらし かごめ"
                  institution: "#{@proposal.lead_organizer.affiliation}"
                  countryCode: "#{country_code.alpha2}"
                }, {
                  email: "#{co_organizers.first.email}"
                  givenName: "#{co_organizers.first.firstname}"
                  familyName: "#{co_organizers.first.lastname}"
                  institution: "#{co_organizers.first.person.affiliation}"
                  countryCode: "#{country_code_organizers.alpha2}"
                  mrAuthorID: 12345
                }]
                correspAuthorEmail: "#{@proposal.lead_organizer.email}"
                title: "#{@proposal.title}"
                sectionAbbrev: "#{@proposal.subject.code}"
                primarySubjects: {
                  scheme: "MSC2020"
                  codes: ["00-01"]
                }
                secondarySubjects: {
                  scheme: "MSC2020"
                  codes: ["00B05", "00A07"]
                }
                abstract: "#{@proposal.title}"
                files: [{
                  role: "main"
                  key: "fileMain"
                }]
              }) {
                identifier
              }
            }
END_STRING

    response = RestClient.post 'https://ef-demo.msp.org/efdemo_y/api/test/birs/',
      {:query => query, :fileMain => File.open(@pdf_path)},
      {:x_editflow_api_token => 'ovmpaE-cR3Kt3qUUY7KAhO20X-XIxslovfPwNY-MUfM='}
    puts response

    if response.body.include?("errors")
      flash[:alert] = "Request cannot be sent!"
    else
      flash[:notice] = "Request sent successfully!"
    end
  end
  
  def set_proposal
    @proposal = Proposal.find_by(id: params[:id])
  end
end
