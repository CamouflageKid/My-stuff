peripheral.find("modem",rednet.open)

while true do
    local c = turtle.craft()
    if c then
        rednet.broadcast("", "crafted")
    end
end