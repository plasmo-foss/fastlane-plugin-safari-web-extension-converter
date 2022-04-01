require 'fastlane_core/ui/ui'

module Fastlane
  module Helper
    class SafariWebExtensionConverterHelper
      def self.flag(flag, value: nil, boolean: false)
        if boolean then return "--#{flag}" end
        unless !value || value.empty? then return "--#{flag} #{value}" end
      end

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
