# TempleteMethod
class Report
  attr_accessor :title, :content
  def initialize
    @title  = "I am a title"
    @content = "I am a content"
    hook_process
  end

  def hook_process ; end
  
  def output
    raise 'Called abstract method : output'
  end
end

class HTMLReport < Report
  def output_title
    puts "<head><title> #{title} </title></head>"
  end

  def hook_process
    @content = "<div> \r\n #{content} \r\n</div>"
  end
  
  def output_content
    puts "<body> #{content} </body>"
  end
  
  def output
    puts "<html>"
    output_title
    output_content
    puts "</html>"
  end
end


class PlainTextReport < Report
  def output_title
    puts title
  end
  
  def output_content
    puts content
  end
  
  def output
    output_title
    output_content
  end
end

HTMLReport.new.output
# PlainTextReport.new.output

