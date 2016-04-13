require 'zanzibar/cli'
require 'rspec'
require 'fakefs/spec_helpers'
require 'webmock'
require 'rspec'
require 'webmock/rspec'
require 'zanzibar/defaults'

include WebMock::API

describe Zanzibar::Cli do
  include FakeFS::SpecHelpers

  describe '#get' do
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
        .to_return(body: SECRET_XML, status: 200)

      Dir.chdir File.join(source_root, 'spec', 'files')
    end

    before(:all) do
      ENV['ZANZIBAR_PASSWORD'] = 'password'
    end

    after(:all) do
      ENV.delete 'ZANZIBAR_PASSWORD'
      WebMock.reset!
    end

    it 'should print a password to stdout' do
      subject.options = { 'domain' => 'zanzitest.net', 'wsdl' => 'scrt.wsdl' }
      expect { subject.get(1234) }.to output(/zanziUserPassword/).to_stdout
    end

    it 'should require a wsdl' do
      expect { subject.get(1234) }.to raise_error.with_message(/#{Zanzibar::NO_WSDL_ERROR}/)
    end

    it 'should be able to get a field value' do
      subject.options = { 'domain' => 'zanzitest.net', 'wsdl' => 'scrt.wsdl', 'fieldlabel' => 'Username' }
      expect { subject.get(1234) }.to output(/ZanziUser/).to_stdout
    end

    it 'should be able to download files' do
      WebMock.reset!
      stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
        .to_return(body: AUTH_XML, status: 200).then
        .to_return(body: SECRET_WITH_KEY_XML, status: 200).then
        .to_return(body: PRIVATE_KEY_XML, status: 200)

      subject.options = { 'domain' => 'zanzitest.net', 'wsdl' => 'scrt.wsdl', 'filelabel' => 'Private Key' }

      expect(FakeFS::FileTest.file? 'zanzi_key').to be(false)
      expect { subject.get(2345) }.to output(/zanzi_key/).to_stdout
      expect(FakeFS::FileTest.file? 'zanzi_key')
    end
  end
end
