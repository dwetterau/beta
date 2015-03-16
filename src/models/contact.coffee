module.exports = (sequelize, DataTypes) ->
  Contact = sequelize.define "Contact",
    user_id: DataTypes.INTEGER
  , classMethods:
    associate: (models) ->
      User.belongsTo(models.User)
  , instanceMethods:
  return Contact

