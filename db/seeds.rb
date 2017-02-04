# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.delete_all
AnnuvinSave.delete_all
GomokuSave.delete_all

User.create( name: "Joe" )


AnnuvinSave.create

a = Annuvin.new
a.export

GomokuSave.create

g = Gomoku.new
g.export

TictacSave.create

t = Tictac.new
t.export