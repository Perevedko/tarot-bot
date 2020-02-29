require './lib/reply_markup_formatter'
require './lib/app_configurator'
require './models/tarot_cache'

class MessageSender
  attr_reader :bot
  attr_reader :text
  attr_reader :chat
  attr_reader :answers
  attr_reader :logger
  attr_reader :tarot

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]
    @answers = options[:answers]
    @tarot = options[:tarot]
    @logger = AppConfigurator.new.get_logger
  end

  def send
    case
    when reply_markup
      bot.api.send_message(chat_id: chat.id, text: text, reply_markup: reply_markup)
    when tarot
      send_tarot_with_caching
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

  def send_tarot_with_caching
    cache_hit = TarotCache.find_by_filepath(tarot.image_location)
    photo = cache_hit&.photo_id || Faraday::UploadIO.new(tarot.image_location, 'image/jpeg')
    response = bot.api.send_photo(chat_id: chat.id, photo: photo)
    if !cache_hit && response["ok"]
      largest_photo = response['result']['photo'].max_by { |photo| photo['file_size'] }
      TarotCache.create(filepath: tarot.image_location, photo_id: largest_photo['file_id'])
    end
  end
end
