require "markov"

data = [
  [0.5, "low", :low],
  [1.0, "middle", :middle],
  [2.0, "high", :high],
  [1.0, [:+, :start, " plus something"], :compound]
]
g = Markov::Generator.new data

g.save("simple_gen.markov")
