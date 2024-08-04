local history_table = {}


function Main()
    while true do
        sleep(0.05)
        if id then
            term.setCursorPos(1, 1)
            term.setCursorPos(1, 19)
            local get = read(nil, history_table)

            if history_table[#history_table] ~= get then
                history_table[#history_table+1] = get
            end

            term.setCursorPos(1, 18)
            term.clearLine()
            term.setCursorPos(1, 1)

            rednet.send(id, get, "is_in_storage")

            local c, d = rednet.receive("is_in_storage.Return", 1)

            if c then
                print("There are "..d.." "..get.." in the system.")
                term.setCursorPos(1, 15)
                term.clearLine()
                term.setCursorPos(1, 14)
                term.clearLine()
            end
        end
    end
end

if not fs.exists("client.lua") then
    shell.run("wget https://raw.githubusercontent.com/CamouflageKid/My-stuff/main/client.lua")
end


require("client")

Client_Init()
Client_Loop(Main)
