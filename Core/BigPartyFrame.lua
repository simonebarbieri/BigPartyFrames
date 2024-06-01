BigPartyFrameMixin = {}

function BigPartyFrameMixin:OnLoad()
	local function PartyMemberFrameReset(framePool, frame)
		frame.layoutIndex = nil
		FramePool_HideAndClearAnchors(framePool, frame)
	end

	self.PartyMemberFramePool = CreateFramePool("BUTTON", self, "BigPartyMemberFrameTemplate", PartyMemberFrameReset)

	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		if BPF_DB then
			local point, _, relativePoint, x, y = self:GetPoint()
			BPF_DB.party_point = point
			BPF_DB.party_relative_point = relativePoint
			BPF_DB.party_position_x = x
			BPF_DB.party_position_y = y
		end
	end)
	BigPartyFrame_Lock()
	BigPartyFrame_UpdateSettingFrameSize()
	BigPartyFrame_UpdateSettingFramePoint()
end

function BigPartyFrame_UpdateSettingFrameSize()
	local scale = 1
	if BPF_DB then
		scale = BPF_DB.party_scale
	end
	BigPartyFrame:SetScale(scale)
end

function BigPartyFrame_UpdateSettingFramePoint()
	local point = "TOPLEFT"
	local relativePoint = "TOPLEFT"
	local x = 0
	local y = 0
	if BPF_DB then
		point = BPF_DB.party_point
		relativePoint = BPF_DB.party_relative_point
		x = BPF_DB.party_position_x
		y = BPF_DB.party_position_y
	end
	BigPartyFrame:ClearAllPoints()
	BigPartyFrame:SetPoint(point, UIParent, relativePoint, x, y)
end

function BigPartyFrameMixin:OnShow()
	self:InitializePartyMemberFrames()
	self:UpdatePartyFrames()
end

function BigPartyFrameMixin:OnEvent(event, ...)
	self:Layout()
end

function BigPartyFrameMixin:ShouldShow()
	return ShouldShowPartyFrames()
end

function BigPartyFrameMixin:InitializePartyMemberFrames()
	local memberFramesToSetup = {}

	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:SetScript("OnEvent", function(self, event, ...)
		self:UpdatePartyFrames()
	end)

	self.PartyMemberFramePool:ReleaseAll()
	for i = 1, MAX_PARTY_MEMBERS do
		local memberFrame = self.PartyMemberFramePool:Acquire()

		memberFrame:RegisterForDrag("LeftButton")
		memberFrame:SetMovable(true)
		memberFrame:SetScript("OnDragStart", function(self)
			local f = BigPartyFrame:GetScript("OnDragStart")
			if BigPartyFrame_IsUnlocked() then
				f(BigPartyFrame)
			end
		end)
		memberFrame:SetScript("OnDragStop", function(self)
			local f = BigPartyFrame:GetScript("OnDragStop")
			f(BigPartyFrame) -- run it
		end)

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
			memberFrame:UpdateMember()
		else
			memberFrame:Hide()
		end
	end

	self:UpdatePaddingAndLayout()
end

function BigPartyFrame_Unlock()
	BigPartyFrame:SetMovable(true)
	for i=1, MAX_PARTY_MEMBERS do
		local PartyMemberFrame = BigPartyFrame["MemberFrame" .. i]
		if PartyMemberFrame then
			PartyMemberFrame:SetMovable(true)
		end
	end
end

function BigPartyFrame_Lock()
	BigPartyFrame:SetMovable(false)
	for i=1, MAX_PARTY_MEMBERS do
		local PartyMemberFrame = BigPartyFrame["MemberFrame" .. i]
		if PartyMemberFrame then
			PartyMemberFrame:SetMovable(false)
		end
	end
end

function BigPartyFrame_IsLocked()
	return not BigPartyFrame:IsMovable()
end

function BigPartyFrame_IsUnlocked()
	return BigPartyFrame:IsMovable()
end
