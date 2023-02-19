class AddInstallerIdToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_reference :customers, :installer_customer_user, index: false
    remove_column :customer_users, :email, :string
  end
end
