D_SCPBase = D_SCPBase || {}
D_SCPBase.ActiveSCPs = D_SCPBase.ActiveSCPs || {}

local plyMeta = FindMetaTable("Player")

--- Get the SCP that the player is currently controlling
-- @return string The SCP id if the player is an SCP
function plyMeta:GetSCP()
    if !self:IsValid() or !self:IsSCP() then return end

    return D_SCPBase.ActiveSCPs[self]
end

--- Checks if the player is currently an SCP
-- @return boolean True if the player is an SCP, otherwise false
function plyMeta:IsSCP()
    if !self:IsValid() then return end
    if !D_SCPBase.ActiveSCPs[self] then return false end

    return true
end

--- Sets the player to an SCP
-- @param string The class of the SCP
function plyMeta:SetSCP(scp)
    if !self:IsValid() then return end

    self:RemoveSCP()
    D_SCPBase.SetSCP(self, scp)
end

--- Removes player from SCP
-- @return bool Whether the player was an SCP
function plyMeta:RemoveSCP()
    if !self:IsValid() then return end
    if !D_SCPBase.ActiveSCPs[self] then return false end

    D_SCPBase.ActiveSCPs[self] = nil

    self:SetNWBool("SCP", false)
    self:SetNWString("SCP_ID", "null")

    self:Kill()
    self:Spawn()

    print("[(D) SCP-Base Loader] " .. self:Nick() .. " is no longer an SCP.")

    return true
end