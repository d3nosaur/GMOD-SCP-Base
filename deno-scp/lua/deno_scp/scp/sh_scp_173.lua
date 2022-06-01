// The range around the SCP where players will start to blink
local BlinkRange = 1024

if SERVER then
    util.AddNetworkString("D_SCP173_AddWatcher")

    D_SCPBase = D_SCPBase or {}

    local scp = {}
    local watchers = {}

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

    scp.ID = "SCP_173"
    scp.Health = 10000
    scp.Armor = 0
    scp.Model = "models/armacham/security/guard_1.mdl"

    scp.Hooks = {
        ["OnTick"] = function(scp)
            for _, ply in ipairs(watchers[scp]) do
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
            timer.Adjust("D_SCP173_Watching_" .. scp:SteamID(), 15, nil, nil)
            return
        end 

        table.insert(watchingList, scp)

        net.Start("D_SCP173_AddWatcher")
        net.WriteEntity(scp)
        net.SendToServer()

        timer.Create("D_SCP173_Watching_"  .. scp:SteamID(), 15, 1, function()
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
            if(LocalPlayer():CanSee(v)) || v:GetPos():DistToSqr(LocalPlayer():GetPos()) < BlinkRange*BlinkRange then
                AddWatcher(LocalPlayer(), v)
            end
        end
    end)
    timer.Start("D_SCP173_CanBlinkCheck")
end