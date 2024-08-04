shell.setDir("disk/")
shell.run("wget run https://raw.githubusercontent.com/SquidDev-CC/artist/HEAD/installer.lua")
shell.run("wget https://raw.githubusercontent.com/CamouflageKid/My-stuff/main/item_data.lua")
sleep(1)
shell.run("move disk/item_data.lua disk/.artist.d/src/")
fs.delete("disk/.artist.d/src/launch.lua")

shell.setDir("/.")
local file = fs.open("disk/.artist.d/src/launch.lua", "w")
file.write('local context = require "artist"()\n-- Feel free to include custom modules here:\ncontext:require "item_data"\ncontext.config:save()\ncontext:run()')
file.close()


local file2 = fs.open("startup.lua", "w")
if file2 ~= nil then
  file2.write('shell.run("disk/artist.lua")')
end
file2.close()
os.reboot()