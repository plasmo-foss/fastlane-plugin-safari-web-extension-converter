require 'fastlane_core/ui/ui'
require 'xcodeproj'

module Fastlane
  module Helper
    class SafariWebExtensionConverterHelper
      # pass-through params from entrypoint
      def self.generate_command(params)
        swift = params[:objc] ? false : (params[:swift] || true)
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
          flag("swift", boolean: swift),
          flag("objc", boolean: params[:objc]),
          flag("ios-only", boolean: params[:ios_only]),
          flag("mac-only", boolean: params[:mac_only]),
          flag("copy-resources", boolean: params[:copy_resources]),
          flag("force", boolean: params[:force])
        ].compact.join(" ")
      end

      def self.flag(flag, value: nil, boolean: false)
        if boolean then return "--#{flag}" end
        unless !value || value.empty? then return "--#{flag} '#{value}'" end
      end

      private_class_method :flag

      def self.tweak_xcodeproj(
        path,
        xcodeproj_path,
        app_name,
        app_bundle_id,
        app_extension_bundle_id
      )
        xcproj = Xcodeproj::Project.open(xcodeproj_path)

        # Recreating and sharing schemes; mimicking Xcode's UI behavior
        visible = true
        shared = true
        xcproj.recreate_user_schemes(visible, shared)

        # Recreating Apple's incorrect bundle_id generation
        bundle_id_parts = app_bundle_id.split('.')
        bundle_id_parts.pop # Apple's generator ignores this
        app_name_suffix = app_name.split.join('-')
        generated_bundle_id = bundle_id_parts.push(app_name_suffix).join('.')
        generated_extension_bundle_id = "#{generated_bundle_id}.Extension"

        # Replacing pbx bundle identifiers to fix underlying generator bug
        xcproj.targets.each do |target|
          target.build_configurations.each do |config|
            build_settings = target.build_settings(config.name)
            if build_settings['PRODUCT_BUNDLE_IDENTIFIER'] == generated_bundle_id
              build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = app_bundle_id
            elsif build_settings['PRODUCT_BUNDLE_IDENTIFIER'] == generated_extension_bundle_id
              build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = app_extension_bundle_id
            end
          end
        end

        # Write pbx changes
        xcproj.save

        # Replacing static bundle id in generated code
        file_names = ['ViewController.m', 'ViewController.swift']
        file_names.each do |file_name|
          file_path = "#{path}/Shared (App)/#{file_name}"
          next unless File.exist?(file_path)

          text = File.read(file_path)
          new_contents = text.gsub(generated_extension_bundle_id, app_extension_bundle_id)
          File.open(file_path, "w") { |file| file.puts(new_contents) }
        end
      end

      def self.parse(output = "", param)
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
