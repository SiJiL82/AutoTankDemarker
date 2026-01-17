if not AutoTankDemarkerDB then
    AutoTankDemarkerDB = {}
end

local isLoopRunning = false
local lastLoopTime = 0

local function IsPlayerTank()
    local specIndex = GetSpecialization()

    if not specIndex then
        return false
    end

    local _, _, _, _, role = GetSpecializationInfo(specIndex)

    return role == "TANK"
end

local function IsInDungeonOrRaidNotMythicPlus()
    local inInstance, instanceType = IsInInstance()

    if not inInstance then
        return false
    end

    -- Check for party (dungeon) or raid instance
    if instanceType == "party" or instanceType == "raid" then
        local difficulty = select(3, GetInstanceInfo())
        return difficulty ~= 8
    end

    return false
end

local function CanRemoveRaidMarkers()
    local isInRaid = IsInRaid()
    
    if not isInRaid then
        return true  -- Can modify markers on yourself outside of raid
    end
    
    -- Check if player is raid leader
    if UnitIsGroupLeader("player") then
        return true
    end
    
    -- Check if player has assistant role
    if UnitIsGroupAssistant("player") then
        return true
    end
    
    return false
end

local function StartLoop()
    if not CanRemoveRaidMarkers() then
        print("Cannot remove raid markers: insufficient permissions")
        return
    end
    if not IsPlayerTank() then
        return
    end

    isLoopRunning = true
    lastLoopTime = GetTime()
end

local function StopLoop()
    isLoopRunning = false
end

local loopFrame = CreateFrame("Frame")
loopFrame:SetScript("OnUpdate", function(self, elapsed)
    if not isLoopRunning then
        return
    end

    local currentTime = GetTime()
    
    if currentTime - lastLoopTime >= 0.3 then
        -- Check if player is tank
        if IsPlayerTank() then
            -- Check if player has a marker
            for i = 1, 8 do
                if GetRaidTargetIndex("player") == 6 then  -- 6 is the Square marker
                    SetRaidTarget("player", 0)  -- Remove the marker
                    print("Removed Square marker from player")
                    break
                end
            end
        end
        lastLoopTime = currentTime
    end
end)

-- Create a frame to handle events
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "CHALLENGE_MODE_COMPLETED" then
        if IsInDungeonOrRaidNotMythicPlus() then
            print("Player is in a Dungeon or Raid (not Mythic Plus)")
            StartLoop()
        else
            print("Player is not in a Dungeon or Raid (or is in Mythic Plus)")
            StopLoop()
        end
    elseif event == "PLAYER_LEAVING_WORLD" then
        print("Player is leaving instance, clearing marker")
        SetRaidTarget("player", 0)
        StopLoop()
    elseif event == "CHALLENGE_MODE_START" then
        print("Player is starting Mythic Plus")
        StopLoop()
    end
end)
