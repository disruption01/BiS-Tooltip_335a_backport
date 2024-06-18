BistooltipAddon = LibStub("AceAddon-3.0"):NewAddon("Bis-Tooltip")
--local AceAddon =

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
                for slot = 1, GetContainerNumSlots(bag) do
                    local itemID = GetContainerItemID(bag, slot)
                    if itemID ~= nil then
                        collection[itemID] = 1
                    end
                end
            end
            for i=0,18 do
                local itemID = GetInventoryItemID("player", i)
                if itemID ~= nil then
                    collection[itemID] = 1
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
    BistooltipAddon.AddonNameAndVersion = "Bis-Tooltip v7.10"
    BistooltipAddon:initConfig()
    BistooltipAddon:addMapIcon()
    BistooltipAddon:initBislists()
    BistooltipAddon:initBisTooltip()
end
