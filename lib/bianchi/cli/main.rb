# frozen_string_literal: true

# rubocop:disable Metrics/ParameterLists
module Bianchi
  module Cli
    class Main < Thor
      include Thor::Actions

      desc "-v", "Show bianchi version number"
      map %w[-v --version] => :version

      def version
        say "Bianchi version #{Bianchi::VERSION}"
      end

      def self.source_root
        File.dirname(__FILE__)
      end

      desc "setup", "sets up a new ussd project"
      def setup
        template("templates/engine.erb", "ussd/engine.rb")
      end

      desc "g", "Generates a menu page file"
      long_desc <<-LONG_DESC
        Usage: bianchi g|generate menu [name:string] page [number:int]
        \x5 Example: `bianchi generate menu main page 1`
      LONG_DESC

      map %w[g generate] => :generate
      def generate(entity = nil, entity_name = nil, type = nil, number = nil)
        unless ["menu"].include?(entity) && entity_name.is_a?(String) && type == "page" && number.to_i.to_s == number
          say("Usage: bianchi g|generate menu [name:string] page [number:int]", :yellow)
          say("Example: bianchi generate menu main page 1")
          exit(1)
        end

        @menu_name = entity_name
        @page_number = number
        template("templates/page.erb", "ussd/#{@menu_name}_menu/page_#{@page_number}.rb")
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end
# rubocop:enable Metrics/ParameterLists
