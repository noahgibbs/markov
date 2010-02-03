require 'yaml'

module Markov
  class Generator
    attr_reader :structs

    def initialize(data)
      @names = {}
      if data.kind_of? Array
        set_structs data
        return
      end
      raise "Unrecognized type as argument to Markov::Generator.new!"
    end

    def save(filename)
      File.open(filename, "w") do |f|
        f.write YAML::dump(@structs)
      end
    end

    def one
      total = @structs.map {|s| s[0]}.inject(0.0, &:+)
      selected = rand_float_between(0.0, total)

      subtotal = 0.0
      @structs.each do |entry|
        return evaluate(entry[1]) if (subtotal + entry[0]) > selected
        subtotal += entry[0]
      end
    end

    private

    def set_structs(data)
      @structs = data
      data.each do |row|
        next if row.length <= 2
        if row[2].kind_of? Symbol
          @names[row[2]] = row
        else
          raise "Name must be a symbol!" if row[2]
        end
      end
    end

    def evaluate(item)
      case item
        when String then item
        when :one then one()
        when :top then one()
        when Array then evaluate_array(item)
        when Symbol then evaluate(@names[item][1])
        else die "Don't know how to evaluate: #{item.inspect}!"
      end
    end

    def evaluate_array(item)
      if item[0].kind_of? Numeric
      end

      if item[0].kind_of? Symbol
        return case item[0]
          # Normal symbols, evaluate array as concatenation
          when :one then evaluate_and_add(item)
          # Explicit concatenation, just in case
          when :+ then evaluate_and_add(item)

          when :one_of then evaluate_one_of(item)
          else die "Unknown symbol #{item[0]} in array!"
        end
      end
      evaluate_and_add(item)
    end

    def evaluate_and_add(array)
      array.map {|s| evaluate(s)}.inject("", &:+)
    end

    def evaluate_one_of(array)
      elements = array.size - 1   # remove one for leading :one_of symbol

      raise "Unimplemented!"
    end

    def rand_float_between(min, max)
      min + rand * (max - min)
    end
  end

  def self.from_file(filename)
    structures = nil
    File.open(filename) do |f|
      structures = YAML::load(f.read)
    end

    g = Generator.new structures
  end

end

if $0 == __FILE__

require "test/unit"

class MarkovTest < Test::Unit::TestCase
  def test_empty_create
    assert_nothing_raised do
      Markov::Generator.new []
    end
  end

  def test_single_create
    generator = nil
    assert_nothing_raised do
      generator = Markov::Generator.new [[1.0, "bob"]]
    end

    assert_equal generator.one, "bob"
  end

  # Technically, there's a very, very small chance this test could
  # fail.  We could generate 51 results and have *none* of them be
  # "sam" and that *could* be valid.  The odds are just scarily
  # low of that happening in a real situation.
  #
  def test_double_create
    generator = nil
    assert_nothing_raised do
      generator = Markov::Generator.new [[1.0, "bob"], [0.8, "sam", :sam]]
      results = (0..50).map {|n| generator.one}
      assert results.include?("bob")
      assert results.include?("sam")
    end
  end

end

end  # if $0 == __FILE__
