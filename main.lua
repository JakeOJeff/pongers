function love.load()
    wW, wH = love.graphics.getDimensions()
    STATE = "AI"
    AI = require("ai")
    GUI = require("gui")
    GAME_START = false
    PADDLE_IMG = love.graphics.newImage("paddle.png")
    PADDLE2_IMG = love.graphics.newImage("paddle2.png")
    BALL_IMG = love.graphics.newImage("ball.png")
    DEPTH = -15
    FONT = love.graphics.newFont("vcr.ttf", 30)
    bgShader = love.graphics.newShader("background.glsl")

    TBLOCKS = {}
    TCOUNT = 20
    TSIZE = wH/TCOUNT
    TRANSIT = false

    for i = 1, TCOUNT do
        table.insert({
            x = 0,
            y = (i - 1) * TSIZE,
            w = 0,
            h = TSIZE
        })
    end

    BALL = {
        x = wW / 2,
        y = wH / 2,
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
            colorDark = { 0.1843137254901961, 0.5294117647058824, 0.20784313725490197 },
            scorePos = { wW / 2 - FONT:getWidth("10") - 20, 30 },
            speed = 200 -- Second Wise
        },
        {
            posKey = "down",
            negKey = "up",
            score = 0,
            x = wW - 40,
            y = 10,
            w = 30,
            h = 100,
            ranges = {
                { wW - 10, 10 },
                { wW - 10, wH - 10 }
            },
            img = PADDLE2_IMG,
            color = { 0.9215686274509803, 0.5607843137254902, 0.2823529411764706 },
            colorDark = { 0.7803921568627451, 0.3215686274509804, 0.2235294117647059 },
            scorePos = { wW / 2 + FONT:getWidth("10"), 30 },
            speed = 200 -- Second Wise
        }
        -- AI GUIDE
        ,
        {
            posKey = "down",
            negKey = "up",
            guide = true,
            score = 0,
            x = wW - 40,
            y = 10,
            w = 30,
            h = 100,
            ranges = {
                { wW - 10, 10 },
                { wW - 10, wH - 10 }
            },
            img = PADDLE2_IMG,
            color = { 0.9215686274509803, 0.5607843137254902, 0.2823529411764706  },
            colorDark = { 0.7803921568627451, 0.3215686274509804, 0.2235294117647059 },
            scorePos = { wW / 2 + FONT:getWidth("10"), 30 },
            speed = 200 -- Second Wise
        }
    }
    PADDLE_EFFECT = {
        enabled = false,
        scale = 1,
        maxScale = 2,
        hitPaddle = nil
    }
    LAST_PADDLE = nil
    love.graphics.setDefaultFilter("nearest", "nearest")
end

function resetState()
    BALL = {
        x = wW / 2,
        y = wH / 2,
        rad = 20,
        moving = false,
        angle = math.rad(-90),
        speed = 300,
        trail = {}

    }
    for i, v in ipairs(PADDLES) do
        v.y = 10
    end
end

function screenTransition()
    for i = 1, TCOUNT do
        table.insert({
            x = 0,
            y = (i - 1) * TSIZE,
            w = 0,
            h = TSIZE
        })
    end
end

function love.update(dt)
    AI:update(dt)
    GUI:update()
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

    if STATE == "AI" then
        PADDLES[2].y = AI.targetY
    end
    if STATE == "AI GUIDE" then
        PADDLES[3].y = AI.targetY
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

function love.mousepressed(x, y, button)
    GUI:mousepressed(x, y, button)
end
function bounceBall()
    local paddleIndex = checkBallCollision()
    local outOfBounds = checkOutOfBounds()
    if i == 3 then return end
    if outOfBounds == 1 then
        PADDLES[2].score = PADDLES[2].score + 10
    elseif outOfBounds == 2 then
        PADDLES[1].score = PADDLES[1].score + 10
    end

    if outOfBounds == 1 or outOfBounds == 2 then
        screenTransition()
    end

    if paddleIndex then
        local v = PADDLES[paddleIndex]
        v.score = v.score + 1
        BALL.speed = BALL.speed * 1.1
        PADDLE_EFFECT.hitPaddle = v
        PADDLE_EFFECT.enabled = true
        PADDLE_EFFECT.scale = 1
        LAST_PADDLE = v

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
        resetState()
    elseif checkBallBorderCollision() then
        BALL.angle = math.pi - BALL.angle
    end
end

function checkBallCollision()
    for i, v in ipairs(PADDLES) do
        if i == 3 then return end
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
    bgShader:send("time", love.timer.getTime())
    bgShader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})

    love.graphics.setShader(bgShader)
    love.graphics.rectangle("fill", 0, 0, wW, wH)
    love.graphics.setShader()
    -- love.graphics.setBackgroundColor(0.45098039215686275, 0.8745098039215686, 0.9490196078431372)
    for i = 1, 2  do
        -- love.graphics.rectangle("fill", v.x, v.y, v.w, v.h, 10, 10)
        v = PADDLES[i]
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
        love.graphics.setFont(FONT)
        love.graphics.setColor(v.colorDark)
        love.graphics.print(v.score, v.scorePos[1], v.scorePos[2] + 3)
        love.graphics.setColor(v.color)
        love.graphics.print(v.score, v.scorePos[1], v.scorePos[2])
    end
    if STATE == "AI GUIDE" then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(PADDLES[3].img, PADDLES[3].x, PADDLES[3].y)
    end
            love.graphics.setColor(1, 1, 1 , 1)

    if #BALL.trail >= 4 then
        if LAST_PADDLE then
                    love.graphics.setColor(LAST_PADDLE.color)

        end
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

    love.graphics.line(wW / 2, 0, wW / 2, wH)

    GUI:draw()
end
