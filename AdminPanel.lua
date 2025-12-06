-- Define config panel
local configFrame = CreateFrame("Frame", "AutoTankDemarkConfig", UIParent, "BasicFrameTemplateWithInset")
configFrame:SetSize(500, 350)
configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
configFrame.TitleBg:SetHeight(30)
configFrame.title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
configFrame.title:SetPoint("TOPLEFT", configFrame.TitleBg, "TOPLEFT", 5, -3)
configFrame.title:SetText("Auto Tank Demarker Settings")
configFrame:EnableMouse(true)
configFrame:SetMovable(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
configFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)
configFrame:Hide()

-- Instance types section heading
local instanceTypeHeading = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
instanceTypeHeading:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 16, -40)
instanceTypeHeading:SetText("Instance Types")

-- Instance type checkboxes
local instanceTypes = {
    { name = "Normal Dungeons", value = "normalDungeon" },
    { name = "Heroic Dungeons", value = "heroicDungeon" },
    { name = "Mythic Dungeons", value = "mythicDungeon" },
    { name = "Mythic Plus", value = "mythicPlus" },
    { name = "Raid Finder", value = "raidFinder" },
    { name = "Normal Raids", value = "normalRaid" },
    { name = "Heroic Raids", value = "heroicRaid" },
    { name = "Mythic Raids", value = "mythicRaid" },
}

local yOffset = -70
for i, instanceType in ipairs(instanceTypes) do
    local checkbox = CreateFrame("CheckButton", "AutoTankDemarker_" .. instanceType.value, configFrame, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 16, yOffset)

    checkbox:SetChecked(AutoTankDemarkerDB[instanceType.value] or false)
    
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 8, 0)
    label:SetText(instanceType.name)
    
    yOffset = yOffset - 28
end


-- Marker types
local markerTypes = {
    { name = "Star", value = 1 },
    { name = "Circle", value = 2 },
    { name = "Diamond", value = 3 },
    { name = "Triangle", value = 4 },
    { name = "Moon", value = 5 },
    { name = "Square", value = 6 },
    { name = "Cross", value = 7 },
    { name = "Skull", value = 8 },
}

yOffset = yOffset - 20
for i, markerType in ipairs(markerTypes) do
    local label = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 16, yOffset)
    label:SetText("{rt" .. markerType.value .."}" .. " " .. markerType.name )

    yOffset = yOffset - 28
end

-- Save button
local saveButton = CreateFrame("Button", nil, configFrame, "GameMenuButtonTemplate")
saveButton:SetSize(100, 25)
saveButton:SetPoint("BOTTOM", configFrame, "BOTTOM", -60, 10)
saveButton:SetText("Save")
saveButton:SetScript("OnClick", function(self)
    for i, instanceType in ipairs(instanceTypes) do
        local checkbox = _G["AutoTankDemarker_" .. instanceType.value]
        AutoTankDemarkerDB[instanceType.value] = checkbox:GetChecked()
    end

    print("Auto Tank Demarker settings saved!")
end)

-- Close button
local closeButton = CreateFrame("Button", nil, configFrame, "GameMenuButtonTemplate")
closeButton:SetSize(100, 25)
closeButton:SetPoint("BOTTOM", configFrame, "BOTTOM", 60, 10)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function(self)
    configFrame:Hide()
end)

-- Register slash commands to open/close the config panel
SLASH_AUTOTANKDEMARKER1 = "/atd"
SlashCmdList["AUTOTANKDEMARKER"] = function()
    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end

-- Add to UISpecialFrames for ESC key handling
table.insert(UISpecialFrames, "AutoTankDemarkConfig")