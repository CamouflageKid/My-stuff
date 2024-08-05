shell.run("wget https://raw.githubusercontent.com/CamouflageKid/My-stuff/main/craft_storage.lua")
local file = fs.open("startup.lua", "w")
if file ~= nil then
  file.write('shell.run("craft_storage.lua")')
end
os.reboot()
