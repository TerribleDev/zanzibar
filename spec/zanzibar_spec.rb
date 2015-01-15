require 'zanzibar'
require 'savon'
require 'webmock'
require 'rspec'
require 'webmock/rspec'

include WebMock::API

describe "Zanzibar Test" do

  client = Zanzibar::Zanzibar.new(:domain => "zanzitest.net", :pwd=>'password', :wsdl => "spec/scrt.wsdl")
  auth_xml = File.read('spec/responses/authenticate_response.xml')
  secret_xml = File.read('spec/responses/get_secret_response.xml')
  secret_with_key_xml = File.read('spec/responses/get_secret_with_keys_response.xml')
  secret_with_attachment_xml = File.read('spec/responses/get_secret_with_attachment_response.xml')
  private_key_xml = File.read('spec/responses/download_private_key_response.xml')
  public_key_xml = File.read('spec/responses/download_public_key_response.xml')
  attachment_xml = File.read('spec/responses/attachment_response.xml')


  it 'should return an auth token' do
    stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
      to_return(:body => auth_xml, :status => 200)

    expect(client.get_token).to eq("imatoken")
  end

  it 'should get a secret' do
    stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
      to_return(:body => auth_xml, :status => 200).then.
        to_return(:body => secret_xml, :status => 200)

    expect(client.get_secret(1234)[:secret][:name]).to eq("Zanzi Test Secret")
  end

  it 'should get a password' do
    stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
      to_return(:body => auth_xml, :status => 200).then.
        to_return(:body => secret_xml, :status => 200)

    expect(client.get_password(1234)).to eq("zanziUserPassword")
  end

  it 'should download a private key' do
    stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
      to_return(:body => auth_xml, :status => 200).then.
          to_return(:body => secret_with_key_xml, :status => 200).then.
            to_return(:body => private_key_xml, :status => 200)

      client.download_secret_file(:scrt_id => 2345, :type => 'Private Key')
      expect(File.exist? 'zanzi_key')
      expect(File.read('zanzi_key')).to eq("-----BEGIN RSA PRIVATE KEY -----\nzanzibarTestPassword\n-----END RSA PRIVATE KEY-----\n")
      File.delete('zanzi_key')
    end

    it 'should download a private key legacy' do
      stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
        to_return(:body => auth_xml, :status => 200).then.
            to_return(:body => secret_with_key_xml, :status => 200).then.
              to_return(:body => private_key_xml, :status => 200)

        client.download_private_key(:scrt_id => 2345)
        expect(File.exist? 'zanzi_key')
        expect(File.read('zanzi_key')).to eq("-----BEGIN RSA PRIVATE KEY -----\nzanzibarTestPassword\n-----END RSA PRIVATE KEY-----\n")
        File.delete('zanzi_key')
      end


  it 'should download a public key' do
    stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
      to_return(:body => auth_xml, :status => 200).then.
          to_return(:body => secret_with_key_xml, :status => 200).then.
            to_return(:body => public_key_xml, :status => 200)

      client.download_secret_file(:scrt_id => 2345, :type => 'Public Key')
      expect(File.exist? 'zanzi_key.pub')
      expect(File.read('zanzi_key.pub')).to eq("1234PublicKey5678==\n")
      File.delete('zanzi_key.pub')
    end

    it 'should download a public key legacy' do
      stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
        to_return(:body => auth_xml, :status => 200).then.
            to_return(:body => secret_with_key_xml, :status => 200).then.
              to_return(:body => public_key_xml, :status => 200)

        client.download_public_key(:scrt_id => 2345)
        expect(File.exist? 'zanzi_key.pub')
        expect(File.read('zanzi_key.pub')).to eq("1234PublicKey5678==\n")
        File.delete('zanzi_key.pub')
      end

  it 'should download an attachment' do
    stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
      to_return(:body => auth_xml, :status => 200).then.
          to_return(:body => secret_with_attachment_xml, :status => 200).then.
            to_return(:body => attachment_xml, :status => 200)

    client.download_secret_file(:scrt_id => 3456, :type => 'Attachment')
    expect(File.exist? 'attachment.txt')
    expect(File.read('attachment.txt')).to eq("I am a secret attachment\n")
    File.delete('attachment.txt')
  end

  it 'should download an attachment legacy' do
    stub_request(:any, "https://www.zanzitest.net/webservices/sswebservice.asmx").
      to_return(:body => auth_xml, :status => 200).then.
          to_return(:body => secret_with_attachment_xml, :status => 200).then.
            to_return(:body => attachment_xml, :status => 200)

    client.download_attachment(:scrt_id => 3456)
    expect(File.exist? 'attachment.txt')
    expect(File.read('attachment.txt')).to eq("I am a secret attachment\n")
    File.delete('attachment.txt')
  end
end
