require "CCTV_Manager"
require "CCTV_i18n"

local function hasAdjacentWallOrFence(square)
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local cell = getCell()

    local neighbors = {
        cell:getGridSquare(x, y - 1, z), -- север
        cell:getGridSquare(x, y + 1, z), -- юг
        cell:getGridSquare(x - 1, y, z), -- запад
        cell:getGridSquare(x + 1, y, z), -- восток
    }

    for _, neighbor in ipairs(neighbors) do
        if neighbor and square:isWallTo(neighbor) then
            return true
        end
    end
    return false
end

local function placeDevice(playerNum, item, isCamera)
    local player = getSpecificPlayer(playerNum)
    if not player then return end
    
    local square = player:getCurrentSquare()
    if not square then return end

    local x, y, z = square:getX(), square:getY(), square:getZ()

    if isCamera then
        -- Камеру можно вешать только на стену или забор
        if not hasAdjacentWallOrFence(square) then
            player:Say(CCTV_i18n.CAMERA_NEEDS_WALL)
            return
        end

        -- Не даём ставить камеры кучей в одном месте
        if CCTV_Manager.isCameraTooClose(x, y) then
            player:Say(CCTV_i18n.CAMERA_TOO_CLOSE)
            return
        end

        local id = CCTV_Manager.generateId("cctv_cam")
        local camName = CCTV_i18n.CAMERA .. " " .. x .. ":" .. y
        CCTV_Manager.registerCamera(id, camName, x, y, z)
        player:Say(CCTV_i18n.CAMERA_WAS_PLANTED .. ": " .. camName)
    else
        local id = CCTV_Manager.generateId("cctv_rep")
        CCTV_Manager.registerRepeater(id, x, y, z)
        player:Say(CCTV_i18n.REPEATER_WAS_PLANTED)
    end

    -- Забираем предмет из инвентаря
    player:getInventory():Remove(item)
end

-- Контекстное меню инвентаря
local function CCTV_OnFillInventoryContextMenu(playerNum, context, items)
    for _, itemData in ipairs(items) do
        local item = itemData

        -- Если выделена группа предметов, PZ упаковывает их в таблицу
        if type(itemData) == "table" and itemData.items then
            item = itemData.items[1]
        end

        if item and item.getFullType then
            local fullType = item:getFullType()

            if fullType == "CCTV.CameraItem" then
                context:addOption(CCTV_i18n.SETUP_CAMERA, item, function()
                    placeDevice(playerNum, item, true)
                end)
            elseif fullType == "CCTV.RepeaterItem" then
                context:addOption(CCTV_i18n.SETUP_REPEATER, item, function()
                    placeDevice(playerNum, item, false)
                end)
            end
        end
    end
end

if Events and Events.OnFillInventoryObjectContextMenu then
    Events.OnFillInventoryObjectContextMenu.Add(CCTV_OnFillInventoryContextMenu)
end
