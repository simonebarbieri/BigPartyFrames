BigPartyMemberFrameMixin={}

function BigPartyMemberFrameMixin:GetUnit()
	-- Override unit is set when we get in a vehicle
	-- Override unit will always be the original (most likely player/party member)
	return self.overrideUnit or self.unit
end

function BigPartyMemberFrameMixin:UpdateArt()
	if UnitHasVehicleUI(self.unit) and UnitIsConnected(self:GetUnit()) then
		self:ToVehicleArt()
	else
		self:ToPlayerArt()
	end
end

function BigPartyMemberFrameMixin:ToPlayerArt()
    if self:IsForbidden() then return end
    if InCombatLockdown() then return end

	self.state = "player"
	self.overrideUnit = nil

	self.VehicleTexture:Hide()
	self.Texture:Show()

	self.Texture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn")

	self.Flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-InCombat", TextureKitConstants.UseAtlasSize)
	self.Flash:SetPoint("CENTER", self, "CENTER", -1.5, 1)

	self.StatusFlash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Status", TextureKitConstants.UseAtlasSize)
	self.StatusFlash:SetPoint("TOPLEFT", self, "TOPLEFT", 18, -14)

	self.HealthBar:SetWidth(124)
	self.HealthBar:SetPoint("TOPLEFT", 85, -41)

	self.HealthBar.HealthBarMask:SetPoint("TOPLEFT", self.HealthBar, "TOPLEFT", -2, 6)

	self.HealthBar:SetHeight(19)
	self.HealthBar.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Mask")
	self.HealthBar.HealthBarMask:SetHeight(31)

	self.ManaBar:SetHeight(10)
	self.ManaBar:SetWidth(124)
	self.ManaBar:SetPoint("TOPLEFT", 85, -61)

	self.ManaBar.ManaBarMask:SetWidth(128)
	self.ManaBar.ManaBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask", TextureKitConstants.UseAtlasSize)

	self:UpdateNameTextAnchors()

	securecall("UnitFrame_SetUnit", self, self.unit, self.HealthBar, self.ManaBar)
	securecall("UnitFrame_Update", self, true)
end

function BigPartyMemberFrameMixin:ToVehicleArt()
    if self:IsForbidden() then return end
    if InCombatLockdown() then return end

	self.state = "vehicle"
	self.overrideUnit = self.unit

	self.Texture:Hide()
	self.VehicleTexture:Show()

	self.Flash:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Vehicle-InCombat", TextureKitConstants.UseAtlasSize)
	self.Flash:SetPoint("CENTER", self.Flash:GetParent(), "CENTER", -3.5, 1)

	self.PartyMemberOverlay.Status:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Vehicle-Status", TextureKitConstants.UseAtlasSize)
	self.PartyMemberOverlay.Status:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 3)

	self.HealthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Vehicle-Bar-Health", TextureKitConstants.UseAtlasSize)
	self.HealthBar:SetWidth(118)
	self.HealthBar:SetHeight(20)
	self.HealthBar:SetPoint("TOPLEFT", 91, -40)
	self:UpdateHealthBarTextAnchors()

	-- Party frames when in a vehicle do not have a mask for the health bar, so remove any applied target mask that would not fit.
	self.HealthBar.HealthBarMask:SetPoint("TOPLEFT", self.HealthBar.HealthBarMask:GetParent(), "TOPLEFT", -8, 6)

	self.ManaBar:SetWidth(118)
	self.ManaBar:SetHeight(10)
	self.ManaBar:SetPoint("TOPLEFT",91,-61)
	self:UpdateManaBarTextAnchors()

	self.ManaBar.ManaBarMask:SetWidth(121)
	self.ManaBar.ManaBarMask:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask")

	self:UpdateNameTextAnchors()

	securecall("UnitFrame_SetUnit", self, self.petUnitToken, self.HealthBar, self.ManaBar)
	securecall("UnitFrame_Update", self, true)
end

function BigPartyMemberFrameMixin:UpdateHealthBarTextAnchors()
	local healthBarTextOffsetX = 0
	local healthBarTextOffsetY = 0
	if (LOCALE_koKR) then
		healthBarTextOffsetY = 1
	elseif (LOCALE_zhCN) then
		healthBarTextOffsetY = 2
	end

	self.HealthBar.CenterText:SetPoint("CENTER", self.HealthBar, "CENTER", 0, healthBarTextOffsetY)
	self.HealthBar.LeftText:SetPoint("LEFT", self.HealthBar, "LEFT", healthBarTextOffsetX, healthBarTextOffsetY)
	self.HealthBar.RightText:SetPoint("RIGHT", self.HealthBar, "RIGHT", -healthBarTextOffsetX, healthBarTextOffsetY)
end

function BigPartyMemberFrameMixin:UpdateManaBarTextAnchors()
	local manaBarTextOffsetY = 0
	if (LOCALE_koKR) then
		manaBarTextOffsetY = 1
	elseif (LOCALE_zhCN) then
		manaBarTextOffsetY = 2
	end

	self.ManaBar.CenterText:SetPoint("CENTER", self.ManaBar, "CENTER", 2, manaBarTextOffsetY)
	self.ManaBar.RightText:SetPoint("RIGHT", self.ManaBar, "RIGHT", 0, manaBarTextOffsetY)

	if(self.state == "player") then
		self.ManaBar.LeftText:SetPoint("LEFT", self.ManaBar, "LEFT", 4, manaBarTextOffsetY)
	else
		self.ManaBar.LeftText:SetPoint("LEFT", self.ManaBar, "LEFT", 3, manaBarTextOffsetY)
	end
end

function BigPartyMemberFrameMixin:UpdateNameTextAnchors()
	if(self.state == "player") then
		self.Name:SetPoint("TOPLEFT", 88, -27)
	else
		self.Name:SetPoint("TOPLEFT", 96, -27)
	end
end

function BigPartyMemberFrameMixin:Setup()
	self.unitToken = "party"..self.layoutIndex
	self.petUnitToken = "partypet"..self.layoutIndex

	self.debuffCountdown = 0
	self.numDebuffs = 0

	UnitFrame_Initialize(self, self.unitToken, self.Name, self.frameType, self.Portrait,
		   self.HealthBar,
		   self.HealthBar.CenterText,
		   self.ManaBar,
		   self.ManaBar.CenterText,
		   self.Flash, nil, nil,
		   self.HealthBar.MyHealPredictionBar,
		   self.HealthBar.OtherHealPredictionBar,
		   self.HealthBar.TotalAbsorbBar,
		   self.HealthBar.OverAbsorbGlow,
		   self.HealthBar.OverHealAbsorbGlow,
		   self.HealthBar.HealAbsorbBar)

	self.HealthBar:SetBarTextZeroText(DEAD)

	self.statusCounter = 0
	self.statusSign = -1
	self.unitHPPercent = 1

	-- Mask the various bar assets, to avoid any overflow with the frame shape.
	self.HealthBar:GetStatusBarTexture():AddMaskTexture(self.HealthBar.HealthBarMask)

	self.ManaBar:GetStatusBarTexture():AddMaskTexture(self.ManaBar.ManaBarMask)

	self:UpdateMember()
	self:UpdateLeader()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	self:RegisterEvent("MUTELIST_UPDATE")
	self:RegisterEvent("IGNORELIST_UPDATE")
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("UNIT_CONNECTION")
	self:RegisterEvent("PARTY_MEMBER_ENABLE")
	self:RegisterEvent("PARTY_MEMBER_DISABLE")
	self:RegisterEvent("UNIT_PHASE")
	self:RegisterEvent("UNIT_CTR_OPTIONS")
	self:RegisterEvent("UNIT_FLAGS")
	self:RegisterEvent("UNIT_OTHER_PARTY_CHANGED")
	self:RegisterEvent("INCOMING_SUMMON_CHANGED")
	self:RegisterUnitEvent("UNIT_AURA", self.unitToken, self.petUnitToken)
	self:RegisterUnitEvent("UNIT_PET",  self.unitToken, self.petUnitToken)

	local function OpenContextMenu(frame, unit, button, isKeyPress)
		local contextData =
		{
			unit = unit,
		};
		UnitPopup_OpenMenu("PARTY", contextData)
	end

	SecureUnitButton_OnLoad(self, self.unitToken, OpenContextMenu)

	self:UpdateArt()
	self:SetFrameLevel(2)
	self:UpdateNotPresentIcon()

	UnitPowerBarAlt_Initialize(self.PowerBarAlt, self.unitToken, 0.5, "GROUP_ROSTER_UPDATE")

	self.initialized = true
end

function BigPartyMemberFrameMixin:UpdateVoiceActivityNotification()
	if self.voiceNotification then
		self.voiceNotification:ClearAllPoints()
		if self.NotPresentIcon:IsShown() then
			self.voiceNotification:SetPoint("LEFT", self.NotPresentIcon, "RIGHT", 0, 0)
		else
			self.voiceNotification:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -12)
		end
	end
end

function BigPartyMemberFrameMixin:VoiceActivityNotificationCreatedCallback(notification)
	self.voiceNotification = notification
	self.voiceNotification:SetParent(self)
	self:UpdateVoiceActivityNotification()
	notification:Show()
end

function BigPartyMemberFrameMixin:UpdateMember()
	if not BigPartyFrame:ShouldShow() then
		self:Hide()
		return
	end

	local showFrame
	if EditModeManagerFrame:ArePartyFramesForcedShown() and not UnitExists(self.unitToken) then
		securecall("UnitFrame_SetUnit", self, "player", self.HealthBar, self.ManaBar)
		showFrame = true
	else
		securecall("UnitFrame_SetUnit", self, self.unitToken, self.HealthBar, self.ManaBar)
		showFrame = UnitExists(self.unitToken)
	end
	if showFrame then
		self:Show()

		if VoiceActivityManager then
			local guid = UnitGUID(self:GetUnit())
			VoiceActivityManager:RegisterFrameForVoiceActivityNotifications(self, guid, nil, "VoiceActivityNotificationPartyTemplate", "Button", PartyMemberFrameMixin.VoiceActivityNotificationCreatedCallback)
		end

		securecall("UnitFrame_Update", self, true)
	else
		if VoiceActivityManager then
			VoiceActivityManager:UnregisterFrameForVoiceActivityNotifications(self)
			self.voiceNotification = nil
		end
		self:Hide()
	end

	self:UpdateDistance()

	self:UpdatePvPStatus()
	self:UpdateVoiceStatus()
	self:UpdateReadyCheck()
	self:UpdateOnlineStatus()
	self:UpdateNotPresentIcon()
	self:UpdateArt()
end

function BigPartyMemberFrameMixin:UpdateMemberHealth(elapsed)
	if ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
		local alpha = 255
		local counter = self.statusCounter + elapsed
		local sign    = self.statusSign

		if ( counter > 0.5 ) then
			sign = -sign
			self.statusSign = sign
		end
		counter = mod(counter, 0.5)
		self.statusCounter = counter

		if ( sign == 1 ) then
			alpha = (127  + (counter * 256)) / 255
		else
			alpha = (255 - (counter * 256)) / 255
		end
		self.Portrait:SetAlpha(alpha)
	end
end

function BigPartyMemberFrameMixin:UpdateDistance()
	local inRange, _ = UnitInRange(self.unit)

    if inRange then
        self:SetAlpha(1.0)
    else
        self:SetAlpha(0.30)
    end
end

function BigPartyMemberFrameMixin:UpdateLeader()
	local leaderIcon = self.PartyMemberOverlay.LeaderIcon
	local guideIcon = self.PartyMemberOverlay.GuideIcon

	if UnitIsGroupLeader(self:GetUnit()) then
		if ( HasLFGRestrictions() ) then
			guideIcon:Show()
			leaderIcon:Hide()
		else
			leaderIcon:Show()
			guideIcon:Hide()
		end
	else
		guideIcon:Hide()
		leaderIcon:Hide()
	end
end

function BigPartyMemberFrameMixin:UpdatePvPStatus()
	local icon = self.PartyMemberOverlay.PVPIcon
	local factionGroup = UnitFactionGroup(self:GetUnit())
	if UnitIsPVPFreeForAll(self:GetUnit()) then
		icon:SetAtlas("ui-hud-unitframe-player-pvp-ffaicon", true)
		icon:Show()
	elseif factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self:GetUnit()) then
		local atlas = (factionGroup == "Horde") and "ui-hud-unitframe-player-pvp-hordeicon" or "ui-hud-unitframe-player-pvp-allianceicon"
		icon:SetAtlas(atlas, true)
		icon:Show()
	else
		icon:Hide()
	end
end

function BigPartyMemberFrameMixin:UpdateAssignedRoles()
	local icon = self.PartyMemberOverlay.RoleIcon
	local role = UnitGroupRolesAssignedEnum(self:GetUnit())

	if role == Enum.LFGRole.Tank then
		icon:SetAtlas("roleicon-tiny-tank")
		icon:Show()
	elseif role == Enum.LFGRole.Healer then
		icon:SetAtlas("roleicon-tiny-healer")
		icon:Show()
	elseif role == Enum.LFGRole.Damage then
		icon:SetAtlas("roleicon-tiny-dps")
		icon:Show()
	else
		icon:Hide()
	end
end

function BigPartyMemberFrameMixin:UpdateVoiceStatus()
	if not UnitName(self:GetUnit()) then
		--No need to update if the frame doesn't have a unit.
		return
	end

	local mode
	local inInstance, instanceType = IsInInstance()

	if ( (instanceType == "pvp") or (instanceType == "arena") ) then
		mode = "Battleground"
	elseif ( IsInRaid() ) then
		mode = "raid"
	else
		mode = "party"
	end
end

function BigPartyMemberFrameMixin:UpdateReadyCheck()
	local readyCheckFrame = self.ReadyCheck
	local readyCheckStatus = GetReadyCheckStatus(self:GetUnit())
	if UnitName(self:GetUnit()) and UnitIsConnected(self:GetUnit()) and readyCheckStatus then
		if ( readyCheckStatus == "ready" ) then
			ReadyCheck_Confirm(readyCheckFrame, 1)
		elseif ( readyCheckStatus == "notready" ) then
			ReadyCheck_Confirm(readyCheckFrame, 0)
		else -- "waiting"
			ReadyCheck_Start(readyCheckFrame)
		end
	else
		readyCheckFrame:Hide()
	end
end

function BigPartyMemberFrameMixin:UpdateNotPresentIcon()
	if UnitInOtherParty(self:GetUnit()) then
		self:SetAlpha(0.6)
		self.NotPresentIcon.texture:SetAtlas("groupfinder-eye-single", true)
		self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1)
		self.NotPresentIcon.Border:Show()
		self.NotPresentIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
		self.NotPresentIcon:Show()
	elseif C_IncomingSummon.HasIncomingSummon(self:GetUnit()) then
		local status = C_IncomingSummon.IncomingSummonStatus(self:GetUnit())
		if status == Enum.SummonStatus.Pending then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonPending")
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1)
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING
			self.NotPresentIcon.Border:Hide()
			self.NotPresentIcon:Show()
		elseif status == Enum.SummonStatus.Accepted then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonAccepted")
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1)
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED
			self.NotPresentIcon.Border:Hide()
			self.NotPresentIcon:Show()
		elseif status == Enum.SummonStatus.Declined then
			self.NotPresentIcon.texture:SetAtlas("Raid-Icon-SummonDeclined")
			self.NotPresentIcon.texture:SetTexCoord(0, 1, 0, 1)
			self.NotPresentIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED
			self.NotPresentIcon.Border:Hide()
			self.NotPresentIcon:Show()
		end
	else
		local phaseReason = UnitIsConnected(self:GetUnit()) and UnitPhaseReason(self:GetUnit()) or nil
		if phaseReason then
			self:SetAlpha(0.6)
			self.NotPresentIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
			self.NotPresentIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
			self.NotPresentIcon.Border:Hide()
			self.NotPresentIcon.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, self:GetUnit())
			self.NotPresentIcon:Show()
		else
			self:SetAlpha(1)
			self.NotPresentIcon:Hide()
		end
	end

	self:UpdateVoiceActivityNotification()
end

function BigPartyMemberFrameMixin:OnEvent(event, ...)
	securecall("UnitFrame_OnEvent", self, event, ...)

	local arg1, arg2, arg3 = ...
	local selfID = self.layoutIndex

	if event == "UNIT_NAME_UPDATE" then
		securecall("UnitFrame_Update", self, true)
	elseif event == "PLAYER_ENTERING_WORLD" then
		if UnitExists(self:GetUnit()) then
			self:UpdateMember()
			self:UpdateOnlineStatus()
			self:UpdateAssignedRoles()
		end
	elseif event == "GROUP_ROSTER_UPDATE" or event == "UPDATE_ACTIVE_BATTLEFIELD" then
		self:UpdateMember()
		self:UpdateArt()
		self:UpdateAssignedRoles()
		self:UpdateLeader()
	elseif event == "PARTY_LEADER_CHANGED" then
		self:UpdateLeader()
	elseif event == "MUTELIST_UPDATE" or event == "IGNORELIST_UPDATE" then
		self:UpdateVoiceStatus()
	elseif event == "UNIT_FACTION" then
		if arg1 == self:GetUnit() then
			self:UpdatePvPStatus()
		end
	elseif ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		self:UpdateReadyCheck()
	elseif event == "READY_CHECK_FINISHED" then
		if UnitExists(self:GetUnit()) then
			local finishTime = DEFAULT_READY_CHECK_STAY_TIME
			ReadyCheck_Finish(self.ReadyCheck, finishTime)
		end
	elseif event == "UNIT_ENTERED_VEHICLE" then
		if arg1 == self:GetUnit() then
			if arg2 and UnitIsConnected(self:GetUnit()) then
				self:ToVehicleArt()
			else
				self:ToPlayerArt()
			end
			self:UpdateMember()
		end
	elseif event == "UNIT_EXITED_VEHICLE" then
		if arg1 == self:GetUnit() then
			self:ToPlayerArt()
			self:UpdateMember()
		end
	elseif event == "UNIT_CONNECTION" and arg1 == self:GetUnit() then
		self:UpdateArt()
	elseif event == "UNIT_PHASE" or event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" or event == "UNIT_FLAGS" or event == "UNIT_CTR_OPTIONS" then
		if event ~= "UNIT_PHASE" or arg1 == self:GetUnit() then
			self:UpdateNotPresentIcon()
		end
	elseif event == "UNIT_OTHER_PARTY_CHANGED" and arg1 == self:GetUnit() then
		self:UpdateNotPresentIcon()
	elseif event == "INCOMING_SUMMON_CHANGED" then
		self:UpdateNotPresentIcon()
	end

	self:UpdateDistance()
end

function BigPartyMemberFrameMixin:OnUpdate(elapsed)
	if self.initialized then
		self:UpdateMemberHealth(elapsed)
	end
end

function BigPartyMemberFrameMixin:OnEnter()
	UnitFrame_OnEnter(self)
end

function BigPartyMemberFrameMixin:OnLeave()
	UnitFrame_OnLeave(self)
end

function BigPartyMemberFrameMixin:UpdateOnlineStatus()
	local healthBar = self.HealthBar

	if not UnitIsConnected(self:GetUnit()) then
		-- Handle disconnected state
		local unitHPMin, unitHPMax = healthBar:GetMinMaxValues()

		healthBar:SetValue(unitHPMax)
		healthBar:SetStatusBarDesaturated(true)
		SetDesaturation(self.Portrait, true)
		self.PartyMemberOverlay.Disconnect:Show()
	else
		healthBar:SetStatusBarDesaturated(false)
		SetDesaturation(self.Portrait, false)
		self.PartyMemberOverlay.Disconnect:Hide()
	end
end

function BigPartyMemberFrameMixin:PartyMemberHealthCheck(value)
	local unitHPMin, unitHPMax, unitCurrHP
	unitHPMin, unitHPMax = self.HealthBar:GetMinMaxValues()

	unitCurrHP = self.HealthBar:GetValue()
	if unitHPMax > 0 then
		self.unitHPPercent = unitCurrHP / unitHPMax
	else
		self.unitHPPercent = 0
	end

	local unit = self:GetUnit()
	local unitIsDead = UnitIsDead(unit)
	local unitIsGhost = UnitIsGhost(unit)
	if PARTY_FRAME_RESURRECTABLE_TOOLTIP then
		local playerIsDeadOrGhost = UnitIsDeadOrGhost("player")
		local unitIsDeadOrGhost = unitIsDead or unitIsGhost
		self.ResurrectableIndicator:SetShown(not playerIsDeadOrGhost and unitIsDeadOrGhost)
	end

	if unitIsDead then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0)
	elseif unitIsGhost then
		self.Portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0)
	elseif (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) then
		self.Portrait:SetVertexColor(1.0, 0.0, 0.0)
	else
		self.Portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0)
	end
end
