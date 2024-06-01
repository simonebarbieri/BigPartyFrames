local function ApplyMasque(partyMember, auraIndex, auraType, group)
    local partyMemberAuraFrame = "BPF_PartyAuras"..partyMember..auraType
    local auraButtonName = partyMemberAuraFrame..auraIndex

    local auraButton = _G[auraButtonName]

    local auraData = {
        Icon = auraButton.Icon,
        Border = auraButton.Border,
    }

    group:AddButton(auraButton, auraData)
end

function BPF:InitializeMasque()
    local Masque = LibStub("Masque", true)
    if not Masque then return end

    local Buffs = Masque:Group("Big Party Frames", "Buffs")
    local Debuffs = Masque:Group("Big Party Frames", "Debuffs")

    local maxBuffs = BPF_DB.max_party_buffs
    local maxDebuffs = BPF_DB.max_party_debuffs

    for partyMember = 1, MAX_PARTY_MEMBERS do
        for auraIndex = 1, maxBuffs do
            ApplyMasque(partyMember, auraIndex, "Buff", Buffs)
        end
        for auraIndex = 1, maxDebuffs do
            ApplyMasque(partyMember, auraIndex, "Debuff", Debuffs)
        end
    end
end
