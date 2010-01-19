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
      selected = rand * total

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
        when Array then item.map {|s| evaluate(s)}.inject("", &:+)
        when :one then one()
        when Symbol then evaluate(@names[item][1])
        else die "Don't know how to evaluate: #{item.inspect}!"
      end
    end
  end

  def self.load(filename)
    structures = nil
    File.open(filename) do |f|
      structures = YAML::load(f.read)
    end

    Generator.new structures
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
