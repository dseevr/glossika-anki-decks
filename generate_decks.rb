#!/usr/bin/env ruby
# coding: utf-8

require "bundler/setup"
require "anki"

require_relative "glossika_pdf"
require_relative "lib/language_tree"

HEADERS = %w[front back]


def generate_sentence_deck(parsers, output_filename)
  cards = []

  parsers.each do |parser|
    parser.sentence_pairs.each do |sentence|
      cards << {
        "front" => sentence.chinese,
        "back" =>  [sentence.english, sentence.chinese, sentence.pinyin].join("<br /><br />"),
      }
    end
  end

  deck = Anki::Deck.new(card_headers: HEADERS, card_data: cards, field_separator: "|")
  deck.generate_deck(file: output_filename)

  puts "Wrote #{output_filename}"
end

def generate_frequency_deck(parsers, output_filename, character_count)

  puts "Loading and sorting sentences by score"

  sentences = []

  parsers.each do |parser|
    parser.sentence_pairs.each do |sp|
      sentences << {
        score: LanguageTree.score_for_sentence(sp.chinese),
        data: sp,
      }
    end
  end

  sentences = sentences.sort_by { |s| s[:score] }

  puts "Loaded #{sentences.length} sentences"

  puts "Building cards by iterating over #{character_count} characters"

  cards = []

  skipped = []

  LanguageTree::COMMON_CHARACTERS.take(character_count).each do |char|

    s = nil

    # find the first sentence in the sorted array which contains this character
    sentences.each do |sentence|
      chars = sentence[:data].chinese.chars

      # skip single character sentences
      if chars.length > 1 && chars.include?(char)
        s = sentence
        break
      end
    end

    # if we don't find a match, record it and move on
    unless s
      skipped << char
      next
    end

    cards << {
      "front" => char,
      "back" =>  [
        s[:data].chinese,
        s[:data].pinyin,
        s[:data].english
      ].join("<br /><br />"),
    }
  end

  puts "Skipped #{skipped.length} characters"
  File.write("skipped.txt", skipped.join("\n"))

  deck = Anki::Deck.new(card_headers: HEADERS, card_data: cards, field_separator: "|")
  deck.generate_deck(file: output_filename)

  puts "Wrote #{output_filename}"
end


if __FILE__ == $PROGRAM_NAME
  filenames = (1..3).map { |n| "/home/bill/Desktop/glossika/ENZT-F123-EBK/GLOSSIKA-ENZT-F#{n}-EBK.pdf" }
  start_pages = [35, 36, 36]
  end_pages = [305, 334, 356]

  parsers = []

  [filenames, start_pages, end_pages].transpose.each do |filename, start_page, end_page|
    parsers << GlossikaPDFParser.new(filename, start_page, end_page)
  end

  generate_sentence_deck(parsers, "sentences_deck.txt")

  generate_frequency_deck(parsers, "frequency_deck.txt", 9999) # all ~3000 characters
end
