require './models/user'
require './lib/message_sender'
require './lib/tarot'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id)
  end

  def respond
    on %r{^/start} do
      answer_with_greeting_message
    end

    on %r{^/stop} do
      answer_with_farewell_message
    end

    on %r{^/tarot} do
      send_tarot_images
    end

    on %r{^/cards (\d+)} do |number|
      n = Integer(number) rescue nil
      if n && 1 <= n && n <= Tarot.full_deck.count
        send_tarot_images(n)
      else
        answer_with_argument_error_message
      end
    end
  end

  private

  def on(regex, &block)
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_argument_error_message
    answer_with_message I18n.t('argument_error_message')
  end

  def send_tarot_images(n = 3)
    Tarot.full_deck.sample(n).map do |card|
      send_tarot(card)
    end
  end

  def send_tarot(card)
    MessageSender.new(bot: bot, chat: message.chat, tarot: card).send
  end

  def answer_with_image(image_path)
    MessageSender.new(bot: bot, chat: message.chat, image: image_path).send
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end
end
