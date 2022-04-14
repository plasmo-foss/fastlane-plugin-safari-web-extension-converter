require 'fastlane_core/ui/ui'
require 'xcodeproj'

module Fastlane
  module Helper
    class SafariWebExtensionConverterHelper
      # pass-through params from entrypoint
      def self.generate_command(params)
        return [
          "xcrun",
          "safari-web-extension-converter",
          params[:extension],
          flag("no-prompt", boolean: true),
          flag("no-open", boolean: true),
          flag("project-location", value: params[:project_location]),
          flag("rebuild-project", boolean: params[:rebuild_project]),
          flag("app-name", value: params[:app_name]),
          flag("bundle-identifier", value: params[:bundle_identifier]),
          flag("swift", boolean: params[:swift]),
          flag("objc", boolean: params[:objc]),
          flag("ios-only", boolean: params[:ios_only]),
          flag("mac-only", boolean: params[:mac_only]),
          flag("copy-resources", boolean: params[:copy_resources]),
          flag("force", boolean: params[:force])
        ].compact.join(" ")
      end

      def self.flag(flag, value: nil, boolean: false)
        if boolean then return "--#{flag}" end
        unless !value || value.empty? then return "--#{flag} #{value}" end
      end

      def self.share_schemes(path)
        xcproj = Xcodeproj::Project.open(path)
        visible = true
        shared = true
        xcproj.recreate_user_schemes(visible, shared)
        xcproj.save
      end

      private_class_method :flag

      def self.parse(output, param)
        prefix = "#{param}: "
        return output.split("\n")
                     .chunk { |i| i.match?(/^[\w\s]+:\s/) } # begins with param like `Warning:`
                     .reduce([]) { |arr, i| merge_chunks(arr, i) } # flattens multiline messages and multiple params
                     .select { |i| i.start_with?(prefix) }
                     .map { |i| i.delete_prefix(prefix) }
      end

      def self.merge_chunks(arr, chunk)
        found, lines = chunk
        if found then arr.push(*lines) # multiple params in a row
        elsif arr.length > 0 then arr[-1] += lines.join("\n") # multiline output
        end
        return arr
      end

      private_class_method :merge_chunks
    end
  end
end
