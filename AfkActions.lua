local frame = CreateFrame("Frame")
local afkActionsTimers = {}
local backActionsTimers = {}
local lastAfkState = UnitIsAFK("player")

-- General functions
local function GetOptionValue(key)
   return AfkActionsOptions[key]
end

local function CancelActions(timers)
    for _, timer in ipairs(timers) do
        if timer.Cancel then
            timer:Cancel()
        end
    end
    for k in pairs(timers) do
        timers[k] = nil
    end
end

-- AFK actions
local function GetActionList(inputOptionKey)
    local actions = GetOptionValue(inputOptionKey)
    local actionsList = {}

    for action in string.gmatch(actions, "%[(.-)%]") do
        table.insert(actionsList, action)
    end

    return actionsList
end

local function PerformAction(actionType, actionValue)
    local actionType = string.upper(actionType)
    local actionValue = string.upper(actionValue)

    if actionType == "EMOTE" then
        DoEmote(actionValue)
    elseif actionType ~= "WAIT" then
        print(string.format("Action type not supported: %s", actionType))
    end
end

local function PerformActions(enabledOptionKey, inputOptionKey, timers)
    if GetOptionValue(enabledOptionKey) == true then
        local actions = GetActionList(inputOptionKey)
        local additionalTime = 0

        for index, action in ipairs(actions) do
            local actionType, actionValue = string.match(action, "([^,]+),([^,]+)")

            if string.upper(actionType) == "WAIT" and actionValue then
                local formattedTime = actionValue / 1000
                additionalTime = additionalTime + formattedTime
            end

            local delay = index + additionalTime

            if index == 1 then
                delay = delay - 1
                additionalTime = additionalTime - 1
            end

            local timer = C_Timer.NewTimer(delay, function()
                PerformAction(actionType, actionValue)
            end)

            table.insert(timers, timer)
        end
    end
end

-- Messages
local function SendMessage(enabledOptionKey, inputOptionKey, channelOptionKey)
    if GetOptionValue(enabledOptionKey) == true then
        local message = GetOptionValue(inputOptionKey)
        local channel = GetOptionValue(channelOptionKey)

        SendChatMessage(message, channel)
    end
end

-- Auto reply
local function SetAutoReplyMessage()
    if GetOptionValue("AUTO_REPLY_ENABLED") == true and GetOptionValue("AUTO_REPLY_MESSAGE") ~= nil then
        local message = GetOptionValue("AUTO_REPLY_MESSAGE")
        SendChatMessage(message, "AFK")
    else
        SendChatMessage("AFK", "AFK")
    end
end

-- AFK event
local function CheckAfk(self, event, unit)
    if unit == "player" then
        local isAfk = UnitIsAFK("player")

        if isAfk ~= lastAfkState then
            lastAfkState = isAfk

            if isAfk then
                CancelActions(afkActionsTimers)
                CancelActions(backActionsTimers)
                PerformActions("ACTIONS_AFK_ENABLED", "ACTIONS_AFK_INPUT", afkActionsTimers)
            else
                CancelActions(afkActionsTimers)
                CancelActions(backActionsTimers)
                PerformActions("ACTIONS_BACK_ENABLED", "ACTIONS_BACK_INPUT", backActionsTimers)
                SendMessage("MESSAGE_BACK_ENABLED", "MESSAGE_BACK_INPUT", "MESSAGE_BACK_SELECTED_CHANNEL")
            end
        end
    end
end

-- Custom AFK
local function RegisterCustomAfkCommand ()
    SlashCmdList["GOAFK"] = function(msg)
        if UnitIsAFK("player") then
            SendChatMessage("", "AFK")
        else
            CancelActions(afkActionsTimers)
            CancelActions(backActionsTimers)
            PerformActions("ACTIONS_AFK_ENABLED", "ACTIONS_AFK_INPUT", afkActionsTimers)
            SendMessage("MESSAGE_AFK_ENABLED", "MESSAGE_AFK_INPUT", "MESSAGE_AFK_SELECTED_CHANNEL")
            SetAutoReplyMessage()
            lastAfkState = true
        end
    end
    SLASH_GOAFK1 = "/goafk"
end

local function RegisterCustomAfkMacro ()
    local macroName = "GoAfk"
    local macroIcon = "INV_Misc_QuestionMark"
    local macroBody = "/goafk"

    local macroExists = false

    for i = 1, GetNumMacros() do
        local name = GetMacroInfo(i)

        if name == macroName then
            macroExists = true
            break
        end
    end

    if not macroExists then
       local perCharacter = false
        local macro = CreateMacro(macroName, macroIcon, macroBody, perCharacter)

        if not macro then
            print("Couldn't create /goafk macro")
        end
    end
end

local function RegisterCustomAfk()
    RegisterCustomAfkCommand()
    RegisterCustomAfkMacro()
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")

frame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_LOGIN" then
        RegisterCustomAfk()
    end

    if event == "PLAYER_FLAGS_CHANGED" then
        CheckAfk(self, event, unit)
    end
end)
