require 'fileutils'

namespace :backup do
  desc 'crontab -e'
  task :crontab do
    puts <<-CRONTAB
      m h d m d command
      0 3 * * * cd /var/www/do8 && /usr/bin/rake backup:log:all > /dev/null 2>&1
      5 3 * * * cd /var/www/do8 && /usr/bin/rake backup:db:mysql RAILS_ENV=production > /dev/null 2>&1
    CRONTAB
  end

  desc 'backup log'
  namespace :log do
    desc 'rake backup:log:all'
    task :all do
      # 建备份目录
      backup_path = File.join(Rails.root, 'backup', 'log', "#{Date.today.year}-#{Date.today.month}")
      FileUtils.mkdir_p(backup_path) unless File.exist?(backup_path)

      # 文件名
      filename = File.join(backup_path, "log_#{Time.now.strftime("%Y%m%d%H%M%S")}.tar.gz")

      # 执行备份命令
      cmd = "tar -czvf #{filename} log/*.log"
      `#{cmd}`
      Rake::Task["log:clear"].invoke if File.size?(filename)
    end
  end

  desc 'backup db'
  namespace :db do
    desc 'rake backup:db:mysql RAILS_ENV=production'
    task :mysql => :environment do
      # 建备份目录
      backup_path = File.join(Rails.root, 'backup', 'db', "#{Date.today.year}-#{Date.today.month}")
      FileUtils.mkdir_p(backup_path) unless File.exist?(backup_path)

      # 文件名
      tmp_filename = File.join(Rails.root, 'backup', 'db', 'tmp.sql')
      filename = File.join(backup_path, "db_#{Rails.env}_#{Time.now.strftime("%Y%m%d%H%M%S")}.tar.gz")

      # 获取数据库信息
      db_config = Rails.configuration.database_configuration[Rails.env].symbolize_keys
      net_buffer_length = ActiveRecord::Base.connection.execute("SHOW VARIABLES LIKE 'net_buffer_length';").to_enum.to_a[0][1]
      max_allowed_packet = ActiveRecord::Base.connection.execute("SHOW VARIABLES LIKE 'max_allowed_packet';").to_enum.to_a[0][1]

      # 执行备份命令
      cmd = <<-CMD
        mysqldump -u#{db_config[:username]} -p#{db_config[:password]} \
          --skip-opt --create-option --set-charset --default-character-set=utf8 \
          -e --max_allowed_packet=#{max_allowed_packet} --net_buffer_length=#{net_buffer_length} #{db_config[:database]} > #{tmp_filename}
        tar -czvf #{filename} backup/db/tmp.sql
      CMD
      `#{cmd}`
    end
  end
end
