require 'fastlane_core/ui/ui'
require 'open3'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Actions
    class ConvertWebExtensionAction < Action
      def self.description
        "Uses Apple's safari-web-extension-converter via xcrun to convert an extension to a Safari Web Extension"
      end

      def self.authors
        ["Plasmo Corp."]
      end

      def self.validate_input(params)
        if params[:extension].nil?
          UI.user_error!("no extension param specified")
          return
        end

        if params[:swift] && params[:objc]
          UI.user_error!("can't specify both swift and objc")
          return
        end

        if params[:ios_only] && params[:mac_only]
          UI.user_error!("can't specify both ios_only and mac_only")
          return
        end
        return true # input valid
      end

      def self.run(params)
        unless self.validate_input(params)
          return # failed validation
        end

        unless system("command -v xcrun > /dev/null") # hide xcrun output
          UI.abort_with_message!("xcrun command does not exist")
          return # xcrun not found
        end

        xcrun = Helper::SafariWebExtensionConverterHelper.generate_command(params)
        UI.message("Running safari-web-extension-converter")
        stdout, stderr = Open3.capture3(xcrun)

        output = {
          "warnings" => nil,
          "project_location" => nil,
          "app_name" => nil,
          "app_bundle_identifier" => nil,
          "platform" => nil,
          "language" => nil
        }

        if stderr.start_with?("Could not find extension at")
          UI.user_error!("extension not found at specified directory")
          return nil
        end
        unless stderr.empty?
          warnings = Helper::SafariWebExtensionConverterHelper.parse(stderr, "Warning")
          UI.message("#{warnings.count} extension conversion warnings detected")
          output["warnings"] = warnings
        end
        unless stdout.empty?
          output["project_location"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "Xcode Project Location").first
          output["app_name"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "App Name").first
          output["app_bundle_identifier"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "App Bundle Identifier").first
          output["platform"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "Platform").first
          output["language"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "Language").first
        end
        UI.message("Successfully generated Xcode project")
        return output
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :extension,
                                       description: "The directory path of your Web Extension",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :project_location,
                                       description: "Save the generated app and Xcode project to the file path",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :rebuild_project,
                                       description: "Rebuild the existing Safari web extension Xcode project at the file path with different options or platforms. Use this option to add iOS to your existing macOS project",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       description: "Use the value to name the generated app and the Xcode project",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :bundle_identifier,
                                       description: "Use the value as the bundle identifier for the generated app. This identifier is unique to your app in your developer account. A reverse-DNS-style identifier is recommended (for example, com.company.extensionName)",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :swift,
                                       description: "Use Swift in the generated app",
                                       optional: true,
                                       default_value: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :objc,
                                       description: "Use Objective-C in the generated app",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :ios_only,
                                       description: "Create an iOS only project",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :mac_only,
                                       description: "Create a macOS only project",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :copy_resources,
                                       description: "Copy the extension files into the generated project. If you don’t specify this parameter, the project references the original extension files",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :force,
                                       description: "Overwrite the output directory, if one exists",
                                       optional: true,
                                       is_string: false)
        ]
      end

      def self.is_supported?(platform)
        %i[ios mac].include?(platform)
      end
    end
  end
end
