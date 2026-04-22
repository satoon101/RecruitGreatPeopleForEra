-- ===========================================================================
--  Recruit Great People - Gameplay Script
--  Auto-recruits remaining Great People for the current Era.
-- ===========================================================================

print("=== Recruit Great People (Gameplay) Loading ===")

local maxValue = 2^31 - 1
local pIndex = GameInfo.GreatPersonClasses["GREAT_PERSON_CLASS_PROPHET"].Index

g_AutoRecruitingInProgress = false

function GetData()
    local data = {}
    for row in GameInfo.GreatPersonIndividuals() do
        local era = GameInfo.Eras[row.EraType].Index
        local class = GameInfo.GreatPersonClasses[row.GreatPersonClassType].Index
        if data[era] == nil then
            data[era] = {}
        end
        if data[era][class] == nil then
            data[era][class] = 0
        end
        data[era][class] = data[era][class] + 1
    end
    return data
end

local gpData = GetData()

function CanRecruitPerson(person, era, numPastRecruits, goldNeeded)
    if goldNeeded == maxValue then
        return false
    end

    if person.Class == pIndex then
        return false
    end

    if person.Era ~= era then
        return false
    end

    if numPastRecruits + 1 >= gpData[era][person.Class] then
        return false
    end

    return true
end

function FindRecruits(playerID, classID, individualID)
    local player = Players[playerID]
    local era = Game.GetEras():GetCurrentEra()
    local pastRecruits = ExposedMembers.CustomGPRecruitment.GetPastRecruitsForEra(era)
    if classID ~= nil then
        if pastRecruits[classID] == nil then
            pastRecruits[classID] = {}
        end

        local foundCurrentIndividual = false
        for _, person in ipairs(pastRecruits) do
            if person.Individual == individualID then
                foundCurrentIndividual = true
                break
            end
        end

        if not foundCurrentIndividual then
            table.insert(pastRecruits[classID], individualID)
        end
    end

    for _, person in ipairs(Game.GetGreatPeople():GetTimeline()) do
        if classID == nil or classID == person.Class then
            local numPastRecruits = 0
            if pastRecruits[person.Class] ~= nil then
                numPastRecruits = #pastRecruits[person.Class]
            end

            local goldNeeded = Game.GetGreatPeople():GetPatronizeCost(
                playerID,
                person.Individual,
                YieldTypes.GOLD
            )
            if CanRecruitPerson(person, era, numPastRecruits, goldNeeded) then
                local pTreasury = player:GetTreasury()
                local currentGold = pTreasury:GetGoldBalance()
                pTreasury:SetGoldBalance(currentGold + goldNeeded)
                ExposedMembers.CustomGPRecruitment.RecruitGreatPerson(
                        playerID,
                        person.Individual
                )
            end
        end
    end
end

function UnitGreatPersonCreated(playerID, _, greatPersonClassID, greatPersonIndividualID)
    if not g_AutoRecruitingInProgress then
        return
    end

    FindRecruits(playerID, greatPersonClassID, greatPersonIndividualID)
end

Events.UnitGreatPersonCreated.Add(UnitGreatPersonCreated)

function OnPlayerTurnActivated(playerID)
    local isLastEraTurn = ExposedMembers.CustomGPRecruitment.IsLastTurnForEra()
    if not isLastEraTurn then
        return
    end

    local player = Players[playerID]
    if not player:IsHuman() then
        return
    end

    g_AutoRecruitingInProgress = true
    FindRecruits(playerID)
end

Events.PlayerTurnActivated.Add(OnPlayerTurnActivated);

function OnPlayerTurnDeactivated()
    g_AutoRecruitingInProgress = false
end
Events.PlayerTurnDeactivated.Add(OnPlayerTurnDeactivated);

print("=== Recruit Great People (Gameplay) Loaded ===")
