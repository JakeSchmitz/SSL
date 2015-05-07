README
=======

This is the web application for GDAE's Social Science Library at Tufts University.

Configuration details
--------

* Ruby version: 2.2

* Gem versions: see Gemfile

* Databases: PostgreSQL (managed by the Rails application) and MongoDB (not managed by the Rails application)

Getting started
-------

* Clone this repository

* Move into the root of the repository (e.g. `SSL/`)

* Ensure you have Ruby 2.2 and the bundler gem installed. [The instructions here](http://cbednarski.com/articles/installing-ruby/)
  were very helpful, but there are multiple ways to do this.

* Run `bundle install`

* Run `bin/rails server` to run the application locally

* If you're new to Rails, [this getting started guide](http://guides.rubyonrails.org/getting_started.html) may be useful.

Deployment
------

* We have had success deploying the app to Heroku.

* The deployment instructions for a Windows Server 2008 R2 architecture are in-progress.
