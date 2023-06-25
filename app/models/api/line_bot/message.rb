module Api
  module LineBot
    class Message < Api::LineBot::Base
      def initialize(event)
        super
        @event = event
      end

      class << self
        def call(event)
          new(event).call
        end
      end

      attr_accessor :event

      def call
        super
        return if message_events.length == 0
        message_events.each do |event|
          next if event.type != Line::Bot::Event::MessageType::Text
          message = {
            type: "text",
            text: event.message["text"]
          }
          client.reply_message(event['replyToken'], message)
        end
      end

      private

      def message_events
        events.select { |event| event.is_a?(Line::Bot::Event::Message) }
      end

    end
  end
end