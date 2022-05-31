local plyMeta = FindMetaTable("Player")

--- Gets the SCP that the player is currently controlling
-- @return The SCP ID if the player is an SCP, otherwise nil
function plyMeta:GetSCP()
    if not self:IsSCP() then return nil end

    return self:GetNWString("SCP_ID")
end

--- Checks if a player is an SCP
-- @return True if the player is an SCP, otherwise false
function plyMeta:IsSCP()
    return self:GetNWBool("SCP")
end