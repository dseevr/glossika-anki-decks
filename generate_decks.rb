#!/usr/bin/env ruby
# coding: utf-8

require "bundler/setup"
require "anki"

require_relative "glossika_pdf"

HEADERS = %w[front back]


def generate_sentence_deck(parser, output_filename)
  cards = []

  parser.sentence_pairs.each do |sentence|
    cards << {
      "front" => sentence.chinese,
      "back" =>  [sentence.english, sentence.chinese, sentence.pinyin].join("<br /><br />"),
    }
  end

  deck = Anki::Deck.new(card_headers: HEADERS, card_data: cards, field_separator: "|")
  deck.generate_deck(file: output_filename)

  puts "wrote #{output_filename}"
end


if __FILE__ == $PROGRAM_NAME
  input_filename = "/home/bill/Desktop/glossika/ENZT-F123-EBK/GLOSSIKA-ENZT-F1-EBK.pdf"
  start_page = 35
  end_page = 305

  parser = GlossikaPDFParser.new(input_filename, start_page, end_page)

  generate_sentence_deck(parser, "sentences_deck.txt")
end
