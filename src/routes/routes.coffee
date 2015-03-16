express = require 'express'
router = express.Router()
passport_config  = require('../lib/auth')

api_controller = require '../controllers/api_controller'
contact_controller = require '../controllers/contact_controller'
index_controller = require '../controllers/index_controller'
message_controller = require '../controllers/message_controller'
user_controller = require '../controllers/user_controller'
notification_controller = require '../controllers/notification_controller'

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
router.get '/message/:id/preview', message_controller.get_preview_message
router.get '/message/:id/sent', message_controller.get_message_sent
router.get '/message/reply', passport_config.isAuthenticated, message_controller.get_create_message
router.get '/message/create', message_controller.get_create_message
router.post '/message/create', message_controller.post_create_message
router.post '/message/archive', passport_config.isAuthenticated,
  message_controller.post_archive_message

# Contacts routes
router.get '/contacts/mine', passport_config.isAuthenticated, contact_controller.get_all_contacts
router.get '/contacts/all', passport_config.isAuthenticated, contact_controller.get_all_users
router.post '/contacts/create', passport_config.isAuthenticated,
  contact_controller.post_create_contact
router.get '/contacts', passport_config.isAuthenticated, contact_controller.get_contacts

# API routes
router.get '/api/flash', api_controller.get_flash
router.get '/api/notifications', passport_config.isAuthenticated,
  notification_controller.get_notifications

# start the notification controller loop
notification_controller.start_listen_loop()

module.exports = router
