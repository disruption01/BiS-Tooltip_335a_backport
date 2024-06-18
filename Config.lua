local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local icon_loaded = false
local icon_name = "BisTooltipIcon"

local sources = {
    wh = "wh",
    wowtbc = "wowtbc"
}

Bistooltip_source_to_url = {
    ["wh"] = "wowhead.com/wotlk [beta]",
    ["wowtbc"] = "wowtbc.gg/wotlk"
}

local db_defaults = {
    char = {
        class_index = 1,
        spec_index = 1,
        phase_index = 1,
        filter_specs = {},
        highlight_spec = {},
        data_source = Nil,
        minimap_icon = true
    }
}

local configTable = {
    type = "group",
    args = {
        minimap_icon = {
            name = "Show minimap icon",
            order = 0,
            desc = "Shows/hides minimap icon",
            type = "toggle",
            set = function(info, val)
                BistooltipAddon.db.char.minimap_icon = val
                if val == true then
                    if icon_loaded == true then
                        LDBIcon:Show(icon_name)
                    else
                        BistooltipAddon:addMapIcon()
                    end
                else
                    LDBIcon:Hide(icon_name)
                end
            end,
            get = function(info)
                return BistooltipAddon.db.char.minimap_icon
            end
        },
        filter_class_names = {
            name = "Filter class names",
            order = 0,
            desc = "Removes class name separators from item tooltips",
            type = "toggle",
            set = function(info, val)
                BistooltipAddon.db.char.filter_class_names = val
            end,
            get = function(info)
                return BistooltipAddon.db.char.filter_class_names
            end
        },
        data_source = {
            name = "Data source",
            order = 1,
            desc = "Changes bis data source",
            type = "select",
            style = "dropdown",
            width = "double",
            values = Bistooltip_source_to_url,
            set = function(info, key, val)
                BistooltipAddon.db.char.data_source = key
                BistooltipAddon:changeSpec(key)
            end,
            get = function(info, key)
                return BistooltipAddon.db.char.data_source
            end
        },
        filter_specs = {
            name = "Filter specs",
            order = 2,
            desc = "Removes unselected specs from item tooltips",
            type = "multiselect",
            values = nil,
            set = function(info, key, val)
                local ci, si = strsplit(":", key)
                ci = tonumber(ci)
                si = tonumber(si)
                local class_name = Bistooltip_classes[ci].name
                local spec_name = Bistooltip_classes[ci].specs[si]
                BistooltipAddon.db.char.filter_specs[class_name][spec_name] = val
            end,
            get = function(info, key)
                local ci, si = strsplit(":", key)
                ci = tonumber(ci)
                si = tonumber(si)
                local class_name = Bistooltip_classes[ci].name
                local spec_name = Bistooltip_classes[ci].specs[si]
                if (not BistooltipAddon.db.char.filter_specs[class_name]) then
                    BistooltipAddon.db.char.filter_specs[class_name] = {}
                end
                if (BistooltipAddon.db.char.filter_specs[class_name][spec_name] == nil) then
                    BistooltipAddon.db.char.filter_specs[class_name][spec_name] = true
                end
                return BistooltipAddon.db.char.filter_specs[class_name][spec_name]
            end
        },
        highlight_spec = {
            name = "Highlight spec",
            order = 3,
            desc = "Highlights selected spec in item tooltips",
            type = "multiselect",
            values = nil,
            set = function(info, key, val)
                if val then
                    local ci, si = strsplit(":", key)
                    ci = tonumber(ci)
                    si = tonumber(si)
                    local class_name = Bistooltip_classes[ci].name
                    local spec_name = Bistooltip_classes[ci].specs[si]
                    BistooltipAddon.db.char.highlight_spec = {
                        key = key,
                        class_name = class_name,
                        spec_name = spec_name
                    }
                else
                    BistooltipAddon.db.char.highlight_spec = {
                    }
                end

            end,
            get = function(info, key)
                return BistooltipAddon.db.char.highlight_spec.key == key
            end
        }
    }
}

local function buildFilterSpecOptions()
    local filter_specs_options = {}
    for ci, class in ipairs(Bistooltip_classes) do
        for si, spec in ipairs(Bistooltip_classes[ci].specs) do
            local option_val = "|T" .. Bistooltip_spec_icons[class.name][spec] .. ":16|t " .. class.name .. " " .. spec
            local option_key = ci .. ":" .. si
            filter_specs_options[option_key] = option_val
        end
    end
    configTable.args.filter_specs.values = filter_specs_options
    configTable.args.highlight_spec.values = filter_specs_options
end

local function openSourceSelectDialog()
    local frame = AceGUI:Create("Window")
    frame:SetWidth(300)
    frame:SetHeight(150)
    frame:EnableResize(false)
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        frame = nil
    end)
    frame:SetLayout("List")
    frame:SetTitle(BistooltipAddon.AddonNameAndVersion)

    local labelEmpty = AceGUI:Create("Label")
    labelEmpty:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
    labelEmpty:SetText(" ")
    frame:AddChild(labelEmpty)

    local label = AceGUI:Create("Label")
    label:SetText("Please select a bis data source to be used for this addon:")
    label:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
    label:SetRelativeWidth(1)
    frame:AddChild(label)

    local labelEmpty2 = AceGUI:Create("Label")
    labelEmpty2:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
    labelEmpty2:SetText(" ")
    frame:AddChild(labelEmpty2)

    local sourceDropdown = AceGUI:Create("Dropdown")
    sourceDropdown:SetCallback("OnValueChanged", function(_, _, key)
        BistooltipAddon.db.char.data_source = key
        BistooltipAddon:changeSpec(key)
    end)
    sourceDropdown:SetRelativeWidth(1)
    sourceDropdown:SetList(Bistooltip_source_to_url)
    sourceDropdown:SetValue(BistooltipAddon.db.char["data_source"])
    frame:AddChild(sourceDropdown)
end

local function migrateAddonDB()
    if not BistooltipAddon.db.char["version"] then
        BistooltipAddon.db.char.version = 6.1
        BistooltipAddon.db.char.highlight_spec = {}
        BistooltipAddon.db.char.filter_specs = {}
        BistooltipAddon.db.char.class_index = 1
        BistooltipAddon.db.char.spec_index = 1
        BistooltipAddon.db.char.phase_index = 1
    end
    if BistooltipAddon.db.char["data_source"] == Nil then
        BistooltipAddon.db.char.data_source = sources.wowtbc
        openSourceSelectDialog()
    end
end

local config_shown = false
function BistooltipAddon:openConfigDialog()
    if config_shown then
        InterfaceOptionsFrame_Show()
    else
        InterfaceOptionsFrame_OpenToCategory(BistooltipAddon.AceAddonName)
        InterfaceOptionsFrame_OpenToCategory(BistooltipAddon.AceAddonName)
    end
    config_shown = not (config_shown)
end

local function enableSpec(spec_name)

    if spec_name == sources.wowtbc then
        Bistooltip_bislists = Bistooltip_wowtbc_bislists;
        Bistooltip_items = Bistooltip_wowtbc_items;
        Bistooltip_classes = Bistooltip_wowtbc_classes;
        Bistooltip_phases = Bistooltip_wowtbc_phases;
    elseif spec_name == sources.wh then
        Bistooltip_bislists = Bistooltip_wh_bislists;
        Bistooltip_items = Bistooltip_wh_items;
        Bistooltip_classes = Bistooltip_wh_classes;
        Bistooltip_phases = Bistooltip_wh_phases;
    end
    Bistooltip_phases_string = ""
    for i, phase in ipairs(Bistooltip_phases) do
        if i ~= 1 then
            Bistooltip_phases_string = Bistooltip_phases_string .. "/"
        end
        Bistooltip_phases_string = Bistooltip_phases_string .. phase
    end

    buildFilterSpecOptions()
end

function BistooltipAddon:addMapIcon()
    if BistooltipAddon.db.char.minimap_icon then
        icon_loaded = true
        local LDB = LibStub("LibDataBroker-1.1", true)
        local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
        if LDB then
            local PC_MinimapBtn = LDB:NewDataObject(icon_name, {
                type = "launcher",
                text = icon_name,
                icon = "interface/icons/inv_weapon_glave_01.blp",
                OnClick = function(_, button)
                    if button == "LeftButton" then
                        BistooltipAddon:createMainFrame()
                    end
                    if button == "RightButton" then
                        BistooltipAddon:openConfigDialog()
                    end
                end,
                OnTooltipShow = function(tt)
                    tt:AddLine(BistooltipAddon.AddonNameAndVersion)
                    tt:AddLine("|cffffff00Left click|r to open the BiS lists window")
                    tt:AddLine("|cffffff00Right click|r to open addon configuration window")
                end,
            })
            if LDBIcon then
                LDBIcon:Register(icon_name, PC_MinimapBtn, BistooltipAddon.db.char)
            end
        end
    end
end

function BistooltipAddon:changeSpec(spec_name)
    BistooltipAddon.db.char.class_index = 1
    BistooltipAddon.db.char.spec_index = 1
    BistooltipAddon.db.char.phase_index = 1
    enableSpec(spec_name)

    BistooltipAddon:initBislists()
    BistooltipAddon:reloadData()
end

function BistooltipAddon:initConfig()

    BistooltipAddon.db = LibStub("AceDB-3.0"):New("BisTooltipDB", db_defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable(BistooltipAddon.AceAddonName, configTable)
    AceConfigDialog:AddToBlizOptions(BistooltipAddon.AceAddonName, BistooltipAddon.AceAddonName)

    migrateAddonDB()

    Bistooltip_bislists = {};
    Bistooltip_items = {};

    enableSpec(BistooltipAddon.db.char["data_source"])
end