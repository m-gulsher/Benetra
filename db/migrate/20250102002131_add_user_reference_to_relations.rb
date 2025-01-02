class AddUserReferenceToRelations < ActiveRecord::Migration[8.0]
  def change
    add_reference :admins, :user, foreign_key: true
    add_reference :agents, :user, foreign_key: true
    add_reference :employees, :user, foreign_key: true
  end
end
