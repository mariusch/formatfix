local Name, AddOn = ...;
local Title = select(2,GetAddOnInfo(Name)):gsub("%s*v?[%d%.]+$","");

local FontType = "Fonts\\FRIZQT__.ttf";  -- choose font here!

local function ApplyFonts()
    PlayerFrameHealthBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameHealthBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameHealthBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")

    PlayerFrameManaBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameManaBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    PlayerFrameManaBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")

    if FormatFix_FormatPet then
        PetFrameHealthBar.TextString:SetFont(FontType, FormatFix_FontSize - 2, "OUTLINE")
        PetFrameHealthBar.LeftText:SetFont(FontType, FormatFix_FontSize - 2, "OUTLINE")
        PetFrameHealthBar.RightText:SetFont(FontType, FormatFix_FontSize - 2, "OUTLINE")

        PetFrameManaBar.TextString:SetFont(FontType, FormatFix_FontSize - 2, "OUTLINE")
        PetFrameManaBar.LeftText:SetFont(FontType, FormatFix_FontSize - 2, "OUTLINE")
        PetFrameManaBar.RightText:SetFont(FontType, FormatFix_FontSize - 2, "OUTLINE")
    end
	
	FocusFrameHealthBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    FocusFrameHealthBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    FocusFrameHealthBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
	
	FocusFrameManaBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    FocusFrameManaBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    FocusFrameManaBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")

    TargetFrameHealthBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameHealthBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameHealthBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")

    TargetFrameManaBar.TextString:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameManaBar.LeftText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
    TargetFrameManaBar.RightText:SetFont(FontType, FormatFix_FontSize, "OUTLINE")
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
function f:ADDON_LOADED()
    if FormatFix_UsePercent == nil then FormatFix_UsePercent = false; end
    if FormatFix_FormatPet == nil then FormatFix_FormatPet = false; end
    if FormatFix_FontSize == nil then FormatFix_FontSize = 12; end

    ApplyFonts();
    if not f.optionsPanel then
        f.optionsPanel = f:CreateGUI()
    end
end

local BarFormatFuncs={
    [PlayerFrameHealthBar]=function(self,textstring,val,min,max)
        textstring:SetText(AbbreviateLargeNumbers(val));
    end;
	 [FocusFrameHealthBar]=function(self,textstring,val,min,max)
        textstring:SetText(AbbreviateLargeNumbers(val));
    end;
    [TargetFrameHealthBar]=function(self,textstring,val,min,max)
        if not FormatFix_UsePercent then textstring:SetText(AbbreviateLargeNumbers(val));
        elseif max==100 then textstring:SetText(AbbreviateLargeNumbers(val).."%");
        else textstring:SetFormattedText("%s || %.0f%%",AbbreviateLargeNumbers(val),100*val/max); end
    end;
    [PetFrameHealthBar]=function(self,textstring,val,min,max)
        if FormatFix_FormatPet then
            textstring:SetText(AbbreviateLargeNumbers(val));
        end;
    end;
    [PetFrameManaBar]=function(self,textstring,val,min,max)
        if FormatFix_FormatPet then
            textstring:SetText(AbbreviateLargeNumbers(val));
            textstring:SetPoint("CENTER", PetFrame, "TOPLEFT", 82, -35);
        end;
    end;
}

BarFormatFuncs[PlayerFrameManaBar]=BarFormatFuncs[PlayerFrameHealthBar];
BarFormatFuncs[FocusFrameManaBar]=BarFormatFuncs[FocusFrameHealthBar];
BarFormatFuncs[TargetFrameManaBar]=BarFormatFuncs[PlayerFrameHealthBar];

hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(self,...)
    if BarFormatFuncs[self] then
        if GetCVar("statusTextDisplay") == "NUMERIC" then
            BarFormatFuncs[self](self,...);
            (...):Show();
        end
    end
end);

function f:CreateGUI()
    local Panel=CreateFrame("Frame"); do
        Panel.name=Title;
        InterfaceOptions_AddCategory(Panel);--	Panel Registration

        local title=Panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
        title:SetPoint("TOPLEFT",12,-15);
        title:SetText(Title);

        local name = "PercentButton"
        local template = "UICheckButtonTemplate"
        local PercentButton = CreateFrame("CheckButton", name, Panel, "UICheckButtonTemplate")
        PercentButton:SetPoint("TOPLEFT", 10, -60)
        PercentButton.text = _G[name.."Text"]
        PercentButton.text:SetText("Hybrid Percent Mode")
        PercentButton:SetChecked(FormatFix_UsePercent)
        PercentButton:SetScript("OnClick", function() FormatFix_UsePercent = not FormatFix_UsePercent end)

        local name = "FormatPetButton"
        local template = "UICheckButtonTemplate"
        local FormatPetButton = CreateFrame("CheckButton", name, Panel, "UICheckButtonTemplate")
        FormatPetButton:SetPoint("TOPLEFT", 10, -100)
        FormatPetButton.text = _G[name.."Text"]
        FormatPetButton.text:SetText("Format Pet Frame (Requires Reload)")
        FormatPetButton:SetChecked(FormatFix_FormatPet)
        FormatPetButton:SetScript("OnClick", function() FormatFix_FormatPet = not FormatFix_FormatPet end)

        local name = "FontSizeSlider"
        local template = "OptionsSliderTemplate"
        local FontSizeSlider = CreateFrame("Slider", name, Panel, template)
        FontSizeSlider:SetPoint("TOPLEFT",20, -160)
        FontSizeSlider.textLow = _G[name.."Low"]
        FontSizeSlider.textHigh = _G[name.."High"]
        FontSizeSlider.text = _G[name.."Text"]
        FontSizeSlider:SetMinMaxValues(8, 16)
        FontSizeSlider.minValue, FontSizeSlider.maxValue = FontSizeSlider:GetMinMaxValues()
        FontSizeSlider.textLow:SetText(FontSizeSlider.minValue)
        FontSizeSlider.textHigh:SetText(FontSizeSlider.maxValue)
        FontSizeSlider:SetValue(FormatFix_FontSize)
        FontSizeSlider.text:SetText("Font Size: "..FontSizeSlider:GetValue(FormatFix_FontSize))
        FontSizeSlider:SetValueStep(1)
        FontSizeSlider:SetObeyStepOnDrag(true);
        FontSizeSlider:SetScript("OnValueChanged", function(self,event,arg1)
            FontSizeSlider.text:SetText("Font Size: "..FontSizeSlider:GetValue(FormatFix_FontSize))
            FormatFix_FontSize = FontSizeSlider:GetValue()
            ApplyFonts()
        end)
    end

    return Panel
end
