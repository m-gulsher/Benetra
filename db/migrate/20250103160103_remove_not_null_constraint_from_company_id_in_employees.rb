class RemoveNotNullConstraintFromCompanyIdInEmployees < ActiveRecord::Migration[8.0]
  def change
    change_column_null :employees, :company_id, true
  end
end
