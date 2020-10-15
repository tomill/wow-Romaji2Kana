# Warcraft Addon: Romaji Translator

Translate chat message: Japanese Romaji to Hiragana

* https://wow.curseforge.com/projects/romaji2kana

---

This addon is for Japanese chat messaging. Show Hiragana text from Romaji.

    [Tomill] konnichiwa
      to
    [Tomill] konnichiwa (こんにちわ)

- Requires Unicode font.
- This addon don't touch outgoing message.
- You can set default enable/disable setting in Menu > Interface > Addon > Romaji Translator.
- Type `/romakana off` command to temporary disable this addon.
- Type `/romakana on` to enable again.

[Nihongo setumei page（日本語の説明ページ）](http://wp.me/pRxTt-1aK)

Changes:

1.9.0

- update for 9.0.x, Shadowlands

1.8.0

- update for 8.0.x
- skip the word beginning with uppercase. `Pandaria ha panda no shima` => `Pandaria は ぱんだ の しま`
- added `w` support. try this => `ukeruwww`
- removed `moo` rule for Tauren (sorry). now `もお`.
- renamed "Romaji Translator" from "Romaji2kana" :D
