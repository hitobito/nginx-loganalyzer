# frozen_string_literal: true

require_relative 'geo_ip'
require 'date'

class Log
  NGINX_LOG_REGEX = /^(((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}) - - \[(.*?)\].*\"(((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4})\"$/

  attr_reader :body, :log_message

  def initialize(log)
    @body = JSON.parse(log)
    @log_message = @body['message']
  end

  def nginx?
    body['kubernetes']['container_name'] == 'nginx' && log_message.match?(NGINX_LOG_REGEX)
  end

  def timestamp
    @timestamp ||= DateTime.strptime(log_message.match(NGINX_LOG_REGEX)[5], '%d/%b/%Y:%H:%M:%S %z')
  end

  def country_code
    @country_code ||= begin
      ip = log_message.match(NGINX_LOG_REGEX)[6]
      GeoIp.instance.country_code(ip)
    end
  end
end
