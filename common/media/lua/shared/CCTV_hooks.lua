CCTV_hooks = {}

function CCTV_hooks.isInstanceOf(object, className)
    if not object then return false end

    if type(object) == "userdata" then
        -- В PZ Build 42 у Java-объектов есть встроенный метод :class():getSimpleName()
        if object.class and object:class() then
            local simpleName = object:class():getSimpleName()
            if simpleName == className then return true end
        end
        return false
    end

    if type(object) == "table" then
        local mt = getmetatable(object)
        while mt do
            if mt.ClassName == className or mt.Type == className then
                return true
            end
            mt = getmetatable(mt)
        end
    end

    local mt = getmetatable(object)
    while mt do
        if mt.ClassName == className then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

return CCTV_hooks