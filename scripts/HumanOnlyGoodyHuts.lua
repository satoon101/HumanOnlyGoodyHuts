local IMPROVEMENT_GOODY_HUT = GameInfo.Improvements["IMPROVEMENT_GOODY_HUT"].Index;
local SAVE_KEY = "HumanOnlyGoodyHuts";

function SerializeHuts(huts)
    local s = ""
    for _, pos in ipairs(huts) do
        s = s ..pos.x .. "," .. pos.y .. ";"
    end
    return s
end

function DeserializeHuts(s)
    local huts = {}
    if s == nil or s == "" then
        return huts
    end

    for x, y in string.gmatch(s, "(%d+),(%d+);") do
        table.insert(huts, {x = tonumber(x), y = tonumber(y)})
    end
    return huts
end

function HideGoodyHuts()
    local iW, iH = Map.GetGridSize();
    local savedData = Game:GetProperty(SAVE_KEY)
    local huts = DeserializeHuts(savedData)

    -- Loop through all plots and store/remove any goody huts
    for x = 0, iW - 1 do
        for y = 0, iH - 1 do
            local pPlot = Map.GetPlot(x, y);
            if pPlot:GetImprovementType() == IMPROVEMENT_GOODY_HUT then
                table.insert(huts, {x = x, y = y});
                ImprovementBuilder.SetImprovementType(pPlot, -1);
            end
        end
    end
    Game:SetProperty(SAVE_KEY, SerializeHuts(huts));
end

function RestoreGoodyHuts()
    local savedData = Game:GetProperty(SAVE_KEY)
    local huts = DeserializeHuts(savedData)

    -- Loop through all known huts in reverse order
    --  in order to remove them if the plot was restored,
    --  thus keeping any that were unable to be restored in the array.
    for i = #huts, 1, -1 do
        local plotData = huts[i]
        local pPlot = Map.GetPlot(plotData.x, plotData.y)
        local pUnitList = Units.GetUnitsInPlot(pPlot)
        if pUnitList == nil or #pUnitList == 0 then
            ImprovementBuilder.SetImprovementType(pPlot, IMPROVEMENT_GOODY_HUT, -1)
            table.remove(huts, i)
        end
    end
    Game:SetProperty(SAVE_KEY, SerializeHuts(huts));
end

function OnPlayerTurnActivated(playerID, bIsFirstTurn)
    local pPlayer = Players[playerID];
    if pPlayer:IsHuman() then
        RestoreGoodyHuts();
    end
end

function OnPlayerTurnDeactivated(playerID)
    local pPlayer = Players[playerID];
    if pPlayer:IsHuman() then
        HideGoodyHuts();
    end
end


-- Register Events
Events.PlayerTurnActivated.Add(OnPlayerTurnActivated);
Events.PlayerTurnDeactivated.Add(OnPlayerTurnDeactivated);
print("Human Only Goody Huts loaded successfully!");
