require 'open-uri'

module PostCodeIndex
  def n_gram_array(string, n = 2)
    last = string.size - 1
    (0..last).map do |i|
      string[i..[(i + n - 1), last].min]
    end
  end

  def download_post_code_zip
    url = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'
    open(url) do |remote|
      File.open(cache_dir('ken_all.zip'), 'wb') do |local|
        local.puts remote.read
      end
    end
    true
  end

  def cache_dir(file_name)
    File.expand_path("../cache/#{file_name}", __FILE__)
  end
end
