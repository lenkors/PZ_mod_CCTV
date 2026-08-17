CCTV_Manager = CCTV_Manager or {}
CCTV_Manager.Cameras = CCTV_Manager.Cameras or {}
CCTV_Manager.Repeaters = CCTV_Manager.Repeaters or {}

CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE = 30 -- Радиус без ретранслятора

function CCTV_Manager.loadData()
    local modData = ModData.getOrCreate("CCTV_SystemData")
    modData.Cameras = modData.Cameras or {}
    modData.Repeaters = modData.Repeaters or {}
    return modData
end

function CCTV_Manager.registerCamera(id, name, x, y, z)
    local data = CCTV_Manager.loadData()
    data.Cameras[id] = { name = name, x = x, y = y, z = z }
end

function CCTV_Manager.registerRepeater(id, x, y, z)
    local data = CCTV_Manager.loadData()
    data.Repeaters[id] = { x = x, y = y, z = z }
end

function CCTV_Manager.removeDevice(id)
    local data = CCTV_Manager.loadData()
    data.Cameras[id] = nil
    data.Repeaters[id] = nil
end

-- Расчет расстояния
local function getDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Тут уже идет не больщая душка потому что хочется что бы камеры работали с телевизором
function CCTV_Manager.hasRepeaterInRange(tvX, tvY)
    local data = CCTV_Manager.loadData()
    for _, rep in pairs(data.Repeaters) do
        if getDistance(tvX, tvY, rep.x, rep.y) <= CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE then
            return true
        end
    end
    return false
end

-- Получить список камер, доступных для конкретного ТВ/ПК. TODO нужно реализовать что то вроде отдельного UI
function CCTV_Manager.getAvailableCameras(tvX, tvY)
    local available = {}
    local data = CCTV_Manager.loadData()
    local hasRepeater = CCTV_Manager.hasRepeaterInRange(tvX, tvY)

    for id, cam in pairs(data.Cameras) do
        local dist = getDistance(tvX, tvY, cam.x, cam.y)
        if dist <= CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE or hasRepeater then
            table.insert(available, {
                id = id,
                name = cam.name,
                x = cam.x, y = cam.y, z = cam.z,
                signal = math.max(0, math.floor(100 - (dist / CCTV_Manager.MAX_DEFAULT_DIRECT_RANGE * 50)))
            })
        end
    end
    return available
end