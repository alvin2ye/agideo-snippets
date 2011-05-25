require 'fileutils'
require 'enumerator' # support rails 1.2.5

namespace :backup do
  desc 'crontab -e'
  task :crontab do
    puts <<-CRONTAB
      m(0-59) h(0-23) d(1-31) m(1-12) w(0-6 0=Sunday) command
      0 3 * * * cd /var/www/<project> && /usr/bin/rake backup:log:analyze RAILS_ENV=production > /dev/null 2>&1
      5 3 * * * cd /var/www/<project> && /usr/bin/rake backup:log:do RAILS_ENV=production > /dev/null 2>&1
      9 3 * * * cd /var/www/<project> && /usr/bin/rake backup:db:mysql RAILS_ENV=production > /dev/null 2>&1
    CRONTAB
  end

  desc 'backup log'
  namespace :log do
    desc 'rake backup:log:analyze RAILS_ENV=production'
    task :analyze => :environment do
      backup_path = File.join(RAILS_ROOT, 'backup', 'report', "#{Date.today.year}-#{Date.today.month}")
      FileUtils.mkdir_p(backup_path) unless File.exist?(backup_path)
      filename = File.join(backup_path, "#{Time.now.strftime("%Y%m%d%H%M%S")}.txt")

      case (defined?(Rails.version) ? Rails.version : RAILS_GEM_VERSION)
        when /3\.\d\.\d/
          request_num = `cat log/#{RAILS_ENV}.log | grep "Started" | wc -l`
          request_num_by_ip = `cat log/#{RAILS_ENV}.log | grep "Started" | awk '{print $5}' | sort | uniq -c`
        when /[2|1]\.\d\.\d/
          request_num = `cat log/#{RAILS_ENV}.log | grep "Processing" | wc -l`
          request_num_by_ip = `cat log/#{RAILS_ENV}.log | grep "Processing " | awk '{print (match($4, /^js/) ? $6 : $4)}' | sort | uniq -c`
        else
          raise "Log analyze not support Rails #{Rails.version} version"
      end
      cmd = <<-CMD
        echo "所有访问数量:#{request_num}每个IP的访问次数:\n#{request_num_by_ip}" > #{filename}
      CMD
      `#{cmd}`
    end

    desc 'rake backup:log:do RAILS_ENV=production'
    task :do => :environment do
      backup_path = File.join(RAILS_ROOT, 'backup', 'log', "#{Date.today.year}-#{Date.today.month}")
      FileUtils.mkdir_p(backup_path) unless File.exist?(backup_path)
      filename = File.join(backup_path, "log_#{Time.now.strftime("%Y%m%d%H%M%S")}.tar.gz")

      cmd = <<-CMD
        tar -czvf #{filename} log/#{RAILS_ENV}.log
      CMD
      `#{cmd}`
      Rake::Task["log:clear"].invoke if File.size?(filename)
    end
  end

  desc 'backup db'
  namespace :db do
    desc 'rake backup:db:mysql RAILS_ENV=production'
    task :mysql => :environment do
      backup_path = File.join(RAILS_ROOT, 'backup', 'db', "#{Date.today.year}-#{Date.today.month}")
      FileUtils.mkdir_p(backup_path) unless File.exist?(backup_path)
      tmp_filename = File.join(RAILS_ROOT, 'backup', 'db', 'tmp.sql')
      filename = File.join(backup_path, "db_#{RAILS_ENV}_#{Time.now.strftime("%Y%m%d%H%M%S")}.tar.gz")

      # 获取数据库信息
      db_config = YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV].symbolize_keys
      net_buffer_length = ActiveRecord::Base.connection.execute("SHOW VARIABLES LIKE 'net_buffer_length';").to_enum.to_a[0][1]
      max_allowed_packet = ActiveRecord::Base.connection.execute("SHOW VARIABLES LIKE 'max_allowed_packet';").to_enum.to_a[0][1]

      cmd = <<-CMD
        mysqldump -u#{db_config[:username]} -p'#{db_config[:password]}' \
          --skip-opt --create-option --set-charset --default-character-set=utf8 \
          -e --max_allowed_packet=#{max_allowed_packet} --net_buffer_length=#{net_buffer_length} #{db_config[:database]} > #{tmp_filename}
        tar -czvf #{filename} backup/db/tmp.sql
        rm -f #{tmp_filename}
      CMD
      `#{cmd}`
    end
  end

  # TODO add backup:clear
end
