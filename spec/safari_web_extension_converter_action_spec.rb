describe Fastlane::Actions::ConvertWebExtensionAction do
  describe '#run' do
    if FastlaneCore::Helper.mac?
      after :each do
        Fastlane::FastFile.new.parse("lane :test do
          Actions.lane_context[SharedValues::CWE_WARNINGS] = nil
          Actions.lane_context[SharedValues::CWE_PROJECT_LOCATION] = nil
          Actions.lane_context[SharedValues::CWE_APP_NAME] = nil
          Actions.lane_context[SharedValues::CWE_APP_BUNDLE_IDENTIFIER] = nil
          Actions.lane_context[SharedValues::CWE_PLATFORM] = nil
          Actions.lane_context[SharedValues::CWE_LANGUAGE] = nil
        end").runner.execute(:test)
      end
      it "raises an error if no extension param is provided" do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            convert_web_extension()
          end").runner.execute(:test)
        end.to raise_error("no extension param specified")
      end
      it "raises an error if both ios_only and mac_only set" do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            convert_web_extension(
              extension: '../example/',
              ios_only: true,
              mac_only: true
            )
          end").runner.execute(:test)
        end.to raise_error("can't specify both ios_only and mac_only")
      end
      it "raises an error if xcrun can't find directory" do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            convert_web_extension(
              extension: './wrong-directory/'
            )
          end").runner.execute(:test)
        end.to raise_error("extension not found at specified directory")
      end
      context "with proper extension directory" do
        let(:output) do
          output = Fastlane::FastFile.new.parse("
          lane :test do
            returned = convert_web_extension(
              extension: '../example/'
            )
            lane_context = {
              CWE_WARNINGS: Actions.lane_context[Actions::SharedValues::CWE_WARNINGS],
              CWE_PROJECT_LOCATION: Actions.lane_context[Actions::SharedValues::CWE_PROJECT_LOCATION],
              CWE_APP_NAME: Actions.lane_context[Actions::SharedValues::CWE_APP_NAME],
              CWE_APP_BUNDLE_IDENTIFIER: Actions.lane_context[Actions::SharedValues::CWE_APP_BUNDLE_IDENTIFIER],
              CWE_PLATFORM: Actions.lane_context[Actions::SharedValues::CWE_PLATFORM],
              CWE_LANGUAGE: Actions.lane_context[Actions::SharedValues::CWE_LANGUAGE],
            }
            [returned, lane_context]
          end").runner.execute(:test)
        end
        it "successfully executes xcrun converter with extension" do
          expect(output[0]["app_name"]).to eq("Plasmo Mock Browser Extension")
          expect(output[0]["app_bundle_identifier"]).to eq("com.yourCompany.Plasmo-Mock-Browser-Extension")
          expect(output[0]["platform"]).to eq("All")
          expect(output[0]["language"]).to eq("Swift")
        end
        it "lane context output is correct" do
          expect(output[1][:CWE_APP_NAME]).to eq("Plasmo Mock Browser Extension")
          expect(output[1][:CWE_APP_BUNDLE_IDENTIFIER]).to eq("com.yourCompany.Plasmo-Mock-Browser-Extension")
          expect(output[1][:CWE_PLATFORM]).to eq("All")
          expect(output[1][:CWE_LANGUAGE]).to eq("Swift")
        end
      end
    else
      it "aborts if environment is missing xcrun" do
        expect do
          Fastlane::FastFile.new.parse("
          lane :test do
            convert_web_extension(
              extension: '../example/'
            )
          end").runner.execute(:test)
        end.to raise_error("xcrun command does not exist")
      end
    end
  end
end
