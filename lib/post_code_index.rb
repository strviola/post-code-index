require 'csv'
require_relative './common_util'
include CommonUtil

module PostCodeIndex
  def n_gram_array(string, n = 2)
    (0..[(string.size - n), 0].max).map do |i|
      string[i..(i + [n, string.size].min - 1)]
    end
  end

  def n_gram_post_code_words(post_code_array, n = 2)
    name = [PREF_INDEX, CITY_INDEX, TOWN_INDEX].map { |index| post_code_array[index] }.join
    [post_code_array[POST_CODE_INDEX], n_gram_array(name, n).uniq]
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
    read_and_write(POST_CODE_FILE_NAME, N_GRAM_FILE_NAME % n) do |input_csv, output_rb|
      dictionary = n_gram_dictionary(input_csv.read, n)
      output_rb.puts <<~RUBY
        module NGramDictionary#{n}
          N_GRAM_DICTIONARY = #{dictionary}
        end
      RUBY
    end
  end

  def search_by_n_gram(n_gram_dictionary, keyword, n = 2)
    found = n_gram_array(keyword, n).map do |keyword_div|
      n_gram_dictionary[keyword_div] || []
    end
    found.inject(:&)
  end

  def find_record(dictionary, post_codes, keyword_div)
    records = []
    post_codes.each do |post_code|
      found = dictionary[post_code]
      if found.size == 1 # 重複・結合共になし
        records << found.first
      elsif found.first[TOWN_INDEX].size >= 30 # 結合あり
        # 本来38文字だが文字コードの関係上やや少なくする
        # 参考: http://www.post.japanpost.jp/zipcode/dl/readme.html
        # TODO: 結合して records に追加
      else # 重複あり…改めて検索
        keyword_include = found.select do |record|
          keyword_div.map do |keyword|
            record.map do |element|
              element.include?(keyword)
            end.inject(:|)
          end.inject(:&)
        end
        records.concat(keyword_include)
      end
    end
    records
  end
end
