require 'thor'

module Bianchi
  module Generator
    class Cli < Thor
      desc "say_hello Name", "an example task"
      def say_hello(name)
        puts "hello #{name}"
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end