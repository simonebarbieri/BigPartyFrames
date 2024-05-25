function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function BPF:RemoveRealmFromName(self)
    if not BPF_DB.remove_realm_name then return end
    if not self.Name then return end
    if not self.Name:GetText() then return end
    if not self.unit then return end
    if not UnitIsPlayer(self.unit) then return end

    local name = string.split(self.Name:GetText(), "-")[1]

    self.Name:SetText(name)
end

function BPF:ClassPortraits(self)
    local _, unitClass = UnitClass(self.unit)
    if string.match(self.unit, "party") and unitClass and UnitInParty(self.unit) and self.Portrait then
        if BPF_DB.use_class_portraits then
            self.Portrait:SetTexture("Interface/TargetingFrame/UI-Classes-Circles")
            self.Portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
        else
            SetPortraitTexture(self.Portrait, self.unit)
            self.portrait:SetTexCoord(0, 1, 0, 1)
        end
    end
end

function BPF:SetPartyMemberFrameStyle(self)
    if not(string.match(self.unit, "party") and UnitInParty(self.unit)) then return end
    if self:IsForbidden() then return end
    if InCombatLockdown() then return end

    self:SetWidth(partyStyle.width)
    self:SetHeight(partyStyle.height)
    self.Texture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn")
    if self.state == "vehicle" then
        self.Texture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Vehicle")
    end
    self.Texture:SetSize(partyStyle.width, partyStyle.height)

    self.HealthBar:SetSize(partyStyle.health_width, partyStyle.health_heigth)
    self.HealthBar:SetPoint("TOPLEFT", partyStyle.health_point_x, partyStyle.health_point_y)
    self.HealthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health")
    self.HealthBar.HealthBarTexture:SetSize(partyStyle.width, partyStyle.health_heigth)
    self.HealthBar.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask")
    self.HealthBar.HealthBarMask:SetSize(partyStyle.width, partyStyle.health_heigth)
    self.HealthBar.HealthBarMask:SetPoint("TOPLEFT", partyStyle.health_mask_point_x, partyStyle.health_mask_point_y)

    self.HealthBar.LeftText:SetPoint("LEFT", self.HealthBar, "LEFT", partyStyle.healthBarTextOffsetX, partyStyle.healthBarTextOffsetY)
    self.HealthBar.RightText:SetPoint("RIGHT", self.HealthBar, "RIGHT", 0, partyStyle.healthBarTextOffsetY)

    self.Flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat")
    self.Flash:SetSize(partyStyle.width - 5, partyStyle.height)

    self.ManaBar:SetSize(partyStyle.mana_width, partyStyle.mana_heigth)
    self.ManaBar:SetPoint("TOPLEFT", partyStyle.mana_point_x, partyStyle.mana_point_y)
    self.ManaBar:GetStatusBarTexture():SetSize(partyStyle.width, partyStyle.mana_heigth)
    self.ManaBar.ManaBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask")
    self.ManaBar.ManaBarMask:SetSize(partyStyle.width, partyStyle.mana_heigth)
    self.ManaBar.ManaBarMask:SetPoint("TOPLEFT", self, "TOPLEFT", partyStyle.mana_mask_point_x, partyStyle.mana_mask_point_y)

    self.Name:SetWidth(partyStyle.name_width)
    self.Name:SetPoint("TOPLEFT", partyStyle.name_point_x, partyStyle.name_point_y)

    self.Portrait:SetSize(partyStyle.portrait_size, partyStyle.portrait_size)
    self.Portrait:SetPoint("TOPLEFT", partyStyle.portrait_point_x, partyStyle.portrait_point_y)

    self.PartyMemberOverlay.Status:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize)
    self.PartyMemberOverlay.Status:SetPoint("TOPLEFT", self, "TOPLEFT", partyStyle.status_point_x, partyStyle.status_point_y)

    self.PartyMemberOverlay.RoleIcon:SetPoint("TOPLEFT", partyStyle.role_point_x, partyStyle.role_point_y)

    self.AuraFrameContainer:SetPoint("TOPLEFT", 500, -43)

    inRange, _ = UnitInRange(self.unit)

    if inRange then
        self:SetAlpha(1.0)
    else
        self:SetAlpha(0.30)
    end
end

function BPF:EnablePartyStyle()
    local partyMemberFrameHookFunctions = {
        "ToPlayerArt",
        "ToVehicleArt",
        "UpdateArt",
        "UpdateHealthBarTextAnchors",
        "UpdateManaBarTextAnchors",
        "UpdateNameTextAnchors",
        "UpdateVoiceActivityNotification",
        "UpdateMember",
        "UpdatePet",
        "UpdateMemberHealth",
        "UpdateLeader",
        "UpdatePvPStatus",
        "UpdateAssignedRoles",
        "UpdateVoiceStatus",
        "UpdateReadyCheck",
        "UpdateNotPresentIcon",
        "UpdateOnlineStatus",
        "UpdateAuras"
    }
    local unitFrameHookFunctions = {
        "UnitFrame_Update",
        "UnitFramePortrait_Update",
        "UnitFrame_UpdateTooltip",
        "UnitFrame_OnEvent"
    }

    for i=1, MAX_PARTY_MEMBERS do
        local PartyMemberFrame = PartyFrame["MemberFrame" .. i]
        if PartyMemberFrame then
            for _, func in pairs(partyMemberFrameHookFunctions) do
                hooksecurefunc(PartyMemberFrame, func, function(self)
                    BPF:SetPartyMemberFrameStyle(self)
                end)
            end
            for _, func in pairs(unitFrameHookFunctions) do
                hooksecurefunc(func, function(self)
                    BPF:SetPartyMemberFrameStyle(self)
                end)
            end
            PartyMemberFrame:HookScript("OnEvent", function(self)
                BPF:SetPartyMemberFrameStyle(self)
            end)
            hooksecurefunc("UnitFramePortrait_Update", function(self)
                BPF:ClassPortraits(self)
            end)
            hooksecurefunc("UnitFrame_Update", function(self)
                BPF:RemoveRealmFromName(self)
            end)
        end
    end
end
