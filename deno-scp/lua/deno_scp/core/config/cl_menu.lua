D_SCPBase = D_SCPBase or {}

local vigColor = Color(0, 0, 0, 150)
local grey = Color(200, 200, 200, 255)

D_SCPBase.OpenConfigMenu = function()
    if D_SCPBase.ConfigMenu then
        D_SCPBase.ConfigMenu:AlphaTo(0, 0.4, 0, function()
            D_SCPBase.ConfigMenu:Close()
        end)
        
        return
    end

    local w = ScrW() * 0.5
    local h = ScrH() * 0.8

    local panel = vgui.Create("MSDSimpleFrame")
    panel:SetSize(w, h)
	panel:SetDraggable(true)
	panel:Center()
	panel:MakePopup()
	panel:SetAlpha(0)
	panel:AlphaTo(255, 0.3)

    panel.OnClose = function()
        D_SCPBase.ConfigMenu = nil
    end

    panel:SetAlpha(1)
    panel:AlphaTo(255, 0.4)

    panel.Paint = function(self, w, h)
        MSD.Blur(self, 1, 1, 255, 55, w, h)
        MSD.DrawTexturedRect(0, 0, w, h, MSD.Materials.vignette, vigColor)

		draw.RoundedBox(0, 0, 0, w, 50, MSD.Theme["l"])
		draw.RoundedBox(0, 0, 0, w, 50, MSD.Theme["l"])
		draw.RoundedBox(0, 0, 52, w, h - 52, MSD.Theme["l"])
		draw.DrawText("D-SCP Config Menu", "MSDFont.25", 12, 12, color_white, TEXT_ALIGN_LEFT)
	end

	panel.closeButton = MSD.IconButton(panel, MSD.Icons48.cross, w - 34, 10, 25, nil, MSD.Config.MainColor.p, function()
		if panel.OnPress then
			panel.OnPress()
			return
		end

		panel:AlphaTo(0, 0.4, 0, function()
			panel:Close()
		end)

        D_SCPBase.UpdateServerConfig(D_SCPBase.Config)
	end)

    panel.backButton = MSD.IconButton(panel, MSD.Icons48.back, 10, 60, 25, nil, MSD.Config.MainColor.p, function()
        panel.backButton:AlphaTo(0, 0.2, 0, function()
            panel.backButton:Hide()

            panel.ConfigButtons:Show()
            panel.ConfigButtons:AlphaTo(255, 0.2)
        end)

        for k,v in pairs(panel.ConfigButtons:GetItems()) do
            v.Settings:Hide()
        end
    end)
    panel.backButton:Hide()

    panel.ConfigButtons = vgui.Create("MSDPanelList", panel)
    panel.ConfigButtons:SetSize(w, h-72)
    panel.ConfigButtons:SetPos(0, 52)
    panel.ConfigButtons:SetSpacing(10)
    panel.ConfigButtons:EnableVerticalScrollbar(true)
    panel.ConfigButtons:EnableHorizontal(true)
    panel.ConfigButtons:SetPadding(25)

    for config, configTable in pairs(D_SCPBase.Config) do
        local button = MSD.Button(nil, 0, 0, w-50, 75, config, function(btn)
            panel.ConfigButtons:AlphaTo(0, 0.2, 0, function()
                panel.ConfigButtons:Hide()

                panel.backButton:Show()
                panel.backButton:AlphaTo(255, 0.2)
            end)

            btn.Settings:Show()
            btn.Settings:AlphaTo(255, 0.2)
        end)

        panel.ConfigButtons:AddItem(button)

        button.Settings = vgui.Create("MSDPanelList", panel)
        button.Settings:SetSize(w, h-92)
        button.Settings:SetPos(0, 80)
        button.Settings:SetSpacing(10)
        button.Settings:EnableVerticalScrollbar(true)
        button.Settings:EnableHorizontal(true)
        button.Settings:SetPadding(w/100)

        for setting, tbl in pairs(configTable) do
            local w2 = w/2.1
            local h2 = 150
    
            local settingPanel = vgui.Create("DPanel")
            settingPanel:SetSize(w2, h2)
            settingPanel.Paint = function(self, w, h)
                MSD.DrawTexturedRect(0, 0, w, h, MSD.Materials.vignette, vigColor)

                draw.RoundedBox(0, 0, 0, w, 40, MSD.Theme["l"])
                draw.RoundedBox(0, 0, 0, w, 40, MSD.Theme["l"])
                draw.RoundedBox(0, 0, 42, w, h - 42, MSD.Theme["l"])

                draw.DrawText(setting, "MSDFont.22", 12, 8, color_white, TEXT_ALIGN_LEFT)
            end

            if tbl.Type == "Number" then
                local entry = MSD.DenoTextEntry(settingPanel, 12, 45, w2-24, h2-50, tbl.Description, tbl.Value, function(entry, val)
                    val = tonumber(val)
                    if val == nil then return end

                    if val < tbl.Min then
                        val = tbl.Min
                    elseif val > tbl.Max then
                        val = tbl.Max
                    end

                    entry:SetText(val)

                    D_SCPBase.Config[config][setting].Value = val
                end, true)
            elseif tbl.Type == "Boolean" then
                local slider = MSD.DenoBoolSlider(settingPanel, 12, 45, w2-24, h2-50, tbl.Description, tbl.Value, function(slider, val)
                    D_SCPBase.Config[config][setting].Value = val
                end)
            elseif tbl.Type == "Key" then
                local binder = MSD.Binder(settingPanel, 12, 45, w2-24, h2-50, tbl.Description, tbl.Value, function(val)
                    D_SCPBase.Config[config][setting].Value = val
                end)
            elseif tbl.Type == "Multiple" then
                local combo = MSD.ComboBox(settingPanel, 12, 45, w2-24, h2-50, tbl.Description, table.KeyFromValue(tbl.Options, tbl.Value) or tbl.Value or "")
                
                for k,v in pairs(tbl.Options) do
                    combo:AddChoice(k)
                end

                combo.OnSelect = function(self, index, value)
                    D_SCPBase.Config[config][setting].Value = tbl.Options[value]
                end
            end

            button.Settings:AddItem(settingPanel)
        end

        button.Settings:Hide()
    end

    D_SCPBase.ConfigMenu = panel
    return panel
end

timer.Simple(0, function()
    D_SCPBase.RequestConfig()
end)