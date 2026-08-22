require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'

-- Сделал по примеру из доки 
-- TODO: Нужно проверить работоспособность обоих методов!!

-- CCTV Camera (Default)
-- @arg place Указываем место спавна: MechanicShelfElectric 
local CCTV_Distribution = {
    MechanicShelfElectric = {
        rolls = 2,
        items = {
            "CCTV.CameraItem", 2,
            "CCTV.RepeaterItem", 1
        },
        junk = {
            rolls = 1,
            items = {
                "CCTV.CameraItem", 2,
                "CCTV.RepeaterItem", 1
            }
        }
    },
    StoreShelfElectronics = {
        rolls = 1,
        items = {
            "CCTV.CameraItem", 4,
            "CCTV.RepeaterItem", 1
        }
    },
}

local ProceduralDistributions_list = ProceduralDistributions.list
local table_insert = table.insert

local function insertInDistrbution(distrib)
    for k,v in pairs(distrib) do
        local ProceduralDistributions_list_k = ProceduralDistributions_list[k]

        -- insert items
        local items = v.items
        local ProceduralDistributions_list_k_items = ProceduralDistributions_list_k.items
        if items then
            for i = 1,#items do
                table_insert(ProceduralDistributions_list_k_items,items[i])
            end
        end

        local junk = v.junk
        local ProceduralDistributions_list_k_junk = ProceduralDistributions_list_k.junk
        if junk then
            for i = 1,#junk do
                table_insert(ProceduralDistributions_list_k_junk,junk[i])
            end
        end
    end
end

insertInDistrbution(CCTV_Distribution)
