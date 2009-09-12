#!/usr/bin/ruby

require 'optparse'

options = Hash.new()
opts = OptionParser.new() do |opts|
  opts.on_tail("-h", "--help", "get help for this CMD") {
    print(opts)
    exit()
  }
  
  opts.on("-l", "--length NUMBER", "Password length") { |length|
    options['length'] = length
  }
  opts.on("-c", "--include_letter BOOLEAN", 'Include ~!@#$%^&*()_+-=?></*-+') { |cl|
    options['include_letter'] = cl
  }
end
opts.parse(ARGV)

class GeneratePassword
  @chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
  @length = 6
  
  def self.get(options={})
    @length = options['length'].to_i if options['length'].to_i > 0
    @chars += '~!@#$%^&*()_+-=?></*-+' if options['include_letter'] == 'true'
    
    password = ''
    @length.downto(1) { |i| 
      password << @chars[rand(@chars.size)] 
    }  
    password
  end
end

puts GeneratePassword.get(options)
print "."
