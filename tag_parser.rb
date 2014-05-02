# Class that parses step definitions from Ruby files

class TagParser

  attr_reader :tags
  def initialize
    @tags = []
  end

  def read(file)
    @current_file = file
    @line_number = 0
    @lines = IO.read(file).split(/\r?\n/)
    parse_lines
  end

  private

  def next_line
    @line_number += 1
    @lines.shift
  end

  def unread(line)
    @line_number -= 1
    @lines.unshift(line)
  end

  def parse_lines
    @comments = []
    while not @lines.empty?
      line = next_line
      case line
      when /^ *#/
        @comments << line
      when /^\s+@.*/
        unread(line)
        parse_tag
        @comments = []
      when /^@.*/
        unread(line)
        parse_tag
      else
        @comments = []
      end

    end
  end

  def parse_tag
    line = next_line
    tag_names = parse_tag_names(line)
    line_number =@line_number
    code = ""
    line = ""
    scenario = ""
    while !@lines.empty? && !(line =~ /^\s+@.*/)
      line = next_line
      case line

      when /^\s+Scenario:.*/
        scenario = line
      else
        code << line
      end

    end
    @tags << {  :names => tag_names, :filename => @current_file, :comments => @comments,:code => code, :scenario=>scenario, :line_number => line_number }
  end

  def parse_step_type(line)
    line.sub(/^([A-Za-z]+).*/, '\1')
  end

  def parse_tag_names(line)
    tags = line.split(' ')
    tags
  end

end
