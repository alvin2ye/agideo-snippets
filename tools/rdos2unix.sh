#!/usr/bin/ruby

dirs = %w(app spec test config db/migrate public/javascripts public/stylesheets)

dirs.each do |dir|
  `find  #{dir} -type f -name *.rb | xargs dos2unix` if File.exist?(dir)
end

p 'ok...'

