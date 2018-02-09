module PostCodeIndex
  def n_gram_array(string, n = 2)
    last = string.size - 1
    (0..last).map do |i|
      string[i..[(i + n - 1), last].min]
    end
  end
end
