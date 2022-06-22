D_SCPBase = D_SCPBase or {}
D_SCPBase.SCPs = D_SCPBase.SCPs or {}

local config = D_SCPBase.Config.General

--- Set a player to an SCP
-- @param ply The player to set.
-- @param scp The scp to set the player to.
if config.scp_setplayer.Value then
    concommand.Add("scp_setplayer", function(ply, cmd, args)
        if not ply:IsValid() then return end

        if !ply:IsAdmin() then 
            ply:PrintMessage(HUD_PRINTCONSOLE, "Only admins are allowed to use this command.")
            return 
        end
        
        local target = args[1]
        local scp = args[2]

        if not target or not scp then 
            ply:PrintMessage(HUD_PRINTCONSOLE, "Usage: scp_setplayer <player> <scp>")
            return
        end

        if not D_SCPBase.SCPs[scp] then
            ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid SCP, list of valid SCPs:")
            for k,v in pairs(D_SCPBase.SCPs) do
                ply:PrintMessage(HUD_PRINTCONSOLE, k)
            end
            return
        end

        local plyTarget = player.FindPlayer(target)

        if plyTarget == ERROR_MULTIPLE_FOUND then
            ply:PrintMessage(HUD_PRINTCONSOLE, "Multiple users with name " .. target .. " found.")
            return
        elseif plyTarget == false then
            ply:PrintMessage(HUD_PRINTCONSOLE, "Can't find user with name " .. target .. ".")
            return
        end

        plyTarget:SetSCP(scp)
        ply:PrintMessage(HUD_PRINTCONSOLE, "Set " .. plyTarget:Nick() .. " to " .. scp .. ".")
    end)
end

--- Removes a player from their active SCP
-- @param ply The player to remove.
if config.scp_removeplayer.Value then
    concommand.Add("scp_removeplayer", function(ply, cmd, args)
        if not ply:IsValid() then return end

        if !ply:IsAdmin() then 
            ply:PrintMessage(HUD_PRINTCONSOLE, "Only admins are allowed to use this command.")
            return 
        end
        
        local target = args[1]

        if not target then 
            ply:PrintMessage(HUD_PRINTCONSOLE, "Usage: scp_removeplayer <player>")
            return
        end

        local plyTarget = player.FindPlayer(target)

        if plyTarget == ERROR_MULTIPLE_FOUND then
            ply:PrintMessage(HUD_PRINTCONSOLE, "Multiple users with name " .. target .. " found.")
            return
        elseif plyTarget == false then
            ply:PrintMessage(HUD_PRINTCONSOLE, "Can't find user with name " .. target .. ".")
            return
        end

        if plyTarget:RemoveSCP() then
            ply:PrintMessage(HUD_PRINTCONSOLE, "Removed " .. plyTarget:Nick() .. " from their active SCP.")
        else
            ply:PrintMessage(HUD_PRINTCONSOLE, plyTarget:Nick() .. " is not currently an SCP.")
        end
    end)
end

concommand.Add("scp_config", function(ply, cmd, args)
    if not ply:IsValid() then return end

    if !ply:IsAdmin() then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "Only admins are allowed to use this command.")
        return 
    end

    D_SCPBase.OpenConfigMenu(ply)
end)