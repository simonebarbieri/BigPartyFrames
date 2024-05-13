local partyAuras = CreateFrame("Frame")

function BPF:InitializeAuras()
    for i = 1, MAX_PARTY_MEMBERS do
        for j = 1, BPF_DB.max_party_buffs do
            local buff = CreateFrame("Button", "BPF_PartyMemberFrame"..i.."Buff"..j, _G["PartyFrame"]["MemberFrame"..i])
            buff:SetFrameLevel(7)
            buff:SetWidth(partyStyle.aura_size)
            buff:SetHeight(partyStyle.aura_size)
            buff:SetID(j)
            buff:ClearAllPoints()
            if j == 1 then
                buff:SetPoint("RIGHT", _G["PartyFrame"]["MemberFrame"..i], "TOPRIGHT", 20, -25)
            else
                buff:SetPoint("LEFT", _G["BPF_PartyMemberFrame"..i.."Buff"..j-1], "RIGHT", partyStyle.aura_spacing, 0)
            end
            buff:SetAttribute("unit", "party"..i)
            RegisterUnitWatch(buff)

            buff.Icon = buff:CreateTexture("BPF_PartyMemberFrame"..i.."Buff"..j.."Icon", "ARTWORK")
            buff.Icon:SetAllPoints(buff)

            buff.Cooldown = CreateFrame("Cooldown", "BPF_PartyMemberFrame"..i.."Buff"..j.."Cooldown", buff, "CooldownFrameTemplate")
            buff.Cooldown:SetFrameLevel(8)
            buff.Cooldown:SetReverse(true)
            buff.Cooldown:ClearAllPoints()
            buff.Cooldown:SetAllPoints(buff.Icon)
            buff.Cooldown:SetParent(buff)
            buff.Cooldown:SetHideCountdownNumbers(true)

            buff.CooldownText = buff.Cooldown:CreateFontString("BPF_PartyMemberFrame"..i.."Buff"..j.."CooldownText", "OVERLAY")
            buff.CooldownText:SetFont(GameFontNormal:GetFont(), 6, "OUTLINE")
            buff.CooldownText:SetTextColor(1, 1, 1)--(1, 0.75, 0)
            buff.CooldownText:ClearAllPoints()
            -- buff.CooldownText:SetPoint("CENTER", buff.Icon, "CENTER", 0, 0)
            buff.CooldownText:SetPoint("BOTTOM", buff.Icon, "CENTER", 0, -15)

            buff.Border = buff:CreateTexture("BPF_PartyMemberFrame"..i.."Buff"..j.."Border", "OVERLAY")
            buff.Border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
            buff.Border:SetWidth(17)
            buff.Border:SetHeight(17)
            buff.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
            buff.Border:ClearAllPoints()
            buff.Border:SetPoint("TOPLEFT", buff, "TOPLEFT", -1, 1)

            buff:EnableMouse(true)
            buff:SetScript("OnLeave",function()
                GameTooltip:Hide()
            end)
        end
        for j = 1, BPF_DB.max_party_debuffs do
            local debuff = CreateFrame("Button", "BPF_PartyMemberFrame"..i.."Debuff"..j, _G["PartyFrame"]["MemberFrame"..i])
            debuff:SetFrameLevel(7)
            debuff:SetWidth(partyStyle.aura_size)
            debuff:SetHeight(partyStyle.aura_size)
            debuff:SetID(j)
            debuff:ClearAllPoints()
            if j == 1 then
                debuff:SetPoint("RIGHT", _G["PartyFrame"]["MemberFrame"..i], "BOTTOMRIGHT", 20, 20)
            else
                debuff:SetPoint("LEFT", _G["BPF_PartyMemberFrame"..i.."Debuff"..j-1], "RIGHT", partyStyle.aura_spacing, 0)
            end
            debuff:SetAttribute("unit", "party"..i)
            RegisterUnitWatch(debuff)

            debuff.Icon = debuff:CreateTexture("BPF_PartyMemberFrame"..i.."Debuff"..j.."Icon", "ARTWORK")
            debuff.Icon:SetAllPoints(debuff)

            debuff.Cooldown = CreateFrame("Cooldown", "BPF_PartyMemberFrame"..i.."Debuff"..j.."Cooldown", debuff, "CooldownFrameTemplate")
            debuff.Cooldown:SetFrameLevel(8)
            debuff.Cooldown:SetReverse(true)
            debuff.Cooldown:ClearAllPoints()
            debuff.Cooldown:SetAllPoints(debuff.Icon)
            debuff.Cooldown:SetParent(debuff)
            debuff.Cooldown:SetHideCountdownNumbers(true)
            -- debuff.Cooldown:Hide()

            debuff.CooldownText = debuff.Cooldown:CreateFontString("BPF_PartyMemberFrame"..i.."Debuff"..j.."CooldownText", "OVERLAY")
            debuff.CooldownText:SetFont(GameFontNormal:GetFont(), 6, "OUTLINE")
            debuff.CooldownText:SetTextColor(1, 1, 1)--(1, 0.75, 0)
            debuff.CooldownText:ClearAllPoints()
            -- debuff.CooldownText:SetPoint("BOTTOM", debuff.Icon, "TOP", 0, 1)
            debuff.CooldownText:SetPoint("BOTTOM", debuff.Icon, "CENTER", 0, -15)

            debuff.CountText = debuff.Cooldown:CreateFontString("BPF_PartyMemberFrame"..i.."Debuff"..j.."CountText", "OVERLAY")
            debuff.CountText:SetFont(GameFontNormal:GetFont(), 10, "OUTLINE")
            debuff.CountText:SetTextColor(1, 1, 1)
            debuff.CountText:ClearAllPoints()
            -- debuff.CountText:SetPoint("CENTER", debuff.Icon, "BOTTOM", 0, 0)
            debuff.CountText:SetPoint("BOTTOMRIGHT", debuff.Icon, "BOTTOMRIGHT", 0, 0)

            debuff.Border = debuff:CreateTexture("BPF_PartyMemberFrame"..i.."Debuff"..j.."Border", "OVERLAY")
            debuff.Border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
            debuff.Border:SetVertexColor(0.57, 0.17, 0.16)
            debuff.Border:SetWidth(17)
            debuff.Border:SetHeight(17)
            debuff.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
            debuff.Border:ClearAllPoints()
            debuff.Border:SetPoint("TOPLEFT", debuff, "TOPLEFT", -1, 1)

            debuff:EnableMouse(true)
            -- debuff:SetScript("OnEnter",function(self)
            --     GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            --     GameTooltip:SetUnitDebuff("party"..i, j)
            -- end)
            debuff:SetScript("OnLeave",function()
                GameTooltip:Hide()
            end)
        end
    end
end

function BPF:SetPartyAuras()
    partyAuras:SetScript("OnUpdate", function(self, elapsed)
        self.timer = (self.timer or 0) + elapsed
        if self.timer >= 0.1 then
            for i = 1, MAX_PARTY_MEMBERS do
                if UnitExists("party"..i) then
                    -- sort buffs by duration and add them from the shortest to the longest
                    local sortedBuffs = {}
                    j = 1
                    while UnitBuff("party"..i, j) do
                        local _, icon, _, _, duration, expires = UnitBuff("party"..i, j)
                        table.insert(sortedBuffs, {icon, duration, expires, j})
                        j = j + 1
                    end
                    table.sort(sortedBuffs, function(a, b)
                        if a[2] == 0 then return false end
                        if b[2] == 0 then return true end
                        return a[2] < b[2]
                    end)
                    for j = 1, BPF_DB.max_party_buffs do
                        if sortedBuffs[j] then
                            local icon = sortedBuffs[j][1]
                            local duration = sortedBuffs[j][2]
                            local expires = sortedBuffs[j][3]
                            local buffNumber = sortedBuffs[j][4]

                            _G["BPF_PartyMemberFrame"..i.."Buff"..j]:SetScript("OnEnter",function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                                GameTooltip:SetUnitBuff("party"..i, buffNumber)
                            end)

                            local timetext = ""
                            _G["BPF_PartyMemberFrame"..i.."Buff"..j].Icon:SetTexture(icon)
                            _G["BPF_PartyMemberFrame"..i.."Buff"..j]:SetAlpha(1)
                            CooldownFrame_Set(_G["BPF_PartyMemberFrame"..i.."Buff"..j].Cooldown, expires - duration, duration, true)
                            if duration > 0 then
                                local timeleft = expires - GetTime()
                                local alpha = 1
                                if timeleft >= 3600 then
                                    timetext = math.floor(timeleft/3600) .. "h"
                                elseif timeleft >= 60 then
                                    timetext = math.floor(timeleft/60) .. "m"
                                else
                                    timetext = math.floor(timeleft)
                                end
                                _G["BPF_PartyMemberFrame"..i.."Buff"..j].CooldownText:SetAlpha(alpha)
                            end
                            _G["BPF_PartyMemberFrame"..i.."Buff"..j].CooldownText:SetText(timetext)
                        else
                            CooldownFrame_Clear(_G["BPF_PartyMemberFrame"..i.."Buff"..j].Cooldown)
                            _G["BPF_PartyMemberFrame"..i.."Buff"..j]:SetAlpha(0)
                        end
                    end
                    local sortedDebuffs = {}
                    j = 1
                    while UnitDebuff("party"..i, j) do
                        local _, icon, count, _, duration, expires = UnitDebuff("party"..i, j)
                        table.insert(sortedDebuffs, {icon, count, duration, expires, j})
                        j = j + 1
                    end
                    table.sort(sortedDebuffs, function(a, b)
                        if a[3] == 0 then return false end
                        if b[3] == 0 then return true end
                        return a[3] < b[3]
                    end)
                    for j = 1, BPF_DB.max_party_debuffs do
                        if sortedDebuffs[j] then
                            local icon = sortedDebuffs[j][1]
                            local count = sortedDebuffs[j][2]
                            local duration = sortedDebuffs[j][3]
                            local expires = sortedDebuffs[j][4]
                            local debuffNumber = sortedDebuffs[j][5]

                            _G["BPF_PartyMemberFrame"..i.."Debuff"..j]:SetScript("OnEnter",function(self)
                                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                                GameTooltip:SetUnitBuff("party"..i, debuffNumber)
                            end)

                            local counttext = ""
                            local timetext = ""
                            if count > 1 then
                                counttext = count
                            end
                            _G["BPF_PartyMemberFrame"..i.."Debuff"..j].Icon:SetTexture(icon)
                            _G["BPF_PartyMemberFrame"..i.."Debuff"..j]:SetAlpha(1)
                            CooldownFrame_Set(_G["BPF_PartyMemberFrame"..i.."Debuff"..j].Cooldown, expires - duration, duration, true)
                            if duration > 0 then
                                local timeleft = expires - GetTime()
                                local alpha = 1
                                if timeleft > 3600 then
                                    timetext = math.floor(timeleft/3600) .. "h"
                                elseif timeleft > 60 then
                                    timetext = math.floor(timeleft/60) .. "m"
                                else
                                    timetext = math.floor(timeleft)
                                end
                                _G["BPF_PartyMemberFrame"..i.."Debuff"..j].CooldownText:SetAlpha(alpha)
                            end
                            _G["BPF_PartyMemberFrame"..i.."Debuff"..j].CooldownText:SetText(timetext)
                            _G["BPF_PartyMemberFrame"..i.."Debuff"..j].CountText:SetText(counttext)
                        else
                            CooldownFrame_Clear(_G["BPF_PartyMemberFrame"..i.."Debuff"..j].Cooldown)
                            _G["BPF_PartyMemberFrame"..i.."Debuff"..j]:SetAlpha(0)
                        end
                    end
                end
            end
            self.timer = 0
        end
    end)
end

function BPF:EnablePartyAuras()
    BPF:InitializeAuras()
    BPF:SetPartyAuras()
end
