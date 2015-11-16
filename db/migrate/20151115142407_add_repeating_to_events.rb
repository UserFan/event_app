class AddRepeatingToEvents < ActiveRecord::Migration
  def change
    add_column :events, :repeats, :string
  end
end
