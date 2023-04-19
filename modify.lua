local modify = {
    version = "0.0",
    connections = {},
    upvals = {},
    hooks = {}
}

function modify.addConnection(self, object, event)
    table.insert(self.connections, object:Connect(event))
end

function modify.hookUpValue(self, func, index, value)
    local old = debug.getupvalue(func, index)
    debug.setupvalue(func, index, value)
    table.insert(self.hooks, {func, index, old})
end

function modify.hookFunction(self, item, index, func)
    local old = item[index]
    hookfunction(item[index], func)
    --item[index] = func

    table.insert(self.hooks, {item, index, old})
end

function modify.unload()
    for _, connection in next, modify.connections do
        connection:Disconnect()
    end

    for _, hookData in next, modify.upvals do
        debug.setupvalue(hookData[1], hookData[2], hookData[3])
    end

    for _, hookData in next, modify.hooks do
        hookData[1][hookData[2] ] = hookData[3]
    end

    --for _, drawing in next, modules:getModule("userinterface").drawings do
    --    drawing.Visible = false
    --    drawing:Remove()
    --end
end

return modify
