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

function BPF:EnablePartyStyle()
    PartyFrame:Hide()

    for i=1, MAX_PARTY_MEMBERS do
        local PartyMemberFrame = BigPartyFrame["MemberFrame" .. i]
        if PartyMemberFrame then
            hooksecurefunc("UnitFramePortrait_Update", function(self)
                BPF:ClassPortraits(self)
            end)
            hooksecurefunc("UnitFrame_Update", function(self)
                BPF:RemoveRealmFromName(self)
            end)
        end
    end

    BigPartyFrame:Show()
end
