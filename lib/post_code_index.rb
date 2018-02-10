require 'csv'
require_relative './common_util'
include CommonUtil

module PostCodeIndex
  def n_gram_array(string, n = 2)
    last = string.size - 1
    (0..last).map do |i|
      string[i..[(i + n - 1), last].min]
    end
  end

  def n_gram_record_hash(post_code_array, n = 2)
    record_hash = {}
    [PREF_INDEX, CITY_INDEX, TOWN_INDEX].each do |index|
      name = post_code_array[index]
      n_gram_array(name, n).each do |key_word|
        record_hash[key_word] = post_code_array[POST_CODE_INDEX]
      end
    end
    record_hash
  end

  def n_gram_dictionary(csv_string, n = 2)
    dictionary_hash = {}
    CSV.parse(csv_string).each do |post_code_array|
      record_hash = n_gram_record_hash(post_code_array)
      post_code = record_hash.values.first
      record_hash.keys.each do |key_word|
        if (post_codes = dictionary_hash[key_word])
          post_codes << post_code
          dictionary_hash[key_word] = post_codes
        else
          dictionary_hash[key_word] = [post_code]
        end
      end
    end
    dictionary_hash
  end
end
