peripheral.find("modem", rednet.open)

function equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function table.ncontains(table, element)
    for _, value in pairs(table) do
        if equals(element, value, false) then
            return false
        end
    end
    return true
end


function table.pos_in_list(table, element)
    local a = 1
    for _, value in pairs(table) do
        if _ == element then
            return a
        end
        a = a + 1
    end
end


data_slots = {}


term.clear()
term.setCursorPos(1, 1)
term.write("Please enter the storage system you will monitor.")
term.setCursorPos(1, 19)
local storage_monitered = read()
term.setCursorPos(1, 18)
term.clearLine()
term.setCursorPos(1, 1)


if not fs.exists("server.lua") then
    shell.run("wget https://raw.githubusercontent.com/CamouflageKid/My-stuff/main/server.lua")
end

require("server")

data_slots = {}
local id_storage = nil

function Main()
    while true do

        sleep(0.05)

        id, data = rednet.receive(storage_monitered)
        id_storage = id

        
        if data ~= nil then

            data_slots = {}
            
            local t = 0

            for i in pairs(data) do
                t = t + 1
                local table_data = {}

                if i == "total_storage" then
                    inv_num = data["total_storage"]
                    table.remove(data, t)
                else
                    for b in pairs(data[i]) do
                        table_data[#table_data+1] = data[i][b]
                    end
                end

                ab = table_data[1]
                ba = table_data[3]

                slot_data = {ab, ba}

                if table.ncontains(data_slots, slot_data) then
                    data_slots[#data_slots+1] = slot_data
                    table_data = {}
                end
            end


            for b in pairs(data_slots) do
                --for c in pairs(data_slots[b]) do
                --    print(data_slots[b][c])
               --end
                if data_slots[b][1] ~= nil then
                    --print(data_slots[b][1])
                    --print(data_slots[b][2])
                end
            end

            --print("total_storage > "..inv_num)
        end
    end
end

server_init()

function in_storage()
    while true do
        local id, data = rednet.receive("is_in_storage")
        local item_num = 0
        if id then
            for i in pairs(data_slots) do
                if data_slots[i][1] ~= nil then
                    if data_slots[i][1] == data then
                        item_num = data_slots[i][2]
                        print(data_slots[i][1])
                        print(data_slots[i][2])
                    end
                end
            end
        end
        rednet.send(id, item_num, "is_in_storage.Return")
    end
end

list_of_crafts = {}
function craft_item_receive()
    while true do
        local sent_id, sent_data = rednet.receive("craft_item")
        list_of_crafts[#list_of_crafts+1] = sent_data
        print(#list_of_crafts)
    end
end

function craft_item()
    while true do
        sleep(0.05)
        if #list_of_crafts > 0 then
            sleep(2.5)
            rednet.send(id_storage, list_of_crafts[1], "crafting_recipe")
            table.remove(list_of_crafts, 1)
        end
        print(#list_of_crafts)

        --if list_of_crafts[1] ~= nil then
        --    rednet.send(id_storage, list_of_crafts[1], "crafting_recipe")
        --    table.remove(list_of_crafts, 1)
        --end
    end
end

function serverData()
    parallel.waitForAll(in_storage, craft_item_receive, craft_item)
end


server_setupMain(serverData)

parallel.waitForAll(Main, server_loop)