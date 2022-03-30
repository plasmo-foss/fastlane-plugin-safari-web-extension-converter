# Safari Web Extension Converter Fastlane plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-safari_web_extension_converter)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-safari_web_extension_converter`, add it to your project by running:

```bash
fastlane add_plugin safari_web_extension_converter
```

## About Safari Web Extension Converter

Uses Apple's `safari-web-extension-converter` via xcrun to convert an extension to a Safari Web Extension

`convert-web-extension` is the entrypoint action that takes a path to an Web Extension and generates an Xcode project. 

## Usage
To get started,

```ruby
convert-web-extension(
  extension: "<path to extension>",
  app_name: "Sea Creator",  # Optional (inferred from Manifest)
  bundle_identifier: "com.example.apple.Sea-Creator", # Optional (inferred from Manifest)
  objc: true, # Optional. Defaults to Swift
  mac_only: true # Optional. Default generates iOS and macOS
)
```

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

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

# License

[MIT](./license) 🚀 [Plasmo Corp.](https://plasmo.com)