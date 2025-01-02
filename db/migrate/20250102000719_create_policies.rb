class CreatePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :policies do |t|
      t.string :name, null: false
      t.text :description 
      t.references :company, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.timestamps
    end
  end
end
