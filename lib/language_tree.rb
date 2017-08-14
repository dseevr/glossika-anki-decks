#!/usr/bin/env ruby
# encoding: utf-8

require "bundler/setup"
require "tradsim"

def load_common_characters
  filename = "data/most_common_traditional_characters.txt"

  # read the first character of each line (skipping the first line) and
  # turn each one into a hash key with the associated frequency as its value.
  # (the file is already sorted by frequency)
  File.read(filename).lines[1..-1].each.with_index(1).map do |a, b|
    [Tradsim::to_trad(a.chars.first), b]
  end.to_h
end

class NonChineseCharacterError < Exception; end

class LanguageTree

  CHINESE_REGEX = /[\u3400-\u9FBF]/
  NON_CHINESE_REGEX = /[^\u3400-\u9FBF]/

  COMMON_CHARACTERS_TO_FREQUENCY = load_common_characters
  COMMON_CHARACTERS = COMMON_CHARACTERS_TO_FREQUENCY.keys

  PUNCTUATION = "()！？。·「」、，—" + "?" + " " # english ? and trailing space

  SCORE_MIN = 0.0
  SCORE_MAX = 100.0

  UNKNOWN_CHARACTER_SCORE = COMMON_CHARACTERS.length + 1

  def self.character_percentile(input)
    ensure_chinese_characters(input)
    raise ArgumentError.new("must be one character") unless input.length == 1

    (character_rank(input).to_f / COMMON_CHARACTERS_TO_FREQUENCY[COMMON_CHARACTERS.last]) * 100
  end

  def self.character_rank(input)
    ensure_chinese_characters(input)

    COMMON_CHARACTERS_TO_FREQUENCY[input] || UNKNOWN_CHARACTER_SCORE
  end

  def self.ensure_chinese_characters(input)
    position = input =~ NON_CHINESE_REGEX

    if position
      msg = [
        "input contained non-chinese characters starting at index #{position}",
        "(\"#{input[position]}\") - Full input: #{input}"
      ]

      raise NonChineseCharacterError.new(msg.join(" "))
    else
      true
    end
  end

  def self.strip_punctuation(input)
    input.tr(PUNCTUATION, "")
  end

  # TODO: improve this function to make it support words (grouped characters).
  #       words composed of two or more characters will need to have a penalty
  #       attached to them so that sentences with only single character words
  #       and particles show up first.
  def self.score_for_sentence(input)
    input = strip_punctuation(input).gsub(NON_CHINESE_REGEX, "")

    ensure_chinese_characters(input)
    raise ArgumentError.new("must not be empty") if input.empty?

    input.chars.uniq.map(&method(:character_rank)).inject(:+).to_f
  end

end
