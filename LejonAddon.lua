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
end

function f:COMBAT_LOG_EVENT_UNFILTERED()
    if not LejonInterrupt then return end
	-- if not IsInGroup() then return end

	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == playerGUID or sourceGUID == UnitGUID('pet'))) then return end

	msg = string.format(INTERRUPT_MESSAGE, destName or UNKNOWN, spellName or UNKNOWN)
	SendChatMessage(msg, "SAY")
end
