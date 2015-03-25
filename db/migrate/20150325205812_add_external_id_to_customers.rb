class AddExternalIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :external_id, :string
  end
end
