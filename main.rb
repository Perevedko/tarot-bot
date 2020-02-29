# frozen_string_literal: true

require 'yaml'
require 'pry'
require 'telegram/bot'

CONFIG = YAML.load_file('config.yml')

Telegram::Bot::Client.run(CONFIG['token']) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    end
  end
end
