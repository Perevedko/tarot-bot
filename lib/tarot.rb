IMAGES_DIR = File.expand_path('./rider-waite/')

SUITS = %i(wands cups swords pentacles)
RANKS = %i(ace page knight queen king) + (2..10).map(&:to_s).map(&:to_sym)
MAJOR = (0..21).map(&:to_s).map(&:to_sym)

class Major
  attr_accessor :number

  def initialize(number)
    raise ArgumentError("#{number} is wrong for major arcana") unless MAJOR.include?(number.to_s.to_sym)

    @number = number
  end

  def image_location
    @image_location ||= File.join(IMAGES_DIR, 'major', "#{number}.jpg")
  end

  def inspect
    "<Major Arcana: number #{number}>"
  end

  def self.all_cards
    @@all_cards ||= MAJOR.map { |num| new(num) }.freeze
  end
end

class Minor
  attr_accessor :suit, :rank

  def initialize(rank:, of:)
    errors = []
    errors << "rank #{rank} is wrong for minor arcana" unless RANKS.include?(rank.to_s.to_sym)
    errors << "suit #{of} is wrong for minor arcana" unless SUITS.include?(of.to_s.to_sym)
    raise ArgumentError(errors.join("\n")) if errors.present?

    @suit = of
    @rank = rank
  end

  def image_location
    @image_location ||= File.join(IMAGES_DIR, suit.to_s, "#{rank}.jpg")
  end

  def inspect
    "<Minor Arcana: #{rank} of #{suit}>"
  end

  def self.all_cards
    @@all_cards ||= SUITS.product(RANKS).map { |suit, rank| new(rank: rank, of: suit) }.freeze
  end
end

class Tarot
  def self.full_deck
    @@full_deck ||= (Major.all_cards + Minor.all_cards).freeze
  end
end