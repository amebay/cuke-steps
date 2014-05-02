#!/usr/bin/env ruby
#-*- encoding: utf-8 -*-
require 'json'
require 'optparse'

require_relative 'step_parser'
require_relative 'tag_parser'
require_relative 'confluence_step_outputter'
require_relative 'html_step_outputter'

# Parse command line
options = {}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: cuke-tags.rb [options] <directories...>"

  opts.on("-o", "--output FILE", "Output to FILE") do |file|
    options[:file] = file
  end
  
end
opts.parse!(ARGV)

# Default output options
if  !options[:file]
  options[:file] = "tags.json"
end

# All other arguments are treated as input directories
dirs = ARGV
if dirs.size == 0
  puts "No source directory provided, use -h for help"
  exit 1
end


puts "Writing output to file '#{options[:file]}'"



# Read files and output
all_tags = []
dir = Dir.new(dirs[0]).to_path
t = TagParser.new
Dir.glob("#{dir}/*.feature") do |file|
  t.read(file)
  tags = t.tags
  all_tags += tags
end
File.open(options[:file], 'w') {|f| f.write(all_tags.to_json) }
