D_SCPBase = D_SCPBase or {}

D_SCPBase.SCPs = D_SCPBase.SCPs or {}
D_SCPBase.ActiveSCPs = D_SCPBase.ActiveSCPs or {}

--- Register an SCP to the system
-- @param SCPTable the SCP's data
function D_SCPBase.RegisterSCP(scpTable)
    scpTable.Health = scpTable.Health or 100
    scpTable.Armor = scpTable.Armor or 0
    scpTable.Model = scpTable.Model or nil
    scpTable.Useable = scpTable.Useable or true
    scpTable.Respawn = scpTable.Respawn or true
    scpTable.KeepWeapons = scpTable.KeepWeapons or false
    scpTable.AllowWeapons = scpTable.AllowWeapons or false
    scpTable.Weapons = scpTable.Weapons or {}
    scpTable.RunSpeed = scpTable.RunSpeed or 240
    scpTable.WalkSpeed = scpTable.WalkSpeed or 160
    scpTable.CanSpeak = scpTable.CanSpeak or false
    scpTable.CanListen = scpTable.CanListen or true

    scpTable.Hooks = scpTable.Hooks or {}

    D_SCPBase.SCPs[scpTable.ID] = scpTable
end

--- Sets a player to an SCP, you should use ply:SetSCP(scp) instead
-- @param Player the player to set
-- @param String the ID of the SCP ("SCP_173")
function D_SCPBase.SetSCP(ply, scp)
    if not IsValid(ply) then return end
    if not D_SCPBase.SCPs[scp] then return end

    local scpTable = D_SCPBase.SCPs[scp]

    D_SCPBase.SetupPlayerSCP(ply, scpTable, true)
    D_SCPBase.RegisterSCPHooks(ply, scpTable)

    D_SCPBase.ActiveSCPs[ply] = scp

    ply:SetNWBool("SCP", true)
    ply:SetNWString("SCP_ID", scp)

    print("[(D) SCP-Base Loader] " .. ply:Nick() .. " has been set to " .. scp .. ".")
end