class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :input
      t.string :output
      t.timestamps null: false
    end
  end
end
