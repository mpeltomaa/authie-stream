class AddIndexesToAuthieSessions < ActiveRecord::Migration[4.2]
  def change
    add_column :authie_sessions, :order_type, :string
    add_index :authie_sessions, :token, :length => 10
    add_index :authie_sessions, :browser_id, :length => 10
    add_index :authie_sessions, :order_id
  end
end
