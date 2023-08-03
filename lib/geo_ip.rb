# frozen_string_literal: true

require 'singleton'

class GeoIp
  include Singleton

  def initialize
    @max_mind = MaxMind::DB.new("#{base_path}/db/geo_ip.mmdb")
  end

  def country_code(ip_address)
    @max_mind.get(ip_address).dig('country', 'iso_code')
  rescue NoMethodError
    'unbekannt'
  end

  def base_path
    File.dirname(File.expand_path($PROGRAM_NAME))
  end
end
