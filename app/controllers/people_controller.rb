class PeopleController < ApplicationController
  before_action :set_person
  layout('devise')

  def new
    @invited_as = invite&.invited_as
    @proposal = invite&.proposal
    @response = params[:response]

    redirect_to root_path, alert: 'Something went wrong.' unless @person
  end

  def update
    if @person.update(person_params)
      redirect_to new_survey_path(code: params[:code], response: params[:response]),
                  notice: "Thank you. Please continue to complete the Diversity and Inclusivity Survey."
    else
      @invited_as = invite&.invited_as
      render :new
    end
  end

  private

  def person_params
    params.require(:person).permit(:affiliation, :department, :academic_status,
                                   :title, :first_phd_year, :country, :region,
                                   :city, :street_1, :street_2, :postal_code,
                                   :other_academic_status, :province, :state)
  end

  def set_person
    @person = invited_person || current_user&.person
  end

  def invite
    Invite.find_by(code: params[:code])
  end

  def invited_person
    invite&.person
  end
end
