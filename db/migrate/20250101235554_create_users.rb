class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""  # Devise field
      t.string :reset_password_token                           # Devise field
      t.datetime :reset_password_sent_at                      # Devise field
      t.datetime :remember_created_at                         # Devise field
      t.string :role, null: false                             # User role (e.g., admin, agent, employee)
      t.references :authenticatable, polymorphic: true        # Polymorphic association
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
