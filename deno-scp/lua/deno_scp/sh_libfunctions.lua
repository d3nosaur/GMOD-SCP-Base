// Some functions that might be useful for future SCPs

local plyMeta = FindMetaTable("Player")

// If ent is on the players screen return true, else return false
function plyMeta:CanSee(ent)
    local plyEye = self:EyeAngles():Forward()
    local plyToEnt = ent:GetPos() - self:GetPos()
    local angle = plyEye:Dot(plyToEnt:GetNormalized())

    if angle < math.cos(1.0472) then return false end

    local checkSpots = {
        ent:GetPos(),
        ent:GetShootPos()
    }

    for _, spot in ipairs(checkSpots) do
        local tr = util.TraceLine({
            start = self:GetShootPos(),
            endpos = spot,
            filter = function(hit) 
                // I want it to work even if there is a player in the way, this is kind of a hacky way to do that but it's whatever 
                if hit == ent then return true
                else return !hit:IsPlayer() end
            end
        })

        if tr.Entity == ent then return true end
    end

    return false
end