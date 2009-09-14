#!/usr/bin/env ruby
class Snpt
  class Annotation < Struct.new(:line, :text)
    def to_s(options={})
      s = "[%3d] " % line
      s << (text.to_s.length > 60 ? text.to_s[0..57] + "..." : text.to_s)
    end
  end

  def self.enumerate(text, options={})
    if text.size == 0
      puts "pls enter search text" 
      return
    end
    extractor = new(text)
    extractor.display(extractor.find, options)
  end

  attr_reader :text

  def initialize(text)
    @text = text
  end

  def find(dirs=%w(ruby rails rails_templete))
    snippet_dir = ENV["AGIDEO_SNIPPETS"] || File.join(ENV["HOME"], "agideo-snippets")
    dirs = []
    Dir.glob("#{snippet_dir}/*").each do |item|
      dirs << item if File.directory?(item)
    end
    dirs.inject({}) { |h, dir| h.update(find_in(dir)) }
  end

  def find_in(dir)
    results = {}

    Dir.glob("#{dir}/*") do |item|
      next if File.basename(item)[0] == ?.

      if File.directory?(item)
        results.update(find_in(item))
      # elsif item =~ /\.(\w*)$/
      else
        results.update(extract_annotations_from(item, /#{text}/))
      end
    end

    results
  end

  def extract_annotations_from(file, pattern)
    lineno = 0
    result = File.readlines(file).inject([]) do |list, line|
      lineno += 1
      next list unless line =~ pattern
      list << Annotation.new(lineno, line)
    end
    result.empty? ? {} : { file => result }
  end

  # Prints the mapping from filenames to annotations in +results+ ordered by filename.
  # The +options+ hash is passed to each annotation's +to_s+.
  def display(results, options={})
    results.keys.sort.each do |file|
      puts "#{file}:"
      results[file].each do |note|
        puts " * #{note.to_s(options)}"
      end
      puts
    end
  end
end

Snpt.enumerate ARGV.first.to_s, :text => true
