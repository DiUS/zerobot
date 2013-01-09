# Zerobot

## Startup Guide for Developers

### Prerequisites
Ensure the following is installed on your machine:

* RVM (https://rvm.io/rvm/install/)
* Ruby 1.9.3 installed via RVM
* Mysql (http://dev.mysql.com/downloads/mysql/)

### Steps

Once the source has been cloned, do the following:
```
brew install qt
rvm use 1.9.3
bundle install
bundle exec rake db:migrate
```

Configure the application
```
cp dev.env .env
source .env
```

Now start the app
```
foreman start
```

### Potential issues

* When starting foreman, you get `Library not loaded: libmysqlclient.18.dylib`
** Solution at http://stackoverflow.com/questions/10557507/rails-mysql-on-osx-library-not-loaded-libmysqlclient-18-dylib