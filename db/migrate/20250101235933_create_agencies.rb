class CreateAgencies < ActiveRecord::Migration[8.0]
  def change
    create_table :agencies do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :poc_email, null: false
      t.timestamps
    end
  end
end
