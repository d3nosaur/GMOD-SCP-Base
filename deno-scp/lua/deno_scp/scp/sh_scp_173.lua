D_SCPBase = D_SCPBase or {}
local config = D_SCPBase.Config.SCP_173

local attackSounds = {
    "scp_173/bone_break_1.wav",
    "scp_173/bone_break_2.wav",
    "scp_173/bone_break_3.wav",
}

local moveSounds = {
    "scp_173/concrete_movement_1.wav",
    "scp_173/concrete_movement_2.wav",
    "scp_173/concrete_movement_3.wav",
}

if SERVER then
    util.AddNetworkString("D_SCP173_AddWatcher")
    util.AddNetworkString("D_SCP173_RemoveWatcher")
    util.AddNetworkString("D_SCP173_ManualBlink")
    util.AddNetworkString("D_SCP173_BlinkHUD")
    util.AddNetworkString("D_SCP173_RandomizeSequence")
    util.AddNetworkString("D_SCP173_RemoveWatcherTimers")

    -- Table of SCPs and their watchers <SCP, {Watchers}>
    local watchers = {}
    -- Table of watchers and their last unblink time <Player, Time>
    local lastBlink = {}
    -- Table of SCPs and the time of their last attack <Player, Time>
    local attackers = {}
    -- Table of SCPs and their active pose <Player, Integer>
    local activeSequence = {}

    net.Receive("D_SCP173_AddWatcher", function(len, watcher)
        local scp = net.ReadEntity()

        if !IsValid(watcher) or !IsValid(scp) or scp:GetSCP() != "SCP_173" or watcher:IsSCP() then return end

        watchers[scp] = watchers[scp] or {}

        table.insert(watchers[scp], watcher)
    end)

    net.Receive("D_SCP173_RemoveWatcher", function(len, watcher)
        local scp = net.ReadEntity()

        if !IsValid(watcher) or !IsValid(scp) or scp:GetSCP() != "SCP_173" then return end

        watchers[scp] = watchers[scp] or {}

        table.RemoveByValue(watchers[scp], watcher)
    end)

    local lastManualBlink = {}
    net.Receive("D_SCP173_ManualBlink", function(len, ply)
        if !config.ManualBlinking or !IsValid(ply) or table.IsEmpty(watchers) or !ply:Alive() then return end

        lastManualBlink[ply] = lastManualBlink[ply] or 0
        
        if !(lastManualBlink[ply] < CurTime() - config.ManualBlinkDelay) then return end

        lastBlink[ply] = CurTime()
        lastManualBlink[ply] = CurTime()
    end)

    local function SCP173_Attack(ply)
        -- The player is frozen when someone is looking at them
        if ply:IsFlagSet(FL_FROZEN) then return end

        -- Hacky way to create attack delays
        attackers[ply] = attackers[ply] or 0
        if !(attackers[ply] < CurTime() - config.AttackDelay) then return end

        -- If entity SCP is looking at is a player or an npc, attack them (TODO: Implement destroying props/doors here)
        local tr = ply:GetEyeTrace()

        local target = tr.Entity
        if !IsValid(target) or !(target:IsPlayer() or target:IsNPC()) or tr.HitPos:DistToSqr(ply:EyePos()) > (config.AttackRange * config.AttackRange) or target:Health() <= 0 then return end

        ply:SetPos(target:GetPos() - (target:GetPos() - ply:GetPos()):GetNormalized() * 40)
        
        local d = DamageInfo()
        d:SetAttacker(ply)
        d:SetDamage(config.AttackDamage)
        d:SetDamageType(DMG_CRUSH)
        target:TakeDamageInfo(d)

        sound.Play(moveSounds[math.random(1, #moveSounds)], ply:GetPos())
        sound.Play(attackSounds[math.random(1, #attackSounds)], ply:GetPos())

        attackers[ply] = CurTime()
    end

    local scp = {}

    scp.ID = "SCP_173"
    scp.Health = config.Health
    scp.Armor = config.Armor
    scp.Model = "models/scp_pandemic/deno_ports/scp_173/scp_173.mdl"
    scp.RunSpeed = config.RunSpeed
    scp.WalkSpeed = config.WalkSpeed
    scp.Respawn = false
    scp.CanSpeak = config.CanSpeak

    scp.Hooks = {
        ["OnTick"] = function(scp)
            if not istable(watchers[scp]) then return end

            -- Iterate over all players who have recently seen the SCP
            for i, ply in ipairs(watchers[scp]) do
                if !IsValid(ply) or !ply:Alive() or ply:IsFlagSet(FL_NOTARGET) then continue end

                -- Initialize blinker array with player if it doesn't exist
                lastBlink[ply] = lastBlink[ply] or CurTime()

                -- If it's time for the player to blink, force them to blink
                if lastBlink[ply] < CurTime() - config.ForcedBlinkDelay then
                    lastBlink[ply] = CurTime() + config.BlinkLength

                    net.Start("D_SCP173_BlinkHUD")
                    net.WriteEntity(ply)
                    net.Send(ply)

                    continue
                end

                -- We add BlinkLength to the lastBlink[ply] time to make sure the player's blink lasts long enough. If the player is still blinking continue
                if lastBlink[ply] > CurTime() then continue end

                -- If the player is not blinking and can see the scp, freeze the SCP
                if ply:CanSee(scp) then
                    if !scp:IsFlagSet(FL_FROZEN) then
                        scp:Freeze(true)
                    end

                    return 
                end
            end

            -- Unfreeze the SCP (This will only trigger if no players can see it)
            if scp:IsFlagSet(FL_FROZEN) then
                scp:Freeze(false)

                if config.ChangePoses then
                    // Randomize the player's pose on client and server
                    activeSequence[scp] = activeSequence[scp] or 0
                    local oldSequence = activeSequence[scp]
                    while activeSequence[scp] == oldSequence do
                        activeSequence[scp] = math.random(0, scp:GetSequenceCount()-1)
                    end

                    net.Start("D_SCP173_RandomizeSequence")
                    net.WriteEntity(scp)
                    net.WriteInt(activeSequence[scp], 8)
                    net.Broadcast()

                    scp:SetSequence(activeSequence[scp])
                end

                -- Call the attack function when unfrozen if they are trying to attack, helps make it easier to attack when people are blinking
                if scp:KeyDown(IN_ATTACK) then
                    SCP173_Attack(scp)
                end
            end
        end,
        ["OnPrimaryAttack"] = function(ply)
            SCP173_Attack(ply)
        end,
        ["OnRemoved"] = function(ply)
            net.Start("D_SCP173_RemoveWatcherTimers")
            net.WriteEntity(ply)
            net.Broadcast()
        end
    }

    D_SCPBase.RegisterSCP(scp)
end

if CLIENT then
    local CanBlink = false
    local LastBlink = 0

    --- The backend code that tells the server it's time to start blinking
    local function AddWatcher(watcher, scp)
        if !IsValid(watcher) or !IsValid(scp) then return end

        CanBlink = true

        -- We don't want to constantly be sending net messages saying that the player is watching the SCP
        -- To prevent this, we only send the net message when the player first sees the SCP and again when they stop watching
        if timer.Exists("D_SCP173_Watching_" .. scp:SteamID()) then
            timer.Adjust("D_SCP173_Watching_" .. scp:SteamID(), 10, nil, nil)
            return
        end 

        net.Start("D_SCP173_AddWatcher")
        net.WriteEntity(scp)
        net.SendToServer()

        timer.Create("D_SCP173_Watching_"  .. scp:SteamID(), 10, 1, function()
            if !IsValid(scp) || !IsValid(LocalPlayer()) then return end

            canBlink = false

            net.Start("D_SCP173_RemoveWatcher")
            net.WriteEntity(scp)
            net.SendToServer()
        end)
    end

    timer.Create("D_SCP173_CanBlinkCheck", 0.1, 0, function()
        if not IsValid(LocalPlayer()) then return end

        local SCPList = player.GetSCPs("SCP_173")

        for k,v in ipairs(SCPList) do
            if LocalPlayer():IsSCP() or !LocalPlayer():CanSee(v) then continue end

            AddWatcher(LocalPlayer(), v)
        end
    end)

    if config.ManualBlinking then
        local nextBlink = 0

        hook.Add("Think", "D_SCP173_BlinkKeyInput", function()
            if input.IsKeyDown( config.ManualBlinkKey ) and nextBlink < CurTime() and !gui.IsConsoleVisible() and !IsValid(vgui.GetKeyboardFocus()) then
                nextBlink = CurTime() + config.ManualBlinkDelay

                net.Start("D_SCP173_ManualBlink")
                net.SendToServer()
            end
        end)
    end

    --- The code to handle the client side HUD when blinking
    local function BlinkHUD()
        if lastBlink < CurTime() - config.BlinkLength then
            hook.Remove("PreDrawHUD", "D_SCP173_BlinkHUD")
            return
        end

        if config.AnimatedBlink then
            local blinkVal = Lerp((CurTime() - lastBlink) / (config.BlinkLength * 0.2), 0, 1)

            cam.Start2D()
                surface.SetDrawColor(0, 0, 0, 255 * blinkVal)
                surface.DrawRect(0, 0, ScrW(), (ScrH()*0.5) * blinkVal)
                surface.DrawRect(0, (ScrH()*0.5) + ((ScrH()*0.5) * (1-blinkVal)), ScrW(), ScrH())
            cam.End2D()
        else
            cam.Start2D()
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(0, 0, ScrW(), ScrH())
            cam.End2D()
        end
    end

    net.Receive("D_SCP173_BlinkHUD", function()
        lastBlink = CurTime()

        hook.Add("PreDrawHUD", "D_SCP173_BlinkHUD", BlinkHUD)
    end)

    net.Receive("D_SCP173_RandomizeSequence", function()
        local scp = net.ReadEntity()
        local seq = net.ReadInt(8)

        scp:SetSequence(seq)
    end)

    net.Receive("D_SCP173_RemoveWatcherTimers", function()
        local scp = net.ReadEntity()

        if timer.Exists("D_SCP173_Watching_" .. scp:SteamID()) then
            timer.Remove("D_SCP173_Watching_" .. scp:SteamID())
        end
    end)
end