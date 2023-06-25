class LineBotController < ApplicationController
  def callback
    body = request.body.read
    Api::LineBot::Message.call(body)
  end
end
