#!/usr/bin/env ruby 

# == Synopsis 
#   This application loads a simple ".markov" file and generates one or
#   many strings from it.  A .markov file is a simple YAML file in a
#   specific format.
#
# == Examples
#   Generate one item from the specified file:
#     generate name_file.markov
#
#   Generate 50 items from the specified file:
#     generate -n 50 name_file.markov
#
# == Usage 
#   generate [-n <num>] data_file
#
# == Options
#   -n <num>   Generate <num> samples (defaults to 1)
#
# == Author
#   Noah Gibbs
#
# == Copyright
#   Copyright (c) 2010 Noah Gibbs. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'optparse' 
require 'rdoc/usage'
require 'ostruct'

require "markov"

@arguments = ARGV
@options = OpenStruct.new
@options.n = 1
#@options.verbose = false

OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-n', '--num [SAMPLES]', Integer, 'Set the number of samples') { |n|
    @options.n = n
  }
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end.parse! @arguments

# Perform post-parse processing on options
#@options.verbose = false if @options.quiet

# True if required arguments were provided
def arguments_valid?
  #true if @arguments.length == 1 
  true
end

# Parse options, check arguments, then process the command
if arguments_valid? 
  g = Markov.from_files *@arguments
  @options.n.times { print g.one + "\n" }
else
  output_usage
end

#RDoc::usage('usage') # gets usage from comments above
