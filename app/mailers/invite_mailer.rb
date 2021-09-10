class InviteMailer < ApplicationMailer
  def invited_as_text(invite)
    return "an Organizer for" if invite.invited_as?.casecmp('organizer').zero?

    "a Participant in"
  end

  def invite_email
    @invite = params[:invite]
    @lead_organizer = params[:lead_organizer]
    @invited_as = invited_as_text(invite)
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "BIRS Proposal Invitation for #{@invite.invited_as?}", cc: @lead_organizer.email)
  end

  def invite_acceptance
    @invite = params[:invite]
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.strip.delete_suffix(",")
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'BIRS Proposal Confirmation of Interest')
  end

  def invite_decline
    @invite = params[:invite]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'Invite Declined')
  end

  def invite_reminder
    @invite = params[:invite]
    @invited_as = invited_as_text(invite)
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "Please Respond – BIRS Proposal Invitation for #{@invite.invited_as?}")
  end
end
