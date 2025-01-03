class ChangeCompanyAndAgentNullableOnPolicies < ActiveRecord::Migration[8.0]
  def change
    change_column_null :policies, :company_id, true
    change_column_null :policies, :agent_id, true
  end
end
