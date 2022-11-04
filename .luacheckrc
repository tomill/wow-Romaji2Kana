std = "lua51"
max_line_length = false

ignore = {
	"212", -- Unused argument
	"213", -- Unused loop variable
	"214", -- unused hint
}

globals = {
	"LibStub",
	"SlashCmdList",
	"ChatFrame_AddMessageEventFilter",
	"DEFAULT_CHAT_FRAME",
	"SLASH_ROMAJI2KANA1",
	"SLASH_ROMAJI2KANA2",
	"ROMAJI2KANA_STOPWORDS",
}
