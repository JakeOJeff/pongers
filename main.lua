function love.load()
    wW, wH = love.graphics.getDimensions()
    GAME_START = false
    PADDLE_IMG = love.graphics.newImage("paddle.png")
    PADDLE2_IMG = love.graphics.newImage("paddle2.png")
    BALL_IMG = love.graphics.newImage("ball.png")
    DEPTH = -15
    FONT = love.graphics.newFont("vcr.ttf", 30)
    BALL = {
        x = wW / 2 - 5,
        y = wH / 2 - 5,
        rad = 20,
        moving = false,
        angle = math.rad(-90),
        speed = 300,
        trail = {}

    }
    PADDLES = {
        {
            posKey = "s",
            negKey = "w",
            score = 0,
            x = 10,
            y = 10,
            w = 30,
            h = 100,
            ranges = {
                { 10, 10 },
                { 10, wH - 10 }
            },
            img = PADDLE_IMG,
            color = { 0.7019607843137254, 0.8901960784313725, 0.38823529411764707 },
            scorePos = { wW / 2 - FONT:getWidth() - 10, 30 },
            speed = 200 -- Second Wise
        },
        {
            posKey = "down",
            negKey = "up",
            score = 0,
            x = wW - 50,
            y = 10,
            w = 30,
            h = 100,
            ranges = {
                { wW - 10, 10 },
                { wW - 10, wH - 10 }
            },
            img = PADDLE2_IMG,
            color = { 0.9215686274509803, 0.5607843137254902, 0.2823529411764706 },
            scorePos = { wW / 2 + FONT:getWidth() + 10, 30 },
            speed = 200 -- Second Wise
        }
    }
    PADDLE_EFFECT = {
        enabled = false,
        scale = 1,
        maxScale = 2,
        hitPaddle = nil
    }

    love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.update(dt)
    if #BALL.trail > 50 then
        table.remove(BALL.trail, 1)
        table.remove(BALL.trail, 1)
    end
    if PADDLE_EFFECT.enabled and PADDLE_EFFECT.scale < PADDLE_EFFECT.maxScale then
        PADDLE_EFFECT.scale = PADDLE_EFFECT.scale + 5 * dt
    end
    if PADDLE_EFFECT.scale >= PADDLE_EFFECT.maxScale then
        PADDLE_EFFECT.enabled = false
    end

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
    table.insert(BALL.trail, BALL.x)
    table.insert(BALL.trail, BALL.y)
    bounceBall()
end

function bounceBall()
    local paddleIndex = checkBallCollision()
    local outOfBounds = checkOutOfBounds()

    if paddleIndex then
        local v = PADDLES[paddleIndex]
        v.score = v.score + 1
        PADDLE_EFFECT.hitPaddle = v
        PADDLE_EFFECT.enabled = true
        PADDLE_EFFECT.scale = 1

        BALL.angle = -BALL.angle

        -- CLAMPER
        if BALL.x < v.x + v.w * 0.5 then
            BALL.x = v.x - BALL.rad - 1
        else
            BALL.x = v.x + v.w + BALL.rad + 1
        end


        local relY = (BALL.y - v.y) / v.h
        local hitFactor = (relY - 0.5) * math.rad(60)

        BALL.angle = BALL.angle + hitFactor
    elseif outOfBounds then
        love.load()
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

        local distanceSquared = distX ^ 2 + distY ^ 2

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
    if BALL.x > wW then
        return 2
    elseif BALL.x < 0 then
        return 1
    end
end

function love.keypressed(key)
    if key == "e" then
        BALL.moving = not BALL.moving
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0.45098039215686275, 0.8745098039215686, 0.9490196078431372)
    for i, v in ipairs(PADDLES) do
        -- love.graphics.rectangle("fill", v.x, v.y, v.w, v.h, 10, 10)
        love.graphics.setColor(0, 0, 0, 0.1)
        love.graphics.draw(v.img, v.x + DEPTH, v.y)
        if PADDLE_EFFECT.enabled and PADDLE_EFFECT.hitPaddle == v then
            love.graphics.setColor(1, 1, 1, 1 - (PADDLE_EFFECT.scale / PADDLE_EFFECT.maxScale))
            local ox, oy = v.x + v.w / 2, v.y + v.h / 2
            love.graphics.push()
            love.graphics.translate(ox, oy)
            love.graphics.scale(PADDLE_EFFECT.scale, PADDLE_EFFECT.scale)
            love.graphics.draw(v.img, -v.w / 2, -v.h / 2)
            love.graphics.pop()
        end
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(v.img, v.x, v.y)
    end

    if #BALL.trail >= 4 then
        love.graphics.line(BALL.trail)
    end
    -- love.graphics.circle("fill", BALL.x, BALL.y, BALL.rad)
    love.graphics.push()
    love.graphics.translate(-BALL.rad, -BALL.rad)
    love.graphics.setColor(0, 0, 0, 0.1)
    love.graphics.draw(BALL_IMG, BALL.x + DEPTH, BALL.y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(BALL_IMG, BALL.x, BALL.y)
    love.graphics.pop()
end
