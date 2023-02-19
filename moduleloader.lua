getgenv().modules = modules or print("loading") or {
    status = "loading",
    files = {},
    latest = {
        ["script.lua"] = "0.0",
        ["loader.lua"] = "0.0",
        ["pathfinding.lua"] = "0.0"
    },
    scripts = {
        "script.lua",
        "loader.lua",
        "pathfinding.lua"
    }
}

for _, scriptName in next, modules.scripts do
    modules.files[scriptName] = game:HttpGet("https://raw.githubusercontent.com/Remaster888/hub/main/" .. scriptName, true)
end

modules.getModule = setmetatable({}, {__index = function(self, index)
    local startIndex = index
    local value = rawget(self, index)

    if value then
        return value
    else
        index = string.gsub(index, ".lua", "") .. ".lua"
        modules.status = "loading " .. index
        print("loading " .. index)
        local file = ({pcall(readfile, index)})[2]; file = file and file ~= "file does not exist" and loadstring(file)()

        if not file or file.version ~= modules.latest[index] then
            modules.status = not file and "downloading " .. index or "updating " .. index
            print(modules.status)
            file = modules.files[index]
            writefile(index, file)
            file = loadstring(file)()
        end

        modules.status = "loading"
        rawset(self, startIndex, file)
        return file
    end
end})

return modules
