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
          qiita_trends_api_response = Api::Qiita::Trend.call
          qiita_trends_json = JSON.parse(qiita_trends_api_response.body)

          # トレンド上位5記事のみ抽出
          # TODO: そもそもの取得件数をAPI側で制御できないか
          message = 5.times.map do |i|
            {
              type: "text",
              text: qiita_trends_json[i]["node"]["linkUrl"]
            }
          end
          client.reply_message(event['replyToken'],  message)

        end
      end

      private

      def message_events
        events.select { |event| event.is_a?(Line::Bot::Event::Message) }
      end

    end
  end
end