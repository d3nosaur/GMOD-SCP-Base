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

    D_SCPBase.SetupPlayerSCP(ply, scpTable)
    D_SCPBase.RegisterSCPHooks(ply, scpTable)

    D_SCPBase.ActiveSCPs[ply] = scp

    ply:SetNWBool("SCP", true)
    ply:SetNWString("SCP_ID", scp)

    print("[(D) SCP-Base Loader] " .. ply:Nick() .. " has been set to " .. scp .. ".")
end

--- Sets up the player's stats to the SCPs
-- @param Player the player to set
-- @param SCPTable the SCP's data
function D_SCPBase.SetupPlayerSCP(ply, scpTable)
    if scpTable.Respawn then
        ply:Kill()
        ply:Spawn()
    end

    ply:SetHealth(scpTable.Health)
    ply:SetMaxHealth(scpTable.Health)
    ply:SetArmor(scpTable.Armor)
    ply:SetMaxArmor(scpTable.Armor)
    ply:SetModel(scpTable.Model)
        
    if !scpTable.KeepWeapons then
        ply:StripWeapons()
    end

    for k,v in ipairs(scpTable.Weapons) do
        ply:Give(v)
    end

    if IsValid(scpTable.Hooks.PlayerSpawn) then
        scpTable.Hooks.PlayerSpawn(ply)
    end
end