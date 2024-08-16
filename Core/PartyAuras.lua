BPF.PartyAuras = CreateFrame("Frame", "BPF_PartyAuras")

local function CreateAura(partyMember, auraIndex, auraType, anchor, x, y)
    local partyMemberAuraFrame = "BPF_PartyAuras"..partyMember..auraType
    local auraButtonName = partyMemberAuraFrame..auraIndex

    local aura = CreateFrame("Button", auraButtonName, _G["BigPartyFrame"]["MemberFrame"..partyMember])

    aura:SetFrameLevel(7)
    aura:SetWidth(15)
    aura:SetHeight(15)
    aura:SetID(auraIndex)
    aura:ClearAllPoints()
    if auraIndex == 1 then
        aura:SetPoint("RIGHT", _G["BigPartyFrame"]["MemberFrame"..partyMember], anchor, x, y)
    else
        aura:SetPoint("LEFT", _G[partyMemberAuraFrame..auraIndex-1], "RIGHT", 4, 0)
    end
    aura:SetAttribute("unit", "party"..partyMember)
    RegisterUnitWatch(aura)

    aura.Icon = aura:CreateTexture(auraButtonName.."Icon", "ARTWORK")
    aura.Icon:SetAllPoints(aura)

    aura.Cooldown = CreateFrame("Cooldown", auraButtonName.."Cooldown", aura, "CooldownFrameTemplate")
    aura.Cooldown:SetFrameLevel(8)
    aura.Cooldown:SetReverse(true)
    aura.Cooldown:ClearAllPoints()
    aura.Cooldown:SetAllPoints(aura.Icon)
    aura.Cooldown:SetParent(aura)
    aura.Cooldown:SetHideCountdownNumbers(true)

    aura.CooldownText = aura.Cooldown:CreateFontString(auraButtonName.."CooldownText", "OVERLAY")
    aura.CooldownText:SetFont(GameFontNormal:GetFont(), 6, "OUTLINE")
    aura.CooldownText:SetTextColor(1, 1, 1)--(1, 0.75, 0)
    aura.CooldownText:ClearAllPoints()
    aura.CooldownText:SetPoint("BOTTOM", aura.Icon, "CENTER", 0, -15)

    aura.CountText = aura.Cooldown:CreateFontString(auraButtonName.."CountText", "OVERLAY")
    aura.CountText:SetFont(GameFontNormal:GetFont(), 6, "OUTLINE")
    aura.CountText:SetTextColor(1, 1, 1)
    aura.CountText:ClearAllPoints()
    aura.CountText:SetPoint("CENTER", aura.Icon, "TOPRIGHT", 0, 0)

    aura.Border = aura:CreateTexture(auraButtonName.."Border", "OVERLAY")
    aura.Border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
    aura.Border:SetWidth(17)
    aura.Border:SetHeight(17)
    aura.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
    aura.Border:ClearAllPoints()
    aura.Border:SetPoint("TOPLEFT", aura, "TOPLEFT", -1, 1)

    aura:EnableMouse(true)
    aura:SetScript("OnLeave",function()
        GameTooltip:Hide()
    end)
end

local function GetSortedAuras(partyMember, auraType)
    local sortedAuras = {}
    local auraIndex = 1
    local auradata = C_UnitAuras.GetAuraDataByIndex("party"..partyMember, auraIndex, auraType)
    while auradata do
        table.insert(sortedAuras, {
            icon=auradata.icon,
            count=auradata.charges and auradata.charges or 0,
            duration=auradata.duration,
            expires=auradata.expirationTime,
            source=auradata.sourceUnit,
            auraIndex=auraIndex
        })
        auraIndex = auraIndex + 1
        auradata = C_UnitAuras.GetAuraDataByIndex("party"..partyMember, auraIndex, auraType)
    end
    table.sort(sortedAuras, function(a, b)
        if a.expires == 0 then return false end
        if b.expires == 0 then return true end
        return a.expires < b.expires
    end)

    return sortedAuras
end

local function SetAura(aura, auraType, partyMember, auraIndex)
    local partyMemberAuraFrame = "BPF_PartyAuras"..partyMember..auraType
    local auraButtonName = partyMemberAuraFrame..auraIndex

    local auraButton = _G[auraButtonName]

    if aura then
        auraButton:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetUnitAura("party"..partyMember, aura.auraIndex, auraType == "Buff" and "HELPFUL" or "HARMFUL")
        end)

        local counttext = ""
        local timetext = ""
        if aura.count > 1 then
            counttext = aura.count
        end
        auraButton.Icon:SetTexture(aura.icon)
        auraButton:SetAlpha(1)
        CooldownFrame_Set(auraButton.Cooldown, aura.expires - aura.duration, aura.duration, true)
        if aura.duration > 0 then
            local timeleft = aura.expires - GetTime()
            local alpha = 1
            if timeleft > 3600 then
                timetext = math.floor(timeleft/3600) .. "h"
            elseif timeleft > 60 then
                timetext = math.floor(timeleft/60) .. "m"
            else
                timetext = tostring(math.floor(timeleft))
            end
            auraButton.CooldownText:SetAlpha(alpha)
        end
        local borderColor = {r=0, g=0, b=0}
        if auraType == "Debuff" then
            borderColor = {r=1, g=0, b=0}
        elseif aura.source == "player" then
            borderColor = {r=0, g=1, b=0}
        else
            borderColor = {r=0, g=0, b=0}
        end
        auraButton.Border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
        auraButton.CooldownText:SetText(timetext)
        auraButton.CountText:SetText(counttext)
    else
        CooldownFrame_Clear(auraButton.Cooldown)
        auraButton:SetAlpha(0)
    end
end

function BPF:AurasUpdate()
    for partyMember = 1, MAX_PARTY_MEMBERS do
        if UnitExists("party"..partyMember) then
            -- sort buffs by duration and add them from the shortest to the longest
            local sortedBuffs = GetSortedAuras(partyMember, "HELPFUL")
            for auraIndex = 1, BPF_DB.MaxBuffs do
                SetAura(sortedBuffs[auraIndex], "Buff", partyMember, auraIndex)
            end
            local sortedDebuffs = GetSortedAuras(partyMember, "HARMFUL")
            for auraIndex = 1, BPF_DB.MaxDebuffs do
                SetAura(sortedDebuffs[auraIndex], "Debuff", partyMember, auraIndex)
            end
        end
    end
end

function BPF:EnablePartyAuras()
    BPF_DB.MaxBuffs = BPF_DB.max_party_buffs
    BPF_DB.MaxDebuffs = BPF_DB.max_party_debuffs

    for partyMember = 1, MAX_PARTY_MEMBERS do
        for auraIndex = 1, BPF_DB.MaxBuffs do
            CreateAura(partyMember, auraIndex, "Buff", "TOPRIGHT", 0, -35)
        end
        for auraIndex = 1, BPF_DB.MaxDebuffs do
            CreateAura(partyMember, auraIndex, "Debuff", "BOTTOMRIGHT", 0, 35)
        end
    end

    BPF.PartyAuras:SetScript("OnUpdate", function(self, elapsed)
        self.timer = (self.timer or 0) + elapsed
        if self.timer >= 0.1 then
            BPF:AurasUpdate()
            self.timer = 0
        end
    end)
end
