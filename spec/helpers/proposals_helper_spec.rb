require 'rails_helper'

RSpec.describe ProposalsHelper, type: :helper do
  describe "#proposal_types" do
    let(:location) { create(:location) }
    let(:proposal_type) { create(:proposal_type, locations: [location]) }
    let(:published_form) { create(:proposal_form, proposal_type: proposal_type, status: :active) }
    let(:proposal_type1) { create(:proposal_type, locations: [location]) }
    let(:draft_form) { create(:proposal_form, proposal_type: proposal_type1, status: :draft) }

    it "returns proposal types [name,id] if it has publish form" do
      published_form
      expect(proposal_types).to eq([[proposal_type.name, proposal_type.id]])
    end

    it "returns no proposal types [name,id] if not has publish form" do
      draft_form
      expect(proposal_types).to eq([])
    end
  end

  describe "#proposal_type_year" do
    let(:proposal_type) { create(:proposal_type) }
    it "return array of year comma separated [year]" do
      expect(proposal_type_year(proposal_type)).to match_array(%w[2021 2022 2023])
    end
  end

  describe "#locations" do
    let(:locations_list) { create_list(:location, 4) }
    it "returns array of locations [name,id]" do
      locations_list
      expect(locations).to match_array(locations_list.pluck(:name, :id))
    end
  end

  describe "#common_proposal_fields" do
    let(:p_type) { create(:proposal_type) }
    let(:p_form) { create(:proposal_form, proposal_type: p_type, status: :active) }
    let(:fields) { create(:proposal_field, :radio_field, proposal_form: p_form) }
    let(:proposal) { create(:proposal, proposal_form: p_form, proposal_type: p_type) }
    it "returns proposal fields" do
      fields
      expect(common_proposal_fields(proposal)).to eq([fields])
    end
  end

  describe '#proposal_ams_subjects_code' do
    let(:proposal) { create :proposal }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject) do
      create(:ams_subject,
             subject_category_ids: subject_category.id,
             subject_id: subject.id)
    end
    let(:proposal_ams_subject) do
      create(:proposal_ams_subject, proposal: proposal, ams_subject: ams_subject, code: 'code2')
    end

    before do
      proposal.proposal_ams_subjects << proposal_ams_subject
    end

    it 'returns id of proposal ams subject with provided code' do
      expect(proposal_ams_subjects_code(proposal, 'code2')).to eq(ams_subject.id)
    end
  end
end
