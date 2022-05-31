D_SCPBase = D_SCPBase || {}
D_SCPBase.ActiveSCPs = D_SCPBase.ActiveSCPs || {}

local plyMeta = FindMetaTable("Player")

--- Get the SCP that the player is currently controlling
-- @return string The SCP id if the player is an SCP, otherwise nil
function plyMeta:GetSCP()
    if !self:IsValid() then return end
    if !D_SCPBase.ActiveSCPs[self] then return nil end

    return D_SCPBase.ActiveSCPs[self]
end

--- Sets the player to an SCP
-- @param string The class of the SCP
function plyMeta:SetSCP(scp)
    if !self:IsValid() then return end

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