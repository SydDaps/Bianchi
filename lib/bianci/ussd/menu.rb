# frozen_string_literal: true

module Bianci
  module USSD
    class Menu
      attr_reader :name, :options

      def initialize(name, options = {})
        @name = name.to_s
        @options = options
      end
    end
  end
end
