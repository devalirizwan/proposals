require 'rails_helper'

RSpec.describe "/person", type: :request do
  let(:proposal) { create(:proposal) }
  let(:invite) { create(:invite, proposal: proposal) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Person", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end
  describe "GET /new" do
    it "renders a successful response" do
      get new_person_url(code: invite.code, response: 'yes')
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    let(:person_params) do
      { department: 'computer_science' }
    end

    context "with valid parameters" do
      before do
        patch person_url(person), params: { person: person_params }
      end

      it "updates the requested Person" do
        expect(person.reload.department).to eq('computer_science')
      end
    end
  end
end
