BistooltipAddon = LibStub("AceAddon-3.0"):NewAddon("Bis-Tooltip")

Bistooltip_char_equipment = {}

local function collectItemIDs(bislists)
    local itemIDs = {}

    for _, classData in pairs(bislists) do
        for _, specData in pairs(classData) do
            for _, phaseData in pairs(specData) do
                for _, itemData in ipairs(phaseData) do
                    for key, value in pairs(itemData) do
                        if type(key) == "number" then
                            table.insert(itemIDs, value)
                        elseif key == "enhs" then
                            for _, enhData in pairs(value) do
                                if enhData.type == "item" and enhData.id then
                                    table.insert(itemIDs, enhData.id)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return itemIDs
end

local function createEquipmentWatcher()
    local frame = CreateFrame("Frame")
    frame:Hide()

    frame:SetScript("OnEvent", frame.Show)
    frame:RegisterEvent("BAG_UPDATE")

    local flag = false

    frame:SetScript("OnUpdate", function(self, elapsed)
        self:Hide()
        if not flag then
            flag = true
            local collection = {}

            -- Check player's bags (inventory)
            for bag = 0, NUM_BAG_SLOTS do
                local numSlots = GetContainerNumSlots(bag)
                for slot = 1, numSlots do
                    local itemLink = GetContainerItemLink(bag, slot)
                    if itemLink then
                        local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
                        if itemID then
                            collection[itemID] = 1 -- Item is in bags
                        end
                    end
                end
            end

            -- Check player's bank
            for bankBag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
                local numSlots = GetContainerNumSlots(bankBag)
                for slot = 1, numSlots do
                    local itemLink = GetContainerItemLink(bankBag, slot)
                    if itemLink then
                        local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
                        if itemID then
                            collection[itemID] = 1 -- Item is in bank
                        end
                    end
                end
            end

            -- Check worn equipment
            for i = 1, 19 do
                local itemID = GetInventoryItemID("player", i)
                if itemID then
                    collection[itemID] = 2 -- Item is equipped
                end
            end

            -- Check items using GetItemCount
            local itemIDs = collectItemIDs(Bistooltip_bislists)
            for _, itemID in ipairs(itemIDs) do
                local count = GetItemCount(itemID, true) -- true includes the bank
                if count > 0 then
                    collection[itemID] = 1 -- Store the item count
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
    BistooltipAddon.AddonNameAndVersion = "Bis-Tooltip 3.3.5a backport by Silver [DisruptionAuras]"
    BistooltipAddon:initConfig()
    BistooltipAddon:addMapIcon()
    BistooltipAddon:initBislists()
    BistooltipAddon:initBisTooltip()
end
