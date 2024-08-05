BPF = LibStub("AceAddon-3.0"):NewAddon("BPF", "AceConsole-3.0")

function BPF:OnInitialize()
    -- Database Default profile
    local defaults = {
        profile = {
            party_point = "TOPLEFT",
            party_relative_point = "TOPLEFT",
            party_position_x = 0,
            party_position_y = 0,
            party_locked = true,
            party_scale = 1,
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

	BigPartyFrame_UpdateSettingFrameSize()
	BigPartyFrame_UpdateSettingFramePoint()
end
