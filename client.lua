function Client_Init()

    peripheral.find("modem", rednet.open)

    term.clear()
    term.setCursorPos(1, 1)
    term.write("Please enter the url.")
    term.setCursorPos(1, 19)
    local data_server_connection = read()
    term.setCursorPos(1, 18)
    term.clearLine()
    term.setCursorPos(1, 1)

    url_and_name = {}

    for data_word in string.gmatch(data_server_connection, '([^/]+)') do
        url_and_name[#url_and_name+1] = data_word
    end

    local url = url_and_name[1]
    local name = url_and_name[2]


    id = rednet.lookup(url, name)


    sleep(0.05)
    if not id then
        print("No computer found.")
    end
end



local function Connection()
    while true do
        sleep(0.05)
        if id then
            rednet.send(id, "data", "connection")
            if not rednet.receive("connected", 0.1) then
                while true do
                    id = rednet.lookup(url, name)
                    if not id then
                        print("No computer found.")
                    end
                    rednet.send(id, "data", "connection")
                    if rednet.receive("connected", 0.1) then
                        break
                    end
                end
            end

            a, b = rednet.receive("disconnect")
            if a then
                rednet.send(a, "data", "disconnect_response")
            end
        else
            id = rednet.lookup(url, name)
            if id then
                print("Computer found.")
            end
        end
    end
end


function Client_Loop(func)
    parallel.waitForAll(Connection, func)
end