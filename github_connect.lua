if not fs.exists("clone.lua") then
    shell.run("wget https://raw.githubusercontent.com/CamouflageKid/My-stuff/main/clone.lua")
end

local repo = ...

local list = {}
for data in string.gmatch(repo, '([^/]+)') do
    list[#list+1] = data
end

local repo_name = list[#list]

while true do
    sleep(5)
    if fs.exists(repo_name) then
        shell.run("delete "..repo_name)
    end
    sleep(0.00005)
    shell.run("clone "..repo)
end

