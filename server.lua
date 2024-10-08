function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end


function server_init()
    
    peripheral.find("modem", rednet.close)
    peripheral.find("modem", rednet.open)

    term.clear()


    while true do


        if not fs.exists("server_data_config.lua") then
            term.setCursorPos(1, 1)
            term.write("Please enter the url you will host.")
            term.setCursorPos(1, 19)
            local data_server_connection = read()
            term.setCursorPos(1, 18)
            term.clearLine()
        
            local file = fs.open("server_data_config.lua", "w")
            file.write(data_server_connection)
            file.close()
        else
            local file = fs.open("server_data_config.lua", "r")
            data_server_connection = file.readAll()
            file.close()
        end

        term.setCursorPos(1, 18)

        url_and_name = {}

        for data_word in string.gmatch(data_server_connection, '([^/]+)') do
            url_and_name[#url_and_name+1] = data_word
        end

        local url = url_and_name[1]
        local name = url_and_name[2]


        local a = rednet.lookup(url, name)

        if a and a ~= os.getComputerID() then
            term.write("Url not available.")
        else
           rednet.host(url, name)
           print("Hosting server under: "..url.."/"..name)
           sleep(1)
           term.setCursorPos(1,18)
           term.clearLine()
           break
        end
    end
    connected_id_list = {}
    term.setCursorPos(1, 1)
end


local function connection()
    while true do
        sleep(0.05)
        id, data = rednet.receive("connection", 0.5)
        if data then
            if table.contains(connected_id_list, id) ~= true then
                connected_id_list[#connected_id_list+1] = id
                print("Computer "..id.." is now connected.")
            end
            rednet.send(id, "data", "connected")
        end
    end
end

function disconnect()
    while true do
        sleep(1)
        for i in pairs(connected_id_list) do
            rednet.send(connected_id_list[i], "data", "disconnect")
            if rednet.receive("disconnect_response", 0.5) then
            else
                print("Computer "..connected_id_list[i].." has been disconnected.")
                table.remove(connected_id_list, i)
            end
        end
    end
end



function IsOnline()
    while true do
        local id, data = rednet.receive("Is_Online")

        if table.contains(connected_id_list, id) then
            local data_num = tonumber(data)
            print("Received 'IsOnline' request from computer "..id.. " about computer "..data_num..".")
            if table.contains(connected_id_list, data_num) then
                rednet.send(id, true, "Is_Online.Return")
            else
                rednet.send(id, false, "Is_Online.Return")
            end
        end
    end
end

function null_func() end


server_function = null_func

function server_setupMain(Main)
    server_function = Main
end

function server_loop()
    parallel.waitForAll(connection, disconnect, IsOnline, server_function)
end
