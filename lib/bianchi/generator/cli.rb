require 'thor'
module Bianchi
  module Generator
    class Cli < Thor
      desc "-v", "Show bianchi version number"
      map %w[-v --version] => :version
      # USAGE: bianchi -v
      def version
        say "Bianchi #{Bianchi::VERSION}"
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end