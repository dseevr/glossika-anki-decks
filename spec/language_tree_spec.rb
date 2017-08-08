#!/usr/bin/env ruby
# encoding: utf-8

require "language_tree"

LT = LanguageTree

RSpec.describe LT do

  describe ".character_percentile" do
    context "when the input is not a single character" do
      it "should raise an exception" do
        ["", "是的"].each do |input|
          expect { LT.character_percentile(input) }.to raise_error(ArgumentError)
        end
      end
    end

    context "when the input is not a chinese character" do
      it "should raise an exception" do
        expect { LT.character_percentile("a") }.to raise_error(NonChineseCharacterError)
      end
    end

    context "when the input character does not exist" do
      it "should have a score higher than the highest score" do
        char = "麤"

        expect(LT::COMMON_CHARACTERS.include?(char)).to be false

        expect(LT.character_percentile(char)).to be > LT::SCORE_MAX
      end
    end

    it "should return a score between MIN and MAX" do
      score = LT.character_percentile("是")

      expect(score).to be_a(Float)
      expect(score).to be >= LT::SCORE_MIN
      expect(score).to be <= LT::SCORE_MAX
    end

    it "should return scores that makes sense" do
      chars = LT::COMMON_CHARACTERS.take(10)

      sorted_chars = chars.reverse.sort_by { |c| LT.character_percentile(c) }

      expect(sorted_chars).to eq(chars)
    end
  end

  describe ".strip_punctuation" do
    it "should strip punctuation if present" do
      input = "你好"

      expect(LT.strip_punctuation(input)).to eq(input)
      expect(LT.strip_punctuation(input + "？。·「」")).to eq(input)
    end
  end

  describe ".score_for_sentence" do
    context "when the input is empty" do
      it "should raise an exception" do
        expect { LT.score_for_sentence("") }.to raise_error(ArgumentError)
      end
    end

    context "when the input is not empty" do
      it "should return a score between MIN and MAX" do
        score = LT.score_for_sentence("是的")

        expect(score).to be_a(Float)
        expect(score).to be >= LT::SCORE_MIN
        expect(score).to be <= LT::SCORE_MAX
      end

      it "should return a score that makes sense" do
        sentences = [
          "你 好",
          "我 不 知道",
          "我 的 中文 不 是 很 好。",
          "他 不 喜歡 吃 魚。",
          "廁所 在 哪裡？",
        ]

        sorted_sentences = sentences.reverse.sort_by { |s| LT.score_for_sentence(s) }

        expect(sorted_sentences).to eq(sentences)
      end
    end
  end

end
