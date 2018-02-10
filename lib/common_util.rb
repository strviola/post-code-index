module CommonUtil
  POST_CODE_INDEX = 2
  PREF_INDEX = 6
  CITY_INDEX = 7
  TOWN_INDEX = 8

  POST_CODE_FILE_NAME = 'KEN_ALL_UTF.csv'
  N_GRAM_FILE_NAME = 'n_gram_dictionary_%d.rb'

  def cache_dir(file_name)
    File.expand_path("../cache/#{file_name}", __FILE__)
  end
end
