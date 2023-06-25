module Api
  module LineBot
    class Base
      def initialize(body)
        @events = client.parse_events_from(body)
      end

      attr_accessor :events

      def call
        return if events.length == 0
      end

      def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
      end
    end
  end
end