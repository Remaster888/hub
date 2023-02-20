getgenv().modules = modules or print("loading") or {
    version = "0.0",
    status = "loading",
    files = {},
    latest = {
        ["loader.lua"] = "0.0",
        ["modify.lua"] = "0.0",
        ["pathfinding.lua"] = "0.0",
        ["userinterface.lua"] = "0.0"
    },
    scripts = {
        "loader.lua",
        "modify.lua",
        "pathfinding.lua",
        "userinterface.lua"
    }
}

if not isfolder("remaster") then
    makefolder("remaster")
end

for _, scriptName in next, modules.scripts do
    modules.files[string.gsub(scriptName, ".lua", "")] = game:HttpGet("https://raw.githubusercontent.com/Remaster888/hub/main/" .. scriptName, true)
end

--modules.getModule = setmetatable({}, {__index = function(self, index)
function modules.getModule(self, index)
    local startIndex = index
    local value = rawget(self, index)

    if value then
        return value
    else
        index = string.gsub(index, ".lua", "") .. ".lua"
        modules.status = "loading " .. index
        print("loading " .. index)
        local file; file = readfile("remaster\\" .. index); file = file and file ~= "file does not exist" and loadstring(file)()
            
        if not file or file.version ~= modules.latest[index] then
            modules.status = not file and "downloading " .. index or "updating " .. index
            print(modules.status)
            file = modules.files[string.gsub(index, ".lua", "")]
            writefile("remaster\\" .. index, file)
            file = loadstring(file)()
        end

        modules.status = "loading"
        file = type(file) == "string" and loadstring(file)() or file
        rawset(self, startIndex, file)
        return file
    end
end

return modules
