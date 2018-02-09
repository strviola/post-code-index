module PostCodeIndex
  def n_gram_array(string, n = 2)
    last = string.size - 1
    (0..last).map do |i|
      string[i..[(i + n - 1), last].min]
    end
  end

  def n_gram_record_hash(post_code_array, n = 2)
    post_code_index = 2
    pref_index = 6
    city_index = 7
    town_index = 8
    record_hash = {}
    [pref_index, city_index, town_index].each do |index|
      name = post_code_array[index]
      n_gram_array(name, n).each do |key_word|
        record_hash[key_word] = post_code_array[post_code_index]
      end
    end
    record_hash
  end
end
