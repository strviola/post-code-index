require 'open-uri'
require 'zip'
require 'kconv'

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

  def convert_charset
    read_and_write('KEN_ALL.CSV', POST_CODE_FILE_NAME) do |sjis, utf|
      utf.puts sjis.read.kconv(Kconv::UTF8, Kconv::SJIS)
    end
  end

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
    read_and_write(POST_CODE_FILE_NAME, CONCAT_POST_CODE_FILE_NAME) do |input_csv, output_rb|
      dictionary = concat_post_code_table(input_csv.read)
      output_rb.puts <<~RUBY
        module PostCode
          POST_CODE_DICTIONARY = #{dictionary}
        end
      RUBY
    end
  end
end
