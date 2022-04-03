require 'fastlane/action'
require 'fastlane_core/ui/ui'
require 'open3'
require_relative '../helper/safari_web_extension_converter_helper'

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

      def self.run(params)
        extension = params[:extension]
        project_location = params[:project_location]
        rebuild_project = params[:rebuild_project]
        app_name = params[:app_name]
        bundle_identifier = params[:bundle_identifier]
        swift = params[:swift]
        objc = params[:objc]
        ios_only = params[:ios_only]
        mac_only = params[:mac_only]
        copy_resources = params[:copy_resources]
        force = params[:force]

        unless system("command -v xcrun > /dev/null") # hide xcrun output
          UI.abort_with_message!("xcrun command does not exist")
          return
        end

        if extension.nil?
          UI.user_error!("no extension param specified")
          return
        end

        if swift && objc
          UI.user_error!("can't specify both swift and objc")
          return
        end

        if ios_only && mac_only
          UI.user_error!("can't specify both ios_only and mac_only")
          return
        end

        xcrun = [
          "xcrun",
          "safari-web-extension-converter",
          extension,
          Helper::SafariWebExtensionConverterHelper.flag("no-prompt", boolean: true),
          Helper::SafariWebExtensionConverterHelper.flag("no-open", boolean: true),
          Helper::SafariWebExtensionConverterHelper.flag("project-location", value: project_location),
          Helper::SafariWebExtensionConverterHelper.flag("rebuild-project", boolean: rebuild_project),
          Helper::SafariWebExtensionConverterHelper.flag("app-name", value: app_name),
          Helper::SafariWebExtensionConverterHelper.flag("bundle-identifier", value: bundle_identifier),
          Helper::SafariWebExtensionConverterHelper.flag("swift", boolean: swift),
          Helper::SafariWebExtensionConverterHelper.flag("objc", boolean: objc),
          Helper::SafariWebExtensionConverterHelper.flag("ios-only", boolean: ios_only),
          Helper::SafariWebExtensionConverterHelper.flag("mac-only", boolean: mac_only),
          Helper::SafariWebExtensionConverterHelper.flag("copy-resources", boolean: copy_resources),
          Helper::SafariWebExtensionConverterHelper.flag("force", boolean: force)
        ].compact.join(" ")
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
          output["warnings"] = Helper::SafariWebExtensionConverterHelper.parse(stderr, "Warning")
        end
        unless stdout.empty?
          output["project_location"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "Xcode Project Location").first
          output["app_name"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "App Name").first
          output["app_bundle_identifier"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "App Bundle Identifier").first
          output["platform"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "Platform").first
          output["language"] = Helper::SafariWebExtensionConverterHelper.parse(stdout, "Language").first
        end
        
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
