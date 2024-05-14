BPF = LibStub("AceAddon-3.0"):NewAddon("BPF", "AceConsole-3.0")

function BPF:OnInitialize()
    -- Database Default profile
    local defaults = {
        profile = {
          use_class_portraits = true,
          remove_realm_name = true,
          max_party_buffs = 10,
          max_party_debuffs = 10,
        }
    }

    -- Register Database
    self.db = LibStub("AceDB-3.0"):New("BPFDB", defaults, true)

    -- Assign DB to a global variable
    BPF_DB = self.db.profile
end
