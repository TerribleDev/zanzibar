require 'zanzibar/cli'
require 'zanzibar/version'
require 'zanzibar/defaults'
require 'rspec'

describe Zanzibar::Cli do
  describe '#version' do
    it 'should print the gem version' do
      expect { subject.version }.to output(/#{Zanzibar::APPLICATION_NAME} Version/).to_stdout
    end
  end
end
