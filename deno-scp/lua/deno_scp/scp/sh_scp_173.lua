-- Delay between manual blinks
local ManualBlinkDelay = 0.5
-- Delay between forced blinks
local ForcedBlinkDelay = 7.5
-- Key to blink manually
local ManualBlinkKey = KEY_N
-- Whether or not to allow manual blinking
local ManualBlinking = true
-- Length of the blink (In seconds) (Only affects client side vision)
local BlinkLength = 0.3
-- Whether or not to animate the client side blink 
local AnimatedBlink = true
-- Delay between attacks (In seconds)
local AttackDelay = 3
-- Attack Range (In units)
local AttackRange = 256
-- Snap Neck Damage
local AttackDamage = 10000

if SERVER then
    util.AddNetworkString("D_SCP173_AddWatcher")
    util.AddNetworkString("D_SCP173_RemoveWatcher")
    util.AddNetworkString("D_SCP173_ManualBlink")
    util.AddNetworkString("D_SCP173_BlinkHUD")

    D_SCPBase = D_SCPBase or {}

    -- Table of SCPs and their watchers <SCP, {Watchers}>
    local watchers = {}
    -- Table of watchers and their last blink time <Player, Time>
    local blinkers = {}
    -- Table of SCPs and the time of their last attack <Player, Time>
    local attackers = {}

    net.Receive("D_SCP173_AddWatcher", function(len, watcher)
        local scp = net.ReadEntity()

        if !IsValid(watcher) or !IsValid(scp) or scp:GetSCP() != "SCP_173" then return end

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
        if !ManualBlinking or !IsValid(ply) or table.IsEmpty(watchers) or !ply:Alive() then return end

        lastManualBlink[ply] = lastManualBlink[ply] or 0
        
        if !(lastManualBlink[ply] < CurTime() - ManualBlinkDelay) then return end

        blinkers[ply] = CurTime()
        lastManualBlink[ply] = CurTime()
    end)

    local function SCP173_Attack(ply)
        if ply:IsFlagSet(FL_FROZEN) then return end

        attackers[ply] = attackers[ply] or 0

        if !(attackers[ply] < CurTime() - AttackDelay) then return end

        local tr = ply:GetEyeTrace()

        local target = tr.Entity
        if !IsValid(target) or !(target:IsPlayer() or target:IsNPC()) or tr.HitPos:DistToSqr(ply:EyePos()) > (AttackRange * AttackRange) or target:Health() <= 0 then return end

        ply:SetPos(target:GetPos() - (target:GetPos() - ply:GetPos()):GetNormalized() * 40)
        
        local d = DamageInfo()
        d:SetAttacker(ply)
        d:SetDamage(AttackDamage)
        d:SetDamageType(DMG_CRUSH)
        target:TakeDamageInfo(d)

        attackers[ply] = CurTime()
    end

    local scp = {}

    scp.ID = "SCP_173"
    scp.Health = 10000
    scp.Armor = 0
    scp.Model = "models/mossman.mdl"
    scp.RunSpeed = 600
    scp.WalkSpeed = 400
    scp.Respawn = true
    scp.CanSpeak = false

    scp.Hooks = {
        ["OnTick"] = function(scp)
            if not istable(watchers[scp]) then return end

            -- Iterate over all players who have recently seen the SCP
            for _, ply in ipairs(watchers[scp]) do
                -- Initialize blinker array with player if it doesn't exist
                blinkers[ply] = blinkers[ply] or CurTime()

                -- If the player is blinking, blink them and disregard rest of code
                if blinkers[ply] < CurTime() then
                    blinkers[ply] = CurTime() + ForcedBlinkDelay

                    net.Start("D_SCP173_BlinkHUD")
                    net.Send(ply)
                    continue
                end

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

                -- Call the attack function when unfrozen if they are trying to attack, helps make it easier to attack when people are blinking
                if scp:KeyDown(IN_ATTACK) then
                    SCP173_Attack(scp)
                end
            end
        end,
        ["OnPrimaryAttack"] = function(ply)
            SCP173_Attack(ply)
        end
    }

    D_SCPBase.RegisterSCP(scp)
end

if CLIENT then
    local CanBlink = false
    local LastBlink = 0

    local watchingList = {}

    --- The backend code that tells the server it's time to start blinking
    local function AddWatcher(watcher, scp)
        if !IsValid(watcher) or !IsValid(scp) then return end

        CanBlink = true

        if table.HasValue(watchingList, scp) && timer.Exists("D_SCP173_Watching_" .. scp:SteamID()) then
            timer.Adjust("D_SCP173_Watching_" .. scp:SteamID(), 30, nil, nil)
            return
        end 

        table.insert(watchingList, scp)

        net.Start("D_SCP173_AddWatcher")
        net.WriteEntity(scp)
        net.SendToServer()

        timer.Create("D_SCP173_Watching_"  .. scp:SteamID(), 30, 1, function()
            if !IsValid(v) || !IsValid(LocalPlayer()) then return end

            canBlink = false

            net.Start("D_SCP173_RemoveWatcher")
            net.WriteEntity(scp)
            net.SendToServer()
        end)
    end

    timer.Create("D_SCP173_CanBlinkCheck", 0.1, 0, function()
        if not IsValid(LocalPlayer()) then return end

        local SCPList = GetSCPs("SCP_173")

        for k,v in ipairs(SCPList) do
            if(LocalPlayer():CanSee(v)) then
                AddWatcher(LocalPlayer(), v)
            end
        end
    end)

    if ManualBlinking then
        local nextBlink = 0

        hook.Add("Think", "D_SCP173_BlinkKeyInput", function()
            if input.IsKeyDown( ManualBlinkKey ) and nextBlink < CurTime() and !gui.IsConsoleVisible() and !IsValid(vgui.GetKeyboardFocus()) then
                nextBlink = CurTime() + ManualBlinkDelay

                net.Start("D_SCP173_ManualBlink")
                net.SendToServer()
            end
        end)
    end

    --- The code to handle the client side HUD when blinking
    local BlinkColor = Color(0, 0, 0, 255)
    local function BlinkHUD()
        if lastBlink < CurTime() - BlinkLength then
            hook.Remove("PreDrawHUD", "D_SCP173_BlinkHUD")
            return
        end

        if AnimatedBlink then
            local blinkVal = Lerp((CurTime() - lastBlink) / (BlinkLength * 0.2), 0, 1)

            cam.Start2D()
                surface.SetDrawColor(BlinkColor:Unpack())
                surface.DrawRect(0, 0, ScrW(), (ScrH()*0.5) * blinkVal)
                surface.DrawRect(0, (ScrH()*0.5) + ((ScrH()*0.5) * (1-blinkVal)), ScrW(), ScrH())
            cam.End2D()
        else
            cam.Start2D()
                surface.SetDrawColor(BlinkColor:Unpack())
                surface.DrawRect(0, 0, ScrW(), ScrH())
            cam.End2D()
        end
    end

    net.Receive("D_SCP173_BlinkHUD", function()
        lastBlink = CurTime()

        hook.Add("PreDrawHUD", "D_SCP173_BlinkHUD", BlinkHUD)
    end)
end