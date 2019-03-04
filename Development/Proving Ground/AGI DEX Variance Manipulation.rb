agi = 10
dex = 10
total = agi + dex
middle = dex / total.to_f
25.times do
  var = 0.5 - (0.5 - middle).abs
  puts middle + rand*var - rand*var
end
