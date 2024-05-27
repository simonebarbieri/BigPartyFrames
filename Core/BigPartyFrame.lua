-- BigPartyFrame = CreateFrame("Frame", "BPF_PartyFrame")
BigPartyFrameMixin = {}

function BigPartyFrameMixin:OnLoad()
	if C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.ForcedPartyFrameScale) then
		self:SetScale(C_GameModeManager.GetFeatureSetting(Enum.GameModeFeatureSetting.ForcedPartyFrameScale))
	end

	local function PartyMemberFrameReset(framePool, frame)
		frame.layoutIndex = nil
		FramePool_HideAndClearAnchors(framePool, frame)
	end

	self.PartyMemberFramePool = CreateFramePool("BUTTON", self, "BigPartyMemberFrameTemplate", PartyMemberFrameReset)
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function BigPartyFrameMixin:UpdateSystemSettingFrameSize()
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.ForcedPartyFrameScale) then
		EditModeUnitFrameSystemMixin.UpdateSystemSettingFrameSize(self)
	end
end

function BigPartyFrameMixin:OnShow()
	self:InitializePartyMemberFrames()
	self:UpdatePartyFrames()
end

function BigPartyFrameMixin:OnEvent(event, ...)
	self:Layout()
end

function BigPartyFrameMixin:ShouldShow()
	return ShouldShowPartyFrames() and not EditModeManagerFrame:UseRaidStylePartyFrames()
end

function BigPartyFrameMixin:InitializePartyMemberFrames()
	local memberFramesToSetup = {}

	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:SetScript("OnEvent", function(self, event, ...)
		self:UpdatePartyFrames()
	end)

	self.PartyMemberFramePool:ReleaseAll()
	for i = 1, MAX_PARTY_MEMBERS do
		local memberFrame = self.PartyMemberFramePool:Acquire()

		-- Set for debugging purposes.
		memberFrame:SetParentKey("MemberFrame"..i)

		memberFrame:SetAttribute("unit", "party"..i)
		memberFrame:RegisterForClicks("AnyUp")
		memberFrame:SetAttribute("*type1", "target") -- Target unit on left click
		memberFrame:SetAttribute("*type2", "togglemenu") -- Toggle units menu on left click
		memberFrame:SetAttribute("*type3", "assist") -- On middle click, target the target of the clicked unit

		memberFrame:SetPoint("TOPLEFT")
		memberFrame.layoutIndex = i
		memberFramesToSetup[i] = memberFrame
		memberFrame:SetShown(self:ShouldShow())
	end
	self:Layout()
	for _, frame in ipairs(memberFramesToSetup) do
		frame:Setup()
	end
end

function BigPartyFrameMixin:UpdateMemberFrames()
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		memberFrame:UpdateMember()
	end

	self:Layout()
end

function BigPartyFrameMixin:UpdatePartyMemberBackground()
	if not self.Background then
		return
	end

	if not self:ShouldShow() or not EditModeManagerFrame:ShouldShowPartyFrameBackground() then
		self.Background:Hide()
		return
	end

	local numMembers = EditModeManagerFrame:ArePartyFramesForcedShown() and MAX_PARTY_MEMBERS or GetNumSubgroupMembers()
	if numMembers > 0 then
		for memberFrame in self.PartyMemberFramePool:EnumerateActive() do 
			if memberFrame.layoutIndex == numMembers then
				if memberFrame.PetFrame:IsShown() then
					self.Background:SetPoint("BOTTOMLEFT", memberFrame, "BOTTOMLEFT", -5, -21)
				else
					self.Background:SetPoint("BOTTOMLEFT", memberFrame, "BOTTOMLEFT", -5, -5)
				end
			end
		end
		self.Background:Show()
	else
		self.Background:Hide()
	end
end

function BigPartyFrameMixin:HidePartyFrames()
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		memberFrame:Hide()
	end
end

function BigPartyFrameMixin:UpdatePaddingAndLayout()
	self.leftPadding = 0
	self.rightPadding = 0

	self:Layout()
end

function BigPartyFrameMixin:UpdatePartyFrames()
	local showPartyFrames = self:ShouldShow()
	for memberFrame in self.PartyMemberFramePool:EnumerateActive() do
		if showPartyFrames then
			memberFrame:Show()
			memberFrame:UpdateMember()
		else
			memberFrame:Hide()
		end
	end

	self:UpdatePartyMemberBackground()
	self:UpdatePaddingAndLayout()
end
