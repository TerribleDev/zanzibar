require 'zanzibar/cli'
require 'zanzibar/defaults'
require 'rspec'
require 'fakefs/spec_helpers'
require 'webmock'
require 'rspec'
require 'webmock/rspec'

include WebMock::API

describe Zanzibar::Cli do
  include FakeFS::SpecHelpers

  describe '#bundle' do
    context 'when Zanzifile already exists' do
      before(:each) do
        spec_root = File.join(source_root, 'spec')
        response_root = File.join(spec_root, 'responses')
        wsdl = File.join(spec_root, 'scrt.wsdl')
        files = File.join(spec_root, 'files')

        FakeFS::FileSystem.clone response_root
        FakeFS::FileSystem.clone wsdl
        FakeFS::FileSystem.clone files

        stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
          .to_return(body: AUTH_XML, status: 200).then
          .to_return(body: SECRET_WITH_KEY_XML, status: 200).then
          .to_return(body: PRIVATE_KEY_XML, status: 200)

        Dir.chdir File.join(source_root, 'spec', 'files')
      end

      before(:all) do
        ENV['ZANZIBAR_PASSWORD'] = 'password'
      end

      after(:all) do
        ENV.delete 'ZANZIBAR_PASSWORD'
      end

      it 'should have a Zanzifile' do
        expect(FakeFS::FileTest.file? Zanzibar::ZANZIFILE_NAME).to be(true)
        expect(File.read(Zanzibar::ZANZIFILE_NAME)).to include('zanzitest')
      end

      it 'should download a file' do
        expect(FakeFS::FileTest.file? File.join('secrets', 'zanzi_key')).to be(false)
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(FakeFS::FileTest.file? File.join('secrets', 'zanzi_key')).to be(true)
      end

      it 'should download a file to a prefix' do
        expect(FakeFS::FileTest.file? File.join('secrets/ssh', 'zanzi_key')).to be(false)
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(FakeFS::FileTest.file? File.join('secrets/ssh', 'zanzi_key')).to be(true)
      end

      it 'should create a .gitignore' do
        expect(FakeFS::FileTest.file? File.join('secrets', '.gitignore')).to be(false)
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(FakeFS::FileTest.file? File.join('secrets', '.gitignore')).to be(true)
      end

      it 'should create a resolved file' do
        expect(FakeFS::FileTest.file? Zanzibar::RESOLVED_NAME).to be(false)
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(FakeFS::FileTest.file? Zanzibar::RESOLVED_NAME).to be(true)
      end

      it 'should not redownload files it already has' do
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(WebMock).to have_requested(:post, 'https://www.zanzitest.net/webservices/sswebservice.asmx').times(3)

        WebMock.reset!

        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(WebMock).not_to have_requested(:post, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      end

      it 'should redownload on update action' do
        expect { subject.bundle }.to output(/Finished downloading secrets/).to_stdout
        expect(WebMock).to have_requested(:post, 'https://www.zanzitest.net/webservices/sswebservice.asmx').times(3)

        WebMock.reset!
        stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
          .to_return(body: AUTH_XML, status: 200).then
          .to_return(body: SECRET_WITH_KEY_XML, status: 200).then
          .to_return(body: PRIVATE_KEY_XML, status: 200)

        expect { subject.update }.to output(/Finished downloading secrets/).to_stdout
        expect(WebMock).to have_requested(:post, 'https://www.zanzitest.net/webservices/sswebservice.asmx').times(3)
      end

      it 'should reject a malformed Zanzifile' do
        File.write('Zanzifile', 'broken YAML')
        expect { subject.bundle }.to raise_error.with_message(/#{Zanzibar::INVALID_ZANZIFILE_ERROR}/)
      end
    end

    context 'when Zanzifile does not exist' do
      it 'should return an error' do
        expect { subject.bundle }.to raise_error.with_message(/#{Zanzibar::NO_ZANZIFILE_ERROR}/)
      end
    end
  end
end
