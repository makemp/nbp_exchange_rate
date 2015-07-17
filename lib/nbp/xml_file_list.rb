require 'date'
require 'open-uri'
require_relative './commons.rb'
module NBP
  class XMLFileList
    attr_reader :dir_name, :matched_base_file_names

    BASE_NAME = 'dir'
    CORE_WEB_PATH = 'http://www.nbp.pl/kursy/xml/'

    include Commons

    def initialize(date, file_extension = '.txt')
      @dir_name = file_list_name(date) + file_extension
      @nbp_date_format_string = nbp_date_format_string(date)
      @matched_base_file_names = []
    end

    def fetch_file_names
      dir_file = open(CORE_WEB_PATH + dir_name, 'r')
      @matched_base_file_names = dir_file.each_line.with_object([]) do |line, arr|
        trim_line = line.strip
        arr << trim_line if trim_line[-6..-1] == @nbp_date_format_string
      end
    end

    def matched_file_names_as_hashes
      matched_base_file_names.map do |name|
        { table_name: name[0],
          table_number: name[1..3],
          constant_element: name[4],
          year: name[5..6],
          month: name[7..8],
          day: name[9..10],
          extension: name[-4..-1] }
      end
    end

    private

    def nbp_date_format_string(date)
      date_hash = nbp_date_format_hash(date)
      date_hash[:year] + date_hash[:month] + date_hash[:day]
    end

    def file_list_name(date)
      year = date.year.to_s
      return BASE_NAME if year[-2..-1] == DateTime.now.year.to_s[-2..-1]
      BASE_NAME + year
    end
  end
end