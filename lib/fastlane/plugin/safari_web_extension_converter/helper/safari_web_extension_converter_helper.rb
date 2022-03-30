require 'fastlane_core/ui/ui'

module Fastlane
  module Helper
    class SafariWebExtensionConverterHelper
      def self.flag_string(flag, var)
        unless !var || var.empty?
          return "--#{flag} #{var}"
        end
      end

      def self.flag_boolean(flag, var = true)
        if var
          return "--#{flag}"
        end
      end
    end
  end
end
