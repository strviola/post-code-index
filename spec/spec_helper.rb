$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'pry'
require 'post_code_index'
include PostCodeIndex
require 'zip_converter'
include ZipConverter
