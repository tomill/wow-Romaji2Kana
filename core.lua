-- "Romaji Translator" addon by tomill
local addon = LibStub("AceAddon-3.0"):NewAddon("Romaji Translator")

function addon:OnInitialize()
    local defaults = {
        profile = {
            whisper = false,
            guild = true,
            party = false,
            instance = false,
            say = false,
        }
    }

    local options = {
        type = "group",
        args = {}
    }

    local setter = function(info, val) addon.db.profile[ info[#info] ] = val end
    local getter = function(info) return addon.db.profile[ info[#info] ] end
    for k, v in pairs(defaults.profile) do
        local label = k:gsub("^%l", string.upper)
        options.args[k] = {
            type = "toggle",
            name = "Enable on [" .. label .. "] chat message.",
            desc = "check suru to, [" .. label .. "] chat de ON desu.",
            width = "full",
            set = setter,
            get = getter,
        }
    end
    
    self.enabled = true
    self.db = LibStub("AceDB-3.0"):New("Romaji2KanaDB", defaults)
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name)
end


SLASH_ROMAJI2KANA1 = "/romakana"
SLASH_ROMAJI2KANA2 = "/romakana"
SlashCmdList["ROMAJI2KANA"] = function (opt)
    opt = string.lower(opt)

    if opt == "on" then
        addon.enabled = true
        DEFAULT_CHAT_FRAME:AddMessage(addon.name .. ": enabled", 1, 1, 1)
    elseif opt == "off" then
        addon.enabled = false
        DEFAULT_CHAT_FRAME:AddMessage(addon.name .. ": temporary disabled", 1, 1, 1)
    else
        DEFAULT_CHAT_FRAME:AddMessage(addon.name .. ": help", 1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage("/romakana off - disable in this login session", 1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage("/romakana on - enable in this login session", 1, 1, 1)
    end
end

local kanamap = {
    ["bya"] = "びゃ",   ["byo"] = "びょ",   ["byu"] = "びゅ",
    ["cha"] = "ちゃ",   ["chi"] = "ち", ["cho"] = "ちょ",   ["chu"] = "ちゅ",
    ["dya"] = "ぢゃ",
    ["gya"] = "ぎゃ",   ["gyo"] = "ぎょ",   ["gyu"] = "ぎゅ",
    ["hya"] = "ひゃ",   ["hyo"] = "ひょ",   ["hyu"] = "ひゅ",
    ["kya"] = "きゃ",   ["kyo"] = "きょ",   ["kyu"] = "きゅ",
    ["mya"] = "みゃ",   ["myo"] = "みょ",   ["myu"] = "みゅ",
    ["nya"] = "にゃ",   ["nyo"] = "にょ",   ["nyu"] = "にゅ",
    ["rya"] = "りゃ",   ["ryo"] = "りょ",   ["ryu"] = "りゅ",
    ["sha"] = "しゃ",
    ["shi"] = "し", ["sho"] = "しょ",   ["shu"] = "しゅ",
    ["sya"] = "しゃ",   ["syo"] = "しょ",   ["syu"] = "しゅ",
    ["tsu"] = "つ",
    ["tya"] = "ちゃ",   ["tyo"] = "ちょ",   ["tyu"] = "ちゅ",
    
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
    ["wa"] = "わ",  ["wo"] = "を",
    ["ya"] = "や",  ["yo"] = "よ",  ["yu"] = "ゆ",
    ["za"] = "ざ",  ["ze"] = "ぜ",  ["zi"] = "じ",  ["zo"] = "ぞ",  ["zu"] = "ず",
    
    ["a"] = "あ",   ["e"] = "え",   ["i"] = "い",   ["o"] = "お",   ["u"] = "う",
}


local function convertWord(original)
    local word = string.lower(original)

    if string.match(word, "^[(<%[].*[)>%]]$") then
        return original
    end
    
    if ROMAJI2KANA_STOPWORDS[ string.gsub(word, "%A", "") ] then
        return original
    end

    word = string.gsub(word, "(w+)$", function(w)
        local www = ""
        for i = 1, #w do
            www = www .. "ｗ"
        end
        return www
    end)

    word = string.gsub(word, "([bcdfghjkprstwyz])%1", "っ%1")
    word = string.gsub(word, "([bcdghkmnprst][hsy][aeiou])", function(w) return kanamap[w] end)
    word = string.gsub(word, "([bdfghjkmnprstwyz][aeiou])", function(w) return kanamap[w] end)
    word = string.gsub(word, "([aeiou])", function(w) return kanamap[w] end)
    word = string.gsub(word, "nn?", "ん")

    if string.match(word, "%a") then
        return original
    end
    
    return word
end

local function convertMessage(msg)
    if not string.find(msg, "^[%a%d%s%p]+$") then
        return msg -- already includes non ascii. maybe kana. just skip
    end
    
    local res
    local count = { ["word"] = 0, ["kana"] = 0 }
    for word in string.gmatch(msg, "%S+") do
        local kana = convertWord(word)

        count.word = count.word + 1
        if kana ~= word then
            count.kana = count.kana + 1
        end

        if res then
            res = res .. " " .. kana
        else
            res = kana
        end
    end
    
    if count.kana == 0 then
        return msg -- something failed
    elseif ( count.kana / count.word ) <= 0.2 then
        return msg -- something failed
    else
        return string.format("%s (%s)", msg, res)
    end
end

local function hookMessage(self, event, msg, ...)
    if not addon.enabled then
        return
    end

    if (event == "CHAT_MSG_WHISPER" and addon.db.profile.whisper) or
        (event == "CHAT_MSG_SAY" and addon.db.profile.say) or
        (event == "CHAT_MSG_GUILD" and addon.db.profile.guild) or
        (event == "CHAT_MSG_PARTY" and addon.db.profile.party) or
        (event == "CHAT_MSG_PARTY_LEADER" and addon.db.profile.party) or
        (event == "CHAT_MSG_RAID" and addon.db.profile.instance) or
        (event == "CHAT_MSG_RAID_LEADER" and addon.db.profile.instance) or
        (event == "CHAT_MSG_INSTANCE_CHAT" and addon.db.profile.instance) or
        (event == "CHAT_MSG_RAID_WARNING" and addon.db.profile.instance) or
        (event == "CHAT_MSG_INSTANCE_CHAT_LEADER" and addon.db.profile.instance) then
        return false, convertMessage(msg), ...
    end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", hookMessage)
