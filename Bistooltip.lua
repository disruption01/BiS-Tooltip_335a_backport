local LibExtraTip = LibStub:GetLibrary("LibExtraTip-1");
local eventFrame = CreateFrame("Frame", nil, UIParent)
Bistooltip_phases_string = ""

local function specHighlighted(class_name, spec_name)
    return (BistooltipAddon.db.char.highlight_spec.spec_name == spec_name
            and BistooltipAddon.db.char.highlight_spec.class_name == class_name)
end

local function specFiltered(class_name, spec_name)
    if specHighlighted(class_name, spec_name) then
        return false
    end
    if IsAltKeyDown() then
        return false
    end
    if BistooltipAddon.db.char.filter_specs[class_name] then
        return not BistooltipAddon.db.char.filter_specs[class_name][spec_name]
    end
    return false
end

local function classNamesFiltered()
    if BistooltipAddon.db.char.filter_class_names then
        return true
    end
end

local function getFilteredItem(item)
    local filtered_item = {}

    for ki, spec in ipairs(item) do
        local class_name = spec.class_name
        local spec_name = spec.spec_name
        if (not specFiltered(class_name, spec_name)) then
            table.insert(filtered_item, spec)
        end
    end
    return filtered_item
end

local function printSpecLine(tooltip, slot, class_name, spec_name)
    local slot_name = slot.name
    local slot_ranks = slot.ranks
    local prefix = "   "
    if BistooltipAddon.db.char.filter_class_names then
        prefix = ""
    end
    local left_text = prefix .. "|T" .. Bistooltip_spec_icons[class_name][spec_name] .. ":14|t " .. spec_name
    if (slot_name == "Off hand" or slot_name == "Weapon" or slot_name == "Weapon 1h" or slot_name == "Weapon 2h") then
        left_text = left_text .. " (" .. slot_name .. ")"
    end
    local color_r = 1
    local color_g = 0.8
    local color_b = 0
    if specHighlighted(class_name, spec_name) then
        color_r = 0.074
        color_g = 0.964
        color_b = 0.129
    end
    LibExtraTip:AddDoubleLine(
            tooltip, left_text, slot_ranks,
            color_r, color_g, color_b,
            color_r, color_g, color_b,
            false)
end

local function printClassName(tooltip, class_name)
    LibExtraTip:AddLine(tooltip, class_name, 1, 0.8, 0, false)
end

local function OnGameTooltipSetItem(tooltip)
    if BistooltipAddon.db.char.tooltip_with_ctrl and not IsControlKeyDown() then
        return
    end
    local _, link = tooltip:GetItem();

    if link == nil then
        return ;
    end

    local _, itemId, _, _, _, _, _, _, _, _, _, _, _, _ = strsplit(":", link)

    itemId = tonumber(itemId);
    if Bistooltip_items[itemId] == nil then
        return ;
    end
    local item = Bistooltip_items[itemId]
    local specs_count = #item
    item = getFilteredItem(item)
    if (#item > 0) then
        LibExtraTip:AddDoubleLine(tooltip, "Spec name", Bistooltip_phases_string, 1, 1, 0, 1, 1, 0, false)
    else
        return
    end
    local previous_class = nil
    for ki, spec in ipairs(item) do
        local class_name = spec.class_name
        local spec_name = spec.spec_name
        local slots = spec.slots
        for ks, slot in ipairs(slots) do
            if (not classNamesFiltered()) then
                if not (previous_class == class_name) then
                    printClassName(tooltip, class_name)
                    previous_class = class_name
                end
            end
            printSpecLine(tooltip, slot, class_name, spec_name)
        end
    end
    if #item > 0 and Bistooltip_char_equipment[itemId] ~= nil then
        LibExtraTip:AddLine(tooltip, " ", 1, 1, 0, false)
        if Bistooltip_char_equipment[itemId] == 2 then
            LibExtraTip:AddLine(tooltip, "You have this item equipped", 0.074, 0.964, 0.129, false)
        else
            LibExtraTip:AddLine(tooltip, "You have this item in your inventory", 0.074, 0.964, 0.129, false)
        end
    end
    if not (#item == specs_count) then
        if (#item > 0) then
            LibExtraTip:AddLine(tooltip, " ", 1, 1, 0, false)
        end
        LibExtraTip:AddLine(tooltip, "Hold ALT to disable spec filtering", 0.6, 0.6, 0.6, false)
    end
end

function BistooltipAddon:initBisTooltip()
    LibExtraTip:AddCallback({ type = "item", callback = OnGameTooltipSetItem, allevents = true })
    LibExtraTip:RegisterTooltip(GameTooltip);
    LibExtraTip:RegisterTooltip(ItemRefTooltip);
    eventFrame:RegisterEvent("MODIFIER_STATE_CHANGED");
    eventFrame:SetScript("OnEvent", function(_, _, e_key, _, _)
        if (GameTooltip:GetOwner()) then
            if (GameTooltip:GetOwner().hasItem) then
                return
            end

            if (e_key == "RALT" or e_key == "LALT") then
                local _, link = GameTooltip:GetItem()
                if link then
                    GameTooltip:SetHyperlink("|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r")
                    GameTooltip:SetHyperlink(link)
                end
            end
        end
    end)
end