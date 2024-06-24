BistooltipAddon = LibStub("AceAddon-3.0"):NewAddon("Bis-Tooltip")

Bistooltip_char_equipment = {}

local function createEquipmentWatcher()
    local frame = CreateFrame("Frame")
    frame:Hide()

    frame:SetScript("OnEvent", frame.Show)
    frame:RegisterEvent("BAG_UPDATE")

    local flag = false

    frame:SetScript("OnUpdate", function(self)
        self:Hide()
        if flag == false then
            flag = true
            local collection = {}
            for bag = 0, NUM_BAG_SLOTS do
                -- Wrath of the Lich King method to get container slots
                local numSlots = GetContainerNumSlots(bag)
                for slot = 1, numSlots do
                    -- Wrath of the Lich King method to get item ID from a slot
                    local itemLink = GetContainerItemLink(bag, slot)
                    if itemLink then
                        local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
                        if itemID then
                            collection[itemID] = 1
                        end
                    end
                end
            end

            -- Check worn equipment
            for i = 0, 18 do
                local itemID = GetInventoryItemID("player", i)
                if itemID then
                    collection[itemID] = 2
                end
            end

            Bistooltip_char_equipment = collection
            flag = false
        end
    end)
end

function BistooltipAddon:OnInitialize()
    createEquipmentWatcher()
    BistooltipAddon.AceAddonName = "Bis-Tooltip"
    BistooltipAddon.AddonNameAndVersion = "Bis-Tooltip v7.42"
    BistooltipAddon:initConfig()
    BistooltipAddon:addMapIcon()
    BistooltipAddon:initBislists()
    BistooltipAddon:initBisTooltip()
end
