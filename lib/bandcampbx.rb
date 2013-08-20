require_relative './bandcampbx/version'
require_relative './bandcampbx/client'
require 'multi_json'
require 'json'

module BandCampBX
  class StandardError < ::StandardError; end
  class InvalidTradeTypeError < StandardError; end

  module Helpers
    def self.json_parse(string)
      MultiJson.load(string)
    end
  end
end
