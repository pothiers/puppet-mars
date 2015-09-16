require 'spec_helper'
describe 'mars' do

  context 'with defaults for all parameters' do
    it { should contain_class('mars') }
  end
end
