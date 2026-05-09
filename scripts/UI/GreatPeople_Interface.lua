-- ===========================================================================
--  Recruit Great People - UI Script
--  Provides Great People based functionality to gameplay scripts.
-- ===========================================================================

print("=== Recruit Great People (GreatPeople) Loading ===")

ExposedMembers.CustomGPRecruitment = ExposedMembers.CustomGPRecruitment or {}

function IsLastTurnForEra()
    return Game.GetEras():GetNextEraCountdown() == 0
end

ExposedMembers.CustomGPRecruitment.IsLastTurnForEra = IsLastTurnForEra

function GetPastRecruitsForEra(era)
    local data = {}
    for _, person in ipairs(Game.GetGreatPeople():GetPastTimeline()) do
        if person.Era == era then
            if data[person.Class] == nil then
                data[person.Class] = {}
            end
            table.insert(data[person.Class], person.Individual)
        end
    end
    return data
end

ExposedMembers.CustomGPRecruitment.GetPastRecruitsForEra = GetPastRecruitsForEra

function RecruitGreatPerson(playerID, personID)
    local params = {}
    params[PlayerOperations.PARAM_GREAT_PERSON_INDIVIDUAL_TYPE] = personID
    params[PlayerOperations.PARAM_YIELD_TYPE] = YieldTypes.GOLD
    UI.RequestPlayerOperation(playerID, PlayerOperations.PATRONIZE_GREAT_PERSON, params)
end

ExposedMembers.CustomGPRecruitment.RecruitGreatPerson = RecruitGreatPerson

print("=== Recruit Great People (GreatPeople) Loaded ===")
