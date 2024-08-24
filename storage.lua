function table.contains_name(table, element)
    for _, value in pairs(table) do
      if value.name == element then
        return true
      end
    end
    return false
end


--prepare a list for the inventories that can't be used.
local non_inv_inventories = {}


--get every peripherals.
local perilist = peripheral.getNames()

--setup two tables.
local inventories = {}
local named_inventories = {}

--go through peripherals to get those that are of the type 'inventory'.
for index, value in ipairs(perilist) do
    if peripheral.hasType(value, "inventory")then
        inventories[#inventories+1] = perilist[index]
    elseif peripheral.hasType(value, "turtle")then
        inventories[#inventories+1] = perilist[index]
    end
end

--go through the inventories to get their 'name'.
for index, value in ipairs(inventories) do
    named_inventories[#named_inventories+1] = value
end

--a function to get the count of every items, does not include details.
function Get_items_num(not_in_inv)
    not_in_inv = not_in_inv or nil

    local data = {}
    for index, value in ipairs(inventories) do
        if  value ~= not_in_inv then
            local inv = peripheral.wrap(inventories[index])

            if not peripheral.hasType(inv, "turtle") then
                local name_inv = value
                for slot, item in pairs(inv.list()) do
                    data[#data+1] = item
                end
            end
        end
    end

    local data2 = {}
    for i, value in pairs(data) do
        if not table.contains_name(data2, value.name) then
            data2[#data2+1] = value
        else
            for _, val in pairs(data2) do
                if val.name == value.name then
                    val.count = val.count + value.count
                end
            end
        end
    end

    return data2
end


--for key, value in pairs(Get_items_num()) do
--    print(value.count.." "..value.name)
--end


local function push_global(toName, item_name, limit, toslot)
    toslot = toslot or nil
    limit = limit or 64

    for index, value in ipairs(inventories) do
        if  value ~= toName then
            local inv = peripheral.wrap(inventories[index])
            local name_inv = value
            for slot, item in pairs(inv.list()) do
                if item.name == item_name then
                    if item.count >= limit then
                        if toslot ~= nil then
                            inv.pushItems(toName, slot, limit, toslot)
                        else
                            inv.pushItems(toName, slot, limit)
                        end
                        return
                    elseif item.count < limit then
                        if toslot ~= nil then
                            inv.pushItems(toName, slot, item.count, toslot)
                        else
                            inv.pushItems(toName, slot, item.count)
                        end
                        limit = limit - item.count
                    end
                end
            end
        end
    end
end


function send_to(inventory, item_name, item_count, slot)
    slot = slot or nil
    local has_enough = false
    for i, val in pairs(Get_items_num(inventory)) do
        if val.name == item_name then
            if val.count >= item_count then
                has_enough = true
            end
        end
    end

    if has_enough then
        push_global(inventory, item_name, item_count, slot)
        return true
    else
        return false
    end
end


function Inv_Num(num)
    for index, name in ipairs(inventories) do
        if index == num then
            return name
        end
    end
end


--send_to(Inv_Num(4), "minecraft:diamond", 32)