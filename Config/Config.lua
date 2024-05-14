BPF_Config = BPF:NewModule("BPF_Config")

function BPF_Config:OnEnable()
    -- Create Menu
    local options = {
        type = 'group',
        args = {
            moreoptions={
                name = 'General',
                type = 'group',
                childGroups = 'select',
                args={
                    partyframesHeader = {
                        type = 'header',
                        name = 'Party Frames Options',
                        order = 1
                    },
                    use_class_portraits = {
                        type = 'toggle',
                        order = 2,
                        width = 'full',
                        name = 'Use Class Portraits',
                        desc = 'Use class portraits instead of the default portraits',
                        set = function(_, val)
                            BPF_DB.use_class_portraits = val
                            for i=1, MAX_PARTY_MEMBERS do
                                local PartyMemberFrame = PartyFrame["MemberFrame" .. i]
                                if PartyMemberFrame then
                                    BPF:ClassPortraits(PartyMemberFrame)
                                end
                            end
                        end,
                        get = function()
                            return BPF_DB.use_class_portraits
                        end
                    },
                    remove_realm_name = {
                        type = 'toggle',
                        order = 3,
                        width = 'full',
                        name = 'Remove Realm From Name (*)',
                        desc = 'Remove the Realm name from the player\'s name',
                        set = function(_, val)
                            BPF_DB.remove_realm_name = val
                        end,
                        get = function()
                            return BPF_DB.remove_realm_name
                        end
                    },
                    auraHeader = {
                        type = 'header',
                        name = 'Auras Options',
                        order = 10
                    },
                    max_party_buffs = {
                        type = 'range',
                        min = 3,
                        max = 20,
                        step = 1,
                        order = 12,
                        name = 'Max Party Buffs (*)',
                        desc = 'Set the maximum number of visible buffs',
                        set = function(_, val)
                            BPF_DB.max_party_buffs = val
                        end,
                        get = function()
                            return BPF_DB.max_party_buffs
                        end
                    },
                    max_party_debuffs = {
                        type = 'range',
                        min = 3,
                        max = 20,
                        step = 1,
                        order = 13,
                        name = 'Max Party Debuffs (*)',
                        desc = 'Set the maximum number of visible debuffs',
                        set = function(_, val)
                            BPF_DB.max_party_debuffs = val
                        end,
                        get = function()
                            return BPF_DB.max_party_debuffs
                        end
                    },
                    reload_ui_warning = {
                        type = 'description',
                        name = '(*) These options require a reload of the ui.',
                        order = -1
                    }
                }
            }
        }
    }

    -- Register Menu
    LibStub('AceConfig-3.0'):RegisterOptionsTable('Big Party Frames', options)
    local BPF_ConfigPanel = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('Big Party Frames')

    -- Register Slash Command
    BPF:RegisterChatCommand('BPF', function(_)
        InterfaceOptionsFrame_OpenToCategory(BPF_ConfigPanel)
    end)
end
