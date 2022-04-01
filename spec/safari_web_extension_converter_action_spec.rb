describe Fastlane::Actions::ConvertWebExtensionAction do
  describe '#run' do
    if FastlaneCore::Helper.mac?
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
            convert_web_extension(
              extension: '../example/'
            )
          end").runner.execute(:test)
        end
        it "successfully executes xcrun converter with extension" do
          expect(output["app_name"]).to eq("Plasmo Mock Browser Extension")
          expect(output["app_bundle_identifier"]).to eq("com.yourCompany.Plasmo-Mock-Browser-Extension")
          expect(output["platform"]).to eq("All")
          expect(output["language"]).to eq("Swift")
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
