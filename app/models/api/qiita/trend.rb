module Api
  module Qiita
    class Trend < Api::Qiita::Base
      API_PATH = '/trend'

      # TODO: うまいこと親から継承できないか
      def uri
        URI("#{API_HOST}#{API_PATH}")
      end

      def call
        Net::HTTP.get_response(uri)
      end

      class << self
        def call
          new.call
        end
      end

    end
  end
end