module CommonUtil
  POST_CODE_INDEX = 2
  PREF_INDEX = 6
  CITY_INDEX = 7
  TOWN_INDEX = 8

  def cache_dir(file_name)
    File.expand_path("../cache/#{file_name}", __FILE__)
  end
end
