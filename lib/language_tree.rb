#!/usr/bin/env ruby
# encoding: utf-8

require "bundler/setup"
require "tradsim"

def load_common_characters
  filename = "data/most_common_traditional_characters.txt"

  characters = File.read(filename).lines[1..-1].map { |l| Tradsim::to_trad(l.chars.first) }
  characters.zip((1..(characters.length)).to_a).to_h
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

  def self.character_percentile(input)
    ensure_chinese_characters(input)
    raise ArgumentError.new("must be one character") unless input.length == 1

    rank = character_rank(input)
    
    (rank.to_f / COMMON_CHARACTERS_TO_FREQUENCY[COMMON_CHARACTERS.last]) * 100
  end

  def self.character_rank(input)
    ensure_chinese_characters(input)

    rank = COMMON_CHARACTERS_TO_FREQUENCY[input]

    if rank
      rank
    else
      # unknown characters can't be classified, so we return an implausible rank
      COMMON_CHARACTERS.length + 1
    end
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

    score = 0

    # TODO: why doesn't inject work here?
    input.chars.uniq.each do |char|
      score += character_rank(char)
    end

    score.to_f
  end

end
