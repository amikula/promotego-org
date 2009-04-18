class AddUniqueForeignKeyIndexToAffiliations < ActiveRecord::Migration
  def self.up
    add_index :affiliations, [:affiliate_id, :foreign_key]
  end

  def self.down
    remove_index :affiliations, :column => [:affiliate_id, :foreign_key]
  end
end
