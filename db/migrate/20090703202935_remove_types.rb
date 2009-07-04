class RemoveTypes < ActiveRecord::Migration
  def self.up
    drop_table :types
    remove_column :locations, :type_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
