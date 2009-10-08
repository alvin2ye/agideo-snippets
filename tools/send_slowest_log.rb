#!/usr/bin/ruby
#
## Author by robin
## change 2009-10-8
#
projects = {
  :xxx => { :path => "app_path/log/production.log" },
  :xxx => { :path => "app_path/log/production.log", :allow_time => 200, :time_unit => 'ms', :url_index => 11 }
}

projects.each do |name, options|
  allow_time = options[:allow_time] || 1
  time_unit = options[:time_unit] || 's'
  mail_body = []

  lines = `cat #{options[:path]} | grep "200 OK" | awk '{print $3 " " $#{options[:url_index] || 17}}' | sort -nr`
  lines.each do |line|
    mail_body << line if line.split.first.to_f > allow_time
  end

  unless mail_body.empty?
    `echo "#{mail_body}" | mail xxxx@gmail.com -s "#{Time.now.strftime("%Y%m%d%H%M%S")} #{name} log time bigger than #{allow_time}#{time_unit}" -a "From: xxx@gmail.com"`
  end
end
