# frozen_string_literal: true

require 'json'
require 'zlib'
require 'stringio'
require 'maxmind/db'
require_relative 'log'

class Reporter
  def initialize
    puts 'Land -> # Requests total / # davon authentifiziert'

    collect_logs
  end

  private

  def collect_logs
    nginx_logs = extract_nginx_logs

    grouped_by_month(nginx_logs).each do |month, logs|
      output_for_month = grouped_by_country(logs).map do |country, l|
        [country, [l.size, l.count(&:authorized?)].join(' / ')].join(' -> ')
      end.join("\n")
      puts [month, output_for_month].join("\n\n")
    end
  end

  def base_path
    File.dirname(File.expand_path($PROGRAM_NAME))
  end

  def extract_nginx_logs
    nginx_logs = []
    Dir["#{base_path}/logs/*.gz"].each do |f|
      gz = Zlib::GzipReader.new(StringIO.new(File.read(f)))
      nginx_logs += initialize_logs(gz.read)
      gz.close
    end
    nginx_logs
  end

  def initialize_logs(logs)
    logs.lines.map do |log|
      Log.new(log)
    end.select(&:nginx?)
  end

  def grouped_by_month(logs)
    logs.group_by do |log|
      log.timestamp.strftime('%Y.%m')
    end
  end

  def grouped_by_country(logs)
    logs.group_by(&:country_code).sort_by { |_c, l| l.size }
  end
end
