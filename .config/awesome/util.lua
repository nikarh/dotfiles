function shallow_copy(t)
    if type(t) ~= 'table' then return t end
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

local function merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                merge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = shallow_copy(v)
            end
        else
            t1[k] = shallow_copy(v)
        end
    end
    return shallow_copy(t1)
end

return {
    merge = function(t1, t2)
        return merge(merge({}, t1), t2)
    end
}
