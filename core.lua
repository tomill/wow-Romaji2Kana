local addon = LibStub("AceAddon-3.0"):NewAddon("Romaji2Kana")

function addon:OnInitialize()
    local defaults = {
        profile = {
            whisper = false,
            guild = true,
            party = false,
            instance = false,
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
            name = "Enable [" .. label .. "] chat message.",
            desc = "check suru to, [" .. label .. "] chat de yuu kou.",
            width = "full",
            set = setter,
            get = getter,
        }
    end
    
    self.enabled = true
    self.db = LibStub("AceDB-3.0"):New(self.name .. "DB", defaults)
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name)
end


SLASH_ROMAJI2KANA1 = "/romakana"
SLASH_ROMAJI2KANA2 = "/romakana"
SlashCmdList["ROMAJI2KANA"] = function (opt)
    opt = string.lower(opt)

    if opt == "on" then
        addon.enabled = true
        DEFAULT_CHAT_FRAME:AddMessage("Romaji2Kana: enabled", 1, 1, 1)
    elseif opt == "off" then
        addon.enabled = false
        DEFAULT_CHAT_FRAME:AddMessage("Romaji2Kana: temporary disabled", 1, 1, 1)
    else
        DEFAULT_CHAT_FRAME:AddMessage("/romakana off - temporary disabled Romaji2Kana", 1, 1, 1)
        DEFAULT_CHAT_FRAME:AddMessage("/romakana on - enable Romaji2Kana", 1, 1, 1)
    end
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
    ["fa"] = "ふぁ", ["fe"] = "ふぇ", ["fi"] = "ふぃ", ["fo"] = "ふぉ", ["fu"] = "ふ",
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

-- freq words and looks like romaji
local stopwords = {
    ["aadara"] = 1,
    ["adamantite"] = 1,
    ["addon"] = 1,
    ["adi"] = 1,
    ["adoken"] = 1,
    ["aeda"] = 1,
    ["again"] = 1,
    ["agamaggan"] = 1,
    ["agira"] = 1,
    ["ain"] = 1,
    ["amaira"] = 1,
    ["aman"] = 1,
    ["amenra"] = 1,
    ["ammonite"] = 1,
    ["anddi"] = 1,
    ["andu"] = 1,
    ["anyone"] = 1,
    ["aoe"] = 1,
    ["area"] = 1,
    ["aregon"] = 1,
    ["aren"] = 1,
    ["arise"] = 1,
    ["asian"] = 1,
    ["assassin"] = 1,
    ["assume"] = 1,
    ["asun"] = 1,
    ["attention"] = 1,
    ["auchindoun"] = 1,
    ["aura"] = 1,
    ["aureaa"] = 1,
    ["aurora"] = 1,
    ["aurron"] = 1,
    ["auto"] = 1,
    ["awesome"] = 1,
    ["aye"] = 1,
    ["azure"] = 1,
    ["baine"] = 1,
    ["bamboo"] = 1,
    ["banana"] = 1,
    ["bandage"] = 1,
    ["baradin"] = 1,
    ["barrage"] = 1,
    ["base"] = 1,
    ["basin"] = 1,
    ["be"] = 1,
    ["bearaga"] = 1,
    ["been"] = 1,
    ["before"] = 1,
    ["begin"] = 1,
    ["begun"] = 1,
    ["bein"] = 1,
    ["benicha"] = 1,
    ["bike"] = 1,
    ["bio"] = 1,
    ["biodin"] = 1,
    ["bishuna"] = 1,
    ["bite"] = 1,
    ["boa"] = 1,
    ["boe"] = 1,
    ["bojaa"] = 1,
    ["bone"] = 1,
    ["bonesin"] = 1,
    ["boo"] = 1,
    ["boomkin"] = 1,
    ["borean"] = 1,
    ["button"] = 1,
    ["chain"] = 1,
    ["champion"] = 1,
    ["change"] = 1,
    ["chase"] = 1,
    ["chatoe"] = 1,
    ["cheese"] = 1,
    ["cheshire"] = 1,
    ["chimera"] = 1,
    ["choose"] = 1,
    ["daasu"] = 1,
    ["dagomda"] = 1,
    ["damage"] = 1,
    ["damuramu"] = 1,
    ["defense"] = 1,
    ["demisie"] = 1,
    ["demon"] = 1,
    ["demure"] = 1,
    ["dendimon"] = 1,
    ["dense"] = 1,
    ["dese"] = 1,
    ["desire"] = 1,
    ["detonation"] = 1,
    ["die"] = 1,
    ["diggin"] = 1,
    ["digiman"] = 1,
    ["dimension"] = 1,
    ["dire"] = 1,
    ["disengage"] = 1,
    ["doe"] = 1,
    ["doin"] = 1,
    ["dominate"] = 1,
    ["done"] = 1,
    ["dude"] = 1,
    ["due"] = 1,
    ["dun"] = 1,
    ["dungeon"] = 1,
    ["dunno"] = 1,
    ["durotan"] = 1,
    ["ebon"] = 1,
    ["echo"] = 1,
    ["eeriee"] = 1,
    ["engage"] = 1,
    ["engine"] = 1,
    ["enrage"] = 1,
    ["entire"] = 1,
    ["eona"] = 1,
    ["etima"] = 1,
    ["eye"] = 1,
    ["fade"] = 1,
    ["fae"] = 1,
    ["faerie"] = 1,
    ["fantasee"] = 1,
    ["fate"] = 1,
    ["figure"] = 1,
    ["fine"] = 1,
    ["fire"] = 1,
    ["foreman"] = 1,
    ["fujimu"] = 1,
    ["future"] = 1,
    ["gain"] = 1,
    ["game"] = 1,
    ["gametime"] = 1,
    ["gamon"] = 1,
    ["garona"] = 1,
    ["garrison"] = 1,
    ["garrote"] = 1,
    ["gate"] = 1,
    ["gettin"] = 1,
    ["gimme"] = 1,
    ["ginta"] = 1,
    ["goin"] = 1,
    ["gone"] = 1,
    ["gonna"] = 1,
    ["goren"] = 1,
    ["gotta"] = 1,
    ["gotten"] = 1,
    ["gouge"] = 1,
    ["guerra"] = 1,
    ["guide"] = 1,
    ["guise"] = 1,
    ["gunna"] = 1,
    ["gurubashi"] = 1,
    ["hagara"] = 1,
    ["haja"] = 1,
    ["happen"] = 1,
    ["harrison"] = 1,
    ["here"] = 1,
    ["hero"] = 1,
    ["hi"] = 1,
    ["hidden"] = 1,
    ["hihi"] = 1,
    ["home"] = 1,
    ["homie"] = 1,
    ["hope"] = 1,
    ["house"] = 1,
    ["hozen"] = 1,
    ["hue"] = 1,
    ["huge"] = 1,
    ["i"] = 1,
    ["ibe"] = 1,
    ["idea"] = 1,
    ["image"] = 1,
    ["imagine"] = 1,
    ["imma"] = 1,
    ["immediate"] = 1,
    ["infinite"] = 1,
    ["infusion"] = 1,
    ["initiate"] = 1,
    ["insane"] = 1,
    ["inside"] = 1,
    ["into"] = 1,
    ["iron"] = 1,
    ["ironton"] = 1,
    ["issue"] = 1,
    ["jade"] = 1,
    ["jadenne"] = 1,
    ["jaeden"] = 1,
    ["japanese"] = 1,
    ["joke"] = 1,
    ["jubei"] = 1,
    ["kazziro"] = 1,
    ["keen"] = 1,
    ["keyana"] = 1,
    ["kiaran"] = 1,
    ["kieu"] = 1,
    ["kimzee"] = 1,
    ["kinda"] = 1,
    ["kinyato"] = 1,
    ["koragon"] = 1,
    ["kuduro"] = 1,
    ["machine"] = 1,
    ["madoran"] = 1,
    ["mage"] = 1,
    ["main"] = 1,
    ["makin"] = 1,
    ["man"] = 1,
    ["mana"] = 1,
    ["marriage"] = 1,
    ["mashaya"] = 1,
    ["mature"] = 1,
    ["mean"] = 1,
    ["mechano"] = 1,
    ["meditation"] = 1,
    ["meimi"] = 1,
    ["meku"] = 1,
    ["menadea"] = 1,
    ["menagerie"] = 1,
    ["mengooo"] = 1,
    ["mention"] = 1,
    ["message"] = 1,
    ["messin"] = 1,
    ["mike"] = 1,
    ["mine"] = 1,
    ["minioni"] = 1,
    ["mino"] = 1,
    ["minro"] = 1,
    ["minute"] = 1,
    ["mirenda"] = 1,
    ["mission"] = 1,
    ["misuse"] = 1,
    ["modaga"] = 1,
    ["mode"] = 1,
    ["moderation"] = 1,
    ["mogorain"] = 1,
    ["mojodishu"] = 1,
    ["mon"] = 1,
    ["moogaru"] = 1,
    ["moon"] = 1,
    ["more"] = 1,
    ["moron"] = 1,
    ["moronao"] = 1,
    ["mountain"] = 1,
    ["muradin"] = 1,
    ["nagan"] = 1,
    ["naion"] = 1,
    ["name"] = 1,
    ["nanode"] = 1,
    ["nature"] = 1,
    ["needin"] = 1,
    ["neesa"] = 1,
    ["nerubian"] = 1,
    ["nigga"] = 1,
    ["noise"] = 1,
    ["noize"] = 1,
    ["none"] = 1,
    ["noone"] = 1,
    ["nooten"] = 1,
    ["nope"] = 1,
    ["nose"] = 1,
    ["note"] = 1,
    ["nuke"] = 1,
    ["offense"] = 1,
    ["one"] = 1,
    ["onto"] = 1,
    ["oon"] = 1,
    ["oosorra"] = 1,
    ["ooze"] = 1,
    ["open"] = 1,
    ["operation"] = 1,
    ["opinion"] = 1,
    ["opposition"] = 1,
    ["orange"] = 1,
    ["page"] = 1,
    ["pain"] = 1,
    ["pan"] = 1,
    ["panda"] = 1,
    ["pandason"] = 1,
    ["parade"] = 1,
    ["pause"] = 1,
    ["pee"] = 1,
    ["penguin"] = 1,
    ["peon"] = 1,
    ["pepe"] = 1,
    ["pie"] = 1,
    ["pirate"] = 1,
    ["poison"] = 1,
    ["pose"] = 1,
    ["position"] = 1,
    ["posseidon"] = 1,
    ["potion"] = 1,
    ["pure"] = 1,
    ["pusha"] = 1,
    ["rage"] = 1,
    ["ragefire"] = 1,
    ["rain"] = 1,
    ["raise"] = 1,
    ["range"] = 1,
    ["rape"] = 1,
    ["rare"] = 1,
    ["rate"] = 1,
    ["razeege"] = 1,
    ["reason"] = 1,
    ["regen"] = 1,
    ["regeneration"] = 1,
    ["remain"] = 1,
    ["ride"] = 1,
    ["rise"] = 1,
    ["risen"] = 1,
    ["robe"] = 1,
    ["roda"] = 1,
    ["rodanoe"] = 1,
    ["rogi"] = 1,
    ["rogue"] = 1,
    ["ronga"] = 1,
    ["rouge"] = 1,
    ["rude"] = 1,
    ["run"] = 1,
    ["rune"] = 1,
    ["safe"] = 1,
    ["saggezza"] = 1,
    ["saken"] = 1,
    ["samorria"] = 1,
    ["saronite"] = 1,
    ["satin"] = 1,
    ["sea"] = 1,
    ["season"] = 1,
    ["see"] = 1,
    ["seein"] = 1,
    ["seen"] = 1,
    ["seeyou"] = 1,
    ["senario"] = 1,
    ["senisa"] = 1,
    ["sense"] = 1,
    ["sereia"] = 1,
    ["shake"] = 1,
    ["shaman"] = 1,
    ["shame"] = 1,
    ["shape"] = 1,
    ["share"] = 1,
    ["shoa"] = 1,
    ["side"] = 1,
    ["siege"] = 1,
    ["simka"] = 1,
    ["situation"] = 1,
    ["size"] = 1,
    ["some"] = 1,
    ["someone"] = 1,
    ["somone"] = 1,
    ["son"] = 1,
    ["soon"] = 1,
    ["soranna"] = 1,
    ["summon"] = 1,
    ["sun"] = 1,
    ["sunchu"] = 1,
    ["suppose"] = 1,
    ["tairise"] = 1,
    ["taken"] = 1,
    ["tanaan"] = 1,
    ["tarianoka"] = 1,
    ["tassenia"] = 1,
    ["tea"] = 1,
    ["teamnite"] = 1,
    ["teenieweenie"] = 1,
    ["tense"] = 1,
    ["teron"] = 1,
    ["tide"] = 1,
    ["time"] = 1,
    ["tin"] = 1,
    ["tindomino"] = 1,
    ["tirion"] = 1,
    ["titan"] = 1,
    ["token"] = 1,
    ["tome"] = 1,
    ["tone"] = 1,
    ["tongue"] = 1,
    ["too"] = 1,
    ["toon"] = 1,
    ["tube"] = 1,
    ["tue"] = 1,
    ["u"] = 1,
    ["uden"] = 1,
    ["ukambe"] = 1,
    ["undan"] = 1,
    ["unga"] = 1,
    ["upon"] = 1,
    ["uropa"] = 1,
    ["use"] = 1,
    ["wanjun"] = 1,
    ["wanna"] = 1,
    ["wattino"] = 1,
    ["we"] = 1,
    ["weapon"] = 1,
    ["weenee"] = 1,
    ["were"] = 1,
    ["weren"] = 1,
    ["wide"] = 1,
    ["wien"] = 1,
    ["wife"] = 1,
    ["wine"] = 1,
    ["wipe"] = 1,
    ["wire"] = 1,
    ["wise"] = 1,
    ["woman"] = 1,
    ["wombo"] = 1,
    ["women"] = 1,
    ["won"] = 1,
    ["woo"] = 1,
    ["wooden"] = 1,
    ["yeko"] = 1,
    ["yeti"] = 1,
    ["yoon"] = 1,
    ["you"] = 1,
    ["youre"] = 1,
    ["youtube"] = 1,
    ["zaradia"] = 1,
    ["zareya"] = 1,
    ["zeeza"] = 1,
    ["zintiri"] = 1,
    ["zon"] = 1,
    ["zone"] = 1,
    ["zooboo"] = 1,
}


local function convertWord(original)
    local word = string.lower(original)

    if string.match(word, "^[(<%[].*[)>%]]$") then
        return original
    end
    
    if string.match(word, "^mo+") then
        return original
    end
    
    if stopwords[ string.gsub(word, "%A", "") ] then
        return original
    end

    local word = string.gsub(word, "([bcdfghjkprstwyz])%1", "っ%1")
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
    
    local res = nil
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
        (event == "CHAT_MSG_GUILD" and addon.db.profile.guild) or
        (event == "CHAT_MSG_PARTY" and addon.db.profile.party) or
        (event == "CHAT_MSG_PARTY_LEADER" and addon.db.profile.party) or
        (event == "CHAT_MSG_RAID" and addon.db.profile.instance) or
        (event == "CHAT_MSG_RAID_LEADER" and addon.db.profile.instance) or
        (event == "CHAT_MSG_INSTANCE_CHAT" and addon.db.profile.instance) or
        (event == "CHAT_MSG_INSTANCE_CHAT_LEADER" and addon.db.profile.instance) then
        return false, convertMessage(msg), ...
    end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", hookMessage)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", hookMessage)
