# frozen_string_literal: true

require 'json'
require 'zlib'
require 'maxmind/db'
require_relative 'log'

class Reporter


  def initialize
    collect_logs
  end

  private

  def collect_logs
    nginx_logs = []
    Dir["#{base_path}/../logs/*.gz"].each do |f|
      begin
        decompressed = Zlib.gunzip(File.read(f))
        nginx_logs += extract_nginx_logs(decompressed)
      rescue Zlib::DataError, Zlib::GzipFile::CRCError
      end
    end

    grouped_by_month(nginx_logs).each do |month, logs|
      puts [month, logs.map(&:country_code).tally.sort_by { |_k, v| v }.map { |l| l.join(' -> ') }.join("\n")].join("\n\n")
    end
  end

  def base_path
    File.dirname(File.expand_path($PROGRAM_NAME))
  end

  def extract_nginx_logs(logs)
    logs.lines.map do |log|
      Log.new(log)
    end.select(&:nginx?)
  end

  def grouped_by_month(logs)
    logs.group_by do |log|
      log.timestamp.strftime('%Y.%m')
    end
  end
end

Reporter.new
