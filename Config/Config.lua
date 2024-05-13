local BPF_Config = BPF:NewModule("BPF_Config")

function BPF_Config:OnEnable()
    -- Create Menu
    local options = {
        type = 'group',
        args = {
            moreoptions={
                name = 'General',
                type = 'group',
                childGroups = "select",
                args={
                    partyframesHeader = {
                        type = 'header',
                        name = 'Party Frames Options',
                        order = 1
                    },
                    use_class_portraits = {
                        type = "toggle",
                        order = 1,
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
                        type = "toggle",
                        order = 2,
                        name = 'Remove Realm From Name (Requires ReloadUI)',
                        desc = 'Remove the Realm name from the player\'s name',
                        set = function(_, val)
                            BPF_DB.remove_realm_name = val
                        end,
                        get = function()
                            return BPF_DB.remove_realm_name
                        end
                    },
                    -- auraHeader = {
                    --     type = 'header',
                    --     name = 'Auras Options',
                    --     order = 50
                    -- },
                    -- max_buff_debuff_desc = {
                    --     type = 'description',
                    --     name = 'These options require a reload of the ui.',
                    --     order = 51
                    -- },
                    -- max_party_buffs = {
                    --     type = "range",
                    --     min = 3,
                    --     max = 20,
                    --     step = 1,
                    --     order = 53,
                    --     name = 'Max Party Buffs',
                    --     desc = 'Set the maximum number of visible buffs',
                    --     set = function(_, val)
                    --         BPF_DB.max_party_buffs = val
                    --     end,
                    --     get = function()
                    --         return BPF_DB.max_party_buffs
                    --     end
                    -- },
                    -- max_party_debuffs = {
                    --     type = "range",
                    --     min = 3,
                    --     max = 20,
                    --     step = 1,
                    --     order = 54,
                    --     name = 'Max Party Debuffs',
                    --     desc = 'Set the maximum number of visible debuffs',
                    --     set = function(_, val)
                    --         BPF_DB.max_party_debuffs = val
                    --     end,
                    --     get = function()
                    --         return BPF_DB.max_party_debuffs
                    --     end
                    -- }
                }
            }
        }
    }

    -- Register Menu
    LibStub('AceConfig-3.0'):RegisterOptionsTable('Big Party Frames', options)
    local BPF_Config = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('Big Party Frames')

    -- Slash Command Function
    function SlashCommand(msg)
        InterfaceOptionsFrame_OpenToCategory(BPF_Config)
    end

    -- Register Slash Command
    BPF:RegisterChatCommand('BPF', SlashCommand)
end
