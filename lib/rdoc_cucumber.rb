# Author:: Balazs MEZODI

require "stringio"
require_relative "step_parser"


class Cucumber_Parser < RDoc::Parser

  parse_files_matching(/.*\/step_definitions\/.*\.rb$/)

  include RDoc::Parser::RubyTools

  def initialize(top_level, file_name, body, options, stats)
    @stepParser = StepParser.new
    @top_level = top_level
    @file_name = file_name
    @body = body
    @options = options
    @stats   = stats
  end

  def scan
    @stepParser.read(@file_name, StringIO.open(@body, "r"))
    hook_node = @top_level.add_module(RDoc::NormalModule, "StepDefinitions")
    hook_node.record_location(@top_level)
    @stepParser.steps.each { |step|
      meth = RDoc::AnyMethod.new(nil, step[:name])

      meth.start_collecting_tokens
      meth.add_token(RDoc::RubyToken::TkCOMMENT.new(0, step[:line_number], 1, "# File #{step[:filename]}, line #{step[:line_number]}"))
      meth.add_token(RDoc::RubyToken::NEWLINE_TOKEN)

      @scanner = RDoc::RubyLex.new(step[:naked_code].join("\n"), @options)
      @scanner.exception_on_syntax_error = false
      reset
      params = nil
      while not (tk = get_tk).nil?
        meth.add_token(tk)

        unless params
          case tk
          when RDoc::RubyToken::TkNL, RDoc::RubyToken::TkSEMICOLON
            unget_tk(tk)
            params = get_tkread.gsub(/\s+/, ' ').strip.gsub(/^\|/, '').gsub(/\|$/, '')
            tk = get_tk
          when RDoc::RubyToken::TkDO
            get_tkread # just to reset the read buffer
          end
        end
      end
      meth.block_params = params if params and not params.empty?

      meth.comment = step[:comments].join("\n")
      meth.record_location(@top_level)
      hook_node.add_method(meth)
    }
    return @top_level
  end

end


# EOF
