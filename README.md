# Safari Web Extension Converter Fastlane plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-safari_web_extension_converter)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. It is a component of [Plasmo Corp's](https://plasmo.com) [Browser Plugin Publisher](https://github.com/plasmo-corp/bpp) for GitHub Actions, the easiest way to publish a cross-platform browser extension. 

To get started add it to your project by running:

```sh
fastlane add_plugin safari_web_extension_converter
```

*Requires macOS, Xcode 12 or greater, and Xcode Command Line tools.*

## About Safari Web Extension Converter

Uses Apple's `safari-web-extension-converter` via Xcode Command Line tools `xcrun` to convert a Web Extension (i.e. Chrome Extensions) to a Safari Web Extension. The CLI this plugin relies on was released alongside Xcode 12 at WWDC 2021 with the session [Meet Safari Web Extensions on iOS](https://developer.apple.com/videos/play/wwdc2021/10104). Supports universal iOS and macOS extensions by default.

`convert_web_extension` is the entrypoint action that takes a path to a Web Extension and generates an Xcode project. 

## Usage
To get started, try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`. The [example Fastfile](fastlane/Fastfile) describes the plugin usage, and [example](example/) is an example Web Extension. The plugin outputs helpful metadata, like warnings for missing extension features in the Safari environment, and the generated Xcode project location.

```ruby
convert_web_extension(
  extension: "<path to extension>",
  app_name: "Sea Creator",  # Optional (inferred from Manifest)
  bundle_identifier: "com.example.apple.Sea-Creator", # Optional (inferred from Manifest)
  objc: true, # Optional. Defaults to Swift
  mac_only: true # Optional. Default generates iOS and macOS
)
```

Take it for a spin and Build & Run in Xcode. Follow Apple's guide to test your Web Extension: [Running Your Safari Web Extension](https://developer.apple.com/documentation/safariservices/safari_web_extensions/running_your_safari_web_extension)

### Parameters
| Key               | Description |
| ----------------- | ----------- |
| extension         | The directory path of your Web Extension. |
| project_location  | Save the generated app and Xcode project to the file path. |
| rebuild_project   | Rebuild the existing Safari web extension Xcode project at the file path with different options or platforms. Use this option to add iOS to your existing macOS project. |
| app_name          | Use the value to name the generated app and the Xcode project. |
| bundle_identifier | Use the value as the bundle identifier for the generated app. This identifier is unique to your app in your developer account. A reverse-DNS-style identifier is recommended (for example, com.company.extensionName). |
| swift             | Use Swift in the generated app. |
| objc              | Use Objective-C in the generated app. |
| ios_only          | Create an iOS only project. |
| mac_only          | Create a macOS only project. |
| copy_resources    | Copy the extension files into the generated project. If you don’t specify this parameter, the project references the original extension files. |
| force             | Overwrite the output directory, if one exists. |

### Plugin Output
```json
{
  "warnings": [],
  "project_location": "<generated project dir>",
  "app_name": "App Name",
  "app_bundle_identifier": "com.example.app-name.extension",
  "platform": "All",
  "language": "Swift"
}
```

## Run tests for this plugin

To run both the tests, and code style validation, run
```sh
rake
```

## Internals

The plugin validates user input and checks if `xcrun` is available in the environment. `Open3.capture3(xcrun)` is the `self.run` [entrypoint](lib/fastlane/plugin/safari_web_extension_converter/actions/convert_web_extension_action.rb) is responsible for the heavy lifting by spawning an `xcrun` instance, collecting stdout and stderr. Output is parsed for generative metadata and warnings.

- the [action](lib/fastlane/plugin/safari_web_extension_converter/actions/convert_web_extension_action.rb) is the plugin entrypoint
- the [helper](lib/fastlane/plugin/safari_web_extension_converter/helper/safari_web_extension_converter_helper.rb) includes helper functions, like output parsing
- version is maintained in [version.rb](lib/fastlane/plugin/safari_web_extension_converter/version.rb)
- a [spec action](spec/safari_web_extension_converter_action_spec.rb) executes RSpec tests using a top-level Fastlane lane

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

# License

[MIT](./license) 🚀 [Plasmo Corp.](https://plasmo.com)