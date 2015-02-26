require 'zanzibar'
require 'savon'
require 'webmock'
require 'rspec'
require 'webmock/rspec'

include WebMock::API

describe 'Zanzibar Test' do
  client = Zanzibar::Zanzibar.new(domain: 'zanzitest.net', pwd: 'password', wsdl: 'spec/scrt.wsdl')

  it 'should return an auth token' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200)

    expect(client.get_token).to eq('imatoken')
  end

  it 'should get a secret' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_XML, status: 200)

    expect(client.get_secret(1234)[:secret][:name]).to eq('Zanzi Test Secret')
  end

  it 'should get a password' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_XML, status: 200)

    expect(client.get_password(1234)).to eq('zanziUserPassword')
  end

  it 'should download a private key' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_WITH_KEY_XML, status: 200).then
      .to_return(body: PRIVATE_KEY_XML, status: 200)

    client.download_secret_file(scrt_id: 2345, type: 'Private Key')
    expect(File.exist? 'zanzi_key')
    expect(File.read('zanzi_key')).to eq("-----BEGIN RSA PRIVATE KEY -----\nzanzibarTestPassword\n-----END RSA PRIVATE KEY-----\n")
    File.delete('zanzi_key')
  end

  it 'should download a private key legacy' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_WITH_KEY_XML, status: 200).then
      .to_return(body: PRIVATE_KEY_XML, status: 200)

    client.download_private_key(scrt_id: 2345)
    expect(File.exist? 'zanzi_key')
    expect(File.read('zanzi_key')).to eq("-----BEGIN RSA PRIVATE KEY -----\nzanzibarTestPassword\n-----END RSA PRIVATE KEY-----\n")
    File.delete('zanzi_key')
  end

  it 'should download a public key' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_WITH_KEY_XML, status: 200).then
      .to_return(body: PUBLIC_KEY_XML, status: 200)

    client.download_secret_file(scrt_id: 2345, type: 'Public Key')
    expect(File.exist? 'zanzi_key.pub')
    expect(File.read('zanzi_key.pub')).to eq("1234PublicKey5678==\n")
    File.delete('zanzi_key.pub')
  end

  it 'should download a public key legacy' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_WITH_KEY_XML, status: 200).then
      .to_return(body: PUBLIC_KEY_XML, status: 200)

    client.download_public_key(scrt_id: 2345)
    expect(File.exist? 'zanzi_key.pub')
    expect(File.read('zanzi_key.pub')).to eq("1234PublicKey5678==\n")
    File.delete('zanzi_key.pub')
  end

  it 'should download an attachment' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_WITH_ATTACHMENT_XML, status: 200).then
      .to_return(body: ATTACHMENT_XML, status: 200)

    client.download_secret_file(scrt_id: 3456, type: 'Attachment')
    expect(File.exist? 'attachment.txt')
    expect(File.read('attachment.txt')).to eq("I am a secret attachment\n")
    File.delete('attachment.txt')
  end

  it 'should download an attachment legacy' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_WITH_ATTACHMENT_XML, status: 200).then
      .to_return(body: ATTACHMENT_XML, status: 200)

    client.download_attachment(scrt_id: 3456)
    expect(File.exist? 'attachment.txt')
    expect(File.read('attachment.txt')).to eq("I am a secret attachment\n")
    File.delete('attachment.txt')
  end

  it 'should save credentials to a file' do
    stub_request(:any, 'https://www.zanzitest.net/webservices/sswebservice.asmx')
      .to_return(body: AUTH_XML, status: 200).then
      .to_return(body: SECRET_XML, status: 200)

      client.get_username_and_password_and_save(1234, '.', 'zanziTestCreds')
      expect(File.exist? 'zanziTestCreds')
      expect(File.read('zanziTestCreds')).to eq({'username' => 'ZanziUser', 'password' => 'zanziUserPassword'}.to_yaml)
      File.delete('zanziTestCreds')
  end

  it 'should use environment variables for credentials' do
    ENV['ZANZIBAR_USER'] = 'environment_user'
    ENV['ZANZIBAR_PASSWORD'] = 'environment_password'
    client = Zanzibar::Zanzibar.new(domain: 'zanzitest.net', wsdl: 'spec/scrt.wsdl')
    expect(client.get_client_username).to eq(ENV['ZANZIBAR_USER'])
    expect(client.get_client_password).to eq(ENV['ZANZIBAR_PASSWORD'])
    ENV.delete 'ZANZIBAR_PASSWORD'
    ENV.delete 'ZANZIBAR_USER'
  end
end
