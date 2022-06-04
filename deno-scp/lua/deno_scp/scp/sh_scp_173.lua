// Delay between manual blinks
local ManualBlinkDelay = 0.5
// Delay between forced blinks
local ForcedBlinkDelay = 7.5
// Key to blink manually
local ManualBlinkKey = KEY_N
// Whether or not to allow manual blinking
local ManualBlinking = true

if SERVER then
    util.AddNetworkString("D_SCP173_AddWatcher")
    util.AddNetworkString("D_SCP173_RemoveWatcher")
    util.AddNetworkString("D_SCP173_ManualBlink")
    util.AddNetworkString("D_SCP173_BlinkHUD")

    D_SCPBase = D_SCPBase or {}

    local scp = {}
    local watchers = {}
    local blinkers = {}

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

    scp.ID = "SCP_173"
    scp.Health = 10000
    scp.Armor = 0
    scp.Model = "models/mossman.mdl"

    scp.Hooks = {
        ["OnTick"] = function(scp)
            if not istable(watchers[scp]) then return end

            for _, ply in ipairs(watchers[scp]) do
                blinkers[ply] = blinkers[ply] or CurTime()

                if blinkers[ply] < CurTime() then
                    blinkers[ply] = CurTime() + ForcedBlinkDelay

                    net.Start("D_SCP173_BlinkHUD")
                    net.Send(ply)
                    continue
                end

                if ply:CanSee(scp) then
                    scp:SetColor(Color(255, 0, 0))
                    return 
                end
            end

            scp:SetColor(Color(0, 255, 0))
        end
    }

    D_SCPBase.RegisterSCP(scp)
end

if CLIENT then
    local CanBlink = false

    local watchingList = {}

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

        timer.Start("D_SCP173_Watching_" .. scp:SteamID())
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
    timer.Start("D_SCP173_CanBlinkCheck")

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
end