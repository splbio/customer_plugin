class CreateCustomersIssues < ActiveRecord::Migration
  def change
    create_table :customers_issues, :id => false do |t|
      t.references :customer
      t.references :issue
    end

    add_index :customers_issues, [:customer_id, :issue_id]
    add_index :customers_issues, :customer_id
    add_index :customers_issues, :issue_id
  end
end
