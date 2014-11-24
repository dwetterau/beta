module.exports = (sequelize, DataTypes) ->
  MessageInfo = sequelize.define "MessageInfo",
    subject: DataTypes.STRING,
    state: DataTypes.ENUM('UNREAD', 'DELETED')
  , classMethods:
    associate: (models) ->
      MessageInfo.belongsTo(models.User, {as: 'Creator'})
      MessageInfo.belongsTo(models.User, {as: 'Receiver'})
      MessageInfo.belongsTo(models.Message)

  return MessageInfo
