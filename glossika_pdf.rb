# coding: utf-8

require "pdf-reader"

class SentencePair

  ENGLISH_PUNCTUATION = %w_! ? . ] )_ # some legitimately end with ) or ]
  CHINESE_PUNCTUATION = %w_！ ？ 。 ?_ # english question mark is sometimes used

  attr_reader :english, :chinese, :pinyin

  def initialize(english, chinese, pinyin)
    @english = english.strip.gsub("\n", " ")
    @chinese = chinese.strip.gsub("\n", " ")
    @pinyin  = pinyin.strip.gsub("\n", " ")

    # some sentences forget the period outright
    @english += "." if @english =~ /[a-z]\z/

    unless ENGLISH_PUNCTUATION.include?(@english.chars.last)
      raise "unexpected english punctuation: #{@english.chars.last} in sentence: #{@english}"
    end

    unless CHINESE_PUNCTUATION.include?(@chinese.chars.last)
      raise "unexpected chinese punctuation: #{@chinese.chars.last} in sentence: #{@chinese}"
    end

  end

end


class GlossikaPDFParser

  ZH_DELIMITER = "繁".freeze

  def initialize(path, start_page, end_page)
    raise ArgumentError.new("start_page must be <= end_page") unless start_page <= end_page

    @reader = PDF::Reader.new(path)
    @start_page = start_page
    @end_page = end_page
  end

  def sentence_pairs
    Enumerator.new do |enum|
      (@start_page..@end_page).each do |page_number|

        text = @reader.pages[page_number].text.lines.map(&:strip).reject(&:empty?).join("\n")

        english = text.scan(/EN(?!ZT)\s*?(.+?)\n[^\w]/m)
        chinese = text.scan(/#{ZH_DELIMITER}\s*?(.+?)\nPIN/m)
        pinyin  = text.scan(/PIN\s*?(.+?)\nIPA/m)

        unless english.size == chinese.size && chinese.size == pinyin.size
          raise "bad sizes: #{english.size}, #{chinese.size}, #{pinyin.size}"
        end

        if [english.size, chinese.size, pinyin.size].any?(&:zero?)
          raise "unexpected 0 value: #{english.size}, #{chinese.size}, #{pinyin.size}"
        end

        [english, chinese, pinyin].map(&:flatten).transpose.each do |e, c, p|
          enum.yield SentencePair.new(e, c, p)
        end
      end
    end
  end
  
end
