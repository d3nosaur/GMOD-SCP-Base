// Some functions that might be useful for future SCPs

local plyMeta = FindMetaTable("Player")

--- Checks if the player can see the target.
-- @param ent Entity to check
-- @return True if the player can see the entity
function plyMeta:CanSee(ent)
    local plyEye = self:EyeAngles():Forward()
    local plyToEnt = ent:GetPos() - self:GetPos()
    local angle = plyEye:Dot(plyToEnt:GetNormalized())

    if angle < math.cos(1.0472) then return false end

    local checkSpots = {
        ent:GetPos(),
        IsValid(ent.GetShootPos) and ent:GetShootPos() or nil
    }

    for _, spot in ipairs(checkSpots) do
        local tr = util.TraceLine({
            start = self:GetShootPos(),
            endpos = spot,
            filter = self,
            mask = MASK_BLOCKLOS_AND_NPCS
        })

        if tr.Entity == ent then return true end
    end

    return false
end

--- Gives you a list of all the players currently using an SCP
-- @param SCPID The type of SCP
-- @return List<Player> The players
function GetSCPs(scp)
    local SCPList = {}

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetSCP() == scp then
            table.insert(SCPList, ply)
        end 
    end

    return SCPList
end