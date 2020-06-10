-- slash commands
SLASH_LKS1 = "/lks";
SLASH_LKS2 = "/lejon";
SlashCmdList["LKS"] = function(msg)
    if msg == "shout" then
        SendChatMessage("LEJON!", "yell")
        C_Timer.After(1.5, function() SendChatMessage("KOMMANDO!", "yell") end)
        C_Timer.After(3, function() SendChatMessage("SOLDATER!", "yell") end)
    elseif msg == "live" then
        SendChatMessage("lever och dör vid svärdet för Lejon Kommando Soldater!", "emote")
    elseif msg == "interrupt enable" then
        LejonInterrupt = true
        print("LKS interrupt announce is enabled!")
    elseif msg == "interrupt disable" then
        LejonInterrupt = false
        print("LKS interrupt announce is disabled!")
    elseif msg == "interrupt" then
        if LejonInterrupt then
            print("LKS interrupt announce is enabled!")
        else
            print("LKS interrupt announce is disabled!")
        end
    else
        print("Not a valid LKS command! Usage:")
        print("/lejon shout             - battle shout")
        print("/lejon live              - live and die by the sword")
        print("/lejon interrupt         - show interrupt announcement status")
        print("/lejon interrupt enable  - enable interrupt announcement")
        print("/lejon interrupt disable - disable interrupt announcement")
    end
end


-- emotes
local defaultpack = {
    [":this:"] = "Interface\\AddOns\\LejonAddon\\Emotes\\this.tga:28:28",
    [":lks:"] = "Interface\\AddOns\\LejonAddon\\Emotes\\lks.tga:28:28",
};


local emoticons = {
    [":this:"] = ":this:",
    [":lks:"] = ":lks:",
};


local CHATS = {
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER"
};


function Emoticons_UpdateChatFilters()
    for i, chat in ipairs(CHATS) do
        ChatFrame_AddMessageEventFilter(chat, Emoticons_MessageFilter)
    end
end


function Emoticons_MessageFilter(self, event, msg, ...)
    msg = Emoticons_RunReplacement(msg);
    return false, msg, ...
end


local ItemTextFrameSetText = ItemTextPageText.SetText;
function ItemTextPageText.SetText(self, msg, ...)
    if (msg ~= nil) then
        msg = Emoticons_RunReplacement(msg);
    end
    ItemTextFrameSetText(self, msg, ...);
end


local OpenMailBodyTextSetText = OpenMailBodyText.SetText;
function OpenMailBodyText.SetText(self, msg, ...)
    if (msg ~= nil) then
        msg = Emoticons_RunReplacement(msg);
    end
    OpenMailBodyTextSetText(self, msg, ...);
end


function Emoticons_RunReplacement(msg)
    local outstr = "";
    local origlen = string.len(msg);
    local startpos = 1;
    local endpos;

    while (startpos <= origlen) do
        endpos = origlen;
        local pos = string.find(msg, "|H", startpos, true);
        if (pos ~= nil) then endpos = pos; end
        outstr = outstr .. Emoticons_InsertEmoticons(string.sub(msg, startpos, endpos));
        startpos = endpos + 1;
        if (pos ~= nil) then
            endpos = string.find(msg, "|h", startpos, true);
            if (endpos == nil) then endpos = origlen; end
            if (startpos < endpos) then
                outstr = outstr .. string.sub(msg, startpos, endpos);
                startpos = endpos + 1;
            end
        end
    end

    return outstr;
end


function Emoticons_InsertEmoticons(msg)
    for k, v in pairs(emoticons) do
        if (string.find(msg, k, 1, true)) then
            path_and_size = defaultpack[v]

            msg = string.gsub(msg, "(%s)" .. k .. "(%s)",
                              "%1|T" .. path_and_size .. "|t%2");
            msg = string.gsub(msg, "(%s)" .. k .. "$",
                              "%1|T" .. path_and_size .. "|t");
            msg = string.gsub(msg, "^" .. k .. "(%s)",
                              "|T" .. path_and_size .. "|t%1");
            msg = string.gsub(msg, "^" .. k .. "$",
                              "|T" .. path_and_size .. "|t");
            msg = string.gsub(msg, "(%s)" .. k .. "(%c)",
                              "%1|T" .. path_and_size .. "|t%2");
            msg = string.gsub(msg, "(%s)" .. k .. "(%s)",
                              "%1|T" .. path_and_size .. "|t%2");
        end
    end

    return msg;
end


-- interrupt announce
local playerGUID = UnitGUID("player")
local INTERRUPT_MESSAGE = "Interrupted %s's [%s]!"
local f = CreateFrame("FRAME")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)


function f:ADDON_LOADED()
    if LejonInterrupt == nil then
        LejonInterrupt = false;
    end
    Emoticons_UpdateChatFilters();
end


function f:COMBAT_LOG_EVENT_UNFILTERED()
    if not LejonInterrupt then return end
	-- if not IsInGroup() then return end

	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == playerGUID or sourceGUID == UnitGUID('pet'))) then return end

	msg = string.format(INTERRUPT_MESSAGE, destName or UNKNOWN, spellName or UNKNOWN)
	SendChatMessage(msg, "SAY")
end
