local FontType = "Fonts\\FRIZQT__.ttf";  -- choose font here

local function ApplyFonts()
    PlayerFrameHealthBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameHealthBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameHealthBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")

    PlayerFrameManaBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameManaBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameManaBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")

    TargetFrameHealthBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameHealthBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameHealthBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")

    TargetFrameManaBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameManaBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameManaBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
end

SLASH_FF1 = "/ff";
SlashCmdList["FF"] = function(msg)
    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if cmd == "percent" and args == "enable" then
        FormatFix_UsePercent = true
    elseif cmd == "percent" and args == "disable" then
        FormatFix_UsePercent = false
    elseif cmd == "fontsize" and args ~= "" and tonumber(args) ~= nil then
        FormatFix_FontSize = tonumber(args)
        ApplyFonts();
    else
        print("Usage:")
        print("/ff percent enable  -  enable current HP | percentage HP mode. useful for bosses")
        print("/ff percent disable  -  disable current HP | percentage HP mode")
        print("/ff fontsize <number>  -  configure font size")
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
function f:ADDON_LOADED()
    if FormatFix_UsePercent == nil then FormatFix_UsePercent = false; end
    if FormatFix_FontSize == nil then FormatFix_FontSize = 12; end

    ApplyFonts();
end

local BarFormatFuncs={
    [PlayerFrameHealthBar]=function(self,textstring,val,min,max)
        textstring:SetText(AbbreviateLargeNumbers(val));
    end;
    [PlayerFrameManaBar]=function(self,textstring,val,min,max)
        textstring:SetText(AbbreviateLargeNumbers(val));
    end;
    [TargetFrameHealthBar]=function(self,textstring,val,min,max)
        if not FormatFix_UsePercent then textstring:SetText(AbbreviateLargeNumbers(val));
        elseif max==100 then textstring:SetText(AbbreviateLargeNumbers(val).."%");
        else textstring:SetFormattedText("%s || %.0f%%",AbbreviateLargeNumbers(val),100*val/max); end
    end;
}

BarFormatFuncs[PlayerFrameManaBar]=BarFormatFuncs[PlayerFrameHealthBar];
BarFormatFuncs[TargetFrameManaBar]=BarFormatFuncs[PlayerFrameHealthBar];

hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(self,...)
    if BarFormatFuncs[self] then
        if GetCVar("statusTextDisplay") == "NUMERIC" then
            BarFormatFuncs[self](self,...);
            (...):Show();
        end
    end
end);
