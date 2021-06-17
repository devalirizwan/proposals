module ProposalsHelper
  def proposal_types
    ProposalType.active_forms.map { |pt| [pt.name, pt.id] }
  end

  def proposal_type_year(proposal_type)
    return [Date.current.year + 2] if proposal_type.year.blank?

    proposal_type.year&.split(",").map { |year| year }
  end

  def locations
    Location.all.map { |loc| [loc.name, loc.id] }
  end

  def all_proposal_types
    ProposalType.all.map { |pt| [pt.name, pt.id] }
  end

  def common_proposal_fields(proposal)
    proposal.proposal_form&.proposal_fields&.where(location_id: nil)
  end

  def proposal_roles(proposal_roles)
    proposal_roles.joins(:role).where(person_id: current_user.person&.id).pluck('roles.name').map(&:titleize).join(', ')
  end

  def lead_organizer?(proposal_roles)
    proposal_roles.joins(:role).where('person_id =? AND roles.name =?', current_user.person&.id,
                                      'lead_organizer').present?
  end

  def proposal_ams_subjects_code(proposal, code)
    proposal.ams_subjects.find_by_code(code)&.id
  end

  def organizer_intro(proposal)
    types_with_intro = ['5 Day Workshop', 'Summer School']
    return '' unless types_with_intro.include? proposal.proposal_type.name

    %q(<p>5-Day Workshops and Summer Schools require a minimum of 2, and a maximum of 4 total organizers per proposal. In accordance with BIRS' commitment to equity, diversity and inclusion (EDI), the organizing committee should contain at least one early-career researcher within ten years of their doctoral degree. For applications with two organizers, at least one member of the organizing committee must be from an under-represented community in STEM disciplines. For applications with three or more organizers, at least two members of the organizing committee must be from an under-represented community in STEM disciplines.</p>).html_safe
  end
end
