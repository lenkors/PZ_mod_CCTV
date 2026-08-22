require "consts"

local _ItemType = CCTV_Consts.ItemType

CCTV_Manager = CCTV_Manager or {}
CCTV_Manager.Cameras = CCTV_Manager.Cameras or {}
CCTV_Manager.Repeaters = CCTV_Manager.Repeaters or {}

CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE = 10 -- Радиус без ретранслятора
CCTV_Manager.MIN_CAMERA_SPACING = 5 -- Минимальная дистанция между камерами при установке (в тайлах)

-- TODO (мультиплеер): CCTV_Manager сейчас пишет напрямую в ModData без серверной
-- синхронизации/авторитета (нет transmit(), нет проверки на сервере). Мод пока
-- рассчитан только на синглплеер — до мультиплеера это нужно будет переделать.
function CCTV_Manager.loadData()
    local modData = ModData.getOrCreate("CCTV_SystemData")
    modData.Cameras = modData.Cameras or {}
    modData.Repeaters = modData.Repeaters or {}
    return modData
end

---@param type CCTV_Consts.ItemType
function CCTV_Manager.generateId(type)
    local data = CCTV_Manager.loadData()
    data.NextId = (data.NextId or 0) + 1
    local prefix = ""
    if type == _ItemType.Camera then
        prefix = "cctv_cam"
    elseif type == _ItemType.Repeater then
        prefix = "cctv_rep"
    end

    return {
        id = prefix .. "_" .. data.NextId,
        type = type
    }
end

--TODO: оптимизировать поиск камер, сейчас он может дать O(n) и может тормозить при большом количестве камер/ретрансляторов
function CCTV_Manager.registerCamera(id, name, x, y, z)
    local data = CCTV_Manager.loadData()
    data.Cameras[id] = { name = name, x = x, y = y, z = z }
end

function CCTV_Manager.registerRepeater(id, x, y, z)
    local data = CCTV_Manager.loadData()
    data.Repeaters[id] = { x = x, y = y, z = z }
end



function CCTV_Manager.removeDevice(id, type)
    local data = CCTV_Manager.loadData()
    if type == _ItemType.Camera then
        data.Cameras[id] = nil
        return true
    elseif type == _ItemType.Repeater then
        data.Repeaters[id] = nil
        return true
    end

    return false
end

-- Расчет расстояния
local function getDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Проверка на то что рядом с указанными координатами уже стоит камера
-- (используется при установке, чтобы не ставить камеры кучей в одном месте)
function CCTV_Manager.isCameraTooClose(x, y)
    local data = CCTV_Manager.loadData()
    for _, cam in pairs(data.Cameras) do
        if getDistance(x, y, cam.x, cam.y) < CCTV_Manager.MIN_CAMERA_SPACING then
            return true
        end
    end
    return false
end

local function getReachableRepeaters(tvX, tvY)
    local data = CCTV_Manager.loadData()
    local reachable = {}
    local queue = {}

    for id, rep in pairs(data.Repeaters) do
        if getDistance(tvX, tvY, rep.x, rep.y) <= CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE then
            reachable[id] = rep
            table.insert(queue, rep)
        end
    end

    local i = 1
    while i <= #queue do
        local current = queue[i]
        i = i + 1
        for id, rep in pairs(data.Repeaters) do
            if not reachable[id] and getDistance(current.x, current.y, rep.x, rep.y) <= CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE then
                reachable[id] = rep
                table.insert(queue, rep)
            end
        end
    end

    return reachable
end

-- Получить список камер, доступных для конкретного ТВ/ПК. TODO нужно реализовать что то вроде отдельного UI
function CCTV_Manager.getAvailableCameras(tvX, tvY)
    local available = {}
    local data = CCTV_Manager.loadData()
    local reachableRepeaters = getReachableRepeaters(tvX, tvY)

    for id, cam in pairs(data.Cameras) do
        local directDist = getDistance(tvX, tvY, cam.x, cam.y)
        local bestDist = nil

        if directDist <= CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE then
            bestDist = directDist
        else
            -- Ищем ближайший из доступных по цепочке ретрансляторов, дотягивающийся до камеры
            for _, rep in pairs(reachableRepeaters) do
                local repDist = getDistance(rep.x, rep.y, cam.x, cam.y)
                if repDist <= CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE and (not bestDist or repDist < bestDist) then
                    bestDist = repDist
                end
            end
        end

        if bestDist then
            table.insert(available, {
                id = id,
                name = cam.name,
                x = cam.x, y = cam.y, z = cam.z,
                signal = math.max(0, math.floor(100 - (bestDist / CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE * 50)))
            })
        end
    end
    return available
end
