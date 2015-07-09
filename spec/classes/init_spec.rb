require 'spec_helper'
describe 'config_core' do

  context 'with defaults for all parameters' do
    it { should contain_class('config_core') }
  end
end
