# frozen_string_literal: true

require "ductr"

require_relative "environment/#{Ductr.env}"

Dir[File.join(__dir__, "initializers", "*.rb")].each { |file| require file }
