function digMainTunnel()
    --log("digMainTunnel()")
    local digged = 0
    for i=1,length do
        if moveForward(1) then
            digged = digged + 1
            if digged == 3 then
                digSideTunnels()
                digged = 0
            end
        else 
            log("Can't move forward")
            return
        end
    end
end

function digSideTunnels()
    --log("digSideTunnels()")

    local startPoint = {}
    startPoint["x"] = posX
    startPoint["y"] = posY
    startPoint["z"] = posZ

    -- left tunnel
    turnLeft()
    digSideTunnel()

    goToPosition(startPoint["x"], startPoint["y"], startPoint["z"])
    turnTill(0)

    -- right tunnel
    turnRight()
    digSideTunnel()

    goToPosition(startPoint["x"], startPoint["y"], startPoint["z"])
    turnTill(0)

    refuelAndThrowaway()
end

function digSideTunnel()
    --log("digSideTunnel()")
    for i=0, 5 do 
        if moveForward(1) then
            checkSides()
        end
    end
end

function mineOreDeposit(x, y, z)
    --log("mineOreDeposit(x:"..x.."y:"..y.."z:"..z..")")
    while checkFront() do
        moveForward(1)
        checkSides()
    end
    goToPosition(x,y,z)
end

function checkSides()
    --log("checkSides()")
    -- save current position
    local curPos = {}
    curPos["x"] = posX
    curPos["y"] = posY
    curPos["z"] = posZ

    -- check left
    turnLeft()
    curPos["r"] = posR
    if (checkFront()) then
        mineOreDeposit(curPos["x"], curPos["y"], curPos["z"])
    end
    
    -- check right
    turnRight()
    turnRight()
    curPos["r"] = posR
    if (checkFront()) then
        mineOreDeposit(curPos["x"], curPos["y"], curPos["z"])
    end

    -- reset rotation
    turnLeft()
    curPos["r"] = posR
    if (checkUp()) then
        moveUp(1)
        
        turnLeft()
        turnLeft()
        checkFront()
        turnRight()
        turnRight()

        checkSides()

        moveDown(1)
    end

    if (checkDown()) then
        moveDown(1)

        turnLeft()
        turnLeft()
        checkFront()
        turnRight()
        turnRight()

        checkSides()

        moveUp(1)
    end
end

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

----------------------------------------------------------------

function goToPosition(x, y, z)
    --log("goToPosition(x:"..x.."y"..y.."z:"..z..")")
    goToZ(z)
    goToY(y)
    goToX(x)
end

function goToX(x)
    --log("goToX("..x..")")
    turnTill(0)
    if posX > x then
        moveLeft(posX - x)
    else 
        moveRight(x - posX)
    end
end

function goToY(y)
    --log("goToY("..y..")")
    turnTill(0)
    if posY > y then 
        moveBack(posY - y)
    else
        moveForward(y - posY)
    end
end

function goToZ(z)
    --log("goToZ("..z..")")
    turnTill(0)
    if posZ > z then
        moveUp(posZ - z)
    else
        moveDown(z - posZ)
    end
end

----------------------------------------------------------------

function checkFront()
    --log("checkFront()")
    local success, blockData = turtle.inspect()

    if success then
        return checkForOre(blockData)
    else 
        return false
    end
end

function checkUp()
    --log("checkUp()")
    local success, blockData = turtle.inspectUp()
    if success then
        return checkForOre(blockData)
    else 
        return false
    end
end

function checkDown()
    --log("checkDown()")
    local success, blockData = turtle.inspectDown()
    if success then
        return checkForOre(blockData)
    else 
        return false
    end
end

function checkForOre(blockData)
    --log("checkForOre("..blockData["name"]..")")
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

----------------------------------------------------------------

function turnTill(r)
    --log("turnTill("..r..")")
    while posR ~= r do
        turnLeft()
    end
end

function turnLeft()
    --log("turnLeft()")
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
    --log("turnRight()")
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
    --log("moveForward("..distance..")")
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
    --log("Position(x:"..posX.."y"..posY.."z:"..posZ..")")
    return true
end

function moveLeft(distance)
    --log("moveLeft("..distance..")")
    if distance > 0 then 
        turnLeft()
        moveForward(distance)
        turnRight()
    end
end

function moveBack(distance)
    --log("moveBack("..distance..")")
    if distance > 0 then 
        turnLeft()
        turnLeft()
        moveForward(distance)
        turnRight()
        turnRight()
    end
end

function moveRight(distance)
    --log("moveRight("..distance..")")
    if distance > 0 then 
        turnRight()
        moveForward(distance)
        turnLeft()
    end 
end

function moveDown(distance)
    --log("moveDown("..distance..")")
    if distance > 0 then 
        for i=1,distance do 
            if turtle.down() then
                posZ = posZ + 1
                
                
            elseif turtle.digDown() then
                if turtle.down() then
                    posZ = posZ + 1
                    
                    
                else
                    return false
                end
            else 
                return false
            end
        end
    end
    --log("Position(x:"..posX.."y"..posY.."z:"..posZ..")")
    return true
end

function moveUp(distance)
    --log("moveUp("..distance..")")
    if distance > 0 then 
        for i=1,distance do 
            if turtle.up() then
                posZ = posZ - 1
                
                
            elseif turtle.digUp() then
                if turtle.up() then
                    posZ = posZ - 1
                    
                    
                else
                    return false
                end
            else 
                return false
            end
        end
    end
    --log("Position(x:"..posX.."y"..posY.."z:"..posZ..")")
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
end

----------------------------------------------------------------

function start()
    local temp = fs.open("/log", "w")
    temp.write("")
    temp.close()
    --log("start()")
    if turtle.getFuelLevel() <= 100 then
        print("Please refuel")
    else
        print("Using length: "..length)
        digMainTunnel(length)
    end
end

function stop()
    returnItems()
end

function log(message)
    file = fs.open("/log", "a")
    file.writeLine(message)
    file.close()
end

----------------------------------------------------------------

oreNames = {"projectred-exploration:ore","techreborn:ore","ic2:resource","forestry:resources","modularforcefieldsystem:monazit_ore","minecraft:redstone_ore","minecraft:diamond_ore","appliedenergistics2:quartz_ore","minecraft:emerald_ore","minecraft:lapis_ore","minecraft:coal_ore","minecraft:gold_ore","minecraft:iron_ore","thermalfoundation:ore","thaumcraft:ore_cinnabar"}
throwAway= {"minecraft:cobblestone", "minecraft:gravel", "minecraft:dirt"}


distanceToHome = 0 -- how many blocks turtle is away from initial location (0, 0, 0), not working now
length = 10

posX = 0 -- distance relativ to start position LEFT/RIGHT
posY = 0 -- distance relativ to start position FRONT/BACK
posZ = 0 -- distance relativ to start position UP/DOWN 
posR = 0 -- direction the turtle looks; 0 => front; 1 => left; 2 => back; 3 => right 

local tArgs = { ... }
if #tArgs >= 1 then
    length = tonumber(tArgs[1])
    if length < 1 then
        length = 10
    end
end

start()

stop()