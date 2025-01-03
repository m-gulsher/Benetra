class RemoveNotNullOnAgentsAgencyId < ActiveRecord::Migration[8.0]
  def change
    change_column_null :agents, :agency_id, true
  end
end
