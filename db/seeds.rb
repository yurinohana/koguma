# coding: utf-8
require "csv"

CSV.foreach('db/dialogue.csv') do |row|
  Dialogue.create(:input => row[0], :output => row[1])
end

CSV.foreach('db/template.csv') do |row|
  Template.create(:temp => row[0])
end