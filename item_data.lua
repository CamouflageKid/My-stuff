if not fs.exists("data_config.lua") then
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Please enter the name for this system.")
    term.setCursorPos(1, 13)
    system_name = read()
    term.setCursorPos(1, 12)
    term.clearLine()
    term.setCursorPos(1, 1)

    local file = fs.open("data_config.lua", "w")
    file.write(system_name)
    file.close()
else
    local file = fs.open("data_config.lua", "r")
    system_name = file.readAll()
    file.close()
end
    
peripheral.find("modem", rednet.open)

function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

function Key_contains(table, element)
    for _, value in pairs(table) do
      if _ == element then
        return true
      end
    end
    return false
end


return function(context)

    local items = context:require "artist.core.items"
    local turtle_ = context:require "artist.gui.interface.turtle"
    local turtle_helpers = require "artist.lib.turtle"

    local this_turtle = turtle_helpers.get_name()


    local function craft(craft)

        redstone.setOutput("back", true)
        redstone.setOutput("front", true)
        redstone.setOutput("left", true)
        redstone.setOutput("right", true)
        redstone.setOutput("top", true)
        redstone.setOutput("bottom", true)

        local function protect_slots(hash)
            for i in pairs(hash) do
                local name = items.unhash_item(hash[i])
                local psn = {}
                for y = 1, 16 do
                    local info = turtle.getItemDetail(y)
                    if info and info.name == name then
                        psn[i] = name
                    else
                        psn[i] = false
                    end
                end
                protected_slots_new(psn)
            end
        end

        local function unprotect_slots()
            local psn = {}
            for i = 1, 16 do
                psn[i] = false
            end
            protected_slots_new(psn)
        end

        local function match_hash(element, table)
            for i in pairs(table) do
                local list_of_hash_parts = {}
                for data in string.gmatch(table[i], '([^@]+)') do
                    list_of_hash_parts[#list_of_hash_parts+1] = data
                end
                if element == list_of_hash_parts[1] then
                    if list_of_hash_parts[2] ~= nil then
                        return list_of_hash_parts[1]..list_of_hash_parts[2]
                    else
                        return list_of_hash_parts[1]
                    end
                end
            end
        end

        function table.num_of_same_element(table)
            local count = {}
            for i in pairs(table) do
                if not Key_contains(count, table[i]) then
                    count[table[i]] = 1
                else
                    count[table[i]] = count[table[i]] + 1
                end
            end
            return count
        end

        local item_counts = table.num_of_same_element(craft)
        local has_enough = false


        for i in pairs(craft) do
            local a = i

            if a >= 4 and a < 8 then
                a = i + 1
            end

            if a >= 8 and a < 12 then
                a = i + 2
            end

            local hash = match_hash(craft[i], item_hash_list)

            if Key_contains(item_hash_count_list, craft[i]) then
                if item_hash_count_list[craft[i]] >= item_counts[craft[i]] then
                    has_enough = true
                else
                    has_enough = false
                end
            end

            if hash ~= nil and has_enough then
                items.extract(items, this_turtle, hash, 1, a)
            end
        end

        if has_enough then
            protect_slots(item_hash_list)
            turtle.craft()
            unprotect_slots()
        end


        --if item_hash ~= nil then
        --    item_hash = tostring(item_hash)
        --
        --    items.extract(items, this_turtle, item_hash, 1, 1)
        --    items.extract(items, this_turtle, item_hash, 1, 2)
        --    protect_slots()
        --    turtle.craft()
        --    unprotect_slots()
        --end


    end


    local function send_out()
        while true do
            item_hash_list = {}
            item_hash_count_list = {}
            sleep(0.05)
            local data = {}
            local p = 0
            for _, inventory in pairs(items.inventories) do
                p = p + 1
                for _, slot in pairs(inventory.slots or {}) do


                    if slot.count > 0 then

                        if not table.contains(item_hash_list, slot.hash) then
                            --print(slot.hash)
                            item_hash_list[#item_hash_list+1] = tostring(slot.hash)
                            local item = items.item_cache[slot.hash]

                            local tmp_list = {}
                            for stuff in string.gmatch(items.unhash_item(tostring(items.unhash_item(tostring(slot.hash)))), '([^ ]+)') do
                                tmp_list[#tmp_list+1] = stuff
                            end

                            item_hash_count_list[tmp_list[1]] = item.count

                            tmp_list = {}
                        end
                        


                        local item = items.item_cache[slot.hash]
                        if item and item.details then
                            data[#data+1] = item --{item.details,item.count}
                        end
                    end
                end
            end

            total_storage = (p + 1) * 27

            data["total_storage"] = total_storage

            rednet.broadcast(data, system_name)

            id, data  = rednet.receive("crafting_recipe",0.5)
            if id ~= nil then
                craft(data)
                redstone.setOutput("back", false)
                redstone.setOutput("front", false)
                redstone.setOutput("left", false)
                redstone.setOutput("right", false)
                redstone.setOutput("top", false)
                redstone.setOutput("bottom", false)
            end
        end
    end

    
    
    local function queue_send_out()
        if send_out_timer then return end
        send_out_timer = os.startTimer(0.2)
    end


    context.mediator:subscribe("items.inventories_change", queue_send_out)
    context.mediator:subscribe("items.change", queue_send_out)

    context:spawn(function(id)
        send_out()
    
        while true do
          local _, id = os.pullEvent("timer")
          if id == send_out_timer then
            send_out_timer = nil
            send_out()
          end
        end
    end)

end
