# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/string"
require "redis"
require "json"

require_relative "bianci/version"
require_relative "bianci/ussd/engine"
require_relative "bianci/ussd/menu"
require_relative "bianci/ussd/session"
require_relative "bianci/ussd/page"
require_relative "bianci/ussd/store"
require_relative "bianci/ussd/errors"

module Bianci
  class Error < StandardError; end
  # Your code goes here...
end
