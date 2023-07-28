# frozen_string_literal: true
require 'json'
require "zlib"
require "maxmind/db"

class Reporter
  NGINX_LOG_REGEX = /^(((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}).*\"(((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4})\"$/


  def initialize
    @max_mind = MaxMind::DB.new("#{base_path}/../db/geo_ip.mmdb")
    collect_logs
  end

  private

  def collect_logs
    all = []
    Dir["#{base_path}/../logs/*.gz"].each do |f|
      begin
        decompressed = Zlib.gunzip(File.read(f))
        nginx_logs = extract_nginx_logs(decompressed)
        all += nginx_logs
      rescue Zlib::DataError, Zlib::GzipFile::CRCError
      end
    end

    messages = all.map { |l| l['message'] }.select { |l| l.match?(NGINX_LOG_REGEX) }

    puts messages.map { |l| l.match(NGINX_LOG_REGEX)[5] }.map {|ip| country_code(ip)}.tally.sort_by {|_k, v| v}.map{|l| l.join(' -> ')}.join("\n")
  end

  def base_path
    File.dirname(File.expand_path($0))
  end

  def extract_nginx_logs(logs)
    logs.lines.map do |l|
      JSON.parse(l)
    end.select do |l|
      l['kubernetes']['container_name'] == 'nginx'
    end
  end

  def country_code(ip_address)
    @max_mind.get(ip_address).dig('country', 'iso_code')
  end

end

Reporter.new
