shell.run("wget run https://raw.githubusercontent.com/SquidDev-CC/artist/HEAD/installer.lua")
shell.run("wget https://raw.githubusercontent.com/CamouflageKid/My-stuff/main/item_data.lua")
shell.run("wget https://raw.githubusercontent.com/CamouflageKid/My-stuff/main/turtle.lua")
sleep(1)
shell.run("move item_data.lua .artist.d/src/")
fs.delete(".artist.d/src/launch.lua")
fs.delete(".artist.d/src/artist/gui/interface/turtle.lua")

shell.run("move turtle.lua .artist.d/src/artist/gui/interface/")

local file = fs.open(".artist.d/src/launch.lua", "w")
file.write('local context = require "artist"()\n-- Feel free to include custom modules here:\ncontext:require "item_data"\ncontext.config:save()\ncontext:run()')
file.close()


local file2 = fs.open("startup.lua", "w")
if file2 ~= nil then
  file2.write('shell.run("artist.lua")')
end
file2.close()
os.reboot()