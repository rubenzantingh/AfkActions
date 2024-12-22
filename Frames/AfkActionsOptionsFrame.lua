local defaultOptions = {
    ACTIONS_AFK_ENABLED = false,
    ACTIONS_AFK_INPUT = nil,
    ACTIONS_BACK_ENABLED = false,
    ACTIONS_BACK_INPUT = nil,
    MESSAGE_AFK_ENABLED,
    MESSAGE_AFK_INPUT = nil,
    MESSAGE_AFK_SELECTED_CHANNEL = 'PARTY',
    MESSAGE_AFK_CHANNELS = {
        {value = 'SAY', text = 'Say'},
        {value = 'PARTY', text = 'Party'},
        {value = 'RAID', text = 'Raid'},
        {value = 'GUILD', text = 'Guild'},
    },
    MESSAGE_BACK_ENABLED = false,
    MESSAGE_BACK_INPUT = nil,
    MESSAGE_BACK_SELECTED_CHANNEL = 'PARTY',
    MESSAGE_BACK_CHANNELS = {
        {value = 'PARTY', text = 'Party'},
        {value = 'RAID', text = 'Raid'},
        {value = 'GUILD', text = 'Guild'}
    },
    AUTO_REPLY_ENABLED = false,
    AUTO_REPLY_MESSAGE = nil,
}

local addonName = ...
local optionsFrame = CreateFrame("Frame")

local function CreateOptionDropdown(parent, relativeFrame, offsetX, offsetY, label, defaultValueLabel, optionKey, selectedKey)
    local dropdownLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropdownLabel:SetText(label)
    dropdownLabel:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", offsetX, offsetY - 10)

    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", -20, -4)
    
    local selectedOptionLabel = defaultValueLabel

    local function InitializeDropdownOptions()
        local info = UIDropDownMenu_CreateInfo()

        local function OnDropdownValueChanged(self, arg1, arg2, checked)
            AfkActionsOptions[selectedKey] = arg1
            UIDropDownMenu_SetText(dropdown, arg2)
        end

        for index, value in ipairs(AfkActionsOptions[optionKey]) do
            info.text = value.text
            info.value = value.value
            info.arg1 = info.value
            info.arg2 = info.text
            info.checked = AfkActionsOptions[selectedKey] == value.value
            info.func = OnDropdownValueChanged
            info.minWidth = 150

            if info.checked then
                selectedOptionLabel = value.text
            end

            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(dropdown, InitializeDropdownOptions)
    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetText(dropdown, selectedOptionLabel)
    UIDropDownMenu_SetAnchor(dropdown, 0, 0, "TOPLEFT", dropdown)
    return dropdown
end

local function CreateCheckBox(parent, text, optionKey, onClick)
    local checkbox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    checkbox.Text:SetText(text)
    checkbox.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    checkbox.Text:SetPoint("LEFT", 30, 0)
    checkbox:SetScript("OnClick", onClick)
    checkbox:SetChecked(AfkActionsOptions[optionKey])
    return checkbox
end

local function CreateTextInput(parent, relativeFrame, offsetX, offsetY, label, defaultValue, maxLetters, optionKey)
    local inputLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    inputLabel:SetText(label)
    inputLabel:SetPoint("TOPLEFT", relativeFrame, "TOPLEFT", offsetX, offsetY)

    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", inputLabel, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetSize(300, 80)

    local bg = scrollFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(scrollFrame)
    bg:SetColorTexture(0, 0, 0, 0.5)

    local border = CreateFrame("Frame", nil, scrollFrame, BackdropTemplateMixin and "BackdropTemplate")
    border:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", -5, 5)
    border:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 5, -5)
    border:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
    })
    border:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetText(AfkActionsOptions[optionKey] or defaultValue)
    editBox:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    editBox:SetTextInsets(5, 5, 5, 5)
    editBox:SetCursorPosition(0)
    editBox:SetSize(300, 200)
    editBox:SetPoint("TOPLEFT")
    editBox:SetPoint("TOPRIGHT")
    editBox:SetHeight(80)
    editBox:SetMaxLetters(maxLetters)

    scrollFrame:SetScrollChild(editBox)
    scrollFrame:SetVerticalScroll(0)
    scrollFrame:EnableMouse(true)
    scrollFrame:SetScript("OnMouseDown", function(self)
        editBox:SetFocus()
    end)
    
    editBox:SetScript("OnTextChanged", function(self)
        AfkActionsOptions[optionKey] = self:GetText()
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        self:Insert("\n")
    end)

    return scrollFrame
end

local function InitializeOptions()
    local optionsPanel = CreateFrame("Frame", "AfkActionsOptionsPanel", UIParent)
    optionsPanel.name = "AfkActions"

    -- Vars
    local titleOffsetY = -22
    local subTitleOffsetY = -30
    local fieldOffsetX = 25
    local fieldOffsetY = -10

    -- Options panel title
    local panelTitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    panelTitle:SetPoint("TOPLEFT", optionsPanel, 6, titleOffsetY)
    panelTitle:SetText("AfkActions")
    panelTitle:SetTextColor(1, 1, 1)
    panelTitle:SetFont("Fonts\\FRIZQT__.TTF", 20)

    local panelTitleUnderline = optionsPanel:CreateTexture(nil, "ARTWORK")
    panelTitleUnderline:SetColorTexture(1, 1, 1, 0.3)
    panelTitleUnderline:SetPoint("TOPLEFT", panelTitle, "BOTTOMLEFT", 0, -9)
    panelTitleUnderline:SetPoint("TOPRIGHT", optionsPanel, "TOPRIGHT", -16, -31)

    -- Scrollable frame
    local optionsContainerScrollFrame = CreateFrame("ScrollFrame", nil, optionsPanel, "UIPanelScrollFrameTemplate")
    optionsContainerScrollFrame:SetPoint("TOPLEFT", panelTitleUnderline, 0, -10)
    optionsContainerScrollFrame:SetPoint("BOTTOMRIGHT", -38, 30)

    local scrollSpeed = 50

    optionsContainerScrollFrame:EnableMouseWheel(true)
    optionsContainerScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local newOffset = self:GetVerticalScroll() - (delta * scrollSpeed)
        newOffset = math.max(0, math.min(newOffset, self:GetVerticalScrollRange()))
        self:SetVerticalScroll(newOffset)
    end)

    local optionsContainer = CreateFrame("Frame")
    optionsContainerScrollFrame:SetScrollChild(optionsContainer)
    optionsContainer:SetWidth(UIParent:GetWidth())
    optionsContainer:SetHeight(1)

    -- Going AFK
    local afkActionsTitle = optionsContainer:CreateFontString("ARTWORK", nil, "GameFontHighlightLarge")
    afkActionsTitle:SetPoint("TOPLEFT", 8, subTitleOffsetY)
    afkActionsTitle:SetText("Actions (going AFK)")
    afkActionsTitle:SetTextColor(1, 1, 1)

    local afkActionsEnabledCheckbox = CreateCheckBox(optionsContainer, "Enable", "ACTIONS_AFK_ENABLED", function(self)
        local checked = self:GetChecked()
        AfkActionsOptions["ACTIONS_AFK_ENABLED"] = checked
    end)
    afkActionsEnabledCheckbox:SetPoint("TOPLEFT", afkActionsTitle, fieldOffsetX, subTitleOffsetY + fieldOffsetY)

    local afkActionsActionListInput = CreateTextInput(optionsContainer, afkActionsEnabledCheckbox, 6, subTitleOffsetY + fieldOffsetY, "Action list", "", 500, "ACTIONS_AFK_INPUT")

    -- Coming back
    local comingBackActionsTitle = optionsContainer:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    comingBackActionsTitle:SetPoint("TOPLEFT", afkActionsActionListInput, -fieldOffsetX, -afkActionsActionListInput:GetHeight() + subTitleOffsetY)
    comingBackActionsTitle:SetText("Actions (coming back)")
    comingBackActionsTitle:SetTextColor(1, 1, 1)

    local comingBackActionsEnabledCheckbox = CreateCheckBox(optionsContainer, "Enable", "ACTIONS_BACK_ENABLED", function(self)
        local checked = self:GetChecked()
        AfkActionsOptions["ACTIONS_BACK_ENABLED"] = checked
    end)
    comingBackActionsEnabledCheckbox:SetPoint("TOPLEFT", comingBackActionsTitle, fieldOffsetX - 6, subTitleOffsetY + fieldOffsetY)

    local comingBackActionListInput = CreateTextInput(optionsContainer, comingBackActionsEnabledCheckbox, 6, subTitleOffsetY + fieldOffsetY, "Action list", "", 500, "ACTIONS_BACK_INPUT")

    -- Send message (going afk) with custom command
    local sendGoingAfkMessageActionsTitle = optionsContainer:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    sendGoingAfkMessageActionsTitle:SetPoint("TOPLEFT", comingBackActionListInput, -fieldOffsetX, -comingBackActionListInput:GetHeight() + subTitleOffsetY)
    sendGoingAfkMessageActionsTitle:SetText("Send message (going afk). Only works with the /goafk command")
    sendGoingAfkMessageActionsTitle:SetTextColor(1, 1, 1)

    local sendGoingAfkMessageEnabledCheckbox = CreateCheckBox(optionsContainer, "Enable", "MESSAGE_AFK_ENABLED", function(self)
        local checked = self:GetChecked()
        AfkActionsOptions["MESSAGE_AFK_ENABLED"] = checked
    end)
    sendGoingAfkMessageEnabledCheckbox:SetPoint("TOPLEFT", sendGoingAfkMessageActionsTitle, fieldOffsetX - 6, subTitleOffsetY + fieldOffsetY)

    local sendGoingAfkMessageInput = CreateTextInput(optionsContainer, sendGoingAfkMessageEnabledCheckbox, 6, subTitleOffsetY + fieldOffsetY, "Message", "", 200, "MESSAGE_AFK_INPUT")
    local sendGoingAfkMessageChannel = CreateOptionDropdown(optionsContainer, sendGoingAfkMessageInput, 0, -sendGoingAfkMessageInput:GetHeight() + fieldOffsetY, "Channel", "Party", "MESSAGE_AFK_CHANNELS", "MESSAGE_AFK_SELECTED_CHANNEL")

    -- Send message (coming back)
    local sendComingBackMessageActionsTitle = optionsContainer:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    sendComingBackMessageActionsTitle:SetPoint("TOPLEFT", sendGoingAfkMessageChannel, -fieldOffsetX + 20, -sendGoingAfkMessageChannel:GetHeight() + subTitleOffsetY)
    sendComingBackMessageActionsTitle:SetText("Send message (coming back)")
    sendComingBackMessageActionsTitle:SetTextColor(1, 1, 1)

    local sendComingBackMessageEnabledCheckbox = CreateCheckBox(optionsContainer, "Enable", "MESSAGE_BACK_ENABLED", function(self)
        local checked = self:GetChecked()
        AfkActionsOptions["MESSAGE_BACK_ENABLED"] = checked
    end)
    sendComingBackMessageEnabledCheckbox:SetPoint("TOPLEFT", sendComingBackMessageActionsTitle, fieldOffsetX - 6, subTitleOffsetY + fieldOffsetY)

    local sendComingBackMessageInput = CreateTextInput(optionsContainer, sendComingBackMessageEnabledCheckbox, 6, subTitleOffsetY + fieldOffsetY, "Message", "", 200, "MESSAGE_BACK_INPUT")
    local sendComingBackMessageChannel = CreateOptionDropdown(optionsContainer, sendComingBackMessageInput, 0, -sendComingBackMessageInput:GetHeight() + fieldOffsetY, "Channel", "Party", "MESSAGE_BACK_CHANNELS", "MESSAGE_BACK_SELECTED_CHANNEL")

    -- Auto reply
    local autoReplyTitle = optionsContainer:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    autoReplyTitle:SetPoint("TOPLEFT", sendComingBackMessageChannel, -fieldOffsetX + 20, -sendComingBackMessageChannel:GetHeight() + subTitleOffsetY)
    autoReplyTitle:SetText("Custom AFK reply message. Only works with the /goafk command")
    autoReplyTitle:SetTextColor(1, 1, 1)

    local autoReplyEnabledCheckbox = CreateCheckBox(optionsContainer, "Enable", "AUTO_REPLY_ENABLED", function(self)
        local checked = self:GetChecked()
        AfkActionsOptions["AUTO_REPLY_ENABLED"] = checked
    end)
    autoReplyEnabledCheckbox:SetPoint("TOPLEFT", autoReplyTitle, fieldOffsetX - 6, subTitleOffsetY + fieldOffsetY)

    local autoReplyMessageInput = CreateTextInput(optionsContainer, autoReplyEnabledCheckbox, 6, subTitleOffsetY + fieldOffsetY, "Message", "", 200, "AUTO_REPLY_MESSAGE")

    -- Add to interface options
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(optionsContainer)
    else
        local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name);
        Settings.RegisterAddOnCategory(category);
    end
end

local function addonLoaded(self, event, addonLoadedName)
    if addonLoadedName == addonName then
        AfkActionsOptions = AfkActionsOptions or defaultOptions

        for key, value in pairs(defaultOptions) do
            if AfkActionsOptions[key] == nil then
                AfkActionsOptions[key] = value
            end
        end

        InitializeOptions()
    end
end

optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript("OnEvent", addonLoaded)