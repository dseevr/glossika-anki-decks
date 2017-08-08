#!/usr/bin/env ruby
# coding: utf-8

require "bundler/setup"
require_relative "glossika_pdf"

INPUT_FILE = "/home/bill/Desktop/glossika/ENZT-F123-EBK/GLOSSIKA-ENZT-F1-EBK.pdf".freeze
START_PAGE = 35
END_PAGE = 305

GlossikaPDFParser.new(INPUT_FILE, START_PAGE, END_PAGE).sentence_pairs.each.with_index(1) do |sp, i|
  puts "##{i}"
  puts "English: #{sp.english}"
  puts "Chinese: #{sp.chinese}"
  puts "Pinyin: #{sp.pinyin}"
  puts
end
