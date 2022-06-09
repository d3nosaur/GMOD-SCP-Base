-- Some functions that might be useful for future SCPs

local plyMeta = FindMetaTable("Player")

--- Checks if the player can see the target.
-- @param ent Entity to check
-- @return True if the player can see the entity
local FOVAngle = math.cos(1.15)
function plyMeta:CanSee(ent)
    -- NPCs/Players feet can be off screen but rest on screen, this helps with that
    local checkSpots = {
        ent:GetPos(),
        (ent.GetShootPos != nil and ent:GetShootPos() or nil)
    }

    if !IsValid(self) then return end

    local plyDirection = self:GetAimVector()
    for _, spot in pairs(checkSpots) do
        -- dot product vector math to check if ent is within players FOV.
        local spotToPly = (spot-self:EyePos()):GetNormalized()
        local angle = plyDirection:Dot(spotToPly)

        if angle < FOVAngle then continue end
        
        -- Trace masks don't work on clients, so in order to have this check I'll split it up
        if SERVER then
            local tr = util.TraceLine({
                start = self:GetShootPos(),
                endpos = spot,
                filter = self,
                -- Doesn't hit see through things (windows, fences, etc)
                mask = MASK_BLOCKLOS_AND_NPCS,
            })

            if tr.Entity == ent then 
                return true 
            end
        else
            local traces = util.TraceToEnd({
                start = self:GetShootPos(),
                endpos = spot,
                filter = self,
            })

            for _, tr in ipairs(traces) do
                if tr.Entity == ent then 
                    return true 
                -- Not sure if there's a better way to check if the trace hit something see through so I just cancel if it hits the world
                elseif tr.HitWorld then
                    -- don't want to return false here in case one of the other checkspots works
                    break
                end
            end
        end
    end

    return false
end

--- Traces lines until it hits the end position.
-- @param Trace: the trace data, same as util.TraceLine input
-- @param Integer: Maximum number of traces to do (default 10)
-- @return Table: with all of the trace line outputs
function util.TraceToEnd(traceData, maxTraces)
    local traces = {}

    local filteredEnts = {}
    if isfunction(traceData.filter) then
        local oldFunction = traceData.filter

        traceData.filter = function(ent)
            if table.HasValue(filteredEnts, ent) then return false end

            return oldFunction(ent)
        end
    elseif !istable(traceData.filter) then
        filteredEnts = {traceData.filter}
        traceData.filter = filteredEnts
    end

    for i=1, maxTraces or 10 do
        local trace = util.TraceLine(traceData)

        if !trace.Hit or trace.HitPos == traceData.endpos then break end

        traceData.start = trace.HitPos
        table.insert(traces, trace)
        table.insert(filteredEnts, trace.Entity)
    end

    return traces
end

--- Gives you a list of all the players currently using an SCP
-- @param SCPID The type of SCP
-- @return List<Player> The players
function player.GetSCPs(scp)
    local SCPList = {}

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetSCP() == scp then
            table.insert(SCPList, ply)
        end 
    end

    return SCPList
end

--- Finds a player by their name.
-- @param name The name of the player.
-- @return Player, the player if found | ERROR_MULTIPLE_FOUND if multiple players found | false if no players found
ERROR_MULTIPLE_FOUND = true
function player.FindPlayer(name)
    name = string.lower(name)

    local target = false
    for _,ply in ipairs(player.GetAll()) do
        if !string.find(string.lower(ply:Nick()), name) then continue end

        if target then return ERROR_MULTIPLE_FOUND end
        target = ply
    end

    return target or false
end

--- Gets the SCP table for a given SCP
-- @param SCPID The type of SCP
-- @return Table, the SCP table
function GetSCPTable(SCPID)
    return D_SCPBase.SCPs[SCPID]
end