BPF = LibStub("AceAddon-3.0"):NewAddon("BPF", "AceConsole-3.0")

function BPF:OnInitialize()
    -- Database Default profile
    local defaults = {
        profile = {
            party = {
                x = 0,
                y = 0,
                anchor = "TOPLEFT",
                anchorTo = "TOPLEFT"
            },
            use_class_portraits = true,
            use_class_color_healthbar = false,
            remove_realm_name = true,
            max_party_buffs = 10,
            max_party_debuffs = 10,
        }
    }

    -- Register Database
    self.db = LibStub("AceDB-3.0"):New("BPFDB", defaults, true)

    -- Assign DB to a global variable
    BPF_DB = self.db.profile

    local EditModeExpanded = LibStub("EditModeExpanded-1.0", true)

	if EditModeExpanded then
		if BPF_DB then
			EditModeExpanded:RegisterFrame(BigPartyFrame, "Big Party Frame", BPF_DB.party, UIParent, BPF_DB.party.anchor, true)
			EditModeExpanded:RegisterResizable(BigPartyFrame)
		end
	end
end

function BPF:OnEnable()
    BPF:EnablePartyStyle()
    BPF:EnablePartyAuras()
    BPF:InitializeMasque()
end
