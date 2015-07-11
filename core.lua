local addon = LibStub("AceAddon-3.0"):NewAddon("Romaji2Kana")

local setter = function(info, val) addon.db.profile[ info[#info] ] = val end
local getter = function(info) return addon.db.profile[ info[#info] ] end

local defaults = {
    profile = {
        whisper = false,
        guild = true,
        party = false,
        raid = false,
    }
}

local options = {
    type = "group",
    args = {}
}

for k, v in pairs(defaults.profile) do
    local label = k:gsub("^%l", string.upper)
    options.args[k] = {
        type = "toggle",
        name = "Enable [" .. label .. "] chat message.",
        desc = "check suru to [" .. label .. "] chat de yuu kou desu.",
        width = "full",
        set = setter,
        get = getter,
    }
end

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(self.name .. "DB", defaults)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name)
end

local kanamap = {
    ["bya"] = "びゃ",   ["byo"] = "びょ",   ["byu"] = "びゅ",
    ["cha"] = "ちゃ",   ["che"] = "ちぇ",   ["chi"] = "ち", ["cho"] = "ちょ",   ["chu"] = "ちゅ",
    ["dya"] = "ぢゃ",
    ["gya"] = "ぎゃ",   ["gyo"] = "ぎょ",   ["gyu"] = "ぎゅ",
    ["hya"] = "ひゃ",   ["hyo"] = "ひょ",   ["hyu"] = "ひゅ",
    ["kya"] = "きゃ",   ["kyo"] = "きょ",   ["kyu"] = "きゅ",
    ["mya"] = "みゃ",   ["myo"] = "みょ",   ["myu"] = "みゅ",
    ["nya"] = "にゃ",   ["nyo"] = "にょ",   ["nyu"] = "にゅ",
    ["pya"] = "ぴゃ",   ["pyo"] = "ぴょ",   ["pyu"] = "ぴゅ",
    ["rya"] = "りゃ",   ["ryo"] = "りょ",   ["ryu"] = "りゅ",
    ["sha"] = "しゃ",
    ["shi"] = "し", ["sho"] = "しょ",   ["shu"] = "しゅ",
    ["sya"] = "しゃ",   ["syo"] = "しょ",   ["syu"] = "しゅ",
    ["tsu"] = "つ",
    ["tya"] = "ちゃ",   ["tye"] = "ちぇ",   ["tyo"] = "ちょ",   ["tyu"] = "ちゅ",
    
    ["ba"] = "ば",  ["be"] = "べ",  ["bi"] = "び",  ["bo"] = "ぼ",  ["bu"] = "ぶ",
    ["da"] = "だ",  ["de"] = "で",  ["di"] = "でぃ",    ["do"] = "ど",  ["du"] = "どぅ",
    ["fu"] = "ふ",
    ["ga"] = "が",  ["ge"] = "げ",  ["gi"] = "ぎ",  ["go"] = "ご",  ["gu"] = "ぐ",
    ["ha"] = "は",  ["he"] = "へ",  ["hi"] = "ひ",  ["ho"] = "ほ",  ["hu"] = "ふ",
    ["ja"] = "じゃ",    ["ji"] = "じ",  ["jo"] = "じょ",    ["ju"] = "じゅ",
    ["ka"] = "か",  ["ke"] = "け",  ["ki"] = "き",  ["ko"] = "こ",  ["ku"] = "く",
    ["ma"] = "ま",  ["me"] = "め",  ["mi"] = "み",  ["mo"] = "も",  ["mu"] = "む",
    ["na"] = "な",  ["ne"] = "ね",  ["ni"] = "に",  ["no"] = "の",  ["nu"] = "ぬ",
    ["pa"] = "ぱ",  ["pe"] = "ぺ",  ["pi"] = "ぴ",  ["po"] = "ぽ",  ["pu"] = "ぷ",
    ["ra"] = "ら",  ["re"] = "れ",  ["ri"] = "り",  ["ro"] = "ろ",  ["ru"] = "る",
    ["sa"] = "さ",  ["se"] = "せ",  ["si"] = "し",  ["so"] = "そ",  ["su"] = "す",
    ["ta"] = "た",  ["te"] = "て",  ["ti"] = "ち",    ["to"] = "と",  ["tu"] = "つ",
    ["va"] = "ば",    ["ve"] = "べ",    ["vi"] = "び",    ["vo"] = "ぼ",    ["vu"] = "ヴ",
    ["wa"] = "わ",  ["wo"] = "を",
    ["ya"] = "や",  ["yo"] = "よ",  ["yu"] = "ゆ",
    ["za"] = "ざ",  ["ze"] = "ぜ",  ["zi"] = "じ",  ["zo"] = "ぞ",  ["zu"] = "ず",
    
    ["a"] = "あ",   ["e"] = "え",   ["i"] = "い",   ["o"] = "お",   ["u"] = "う",
}

local template = "%s (%s)"
local function kanaConvert(msg)
    if not string.find(msg, "^[%a%d%s%p]+$") then
        return msg -- includes non ascii. maybe kana. just skip
    end
    
    local kana = string.lower(msg)
    kana = string.gsub(kana, "([bcdfghjklpqrstvwxyz])%1", "っ%1")
    kana = string.gsub(kana, "([bcdghkmnprst][hsy][aeiou])", function(w) return kanamap[w] end)
    kana = string.gsub(kana, "([bdfghjkmnprstvwyz][aeiou])", function(w) return kanamap[w] end)
    kana = string.gsub(kana, "([aeiou])", function(w) return kanamap[w] end)
    kana = string.gsub(kana, "nn?", "ん")
    
    if msg == kana then
        return msg -- something failed
    else
        return string.format(template, msg, kana)
    end
end

-- hook whisper
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(self, event, msg, ...)
    if addon.db.profile.whisper then
        return false, kanaConvert(msg), ...
    end
end)


-- hook guild
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", function(self, event, msg, ...)
    if addon.db.profile.guild then
        return false, kanaConvert(msg), ...
    end
end)


-- hook party
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", function(self, event, msg, ...)
    if addon.db.profile.party then
        return false, kanaConvert(msg), ...
    end
end)

ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", function(self, event, msg, ...)
    if addon.db.profile.party then
        return false, kanaConvert(msg), ...
    end
end)

-- hook raid
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", function(self, event, msg, ...)
    if addon.db.profile.raid then
        return false, kanaConvert(msg), ...
    end
end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", function(self, event, msg, ...)
    if addon.db.profile.raid then
        return false, kanaConvert(msg), ...
    end
end)