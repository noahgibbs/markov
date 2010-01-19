require "markov"

data = [
  [0.1, "low", :low],
  [1.0, "middle", :middle],
  [5.0, "high", :high],
  [1.0, [:one, " plus something"], :compound]
]
g = Markov::Generator.new data

g.save("simple_gen.markov")
