function setupHoles(a)
    index = 1

    for y=0, a do
        x = index-1
        while x<a do
            if holeCounter > skip then 
                makeNextHole(x,y)
                saveData(holeCounter)
            end
            holeCounter = holeCounter + 1
            x = x+3
        end
        if index < 3 then
            index = index+1
        else
            index = 1
        end
    end
end

function makeNextHole(x, y)
    goToPosition(x, y, 0)
    digHole()
    returnItems()
end

function returnItems()
    goToPosition(0, 0, 0)

    turnLeft()
    turnLeft()
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end
    turnRight()
    turnRight()
end

function digHole()
    local digDeeper = true
    while digDeeper do 
        local canMoveDown = moveDownAndCheck()
        local canDigDown = turtle.digDown()

        if ((not canMoveDown) and (not canDigDown)) then
            digDeeper = false
        end
    end

    refuelAndThrowaway()
    
    goToZ(0)
end

----------------------------------------------------------------

function refuelAndThrowaway()
    for i=1,16 do
        turtle.select(i)
        local curItem = turtle.getItemDetail()
        if curItem ~= nil then 
            if has_value(throwAway, curItem["name"]) then
                turtle.drop()
            elseif curItem["name"] == "minecraft:coal" then
                turtle.refuel()
            end
        end
    end
end

function moveDownAndCheck()
    if moveDown(1) then
        checkSurrounding()
        return true
    end
    return false
end

function checkSurrounding()
    for i=1,4 do
        checkFront()
        turnLeft()
    end
end

function checkFront()
    local success, blockData = turtle.inspect()

    if success then
        if checkForOre(blockData) then 
            turtle.dig()
        end
    end
end

function checkForOre(blockData)
    
    if  has_value(oreNames, blockData["name"]) then
        return true
    end

    return false
end

function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
 
    return false
end

----------------------------------------------------------------

function goToPosition(x, y, z)
    goToZ(z)
    goToY(y)
    goToX(x)
end

function goToX(x)
    if posX > x then
        moveLeft(posX - x)
    else 
        moveRight(x - posX)
    end
end

function goToY(y)
    if posY > y then 
        moveBack(posY - y)
    else
        moveForward(y - posY)
    end
end

function goToZ(z)
    if posZ > z then
        moveUp(posZ - z)
    else
        moveDown(z - posZ)
    end
end

----------------------------------------------------------------

function turnTill(r)
    while posR ~= r do
        turnLeft()
    end
end

function turnLeft()
    if turtle.turnLeft() then
        if posR < 3 then
            posR = posR + 1
        else 
            posR = 0
        end
        return true
    else
        return false
    end
end

function turnRight()
    if turtle.turnRight() then
        if posR > 0 then
            posR = posR - 1
        else 
            posR = 3
        end
        return true
    else
        return false
    end
end

function moveForward(distance)
    if distance > 0 then 
        for i=1,distance do 
            if turtle.forward() then
                calcMovement()
            elseif turtle.dig() then
                if turtle.forward() then
                    calcMovement()
                else
                    return false
                end
            else 
                return false
            end
        end
    end
    return true
end

function moveLeft(distance)
    if distance > 0 then 
        turnLeft()
        moveForward(distance)
        turnRight()
    end
end

function moveBack(distance)
    if distance > 0 then 
        turnLeft()
        turnLeft()
        moveForward(distance)
        turnRight()
        turnRight()
    end
end

function moveRight(distance)
    if distance > 0 then 
        turnRight()
        moveForward(distance)
        turnLeft()
    end 
end

function moveDown(distance)
    if distance > 0 then 
        for i=1,distance do 
            if turtle.down() then
                posZ = posZ + 1
            elseif turtle.digDown() then
                if turtle.down() then
                    posZ = posZ + 1
                else
                    saveData()
                    return false
                end
            else 
                saveData()
                return false
            end
        end
    end
    saveData()
    return true
end

function moveUp(distance)
    if distance > 0 then 
        for i=1,distance do 
            if turtle.up() then
                posZ = posZ - 1
            elseif turtle.digUp() then
                if turtle.up() then
                    posZ = posZ - 1
                else
                    saveData()
                    return false
                end
            else 
                saveData()
                return false
            end
        end
    end
    saveData()
    return true
end

function calcMovement()
    if posR == 0 then
        posY = posY + 1
    elseif posR == 1 then
        posX = posX - 1
    elseif posR == 2 then 
        posY = posY -1
    elseif posR == 3 then
        posX = posX + 1
    end
    saveData()
end

----------------------------------------------------------------

function saveData()
    local settingFile = fs.open("/setting", "w")

    settingFile.writeLine(size)
    settingFile.writeLine(holeCounter)
    settingFile.writeLine(posX)
    settingFile.writeLine(posY)
    settingFile.writeLine(posZ)
    settingFile.writeLine(posR)

    settingFile.close()
end

----------------------------------------------------------------

function init()
    if not fs.exists("/startup") then 
        local startupFile = fs.open("/startup", "w")
    
        startupFile.writeLine("local settingFile = fs.open('/setting', 'r')")
        startupFile.writeLine("if settingFile ~= nil then")
        startupFile.writeLine("shell.run('smart')")
        startupFile.writeLine("else")
        startupFile.writeLine("shell.run('smart', '10')")
        startupFile.writeLine("end")

        startupFile.close()
    end
end

function start()
    if turtle.getFuelLevel() <= 100 then
        print("Please refuel")
    else
        print("Using size: "..size)
        turnTill(0)
        setupHoles(size)
    end
end

function readSetting()
    local file = fs.readFile("/setting", "r")
    if file ~= nil then
        size = tonumber(file.readLine())
        skip = tonumber(file.readLine())
        posX = tonumber(file.readLine())
        posY = tonumber(file.readLine())
        posZ = tonumber(file.readLine())
        posR = tonumber(file.readLine()) 
    else
        size = 10
        skip = 0
    end
    file.close()
end

function clean()
    fs.delete("/startup")
    fs.delete("/setting")
end

----------------------------------------------------------------

oreNames = {"projectred-exploration:ore","techreborn:ore","ic2:resource","forestry:resources","modularforcefieldsystem:monazit_ore","minecraft:redstone_ore","minecraft:diamond_ore","appliedenergistics2:quartz_ore","minecraft:emerald_ore","minecraft:lapis_ore","minecraft:coal_ore","minecraft:gold_ore","minecraft:iron_ore","thermalfoundation:ore","thaumcraft:ore_cinnabar"}
throwAway= {"minecraft:cobblestone", "minecraft:gravel", "minecraft:dirt"}

holeCounter = 1
skip = 0
size = 10
posX = 0 -- distance relativ to start position LEFT/RIGHT
posY = 0 -- distance relativ to start position FRONT/BACK
posZ = 0 -- distance relativ to start position UP/DOWN 
posR = 0 -- direction the turtle looks; 0 => front; 1 => left; 2 => back; 3 => right 

distanceToHome = 0 -- how many blocks turtle is away from initial location (0, 0, 0), not working now

local tArgs = { ... }
if #tArgs >= 1 then
    size = tonumber(tArgs[1])
    if size < 1 then
        size = 10
    end
end

init()

start()

clean()