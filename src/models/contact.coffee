module.exports = (sequelize, DataTypes) ->
  Contact = sequelize.define "Contact",
    user_id: DataTypes.INTEGER
  , classMethods:
    associate: (models) ->
      Contact.belongsTo(models.User)
  return Contact

