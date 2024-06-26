local eventFrame = CreateFrame("Frame", nil, UIParent)
Bistooltip_phases_string = ""

local function specHighlighted(class_name, spec_name)
    return (BistooltipAddon.db.char.highlight_spec.spec_name == spec_name and
               BistooltipAddon.db.char.highlight_spec.class_name == class_name)
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
    tooltip:AddDoubleLine(left_text, slot_ranks, 1, 0.8, 0)
end

local function printClassName(tooltip, class_name)
    tooltip:AddLine(class_name, 1, 0.8, 0)
end

-- Function to search for item in bislists and return phases
function searchIDInBislists(structure, id)
    print("Debug: Searching for id " .. id)
    local paths = {}

    for class, specs in pairs(structure) do
        print("Debug: Class " .. class)
        for spec, phases in pairs(specs) do
            print("Debug: Spec " .. spec)
            for phase, items in pairs(phases) do
                print("Debug: Phase " .. phase)
                for index, itemData in pairs(items) do
                    if type(itemData) == "table" and itemData[1] then
                        for i, itemId in ipairs(itemData) do
                            if i ~= "slot_name" and i ~= "enhs" and itemId == id then
                                local path = class .. " - " .. spec .. " - " .. phase .. " " .. i
                                table.insert(paths, path)
                                print("Debug: Found item id " .. id .. " at " .. path)
                            end
                        end
                    end
                end
            end
        end
    end

    if #paths > 0 then
        return paths
    else
        print("Debug: Item id " .. id .. " not found")
        return nil
    end
end

-- Define your search function without debug prints
function searchIDInBislistsClassSpec(structure, id, class, spec)
    local paths = {}
    local seen = {} -- To track unique phase labels

    -- Sort phases according to Bistooltip_wowtbc_phases order
    local sortedPhases = {}
    for _, phase in ipairs(Bistooltip_wowtbc_phases) do
        if structure[class] and structure[class][spec] and structure[class][spec][phase] then
            table.insert(sortedPhases, phase)
        end
    end

    -- Iterate over sorted phases
    for _, phase in ipairs(sortedPhases) do
        local items = structure[class][spec][phase]

        for index, itemData in pairs(items) do
            if type(itemData) == "table" and itemData[1] then
                for i, itemId in ipairs(itemData) do
                    if i ~= "slot_name" and i ~= "enhs" and itemId == id then
                        -- Determine the phase label based on the value of i
                        local phaseLabel
                        if i == 1 then
                            phaseLabel = phase .. " BIS"
                        else
                            phaseLabel = phase .. " alt " .. i
                        end

                        -- Add phase label to paths if not already seen
                        if not seen[phaseLabel] then
                            table.insert(paths, phaseLabel)
                            seen[phaseLabel] = true
                        end
                    end
                end
            end
        end
    end

    if #paths > 0 then
        return table.concat(paths, " / ")
    else
        return nil
    end
end

local function caseInsensitivePairs(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        return a:lower() < b:lower()
    end)
    local i = 0
    return function()
        i = i + 1
        local k = keys[i]
        if k then
            return k, t[k]
        end
    end
end

-- Function to calculate the length of a string without color codes
local function getStringLength(str)
    return string.len(string.gsub(str, "|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

-- Function to handle item tooltip
local function OnGameTooltipSetItem(tooltip)
    -- print("Debug: OnGameTooltipSetItem called")
    if BistooltipAddon.db.char.tooltip_with_ctrl and not IsControlKeyDown() then
        -- print("Debug: Control key not pressed, exiting")
        return
    end

    local _, link = tooltip:GetItem()
    if not link then
        -- print("Debug: No item link found, exiting")
        return
    end

    local _, itemId, _, _, _, _, _, _, _, _, _, _, _, _ = strsplit(":", link)
    itemId = tonumber(itemId)
    -- print("Debug: Item ID is " .. tostring(itemId))

    if not itemId then
        -- print("Debug: Invalid item ID, exiting")
        return
    end

    -- tooltip:AddDoubleLine("Spec Name", "Phase", 1, 1, 1, 1, 1, 1)

    -- -- Iterate through each class and specialization
    for class, specs in caseInsensitivePairs(Bistooltip_spec_icons) do
        for spec, icon in pairs(specs) do
            -- Skip the 'classIcon' entry
            if spec ~= "classIcon" then
                -- Search for the item ID in the current class and spec
                local foundPhases = searchIDInBislistsClassSpec(Bistooltip_bislists, itemId, class, spec)

                -- Only proceed if search function returns a non-nil value
                if foundPhases then
                    -- Create a single line with icon, class, spec, and found phases
                    local iconString = string.format("|T%s:18|t", icon) -- 18 is the size of the icon
                    local lineText = string.format("%s %s - %s", iconString, class, spec)
                    -- tooltip:AddLine(lineText, 1, 1, 1)
                    tooltip:AddDoubleLine(lineText, foundPhases, 1, 1, 0, 1, 1, 0)

                    -- Add spacing between entries
                    -- tooltip:AddLine(" ", 1, 1, 0)
                end
            end
        end
    end

    -- if Bistooltip_char_equipment and Bistooltip_char_equipment[itemId] ~= nil then
    --     tooltip:AddLine(" ", 1, 1, 0)
    --     if Bistooltip_char_equipment[itemId] == 2 then
    --         tooltip:AddLine("You have this item equipped", 0.074, 0.964, 0.129)
    --     else
    --         tooltip:AddLine("You have this item in your inventory", 0.074, 0.964, 0.129)
    --     end
    -- end

    -- tooltip:AddLine(" ", 1, 1, 0)
    -- tooltip:AddLine("Hold ALT to disable spec filtering", 0.6, 0.6, 0.6)
end

function BistooltipAddon:initBisTooltip()
    eventFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
    eventFrame:SetScript("OnEvent", function(_, _, e_key, _, _)
        if GameTooltip:GetOwner() then
            if GameTooltip:GetOwner().hasItem then
                return
            end

            if e_key == "RALT" or e_key == "LALT" then
                local _, link = GameTooltip:GetItem()
                if link then
                    GameTooltip:SetHyperlink("|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r")
                    GameTooltip:SetHyperlink(link)
                end
            end
        end
    end)

    GameTooltip:HookScript("OnTooltipSetItem", OnGameTooltipSetItem)
    ItemRefTooltip:HookScript("OnTooltipSetItem", OnGameTooltipSetItem)
end
