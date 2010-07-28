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

require "markov"

arguments = ARGV

def print_usage
  puts "Usage: #{$0} [options]\n"
  puts "  -h: print usage\n"
  puts "  -n ARG: number of times\n"
end

if arguments.include?("-h") || arguments.include?("--help")
  print_usage
  exit
end

option_n = 1
newargs = []

last_was_n = false
arguments.each do |arg|
  if arg == "-n"
    last_was_n = true
  elsif last_was_n
    option_n = arg.to_i
    last_was_n = false
  else
    newargs << arg
  end
end

if newargs.size < 1
  print_usage
  exit
end

g = Markov.from_files *newargs
option_n.times { puts g.one }
