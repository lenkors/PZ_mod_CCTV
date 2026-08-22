require "ISUI/ISUIElement"
require "CCTV_i18n"

CCTV_UI = ISUIElement:derive("CCTV_UI")
CCTV_UI.FOG_REVEAL_RADIUS = 20 -- дальность раскрытия тумана войны вокруг камеры (в тайлах)

function CCTV_UI:new(x, y, width, height, cameraList, playerNum)
    local o = ISUIElement:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    self.cameraList = cameraList or {}
    self.currentCamIndex = 1
    self.playerNum = playerNum or 0
    return o
end

function CCTV_UI:initialise()
    ISUIElement.initialise(self)

    local btnW, btnH = 120, 35
    local bottomY = self.height - 70

    -- ПРЕДЫДУЩАЯ КАМЕРА
    self.prevBtn = ISButton:new(30, bottomY, btnW, btnH, CCTV_i18n.PREV_CAMERA, self, CCTV_UI.onPrevCam)
    self.prevBtn:initialise()
    self:addChild(self.prevBtn)

    -- СЛЕДУЮЩАЯ КАМЕРА
    self.nextBtn = ISButton:new(160, bottomY, btnW, btnH, CCTV_i18n.NEXT_CAMERA, self, CCTV_UI.onNextCam)
    self.nextBtn:initialise()
    self:addChild(self.nextBtn)

    -- ВЫХОД
    self.closeBtn = ISButton:new(self.width - 150, bottomY, btnW, btnH, CCTV_i18n.DISCONNECT_FROM_CCTV, self, CCTV_UI.onClose)
    self.closeBtn:initialise()
    self:addChild(self.closeBtn)

    self:switchCamera(1)
end

function CCTV_UI:switchCamera(index)
    if not self.cameraList or #self.cameraList == 0 then return end

    self.currentCamIndex = index
    local cam = self.cameraList[self.currentCamIndex]

    if cam then
        local player = getSpecificPlayer(self.playerNum or 0)
        if player then
            if not self.origX then
                self.origX = player:getX()
                self.origY = player:getY()
                self.origZ = player:getZ()
                self.origAlpha = player:getAlpha()
            end

            player:teleportTo(cam.x, cam.y, cam.z)
            self:applySpectatorState(player)

            self:revealFogAroundCamera(cam)
        end
    end
end


---@param player IsoPlayer
function CCTV_UI:applySpectatorState(player)
    player:setInvisible(true)
    player:setGhostMode(true, true)
    player:setCollidable(false)
    player:setAlpha(0.0)
    player:setTargetAlpha(0)
    player:setBlockMovement(true)
    player:setCanSeeAll(false)
end

function CCTV_UI:revealFogAroundCamera(cam)
    local playerIndex = self.playerNum or 0
    local cell = getCell()
    local radius = CCTV_UI.FOG_REVEAL_RADIUS
    for dx = -radius, radius do
        for dy = -radius, radius do
            local square = cell:getGridSquare(cam.x + dx, cam.y + dy, cam.z)
            if square then
                square:setIsSeen(playerIndex, true)
            end
        end
    end
end

function CCTV_UI:onPrevCam()
    local newIndex = self.currentCamIndex - 1
    if newIndex < 1 then newIndex = #self.cameraList end
    self:switchCamera(newIndex)
end

function CCTV_UI:onNextCam()
    local newIndex = self.currentCamIndex + 1
    if newIndex > #self.cameraList then newIndex = 1 end
    self:switchCamera(newIndex)
end

function CCTV_UI:prerender()
    local player = getSpecificPlayer(self.playerNum or 0)
    if player then
        self:applySpectatorState(player)
    end

    self:drawRect(0, 0, self.width, self.height, 0.15, 0, 0, 0)

    local activeCam = self.cameraList[self.currentCamIndex]
    if activeCam then
        local camName = activeCam.name or ("Camera " .. self.currentCamIndex)
        local signal = activeCam.signal or 100
        
        self:drawText("● REC [" .. string.upper(camName) .. "]", 40, 40, 0, 1, 0, 1, UIFont.Medium)
        self:drawText((CCTV_i18n.SIGNAL) .. ": " .. signal .. "%", 40, 65, 0, 0.8, 0, 0.8, UIFont.Small)
        self:drawText((CCTV_i18n.CAMERA) .. self.currentCamIndex .. " / " .. #self.cameraList, 40, 85, 0.7, 0.7, 0.7, 1, UIFont.Small)
        self:drawText('Nachumbas Computers .inc', 40, 80, 0, 1, 0, 1, UIFont.Large)
    else
        self:drawText(CCTV_i18n.ERROR_NOT_FOUND, 40, 40, 1, 0, 0, 1, UIFont.Medium)
    end

    local margin = 8
    local thickness = 4
    for i = 0, thickness - 1 do
        self:drawRectBorder(margin + i, margin + i, self.width - (margin + i) * 2, self.height - (margin + i) * 2, 1, 0, 1, 0)
    end
end

function CCTV_UI:clearCameraTarget()
    if self.camTarget then
        self.camTarget:removeFromWorld()
        self.camTarget:removeFromSquare()
        self.camTarget = nil
    end
end

function CCTV_UI:onClose()
    local player = getSpecificPlayer(self.playerNum or 0)
    if player then
        if self.origX then
            player:teleportTo(self.origX, self.origY, self.origZ)
        end

        player:setCollidable(true)
        player:setBlockMovement(false)
        player:setInvisible(false)
        player:setCanSeeAll(false)
        player:setGhostMode(false, true)
        player:setTargetAlpha(1)
        if self.origAlpha then
            player:setAlpha(self.origAlpha)
        else
            player:setAlpha(1.0)
        end

    end

    self:removeFromUIManager()
    CCTV_UI.instance = nil
end
