# frozen_string_literal: true
require "active_support/all"
require "redis"
require "json"
require "thor"


require_relative "bianchi/version"
require_relative "bianchi/ussd/engine"
require_relative "bianchi/ussd/menu"
require_relative "bianchi/ussd/session"
require_relative "bianchi/ussd/page_delegators"
require_relative "bianchi/ussd/page"
require_relative "bianchi/ussd/store"
require_relative "bianchi/ussd/errors"

#cli
require 'bianchi/cli/main'



