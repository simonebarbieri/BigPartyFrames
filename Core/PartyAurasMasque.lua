local function ApplyMasque(partyMember, auraIndex, auraType, group)
    local aura = _G["BPF_PartyMemberFrame"..partyMember..auraType..auraIndex]

    local auraData = {
        Icon = aura.Icon,
        Border = aura.Border,
    }

    group:AddButton(aura, auraData)
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
