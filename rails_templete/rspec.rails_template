# author Robin
# date: 2009-9-27
# links: http://m.onkey.org/2008/12/4/rails-templates
# desc: init new rails project template

# delete dirty files
run 'rm public/index.html'
run "rm public/images/rails.png"
run "rm README"
run "rm doc/README_FOR_APP"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run 'rm -rf test/'

# config database
app = @root.split('/').last
file 'config/database.yml.sample', <<-END
defaults: &defaults
  adapter: mysql
  username: root
  password:
  host: localhost
  encoding: utf8
development:
  <<: *defaults
  database: #{app}_development
test:
  <<: *defaults
  database: #{app}_test
production:
  <<: *defaults
  database: #{app}_production
END
run 'cp config/database.yml.sample config/database.yml'

# config database user & password
username = ask "***Database username?"
password = ask "***Database password?"
File.open('config/database.yml','r+') do |f|
  s = f.read.gsub(/username:(.*)/,"username: #{username}")
  s = s.gsub(/password:(.*)/,"password: #{password}")
  f.rewind
  f.write s
end

# create all databases
rake 'db:create:all'

# rspec 
gem 'cucumber', :lib => false, :env => 'test'
gem 'rspec', :lib => false, :env => 'test'
gem 'rspec-rails', :lib => false, :env => 'test'
gem 'selenium-client', :lib => false, :env => 'test'
gem 'remarkable_rails', :lib => false, :env => 'test', :source => 'http://gems.github.com'
gem 'thoughtbot-factory_girl', :lib => false, :env => 'test', :source => 'http://gems.github.com'

# generate rspec & cucumber dir
generate 'rspec'
generate 'cucumber'

# freeze rails
rake 'rails:freeze:gems'
route 'map.root :controller => :home'

# git init
git :init

file '.gitignore', <<-CODE
log/*.log
log/*.pid
db/*.db
db/*.sqlite3
db/schema.rb
tmp
.DS_Store
doc/api
doc/app
config/database.yml
nbproject
CODE

git :add => "."
git :commit => "-a -m 'Initial Commit'"

plugin 'activerecord_dom_helper', :git => 'git://github.com/alvin2ye/activerecord_dom_helper.git'
plugin 'inherited_resources', :git => 'git://github.com/josevalim/inherited_resources.git'
plugin 'dry_view', :git => 'git://github.com/alvin2ye/dry_view.git'
plugin 'recordselect', :git => 'git://github.com/cainlevy/recordselect.git'
plugin 'number_to_chinese_amount_in_words_helper', :git => 'git://github.com/RobinWu/number_to_chinese_amount_in_words_helper.git'

git :add => "."
git :commit => "-a -m 'add plugins'"

