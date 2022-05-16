require 'fastlane_core/ui/ui'
require 'open3'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Actions
    module SharedValues
      CWE_WARNINGS = :CWE_WARNINGS
      CWE_PROJECT_LOCATION = :CWE_PROJECT_LOCATION
      CWE_APP_NAME = :CWE_APP_NAME
      CWE_APP_BUNDLE_IDENTIFIER = :CWE_APP_BUNDLE_IDENTIFIER
      CWE_APP_EXTENSION_BUNDLE_IDENTIFIER = :CWE_APP_EXTENSION_BUNDLE_IDENTIFIER
      CWE_PLATFORM = :CWE_PLATFORM
      CWE_LANGUAGE = :CWE_LANGUAGE
    end

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

      def self.parse_output(output, param)
        return Helper::SafariWebExtensionConverterHelper.parse(output, param)
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
        if stderr.start_with?("Unable to parse manifest.json at")
          UI.user_error!("extension manifest.json is invalid")
          return nil
        end
        unless stderr.empty?
          warnings = self.parse_output(stderr, "Warning")
          UI.message("#{warnings.count} extension conversion warnings detected")
          Actions.lane_context[SharedValues::CWE_WARNINGS] = warnings
          output["warnings"] = warnings
        end
        unless stdout.empty?
          # Parse individual output keys
          project_location = self.parse_output(stdout, "Xcode Project Location").first
          app_name = self.parse_output(stdout, "App Name").first
          app_bundle_identifier = self.parse_output(stdout, "App Bundle Identifier").first
          platform = self.parse_output(stdout, "Platform").first
          language = self.parse_output(stdout, "Language").first

          # User supplied or generated Extension bundle_id
          app_extension_bundle_identifier = params[:extension_bundle_identifier] || "#{app_bundle_identifier}.extension"

          # Repair project_location path
          project_location = "#{project_location}/#{app_name}"

          # Set lane context variables
          Actions.lane_context[SharedValues::CWE_PROJECT_LOCATION] = project_location
          Actions.lane_context[SharedValues::CWE_APP_NAME] = app_name
          Actions.lane_context[SharedValues::CWE_APP_BUNDLE_IDENTIFIER] = app_bundle_identifier
          Actions.lane_context[SharedValues::CWE_APP_EXTENSION_BUNDLE_IDENTIFIER] = app_extension_bundle_identifier
          Actions.lane_context[SharedValues::CWE_PLATFORM] = platform
          Actions.lane_context[SharedValues::CWE_LANGUAGE] = language

          # Set output dictionary
          output["project_location"] = project_location
          output["app_name"] = app_name
          output["app_bundle_identifier"] = app_bundle_identifier
          output["app_extension_bundle_identifier"] = app_extension_bundle_identifier
          output["platform"] = platform
          output["language"] = language
        end

        # Fixing the generated Xcode project to meet the spec
        Helper::SafariWebExtensionConverterHelper.tweak_xcodeproj(
          project_location,
          "#{project_location}/#{app_name}.xcodeproj",
          app_name,
          app_bundle_identifier,
          app_extension_bundle_identifier
        )

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
                                       description: "Use the value as the bundle identifier for the generated host app. This identifier is unique to your app in your developer account. A reverse-DNS-style identifier is recommended (for example, com.company.app-name)",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :extension_bundle_identifier,
                                       description: "Use the value as the extension bundle identifier for the generated extension target. By default, this is com.company.app-name.extension",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :swift,
                                       description: "Use Swift in the generated app",
                                       optional: true,
                                       default_value: false,
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
                                       description: "Copy the extension files into the generated project. If you dont specify this parameter, the project references the original extension files",
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
