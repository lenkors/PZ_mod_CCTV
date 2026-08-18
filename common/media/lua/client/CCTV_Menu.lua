require "CCTV_i18n"

local function onWatchCCTV(_, playerNum, tvX, tvY)
    local availableCams = CCTV_Manager.getAvailableCameras(tvX, tvY)
    
    if #availableCams == 0 then
        getSpecificPlayer(playerNum):Say("CCTV: " .. CCTV_i18n.OUT_OF_RANGE)
        return
    end

    if not CCTV_UI.instance then
        local width = getCore():getScreenWidth()
        local height = getCore():getScreenHeight()
        
        CCTV_UI.instance = CCTV_UI:new(0, 0, width, height, availableCams, playerNum)
        CCTV_UI.instance:initialise()
        CCTV_UI.instance:addToUIManager()
    end
end

local function CCTV_OnFillWorldObjectContextMenu(playerNum, context, worldobjects)
    for _, obj in ipairs(worldobjects) do
        if obj and obj.getObjectName and obj:getObjectName() == "Television" then
            local square = obj:getSquare()
            if square then
                context:addOption(
                    CCTV_i18n.CONNECT_TO_CCTV,
                    worldobjects,
                    onWatchCCTV,
                    playerNum,
                    square:getX(),
                    square:getY()
                )
                break
            end
        end
    end
end

if Events and Events.OnFillWorldObjectContextMenu then
    Events.OnFillWorldObjectContextMenu.Add(CCTV_OnFillWorldObjectContextMenu)
end
