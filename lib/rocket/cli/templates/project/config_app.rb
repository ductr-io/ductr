# frozen_string_literal: true

require_relative "environment/#{Rocket.config.env}"

Rocket.logger.info("Rocket is running in #{Rocket.config.env} mode")
Rocket.logger.info("Rocket root is #{Rocket.config.root}")
Rocket.logger.info("Config vars: #{Rocket.config.yml.to_h}")
