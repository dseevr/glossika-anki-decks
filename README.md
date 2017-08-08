# Glossika Anki Decks

This is some crappy Ruby code I wrote to parse PDFs from [Glossika](https://glossika.com/) and turn them into Anki decks for personal use.

It generates two decks:

### Chinese -> English/Chinese/Pinyin

These are straight from the PDF in the order they appear.

### Chinese character -> Chinese/Pinyin/English

This is a bit of a mouthful:  this deck has all the traditional chinese characters in order by frequency of appearance in Chinese texts on the front, and it has the simplest (as determined by a crappy scoring function) Chinese sentence in the corpus of Glossika sentences containing that character on the back.

See my other repo for the source data for this:  https://github.com/dseevr/anki-decks-for-the-most-common-chinese-characters

## Why did you make this?

Because I've discovered that learning characters/words/tones/meanings without context is _impossible_ and SRS is _wonderful_ for helping you remember things.  Glossika's product is great on its own, but I want to learn to read Chinese and it's not designed to teach that.

## Why does this only support the Taiwan Mandarin PDFs?

Because [TAIWAN NUMBAH ONE!!!](https://www.youtube.com/watch?v=xN0vUlljX0I)

It could support other PDF types, but you'd need to modify a ton of code.  You'd honestly be better off using this project as a guide and writing your own from scratch.

## License

BSD
