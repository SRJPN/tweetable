# Tweetable 
[![Build Status](https://travis-ci.org/SRJPN/tweetable.svg?branch=master)](https://travis-ci.org/SRJPN/tweetable) [![Coverage Status](https://coveralls.io/repos/github/SRJPN/tweetable/badge.svg?branch=master)](https://coveralls.io/github/SRJPN/tweetable?branch=master) [![Code Climate](https://codeclimate.com/github/SRJPN/tweetable/badges/gpa.svg)](https://codeclimate.com/github/SRJPN/tweetable)

_Helping people to be concise, Precisely._

Tweetable is a platform for a teacher and student where a teacher gives an exercise which students have to attempt in the given time.

### User Manual
Even Tweetable is very simple and intuitive app to use, here is the [manual.](docs/Manual.md)

### About
This app is build on ruby on rails and postgres as database. It uses google auth for sign in. It also uses a open source NLP service [After The Deadline](http://www.afterthedeadline.com/) to analyze the english text.

The UI of the app supports modern mobile browsers as well. However the app has been developed using Google Chrome in mind.

### Contributing
View the [contribution guide](CONTRIBUTING.md) for contributing to the project.

### Hosting Tweetable
If you want to host a instance of Tweetable you can easily host it on [heroku](https://www.heroku.com).
Mostly no code changes are required.

 <sub>Need the google auth secrets for config vars.

### License
This project is licensed under  [Apache License 2.0](LICENSE.md).
