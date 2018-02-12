require 'csv'
require_relative './common_util'
include CommonUtil

module PostCodeIndex
  def n_gram_array(string, n = 2)
    if n > string.size
      [string]
    else
      (0..(string.size - n)).map do |i|
        string[i..(i + n - 1)]
      end
    end
  end

  def n_gram_post_code_words(post_code_array, n = 2)
    key_words = []
    [PREF_INDEX, CITY_INDEX, TOWN_INDEX].each do |index|
      name = post_code_array[index]
      n_gram_array(name, n).each do |key_word|
        key_words << key_word
      end
    end
    [post_code_array[POST_CODE_INDEX], key_words.uniq]
  end

  def n_gram_dictionary(csv_string, n = 2)
    dictionary_hash = {}
    CSV.parse(csv_string).each do |post_code_array|
      post_code, key_words = n_gram_post_code_words(post_code_array, n)
      key_words.each do |key_word|
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

  def crate_hash_file(n = 2)
    return unless File.exists?(cache_dir(POST_CODE_FILE_NAME))
    File.open(cache_dir(POST_CODE_FILE_NAME), 'r') do |input_csv|
      csv_all = input_csv.read
      dictionary = n_gram_dictionary(csv_all, n)
      File.open(cache_dir(N_GRAM_FILE_NAME) % n, 'w') do |output_rb|
        output_rb.puts <<~RUBY
          module NGramDictionary#{n}
            DICTIONARY = #{dictionary}
          end
        RUBY
      end
    end
    true
  end

  def search_by_n_gram(n_gram_dictionary, keyword, n = 2)
    # TODO: implement
  end
end
