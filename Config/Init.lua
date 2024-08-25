BPF = LibStub("AceAddon-3.0"):NewAddon("BPF", "AceConsole-3.0")

local function SetupEditMode(defaultPosition)
    local LEM = LibStub("LibEditMode")

    local function onPositionChanged(frame, layoutName, point, x, y)
        BPF_DB.party.point = point
        BPF_DB.party.x = x
        BPF_DB.party.y = y
    end

	if LEM then
        LEM:AddFrame(BigPartyFrame, onPositionChanged, BPF_DB.party)
	end

    LEM:RegisterCallback('enter', function()
        BigPartyFrame:Show()
    end)
    LEM:RegisterCallback('exit', function()
        BigPartyFrame:SetShown(BigPartyFrame:ShouldShow())
    end)
    LEM:RegisterCallback('layout', function(layoutName)
        if not BPF_DB then
            BPF_DB = {}
        end
        if not BPF_DB.party then
            BPF_DB.party = CopyTable(defaultPosition)
        end

        BigPartyFrame:ClearAllPoints()
        BigPartyFrame:SetPoint(BPF_DB.party.point, BPF_DB.party.x, BPF_DB.party.y)
    end)
end

function BPF:OnInitialize()
    -- Database Default profile
    local defaults = {
        profile = {
            party = {
                x = 0,
                y = 0,
                point = "CENTER"
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

    SetupEditMode(defaults.profile.party)

end

function BPF:OnEnable()
    BPF:EnablePartyStyle()
    BPF:EnablePartyAuras()
    BPF:InitializeMasque()
end
