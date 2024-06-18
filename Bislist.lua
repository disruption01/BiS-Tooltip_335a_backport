local AceGUI = LibStub("AceGUI-3.0")

local class = nil
local spec = nil
local phase = nil
local class_index = nil
local spec_index = nil
local phase_index = nil

local class_options = {}
local class_options_to_class = {}

local spec_options = {}
local spec_options_to_spec = {}
local spec_frame = nil
local items = {}
local spells = {}
local main_frame = nil

local classDropdown = nil
local specDropdown = nil
local phaseDropDown = nil

local checkmarks = {}

local function createItemFrame(item_id, size, with_checkmark)
    if item_id < 0 then
        local f = AceGUI:Create("Label")
        return f
    end
    local item_frame = AceGUI:Create("Icon")
    item_frame:SetImageSize(size, size)
    items[item_id] = Item:CreateFromItemID(item_id);

    if (items[item_id]:GetItemID()) then
        items[item_id]:ContinueOnItemLoad(function()
            local ilink = items[item_id]:GetItemLink()
            item_frame:SetImage(items[item_id]:GetItemIcon())
            if with_checkmark == true then
                local checkMark = item_frame.frame:CreateTexture(nil, "OVERLAY")
                checkMark:SetWidth(32)
                checkMark:SetHeight(32)
                checkMark:SetPoint("CENTER", 6, -8)
                checkMark:SetTexture("Interface\\AddOns\\Bistooltip\\checkmark-16.tga")
                table.insert(checkmarks, checkMark)
            end

            item_frame:SetCallback("OnClick", function(button)
                SetItemRef(ilink, ilink, "LeftButton");
            end)
            item_frame:SetCallback("OnEnter", function(widget)
                GameTooltip:SetOwner(item_frame.frame)
                GameTooltip:SetPoint("TOPRIGHT", item_frame.frame, "TOPRIGHT", 220, -13);
                GameTooltip:SetHyperlink(ilink)
            end)
            item_frame:SetCallback("OnLeave", function(widget)
                GameTooltip:Hide()
            end)
        end)
    end
    return item_frame
end

local function createSpellFrame(spell_id, size)
    if spell_id < 0 then
        local f = AceGUI:Create("Label")
        return f
    end
    local spell_frame = AceGUI:Create("Icon")
    spell_frame:SetImageSize(size, size)
    spells[spell_id] = Spell:CreateFromSpellID(spell_id);

    if (spells[spell_id]:GetSpellID()) then
        spells[spell_id]:ContinueOnSpellLoad(function()
            local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spell_id)
            spell_frame:SetImage(icon)
            local link = GetSpellLink(spell_id)
            if link == nil then
                link = "\124cffffd000\124Hspell:" .. spell_id .. "\124h[" .. name .. "]\124h\124r"
            end
            spell_frame:SetCallback("OnClick", function(button)
                SetItemRef(link, link, "LeftButton");
            end)
            spell_frame:SetCallback("OnEnter", function(widget)
                GameTooltip:SetOwner(spell_frame.frame)
                GameTooltip:SetPoint("TOPRIGHT", spell_frame.frame, "TOPRIGHT", 220, -13);
                GameTooltip:SetHyperlink(link)
            end)
            spell_frame:SetCallback("OnLeave", function(widget)
                GameTooltip:Hide()
            end)
        end)
    end
    return spell_frame
end

local function createEnhancementsFrame(enhancements)
    local frame = AceGUI:Create("SimpleGroup")
    frame:SetLayout("Table")
    frame:SetWidth(40)
    frame:SetHeight(40)
    frame:SetUserData("table", {
        columns = {
            { weight = 14 },
            { width = 14 } },
        spaceV = -10,
        spaceH = 0,
        align = "BOTTOMRIGHT"
    })
    frame:SetFullWidth(true)
    frame:SetFullHeight(true)
    frame:SetHeight(0)
    frame:SetAutoAdjustHeight(false)
    for i, enhancement in ipairs(enhancements) do
        local size = 16

        if enhancement.type == "none" then
            frame:AddChild(createItemFrame(-1, size))
        end
        if enhancement.type == "item" then
            frame:AddChild(createItemFrame(enhancement.id, size))
        end
        if enhancement.type == "spell" then
            frame:AddChild(createSpellFrame(enhancement.id, size))
        end
    end
    return frame
end

local function drawItemSlot(slot)
    local f = AceGUI:Create("Label")
    f:SetText(slot.slot_name)
    f:SetFont("Fonts\\FRIZQT__.TTF", 14)
    spec_frame:AddChild(f)
    spec_frame:AddChild(createEnhancementsFrame(slot.enhs))
    for i, item_id in ipairs(slot) do
        if item_id~=nil and Bistooltip_char_equipment[item_id] == 1 then
            spec_frame:AddChild(createItemFrame(item_id, 40, true))
        else
            spec_frame:AddChild(createItemFrame(item_id, 40))
        end
    end
end

local function drawTableHeader(frame)
    local f = AceGUI:Create("Label")
    f:SetText("Slot")
    f:SetFont("Fonts\\FRIZQT__.TTF", 14)
    local color = 0.6
    f:SetColor(color, color, color)
    frame:AddChild(f)
    frame:AddChild(AceGUI:Create("Label"))
    for i = 1, 6 do
        f = AceGUI:Create("Label")
        f:SetText("Top " .. i)
        f:SetColor(color, color, color)
        frame:AddChild(f)
    end
end

local function saveData()
    BistooltipAddon.db.char.class_index = class_index
    BistooltipAddon.db.char.spec_index = spec_index
    BistooltipAddon.db.char.phase_index = phase_index
end

local function drawSpecData()
    saveData()
    items = {}
    spells = {}
    spec_frame:ReleaseChildren()
    drawTableHeader(spec_frame)
    if not spec or not phase then
        return
    end
    local slots = Bistooltip_bislists[class][spec][phase]
    for key,value in ipairs(checkmarks) do
       value:SetTexture(nil)
    end
    checkmarks = {}
    for i, slot in ipairs(slots) do
        drawItemSlot(slot)
    end
end

local function buildClassDict()
    class_options = {}
    for ci, class in ipairs(Bistooltip_classes) do
        local option_name = "|T" .. Bistooltip_spec_icons[class.name].classIcon .. ":14|t " .. class.name
        table.insert(class_options, option_name)
        class_options_to_class[option_name] = { name = class.name, i = ci }
    end
end

local function buildSpecsDict(class_i)
    spec_options = {}
    spec_options_to_spec = {}
    for si, spec in ipairs(Bistooltip_classes[class_i].specs) do
        local option_name = "|T" .. Bistooltip_spec_icons[class][spec] .. ":14|t " .. spec
        table.insert(spec_options, option_name)
        spec_options_to_spec[option_name] = spec
    end
end

local function loadData()
    class_index = BistooltipAddon.db.char.class_index
    spec_index = BistooltipAddon.db.char.spec_index
    phase_index = BistooltipAddon.db.char.phase_index
    if class_index then
        class = class_options_to_class[class_options[class_index]].name
        buildSpecsDict(class_index)
    end
    if spec_index then
        spec = spec_options_to_spec[spec_options[spec_index]]
    end
    if phase_index then
        phase = Bistooltip_phases[phase_index]
    end
end

local function drawDropdowns()
    local dropDownGroup = AceGUI:Create("SimpleGroup")

    dropDownGroup:SetLayout("Table")
    dropDownGroup:SetUserData("table", {
        columns = {
            110, 180, 70 },
        space = 1,
        align = "BOTTOMRIGHT"
    })
    main_frame:AddChild(dropDownGroup)

    classDropdown = AceGUI:Create("Dropdown")
    specDropdown = AceGUI:Create("Dropdown")
    phaseDropDown = AceGUI:Create("Dropdown")
    specDropdown:SetDisabled(true)

    phaseDropDown:SetCallback("OnValueChanged", function(_, _, key)
        phase_index = key
        phase = Bistooltip_phases[key]
        drawSpecData()
    end)

    specDropdown:SetCallback("OnValueChanged", function(_, _, key)
        spec_index = key
        spec = spec_options_to_spec[spec_options[key]]
        drawSpecData()
    end)

    classDropdown:SetCallback("OnValueChanged", function(_, _, key)
        class_index = key
        class = class_options_to_class[class_options[key]].name

        specDropdown:SetDisabled(false)
        buildSpecsDict(key)
        specDropdown:SetList(spec_options)
        specDropdown:SetValue(1)
        spec_index = 1
        spec = spec_options_to_spec[spec_options[1]]
        drawSpecData()
    end)

    classDropdown:SetList(class_options)
    phaseDropDown:SetList(Bistooltip_phases)

    dropDownGroup:AddChild(classDropdown)
    dropDownGroup:AddChild(specDropdown)
    dropDownGroup:AddChild(phaseDropDown)

    local fillerFrame = AceGUI:Create("Label")
    fillerFrame:SetText(" ")
    main_frame:AddChild(fillerFrame)

    classDropdown:SetValue(class_index)
    if (class_index) then
        buildSpecsDict(class_index)
        specDropdown:SetList(spec_options)
        specDropdown:SetDisabled(false)
    end
    specDropdown:SetValue(spec_index)
    phaseDropDown:SetValue(phase_index)
end

local function createSpecFrame()
    local frame = AceGUI:Create("ScrollFrame")
    frame:SetLayout("Table")
    frame:SetUserData("table", {
        columns = {
            { weight = 40 },
            { width = 44 },
            { width = 44 },
            { width = 44 },
            { width = 44 },
            { width = 44 },
            { width = 44 },
            { width = 44 } },
        space = 1,
        align = "middle"
    })
    frame:SetFullWidth(true)
    frame:SetHeight(0)
    frame:SetAutoAdjustHeight(false)
    main_frame:AddChild(frame)
    spec_frame = frame
end

function BistooltipAddon:reloadData()
    buildClassDict()
    class_index = BistooltipAddon.db.char.class_index
    spec_index = BistooltipAddon.db.char.spec_index
    phase_index = BistooltipAddon.db.char.phase_index

    class = class_options_to_class[class_options[class_index]].name
    buildSpecsDict(class_index)
    spec = spec_options_to_spec[spec_options[spec_index]]
    phase = Bistooltip_phases[phase_index]

    if main_frame then
        phaseDropDown:SetList(Bistooltip_phases)
        classDropdown:SetList(class_options)
        specDropdown:SetList(spec_options)

        classDropdown:SetValue(class_index)
        specDropdown:SetValue(spec_index)
        phaseDropDown:SetValue(phase_index)

        drawSpecData()
        main_frame:SetStatusText(Bistooltip_source_to_url[BistooltipAddon.db.char["data_source"]])
    end
end

function BistooltipAddon:createMainFrame()
    if main_frame then
        BistooltipAddon:closeMainFrame()
        return
    end
    main_frame = AceGUI:Create("Frame")
    main_frame:SetWidth(450)
    main_frame.frame:SetMinResize(420,300)
    main_frame:SetCallback("OnClose", function(widget)
        spec_frame = nil
        items = {}
        spells = {}
        AceGUI:Release(widget)
        main_frame = nil
    end)
    main_frame:SetLayout("List")
    main_frame:SetTitle(BistooltipAddon.AddonNameAndVersion)
    main_frame:SetStatusText(Bistooltip_source_to_url[BistooltipAddon.db.char["data_source"]])
    drawDropdowns()
    createSpecFrame()
    drawSpecData()
end

function BistooltipAddon:closeMainFrame()
    if main_frame then
        AceGUI:Release(main_frame)
        classDropdown = nil
        specDropdown = nil
        phaseDropDown = nil
        return
    end
end


function BistooltipAddon:initBislists()
    buildClassDict()
    loadData()
    LibStub("AceConsole-3.0"):RegisterChatCommand("bistooltip", function()
        BistooltipAddon:createMainFrame()
    end, persist)
end
