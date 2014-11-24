Beta
=============

A website that only allows messages sent between users to be viewed once. The website uses
node.js written in CoffeeScript and MySQL with the Sequelize ORM.

### Description

Users can create messages without logging in that they can share via a link. Once the link
has been requested, the message is deleted from the server and can never be viewed again. The
website allows messages to be sent to users with accounts, at which point only the receiving
user has the ability to read the message (still only once), not even the sender.

### Installation Instructions

Clone the repo and run `npm install` in the default directory.

After setting up MySQL on your machine (with the proper credentials in `configs/config.json`),
you need to compile all the Coffeescript to run the script that builds the MySQL tables.

First run `./scripts/build.sh` and then run `node ./bin/oneoff/init_db.js` until it says the initialization has finished.

`npm start` then starts the server.
