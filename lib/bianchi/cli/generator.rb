module Bianchi
  module Cli
    class Generator < Thor::Group
      include Thor::Actions
      desc "-g {menu_name}_menu_page_{page_number}", "Generates a menu page file in your current directory"

      argument :menu_name_page_number

      def version
        say "Bianchi version #{Bianchi::VERSION}"
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end