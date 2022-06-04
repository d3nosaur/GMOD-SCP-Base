// Some functions that might be useful for future SCPs

local plyMeta = FindMetaTable("Player")

--- Checks if the player can see the target.
-- @param ent Entity to check
-- @return True if the player can see the entity
function plyMeta:CanSee(ent)
    // NPCs/Players feet can be off screen but rest on screen, this helps with that
    local checkSpots = {
        ent:GetPos(),
        (ent.GetShootPos != nil and ent:GetShootPos() or nil)
    }

    for _, spot in pairs(checkSpots) do
        local spotToPly = (spot-self:EyePos()):GetNormalized()
        local plyDirection = self:GetAimVector():GetNormalized()
        local angle = plyDirection:Dot(spotToPly)

        if angle < math.cos(1.15) then continue end

        local tr = util.TraceLine({
            start = self:GetShootPos(),
            endpos = spot,
            filter = self,
            mask = MASK_BLOCKLOS_AND_NPCS
        })

        if tr.Entity == ent then 
            return true 
        end
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