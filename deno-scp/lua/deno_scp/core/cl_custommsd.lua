// Custom MSD elements

timer.Simple(0, function()

    function MSD.DenoTextEntry(parent, x, y, w, h, label, value, func, num)
        local Entry = vgui.Create("DTextEntry")
    
        if x and y then
            Entry:SetParent(parent)
            Entry:SetPos(x, y)
        end
    
        if x == "static" then
            Entry.StaticScale = {
                w = w,
                fixed_h = h,
                minw = 50,
                minh = h
            }
        else
            Entry:SetSize(w, h)
        end
    
        Entry:SetNumeric(num or false)
        Entry:SetText("")
        Entry:SetFont("MSDFont.22")
        Entry.alpha = 0
        Entry:SetDrawLanguageID(false)
    
        Entry.Paint = function(self, wd, hd)
            if self:HasFocus() then
                self.alpha = Lerp(FrameTime() * 5, self.alpha, 255)
            else
                self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
            end
            local rf = MSD.Config.Rounded
            draw.RoundedBox(rf, 0, 0, wd, hd, MSD.Theme["l"])
            draw.RoundedBox(0, rf, hd - 1, wd - rf * 2, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha))
            draw.RoundedBox(0, rf, hd - 1, wd - rf * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha))
    
            if label and not self.error then
                draw.DrawText(label, "MSDFont.22", wd - 3, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_RIGHT)
                draw.DrawText(label, "MSDFont.22", wd - 3, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_RIGHT)
            end
    
            if self.error then
                draw.SimpleText(self.error, "MSDFont.16", 3, 0, MSD.Config.MainColor["r"], TEXT_ALIGN_LEFT)
            end
    
            self:DrawTextEntryText(self.error and MSD.Config.MainColor["rd"] or MSD.Text["l"], MSD.Config.MainColor["p"], MSD.Text["d"])
        end
    
        Entry.OnEnter = func
    
        Entry:SetText(value or "")
    
        if not x or not y then
            parent:AddItem(Entry)
        end
    
        return Entry
    end

    function MSD.DenoBoolSlider(parent, x, y, w, h, text, var, func)
        local button = vgui.Create("DButton")
        button:SetText("")
    
        if x and y then
            button:SetParent(parent)
            button:SetPos(x, y)
        end
    
        if x == "static" then
            button.StaticScale = {
                w = w,
                fixed_h = h,
                minw = 50,
                minh = h
            }
        else
            button:SetSize(w, h)
        end
    
        button.var = var or false
        button.pos = var and 1 or 0
        button.alpha = 0
        button.disabled = false
    
        button.Paint = function(self, wd, hd)
            draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])
    
            if (self.hover or self.hovered) and not self.disabled then
                self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
            else
                self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
            end
    
            draw.DrawText(text, "MSDFont.22", wd-3, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_RIGHT)
            draw.DrawText(text, "MSDFont.22", wd-3, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_RIGHT)
    
            if self.var then
                self.pos = Lerp(0.1, self.pos, 1)
            else
                self.pos = Lerp(0.1, self.pos, 0)
            end
    
            draw.RoundedBox(MSD.Config.Rounded, 7.5, hd / 2 - 10, 68, 20, MSD.Theme["d"])
    
            if self.disabled then
                draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", 40, hd / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
            else
                draw.DrawText(MSD.GetPhrase("off"), "MSDFont.16", 60, hd / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], 255 - self.pos * 255), TEXT_ALIGN_CENTER)
                draw.DrawText(MSD.GetPhrase("on"), "MSDFont.16", 25, hd / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], self.pos * 255), TEXT_ALIGN_CENTER)
                draw.RoundedBox(MSD.Config.Rounded, 7.5 + self.pos * 35, hd / 2 - 10, 34, 20, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.pos * 255))
                draw.RoundedBox(MSD.Config.Rounded, 7.5 + self.pos * 35, hd / 2 - 10, 34, 20, MSD.ColorAlpha(MSD.Text["n"], 255 - self.pos * 255))
            end
        end
    
        button.OnCursorEntered = function(self)
            self.hover = true
        end
    
        button.OnCursorExited = function(self)
            self.hover = false
        end
    
        button.DoClick = function(self)
            if self.disabled then return end
            self.var = not self.var
            func(self, self.var)
        end
    
        if not x or not y then
            parent:AddItem(button)
        end
    
        return button
    end

end)