require 'zanzibar/cli'
require 'zanzibar/defaults'
require 'rspec'
require 'fakefs/spec_helpers'

describe Zanzibar::Cli do
  include FakeFS::SpecHelpers

  describe '#init' do
    before(:each) do
      templates_root = File.join(source_root, 'templates')
      FakeFS::FileSystem.clone templates_root
    end

    context 'when a file does not yet exist' do
      it 'should create a template file' do
        expect { subject.init }.to output(/has been created/).to_stdout
        expect(FakeFS::FileTest.file? Zanzibar::ZANZIFILE_NAME).to be(true)
        expect(File.read Zanzibar::ZANZIFILE_NAME).to match(/fill in your secrets/)
      end

      it 'should accept settings as options' do
        subject.options = { 'wsdl' => 'http://example.com/ss?wsdl',
                            'domain' => 'example.com',
                            'secretdir' => 'testfolderplzignore',
                            'ignoressl' => true }

        expect { subject.init }.to output(/has been created/).to_stdout
        contents = File.read Zanzibar::ZANZIFILE_NAME
        expect(contents).to include('wsdl: http://example.com/ss?wsdl')
        expect(contents).to include('domain: example.com')
        expect(contents).to include('secret_dir: testfolderplzignore')
        expect(contents).to include('ignore_ssl: true')
      end
    end

    context 'when a file already exists' do
      before(:each) { File.write(Zanzibar::ZANZIFILE_NAME, 'test value') }

      it 'should not overwrite an existing file' do
        expect { subject.init }.to raise_error.with_message(/#{Zanzibar::ALREADY_EXISTS_ERROR}/)
        expect(File.read Zanzibar::ZANZIFILE_NAME).to eq('test value')
      end

      it 'should obey the force flag' do
        subject.options = { 'force' => true }

        expect { subject.init }.to output(/has been created/).to_stdout
        expect(File.read Zanzibar::ZANZIFILE_NAME).to match('fill in your secrets')
      end
    end
  end
end
