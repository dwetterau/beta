express = require 'express'
router = express.Router()
passport_config  = require('../lib/auth')

index_controller = require '../lib/controllers/index_controller'
message_controller = require '../lib/controllers/message_controller'
user_controller = require '../lib/controllers/user_controller'

# GET home page
router.get '/', index_controller.get_index

# User routes
router.get '/user/create', user_controller.get_user_create
router.post '/user/create', user_controller.post_user_create
router.get '/user/login', user_controller.get_user_login
router.post '/user/login', user_controller.post_user_login
router.get '/user/logout', user_controller.get_user_logout
router.get '/user/password', passport_config.isAuthenticated, user_controller.get_change_password
router.post '/user/password', passport_config.isAuthenticated, user_controller.post_change_password

# Message routes
router.get '/message/:id/view', message_controller.get_read_message
router.get '/message/:id/sent', message_controller.get_message_sent
router.get '/message/create', message_controller.get_create_message
router.post '/message/create', message_controller.post_create_message

module.exports = router
