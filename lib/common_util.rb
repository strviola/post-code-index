module CommonUtil
  POST_CODE_INDEX = 2
  PREF_INDEX = 6
  CITY_INDEX = 7
  TOWN_INDEX = 8

  POST_CODE_FILE_NAME = 'KEN_ALL_UTF.csv'
  CONCAT_POST_CODE_FILE_NAME = 'post_code.rb'
  N_GRAM_FILE_NAME = 'n_gram_dictionary_%d.rb'

  def cache_dir(file_name)
    File.expand_path("../cache/#{file_name}", __FILE__)
  end

  def read_and_write(input_file_name, output_file_name)
    return unless File.exists?(cache_dir(input_file_name))
    File.open(cache_dir(input_file_name), 'r') do |input|
      File.open(cache_dir(output_file_name), 'w') do |output|
        yield input, output
      end
    end
    true
  end
end
