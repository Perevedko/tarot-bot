require './lib/reply_markup_formatter'
require './lib/app_configurator'

class MessageSender
  attr_reader :bot
  attr_reader :text
  attr_reader :chat
  attr_reader :answers
  attr_reader :logger
  attr_reader :image

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]
    @answers = options[:answers]
    @image = options[:image]
    @logger = AppConfigurator.new.get_logger
  end

  def send
    case
    when reply_markup
      bot.api.send_message(chat_id: chat.id, text: text, reply_markup: reply_markup)
    when image
      bot.api.send_photo(chat_id: chat.id, photo: Faraday::UploadIO.new(image, 'image/jpeg'))
    else
      bot.api.send_message(chat_id: chat.id, text: text)
    end

    logger.debug "sending '#{text}' to #{chat.username}"
  end

  private

  def reply_markup
    if answers
      ReplyMarkupFormatter.new(answers).get_markup
    end
  end
end
