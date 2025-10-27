# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Markawesome do
  it 'has a version number' do
    expect(Markawesome::VERSION).not_to be nil
    expect(Markawesome::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  describe '.configure' do
    after do
      # Reset configuration after each test
      Markawesome.configuration = nil
    end

    it 'allows configuration via block' do
      Markawesome.configure do |config|
        config.callout_icons = { info: 'info-circle' }
      end

      expect(Markawesome.configuration.callout_icons[:info]).to eq('info-circle')
    end

    it 'creates default configuration' do
      config = Markawesome.configure

      expect(config.callout_icons).to be_a(Hash)
      expect(config.callout_icons[:info]).to eq('circle-info')
      expect(config.callout_icons[:success]).to eq('circle-check')
      expect(config.callout_icons[:warning]).to eq('triangle-exclamation')
      expect(config.callout_icons[:danger]).to eq('circle-exclamation')
    end

    it 'allows custom components configuration' do
      Markawesome.configure do |config|
        config.custom_components = { 'my-component' => 'MyComponent' }
      end

      expect(Markawesome.configuration.custom_components['my-component']).to eq('MyComponent')
    end

    it 'persists configuration across calls' do
      Markawesome.configure do |config|
        config.callout_icons = { info: 'custom-icon' }
      end

      expect(Markawesome.configuration.callout_icons[:info]).to eq('custom-icon')

      # Second configure call should use same instance
      Markawesome.configure do |config|
        config.custom_components = { 'test' => 'Test' }
      end

      expect(Markawesome.configuration.callout_icons[:info]).to eq('custom-icon')
      expect(Markawesome.configuration.custom_components['test']).to eq('Test')
    end
  end

  describe Markawesome::Configuration do
    subject(:config) { described_class.new }

    it 'has default callout icons' do
      expect(config.callout_icons).to be_a(Hash)
      expect(config.callout_icons.keys).to contain_exactly(:info, :success, :neutral, :warning, :danger)
    end

    it 'has empty custom components by default' do
      expect(config.custom_components).to eq({})
    end

    it 'allows setting callout icons' do
      config.callout_icons = { info: 'new-icon' }
      expect(config.callout_icons[:info]).to eq('new-icon')
    end

    it 'allows setting custom components' do
      config.custom_components = { 'component' => 'Component' }
      expect(config.custom_components['component']).to eq('Component')
    end
  end
end
