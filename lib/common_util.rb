module CommonUtil
  def cache_dir(file_name)
    File.expand_path("../cache/#{file_name}", __FILE__)
  end
end
