module.exports = (sequelize, DataTypes) ->
  Message = sequelize.define "Message",
    body: DataTypes.STRING
  , classMethods:
    associate: (models) ->
      Message.belongsTo(models.User)
      Message.hasOne(models.MessageInfo, {
        onDelete: 'SET NULL',
        onUpdate: 'NO ACTION'
      })

  return Message
