class AddAffiliationContactAndForeignKey < ActiveRecord::Migration
  def self.up
    add_column :affiliations, :contact_name, :string
    add_column :affiliations, :contact_address, :string
    add_column :affiliations, :contact_city, :string
    add_column :affiliations, :contact_state, :string
    add_column :affiliations, :contact_zip, :string
    add_column :affiliations, :contact_telephone, :string
    add_column :affiliations, :contact_email, :string
    add_column :affiliations, :foreign_key, :string
  end

  def self.down
    remove_column :affiliations, :contact_name
    remove_column :affiliations, :contact_address
    remove_column :affiliations, :contact_city
    remove_column :affiliations, :contact_state
    remove_column :affiliations, :contact_zip
    remove_column :affiliations, :contact_telephone
    remove_column :affiliations, :contact_email
    remove_column :affiliations, :foreign_key
  end
end
