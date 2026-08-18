require "Items/ProceduralDistributions"

local function addCCTVItemsToLoot()
    local cameraItem = "CCTV.CameraItem"
    local relayItem  = "CCTV.RepeaterItem"

    local lootTable = {
        -- Электроника в магазинах и домах
        ["ElectronicStoreMisc"] = {
            [cameraItem] = 1.5,
            [relayItem]  = 0,
        },
        -- Мастерские и гаражи
        ["GarageTools"] = {
            [cameraItem] = 1.0,
            [relayItem]  = 0.5,
        },
        -- Ящики с инструментами
        ["CrateTools"] = {
            [cameraItem] = 0.5,
            [relayItem]  = 0,
        },
        -- Металлические ящики и электроника
        ["CrateElectronics"] = {
            [cameraItem] = 1.0,
            [relayItem]  = 1.0,
        },
        -- Пожарные станции и полицейские участки
        ["PoliceEvidence"] = {
            [cameraItem] = 2.0,
            [relayItem]  = 0.2,
        },
        -- Военные базы и секретные ящики
        ["ArmyStorageElectronics"] = {
            [cameraItem] = 2.0,
            [relayItem]  = 1.0,
        },
    }

    for distName, items in pairs(lootTable) do
        if ProceduralDistributions.list[distName] then
            for itemID, weight in pairs(items) do
                table.insert(ProceduralDistributions.list[distName].items, itemID)
                table.insert(ProceduralDistributions.list[distName].items, weight)
            end
        end
    end
end

if Events and Events.OnPreDistributionMerge then
    Events.OnPreDistributionMerge.Add(addCCTVItemsToLoot)
end

