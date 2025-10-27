# frozen_string_literal: true

require_relative 'markawesome/version'
require_relative 'markawesome/transformer'

# Main module for Markawesome - framework-agnostic Markdown to Web Awesome component transformer
module Markawesome
  class Error < StandardError; end

  # Configuration options
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      configuration
    end
  end

  # Configuration class for customizing transformations
  class Configuration
    attr_accessor :callout_icons, :custom_components

    def initialize
      @callout_icons = default_callout_icons
      @custom_components = {}
    end

    private

    def default_callout_icons
      {
        info: 'circle-info',
        success: 'circle-check',
        neutral: 'gear',
        warning: 'triangle-exclamation',
        danger: 'circle-exclamation'
      }
    end
  end
end
