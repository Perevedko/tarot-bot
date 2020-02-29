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

  def send_tarot_images
    Tarot.full_deck.sample(3).map(&:image_location).map do |image_path|
      answer_with_image(image_path)
    end
  end

  def answer_with_image(image_path)
    MessageSender.new(bot: bot, chat: message.chat, image: image_path).send
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end
end
