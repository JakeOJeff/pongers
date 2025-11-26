function love.load()
    wW, wH = love.graphics.getDimensions()
    GAME_START = false
    BALL = {
        x = wW/2 - 5,
        y = wH/2 - 5,
        rad = 10,
        moving = false,
        angle = math.rad(-90),
        speed = 300,
        trail = {}

    }
    PADDLES = {
        {
            posKey = "s",
            negKey = "w",
            x = 10,
            y = 10,
            w = 20,
            h = 60,
            ranges = {
                {10, 10},
                {10, wH - 10}
            },
            speed = 200 -- Second Wise
        },
        {
            posKey = "down",
            negKey = "up",
            x = wW - 30,
            y = 10,
            w = 20,
            h = 60,
            ranges = {
                {wW - 10, 10},
                {wW - 10, wH - 10}
            },
            speed = 200 -- Second Wise
        }
    }


end

function love.update(dt)
    for i, v in ipairs(PADDLES) do
        if love.keyboard.isDown(v.posKey) then
            if v.ranges[1][1] ~= v.ranges[2][1] then v.x = math.min(v.ranges[2][1] - v.w, v.x + v.speed * dt) end
            if v.ranges[1][2] ~= v.ranges[2][2] then v.y = math.min(v.ranges[2][2] - v.h, v.y + v.speed * dt) end
        elseif love.keyboard.isDown(v.negKey) then
            if v.ranges[1][1] ~= v.ranges[2][1] then v.x = math.max(v.ranges[1][1], v.x - v.speed * dt) end
            if v.ranges[1][2] ~= v.ranges[2][2] then v.y = math.max(v.ranges[1][2], v.y - v.speed * dt) end
        end
    end
    if BALL.moving then
        local dx = math.sin(BALL.angle)
        local dy = math.cos(BALL.angle)

        BALL.x = BALL.x + dx * BALL.speed * dt
        BALL.y = BALL.y + dy * BALL.speed * dt
    end
    bounceBall()
end

function bounceBall()
    local paddleIndex = checkBallCollision()

    if paddleIndex then
        local v = PADDLES[paddleIndex]

        BALL.angle = -BALL.angle


        if BALL.x < v.x + v.w * 0.5 then
            BALL.x = v.x - BALL.rad - 1
        else
            BALL.x = v.x + v.w + BALL.rad + 1
        end


        local relY = (BALL.y - v.y)/v.h 
        local hitFactor = (relY - 0.5) * math.rad(60)

        BALL.angle = BALL.angle + hitFactor
    elseif checkBallBorderCollision() then
        BALL.angle = math.pi - BALL.angle
    end
end

function checkBallCollision()
    for i, v in ipairs(PADDLES) do
        local closestX = math.max(v.x, math.min(BALL.x, v.x + v.w))
        local closestY = math.max(v.y, math.min(BALL.y, v.y + v.h))

        local distX = BALL.x - closestX
        local distY = BALL.y - closestY

        local distanceSquared = distX^2 + distY^2

        if distanceSquared < BALL.rad * BALL.rad then
            return i
        end

    end
    return false
end

function checkBallBorderCollision()
    if BALL.y < BALL.rad or BALL.y > wH - BALL.rad then
        return true
    end

    return false
end

function checkOutOfBounds()
    
end

function love.keypressed(key)
    if key == "e" then
        BALL.moving = not BALL.moving
    end
end

function love.draw()
    for i, v in ipairs(PADDLES) do
        love.graphics.rectangle("fill", v.x, v.y, v.w, v.h, 10, 10)
    end
    love.graphics.circle("fill", BALL.x, BALL.y, BALL.rad)
end

