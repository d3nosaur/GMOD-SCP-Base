if SERVER then
    util.AddNetworkString("D_SCP173_AddWatcher")

    local watchers = {}

    D_SCPBase = D_SCPBase or {}
    local scp = {}

    scp.ID = "SCP_173"
    scp.Health = 10000
    scp.Armor = 0
    scp.Model = "models/armacham/security/guard_1.mdl"

    scp.Hooks = {
        ["OnDamaged"] = function(ply, dmg)
            print("peanut got hurt")
        end,
        ["OnTick"] = function(scp)
            for ply,v in pairs(watchers[scp]) do
                if ply:CanSee(scp) then
                    scp:SetColor(Color(255, 0, 0))
                    return 
                end
            end

            scp:SetColor(Color(0, 255, 0))
        end
    }

    net.Receive("D_SCP173_AddWatcher", function()
        local watcher = net.ReadEntity()
        local scp = net.ReadEntity()

        if !IsValid(watcher) or !IsValid(scp) then return end

        watchers[scp] = watchers[scp] or {}

        watchers[scp][watcher] = true
    end)

    net.Receive("D_SCP173_RemoveWatcher", function()
        local watcher = net.ReadEntity()
        local scp = net.ReadEntity()

        if !IsValid(watcher) or !IsValid(scp) then return end

        watchers[scp] = watchers[scp] or {}

        watchers[scp][watcher] = nil
    end)

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
        net.WriteEntity(LocalPlayer())
        net.WriteEntity(scp)
        net.SendToServer()

        timer.Create("D_SCP173_Watching_"  .. scp:SteamID(), 15, 1, function()
            if !IsValid(v) || !IsValid(LocalPlayer()) then return end

            net.Start("D_SCP173_RemoveWatcher")
            net.WriteEntity(LocalPlayer())
            net.WriteEntity(scp)
            net.SendToServer()
        end)

        timer.Start("D_SCP173_Watching_" .. scp:SteamID())
    end

    timer.Create("D_SCP173_CanBlinkCheck", 0.1, 0, function()
        if not IsValid(LocalPlayer()) then return end

        local SCPList = {}

        for k,v in pairs(ents.GetAll()) do
            if v:IsPlayer() and v:GetSCP() == "SCP_173" then
                table.insert(SCPList, v)
            end
        end

        for k,v in ipairs(SCPList) do
            if !IsValid(v) then 
                table.remove(SCPList, k)
                continue
            end

            if(LocalPlayer():CanSee(v)) || v:GetPos():Distance(LocalPlayer():GetPos()) < 1024 then
                AddWatcher(LocalPlayer(), v)
            end
        end
    end)
    timer.Start("D_SCP173_CanBlinkCheck")
end