class ProposalFieldsController < ApplicationController
  before_action :set_proposal_form, only: %i[new create]

  def new
    type = "ProposalFields::#{params[:field_type]}".safe_constantize.new
    @proposal_field = @proposal_form.proposal_fields.new(fieldable: type)
    @options = type.options.build if params[:field_type] == 'MultiChoice' || params[:field_type] == 'SingleChoice'
    render partial: 'proposal_fields/fields_form',
           locals: { proposal_field: @proposal_field, proposal_form: @proposal_form }
  end

  def create
    @fieldable = "ProposalFields::#{params[:type]}".safe_constantize.new
    @proposal_field = @proposal_form.proposal_fields.new(proposal_field_params)
    @proposal_field.fieldable = @fieldable
    if @proposal_field.save
      redirect_to edit_proposal_form_path(@proposal_form), notice: "Field was successfully created."
    else
      redirect_to edit_proposal_form_path(@proposal_form), alert: @proposal_form.errors
    end
  end

  private

  def proposal_field_params
    params.require(:proposal_field).permit(:index, :description, :location_id, :statement)
  end

  def set_proposal_form
    @proposal_form = ProposalForm.find(params[:proposal_form_id])
  end
end
