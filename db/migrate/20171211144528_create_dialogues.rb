class CreateDialogues < ActiveRecord::Migration
  def change
    create_table :dialogues do |t|
      t.string :input
      t.string :output
      t.timestamps null: false
    end
  end
end
