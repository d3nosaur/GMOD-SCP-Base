D_SCPBase = D_SCPBase or {}

--- Sets up the player's stats to the SCPs
-- @param Player the player to set
-- @param SCPTable the SCP's data
function D_SCPBase.SetupPlayerSCP(ply, scpTable, respawn)
    if respawn and scpTable.Respawn then
        ply:Kill()
        ply:Spawn()
    end

    ply:SetHealth(scpTable.Health)
    ply:SetMaxHealth(scpTable.Health)
    ply:SetArmor(scpTable.Armor)
    ply:SetMaxArmor(scpTable.Armor)
    ply:SetModel(scpTable.Model)
    ply:SetRunSpeed(scpTable.RunSpeed)
    ply:SetWalkSpeed(scpTable.WalkSpeed)
        
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

hook.Add("PlayerSpawn", "D_SCPBase_SetupPlayerSCP", function(ply)
    if !IsValid(ply) or !ply:IsSCP() then return end

    local scpTable = D_SCPBase.SCPs[ply:GetSCP()]
    D_SCPBase.SetupPlayerSCP(ply, scpTable, false)
end)

hook.Add("PlayerSwitchWeapon", "D_SCPBase_PreventWeapons", function(ply)
    if !IsValid(ply) or !ply:IsSCP() then return end

    local scpTable = D_SCPBase.SCPs[ply:GetSCP()]

    if !scpTable.AllowWeapons then return true end
end)

hook.Add("PlayerCanHearPlayersVoice", "D_SCPBase_DisableVoice", function(listener, ply)
    if !IsValid(ply) or !ply:IsSCP() then return end

    local scpTable = D_SCPBase.SCPs[ply:GetSCP()]

    if !scpTable.CanSpeak then return false end
end)

hook.Add("PlayerCanHearPlayersVoice", "D_SCPBase_DisableListening", function(ply, speaker)
    if !IsValid(ply) or !ply:IsSCP() then return end

    local scpTable = D_SCPBase.SCPs[ply:GetSCP()]

    if !scpTable.CanListen then return false end
end)