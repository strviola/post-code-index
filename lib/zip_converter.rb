require 'open-uri'

module ZipConverter
  def download_post_code_zip
    url = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'
    open(url) do |remote|
      File.open(cache_dir('ken_all.zip'), 'wb') do |local|
        local.puts remote.read
      end
    end
    true
  end
end
