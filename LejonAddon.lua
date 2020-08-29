-- ----------------------------------------------------------------------------
-- cthun map
-- ----------------------------------------------------------------------------
local dotPos = {
    -- group 1
    [1] = {0.5, 58}, -- melee cthun
    [2] = {0.5, 69}, -- melee tent
    [3] = {0.5, 123}, -- shaman/flex
    [4] = {-24.5, 166}, -- healer/ranged 1
    [5] = {25.5, 166}, -- healer/ranged 2

    -- group 2
    [6] = {41, 41}, -- melee cthun
    [7] = {49, 49}, -- melee tent
    [8] = {87, 87}, -- shaman/flex
    [9] = {100, 136}, -- healer/ranged 1
    [10] = {135, 102}, -- healer/ranged 2

    -- group 3
    [11] = {-40.5, 41.5}, -- melee cthun
    [12] = {-48.25, 49.75}, -- melee tent
    [13] = {-86, 88}, -- shaman/flex
    [14] = {-134, 101}, -- healer/ranged 1
    [15] = {-99, 136}, -- healer/ranged 2

    -- group 4
    [16] = {57, 1.5}, -- melee cthun
    [17] = {68.5, 1.5}, -- melee tent
    [18] = {123, 1.5}, -- shaman/flex
    [19] = {166, 26.5}, -- healer/ranged 1
    [20] = {166, -23.5}, -- healer/ranged 2

    -- group 5
    [21] = {-57, 1.5}, -- melee cthun
    [22] = {-68.5, 1.5}, -- melee tent
    [23] = {-123, 1.5}, -- shaman/flex
    [24] = {-165, -23.5}, -- healer/ranged 1
    [25] = {-165, 26.5}, -- healer/ranged 2

    -- group 6
    [26] = {40, -39}, -- melee cthun
    [27] = {48.25, -47}, -- melee tent
    [28] = {87, -85}, -- shaman/flex
    [29] = {135, -97.5}, -- healer/ranged 1
    [30] = {99, -133}, -- healer/ranged 2

    -- group 7
    [31] = {-39, -39}, -- melee cthun
    [32] = {-47, -47}, -- melee tent
    [33] = {-86, -86}, -- shaman/flex
    [34] = {-99, -133}, -- healer/ranged 1
    [35] = {-134, -98}, -- healer/ranged 2

    -- group 8
    [36] = {0.5, -55.5}, -- melee cthun
    [37] = {0.5, -67}, -- melee tent
    [38] = {0.5, -121}, -- shaman/flex
    [39] = {25.5, -164}, -- healer/ranged 1
    [40] = {-24.5, -164} -- healer/ranged 2
}

local classColors = {
    ["warrior"] = {0.68, 0.51, 0.33},
    ["rogue"] = {1.0, 0.96, 0.31},
    ["mage"] = {0.21, 0.60, 0.74},
    ["warlock"] = {0.48, 0.41, 0.69},
    ["hunter"] = {0.47, 0.73, 0.25},
    ["priest"] = {1.0, 1.00, 1.00},
    ["druid"] = {1.0, 0.49, 0.04},
    ["shaman"] = {0.0, 0.34, 0.77}
}

local Cthun_PlayerName, _ = UnitName("player")
local backdrop = {
    bgFile = "Interface\\AddOns\\LejonAddon\\CthunImages\\CThun_Positioning.tga",
    edgeFile = "",
    tile = false,
    edgeSize = 0,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local frame = CreateFrame("Frame", "Cthun_room", UIParent)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetFrameStrata("FULLSCREEN")
frame:SetHeight(512)
frame:SetWidth(512)
frame:SetScale(1)
frame:SetPoint("CENTER", 0, 0)
frame:SetBackdrop(backdrop)
frame:SetAlpha(1.00)
frame.x = frame:GetLeft()
frame.y = (frame:GetTop() - frame:GetHeight())
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function() fillGrid() end)
frame:Hide()

local resizeframe
local Width = frame:GetWidth()
local Height = frame:GetHeight()

local function Resizer(frame)
    local s = frame:GetWidth() / Width
    local childrens = {frame:GetChildren()}
    for _, child in ipairs(childrens) do if child ~= resizeframe then child:SetScale(s) end end
    frame:SetHeight(Height * s)
end

local function ResizeFrame(frame)
    resizeframe = CreateFrame("Frame", "CthunResize", frame)
    resizeframe:SetPoint("BottomRight", frame, "BottomRight", -8, 7)
    resizeframe:SetWidth(16)
    resizeframe:SetHeight(16)
    resizeframe:SetFrameLevel(frame:GetFrameLevel() + 7)
    resizeframe:EnableMouse(true)
    local resizetexture = resizeframe:CreateTexture(nil, "Artwork")
    resizetexture:SetPoint("TopLeft", resizeframe, "TopLeft", 0, 0)
    resizetexture:SetWidth(16)
    resizetexture:SetHeight(16)
    resizetexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame:SetMaxResize(1024, 1024)
    frame:SetMinResize(256, 256)
    frame:SetResizable(true)
    resizeframe:SetScript("OnEnter", function(self) resizetexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight") end)
    resizeframe:SetScript("OnLeave", function(self) resizetexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") end)
    resizeframe:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            frame:SetWidth(Width)
            frame:SetHeight(Height)
        else
            resizetexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
            frame:StartSizing("Right")
        end
    end)
    resizeframe:SetScript("OnMouseUp", function(self, button)
        local x, y = GetCursorPosition()
        local fx = self:GetLeft() * self:GetEffectiveScale()
        local fy = self:GetBottom() * self:GetEffectiveScale()
        if x >= fx and x <= (fx + self:GetWidth()) and y >= fy and y <= (fy + self:GetHeight()) then
            resizetexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        else
            resizetexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        end
        frame:StopMovingOrSizing()
    end)
    local scrollframe = CreateFrame("ScrollFrame", "CthunScroll", frame)
    scrollframe:SetWidth(Width)
    scrollframe:SetHeight(Height)
    scrollframe:SetPoint("Topleft", frame, "Topleft", 0, 0)
    frame:SetScript("OnSizeChanged", function(self) Resizer(frame) end)
end

ResizeFrame(frame)

local OpacitySlider = CreateFrame("Slider", "MySlider1", frame, "OptionsSliderTemplate")
OpacitySlider:SetPoint("BOTTOM", frame, "BOTTOMLEFT", 80, 6)
OpacitySlider:SetMinMaxValues(0.25, 1.00)
OpacitySlider:SetValue(1.00)
OpacitySlider:SetValueStep(0.05)
getglobal(OpacitySlider:GetName() .. 'Low'):SetText("")
getglobal(OpacitySlider:GetName() .. 'High'):SetText("")
getglobal(OpacitySlider:GetName() .. 'Text'):SetText('Opacity')
OpacitySlider:SetScript("OnValueChanged", function(self)
    local value = OpacitySlider:GetValue()
    frame:SetAlpha(value)
end)

local CthunHeader = CreateFrame("Frame", "CthunHeader", frame)
CthunHeader:SetPoint("TOP", frame, "TOP", 0, 12)
CthunHeader:SetWidth(256)
CthunHeader:SetHeight(64)
CthunHeader:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header"})

local drag = CreateFrame("Frame", nil, frame)
drag:SetWidth(256)
drag:SetHeight(64)
drag:SetPoint("TOP", frame, "TOP", 0, 12)
drag:EnableMouse(true)
drag:SetScript("OnMouseDown", function() frame:StartMoving() end)

drag:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)

drag:SetScript("OnHide", function() frame:StopMovingOrSizing() end)

local CthunHeaderText = CthunHeader:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
CthunHeaderText:SetPoint("CENTER", CthunHeader, "CENTER", 0, 12)
CthunHeaderText:SetText("LKS C'Thun")

local button = CreateFrame("Button", "Close_button", frame)
button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
button:SetHeight(32)
button:SetWidth(32)
button:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
button:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
button:SetScript("OnLoad", function() button:RegisterForClicks("AnyUp") end)
button:SetScript("OnClick", function() frame:Hide(); end)

-- Create dot frames
for i = 1, 40 do
    dot = CreateFrame("Button", "Dot_" .. i, frame)
    dot:SetPoint("CENTER", frame, "CENTER", dotPos[i][1], dotPos[i][2])
    dot:EnableMouse(true)
    dot:SetFrameLevel(dot:GetFrameLevel() + 3)
    tooltip = CreateFrame("GameTooltip", "Tooltip_" .. i, nil, "GameTooltipTemplate")
    local texdot = dot:CreateTexture("Texture_" .. i, "OVERLAY")
    dot.texture = texdot
    texdot:SetAllPoints(dot)
    texdot:SetTexture("Interface\\AddOns\\LejonAddon\\CthunImages\\playerdot.tga")
    texdot:Hide()
    dot:SetScript("OnEnter", function()
        tooltip:SetOwner(dot, "ANCHOR_RIGHT")
        tooltip:SetText("Empty")
        tooltip:Show()
    end)
    dot:SetScript("OnLeave", function() tooltip:Hide() end)
end

function newDot(dot, tooltip, texture, name, class)
    if (Cthun_PlayerName == name) then
        dot:SetWidth(28)
        dot:SetHeight(28)
    else
        dot:SetWidth(20)
        dot:SetHeight(20)
    end

    if name ~= "Empty" then
        texture:SetVertexColor(classColors[class][1], classColors[class][2], classColors[class][3], 1.0)
        texture:Show()
    else
        texture:Hide()
    end

    dot:SetScript("OnEnter", function()
        tooltip:SetOwner(dot, "ANCHOR_RIGHT")
        tooltip:SetText(name)
        tooltip:Show()
    end)

    dot:SetScript("OnLeave", function() tooltip:Hide() end)
end

local dotRes = {
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}, -- group 1
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}, -- group 2
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}, -- group 3
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}, -- group 4
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}, -- group 5
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}, -- group 6
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}, -- group 7
    {{"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}, {"Empty", "Empty"}}  -- group 8
}

function getRaidInfo()
    for i = 1, 40 do
        local name, _, subgroup, _, class = GetRaidRosterInfo(i);

        if (class == "Rogue") then
            if dotRes[subgroup][1][1] == "Empty" or dotRes[subgroup][1][1] == name then
                dotRes[subgroup][1] = {name, class}
            elseif dotRes[subgroup][2][1] == "Empty" or dotRes[subgroup][2][1] == name then
                dotRes[subgroup][2] = {name, class}
            elseif dotRes[subgroup][3][1] == "Empty" or dotRes[subgroup][3][1] == name then
                dotRes[subgroup][3] = {name, class}
            elseif dotRes[subgroup][4][1] == "Empty" or dotRes[subgroup][4][1] == name then
                dotRes[subgroup][4] = {name, class}
            else
                dotRes[subgroup][5] = {name, class}
            end
        elseif (class == "Warrior") then
            if dotRes[subgroup][2][1] == "Empty" or dotRes[subgroup][2][1] == name then
                dotRes[subgroup][2] = {name, class}
            elseif dotRes[subgroup][1][1] == "Empty" or dotRes[subgroup][1][1] == name then
                dotRes[subgroup][1] = {name, class}
            elseif dotRes[subgroup][3][1] == "Empty" or dotRes[subgroup][3][1] == name then
                dotRes[subgroup][3] = {name, class}
            elseif dotRes[subgroup][4][1] == "Empty" or dotRes[subgroup][4][1] == name then
                dotRes[subgroup][4] = {name, class}
            else
                dotRes[subgroup][5] = {name, class}
            end
        elseif (class == "Shaman" or name == "Ryggfläsk") then
            if dotRes[subgroup][3][1] == "Empty" or dotRes[subgroup][3][1] == name then
                dotRes[subgroup][3] = {name, class}
            elseif dotRes[subgroup][4][1] == "Empty" or dotRes[subgroup][4][1] == name then
                dotRes[subgroup][4] = {name, class}
            elseif dotRes[subgroup][5][1] == "Empty" or dotRes[subgroup][5][1] == name then
                dotRes[subgroup][5] = {name, class}
            elseif dotRes[subgroup][2][1] == "Empty" or dotRes[subgroup][2][1] == name then
                dotRes[subgroup][2] = {name, class}
            else
                dotRes[subgroup][1] = {name, class}
            end
        elseif (class == "Priest" or class == "Druid" or class == "Mage" or class == "Warlock" or class == "Hunter") then
            if dotRes[subgroup][5][1] == "Empty" or dotRes[subgroup][5][1] == name then
                dotRes[subgroup][5] = {name, class}
            elseif dotRes[subgroup][4][1] == "Empty" or dotRes[subgroup][4][1] == name then
                dotRes[subgroup][4] = {name, class}
            elseif dotRes[subgroup][3][1] == "Empty" or dotRes[subgroup][3][1] == name then
                dotRes[subgroup][3] = {name, class}
            elseif dotRes[subgroup][2][1] == "Empty" or dotRes[subgroup][2][1] == name then
                dotRes[subgroup][2] = {name, class}
            else
                dotRes[subgroup][1] = {name, class}
            end
        end
    end
end

function fillGrid()
    wipeReserves()
    getRaidInfo()
    for i = 1, 8 do
        for j = 1, 5 do
            local x = ((i - 1) * 5) + j
            newDot(_G["Dot_" .. x], _G["Tooltip_" .. x], _G["Texture_" .. x], dotRes[i][j][1], strlower(dotRes[i][j][2]))
        end
    end
end

function wipeReserves() for i = 1, 8 do for j = 1, 5 do for k = 1, 2 do dotRes[i][j][k] = "Empty" end end end end

-- ----------------------------------------------------------------------------
-- emotes
-- ----------------------------------------------------------------------------
local defaultpack = {[":this:"] = "Interface\\AddOns\\LejonAddon\\Emotes\\this.tga:28:28", [":lks:"] = "Interface\\AddOns\\LejonAddon\\Emotes\\lks.tga:28:28"};

local emoticons = {[":this:"] = ":this:", [":lks:"] = ":lks:"};

local CHATS = {
    "CHAT_MSG_OFFICER", "CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_CHANNEL", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER"
};

function Emoticons_UpdateChatFilters() for i, chat in ipairs(CHATS) do ChatFrame_AddMessageEventFilter(chat, Emoticons_MessageFilter) end end

function Emoticons_MessageFilter(self, event, msg, ...)
    msg = Emoticons_RunReplacement(msg);
    return false, msg, ...
end

local ItemTextFrameSetText = ItemTextPageText.SetText;
function ItemTextPageText.SetText(self, msg, ...)
    if (msg ~= nil) then msg = Emoticons_RunReplacement(msg); end
    ItemTextFrameSetText(self, msg, ...);
end

local OpenMailBodyTextSetText = OpenMailBodyText.SetText;
function OpenMailBodyText.SetText(self, msg, ...)
    if (msg ~= nil) then msg = Emoticons_RunReplacement(msg); end
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

            msg = string.gsub(msg, "(%s)" .. k .. "(%s)", "%1|T" .. path_and_size .. "|t%2");
            msg = string.gsub(msg, "(%s)" .. k .. "$", "%1|T" .. path_and_size .. "|t");
            msg = string.gsub(msg, "^" .. k .. "(%s)", "|T" .. path_and_size .. "|t%1");
            msg = string.gsub(msg, "^" .. k .. "$", "|T" .. path_and_size .. "|t");
            msg = string.gsub(msg, "(%s)" .. k .. "(%c)", "%1|T" .. path_and_size .. "|t%2");
            msg = string.gsub(msg, "(%s)" .. k .. "(%s)", "%1|T" .. path_and_size .. "|t%2");
        end
    end

    return msg;
end

-- ----------------------------------------------------------------------------
-- interrupt announce
-- ----------------------------------------------------------------------------
local playerGUID = UnitGUID("player")
local INTERRUPT_MESSAGE = "Interrupted %s's [%s]!"
local f = CreateFrame("FRAME")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function f:ADDON_LOADED()
    if LejonInterrupt == nil then LejonInterrupt = true; end
    Emoticons_UpdateChatFilters();
end

function f:COMBAT_LOG_EVENT_UNFILTERED()
    if not LejonInterrupt then return end

    local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()
    if not (event == "SPELL_INTERRUPT" and (sourceGUID == playerGUID or sourceGUID == UnitGUID('pet'))) then return end

    msg = string.format(INTERRUPT_MESSAGE, destName or UNKNOWN, spellName or UNKNOWN)
    SendChatMessage(msg, "SAY")
end

-- ----------------------------------------------------------------------------
-- slash commands
-- ----------------------------------------------------------------------------
SLASH_LKS1 = "/lks";
SLASH_LKS2 = "/lejon";
SlashCmdList["LKS"] = function(msg)
    if msg == "cthun" then
        frame:Show()
        fillGrid()
    elseif msg == "cthun reset" then
        frame:SetWidth(Width)
        frame:SetHeight(Height)
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
    elseif msg == "shout" then
        SendChatMessage("LEJON!", "yell")
        C_Timer.After(1.5, function() SendChatMessage("KOMMANDO!", "yell") end)
        C_Timer.After(3, function() SendChatMessage("SOLDATER!", "yell") end)
    elseif msg == "live" then
        SendChatMessage("lever och dör vid svärdet för Lejon Kommando Soldater!", "emote")
    else
        print("Not a valid Lejon Command! Usage:")
        print("|cff8d63ff/lks cthun|r  -  open cthun map")
        print("|cff8d63ff/lks cthun reset|r  -  reset size of cthun map")
        print("|cff8d63ff/lks interrupt|r  -  show interrupt announcement status")
        print("|cff8d63ff/lks interrupt enable|r  -  enable interrupt announcement")
        print("|cff8d63ff/lks interrupt disable|r  -  disable interrupt announcement")
        print("|cff8d63ff/lks shout|r")
        print("|cff8d63ff/lks live|r")
    end
end
