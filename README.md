# Vyapari
A Simple Warehouse Management with integrated POS & E-Commerce Back End.

## Usage
<TODO> How to use my plugin.

## Installation
Add this line to your application's Gemfile:
<TODO>

```ruby
gem 'vyapari'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install vyapari
```


Installation Instructions

# Installation Instructions

Copy the migrations from the engines you are using
Run the below command 

```bash
$ bundle exec rake railties:install:migrations
```

This will copy migrations from kuppayam and usman engines
which will have migrations to create images, documents, users, features and permissions respectively.



This will copy migrations from kuppayam and usman engines
which will have migrations to create images, documents, users, features and permissions respectively. 

## Create Dummy Data 

run rake task for loading dummy data for users and features to start with.

## Mount the engine

Mount usman engine in your application routes.rb

```
mount Usman::Engine => "/"
```

open browser and go to /sign_in url

## Configurations

config.railties_order = [:main_app, Vyapari::Engine, Usman::Engine, :all]


## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
