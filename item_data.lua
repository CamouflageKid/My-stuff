term.clear()
term.setCursorPos(1, 1)
term.write("Please enter the name for this system.")
term.setCursorPos(1, 13)
system_name = read()
term.setCursorPos(1, 12)
term.clearLine()
term.setCursorPos(1, 1)

peripheral.find("modem", rednet.open)



return function(context)

    local items = context:require "artist.core.items"
    --local turtle_helper = context:require "artist."

    local function send_out()
        local data = {}
        local p = 0
        for _, inventory in pairs(items.inventories) do
            p = p + 1
            for _, slot in pairs(inventory.slots or {}) do
                if slot.count > 0 then
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

        --items.insert(items, inv_num, 1, 1)

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