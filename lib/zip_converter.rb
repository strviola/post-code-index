require 'open-uri'
require 'zip'

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

  def expand_zip
    Zip::File.open(cache_dir('ken_all.zip')) do |zip|
      zip.each do |entry|
        # 1 file 'KEN_ALL.CSV' is generated
        zip.extract(entry, cache_dir(entry.name)) { true }
      end
    end
  end

  # TODO: convert character set Shift_JIS to UTF-8
  # TODO: put to POST_CODE_FILE_NAME (KEN_ALL_UTF.csv)

  def concat_post_code_table(csv_string)
    table_hash = {}
    prev_record = []
    CSV.parse(csv_string).each do |post_code_array|
      if prev_record[POST_CODE_INDEX] == post_code_array[POST_CODE_INDEX]
        post_code_array[TOWN_INDEX] = prev_record[TOWN_INDEX] + post_code_array[TOWN_INDEX]
      end
      table_hash[post_code_array[POST_CODE_INDEX]] = post_code_array
      prev_record = post_code_array
    end
    table_hash
  end

  def create_concat_post_codes
    return unless File.exists?(cache_dir(POST_CODE_FILE_NAME))
    File.open(cache_dir(POST_CODE_FILE_NAME), 'r') do |input_csv|
      csv_all = input_csv.read
      dictionary = concat_post_code_table(csv_all)
      File.open(cache_dir(CONCAT_POST_CODE_FILE_NAME), 'w') do |output_rb|
        output_rb.puts <<~RUBY
          module PostCode
            POST_CODE_DICTIONARY = #{dictionary}
          end
        RUBY
      end
    end
    true
  end
end
