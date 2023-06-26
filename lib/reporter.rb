# frozen_string_literal: true
require 'json'

class Reporter

  def initialize
    puts 'haha'
    collect_logs
  end

  private

  def collect_logs
    all = []
    Dir["#{base_path}/logs/*.har"].each do |f|
      json = JSON.parse(File.read(f))
      all << json
    end

    puts all
  end

  def base_path
    File.dirname(File.expand_path($0))
  end

end
