BigPartyFrameMixin = {}

function BigPartyFrameMixin:OnLoad()
	local function BigPartyMemberFrameReset(framePool, frame)
		frame.layoutIndex = nil
		Pool_HideAndClearAnchors(framePool, frame)
	end

	self.BigPartyMemberFramePool = CreateFramePool("BUTTON", self, "BigPartyMemberFrameTemplate", BigPartyMemberFrameReset)

	self:RegisterEvent("GROUP_ROSTER_UPDATE")
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

	self.BigPartyMemberFramePool:ReleaseAll()

	for i = 1, MAX_PARTY_MEMBERS do
		local memberFrame = self.BigPartyMemberFramePool:Acquire()

		-- Set for debugging purposes.
		memberFrame:SetParentKey("MemberFrame"..i)

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
	for memberFrame in self.BigPartyMemberFramePool:EnumerateActive() do
		memberFrame:UpdateMember()
	end

	self:Layout()
end

function BigPartyFrameMixin:HidePartyFrames()
	for memberFrame in self.BigPartyMemberFramePool:EnumerateActive() do
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
	for memberFrame in self.BigPartyMemberFramePool:EnumerateActive() do
		if showPartyFrames then
			memberFrame:Show()
			memberFrame:UpdateMember()
		else
			memberFrame:Hide()
		end
	end

	self:UpdatePaddingAndLayout()
end
