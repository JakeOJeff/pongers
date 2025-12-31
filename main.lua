wW, wH = love.graphics.getDimensions()



function love.load()
    STATE = "AI"
    AI = require("ai")
    GUI = require("gui")
    AUDIO = require("audio")
    require("ball")
    GAME_START = false
    PADDLE_IMG = love.graphics.newImage("paddle.png")
    PADDLE2_IMG = love.graphics.newImage("paddle2.png")
    BALL_IMG = love.graphics.newImage("ball.png")
    DEPTH = 5
    HEIGHT_FACTOR = 0
    FONT = love.graphics.newFont("vcr.ttf", 30)
    FONT2 = love.graphics.newFont("vcr.ttf", 50)
    FONT3 = love.graphics.newFont("vcr.ttf", 120)

    hoverPlay = 1
    hoverScalePlay = 0

    bgShader = love.graphics.newShader("background.glsl")

    TBLOCKS = {}
    TCOUNT = 100
    TSIZE = wH / TCOUNT
    TRANSIT = false
    TIMER = 0

    MBLOCKS = {}
    MCOUNT = 100
    MSIZE = wW / MCOUNT
    MTIMER = 0
    MTRANSIT = false

    MFADE = "MENU"
    MALPHA = 1
    for i = 1, TCOUNT do
        table.insert(TBLOCKS, {
            x = 0,
            y = (i - 1) * TSIZE,
            w = 0,
            h = TSIZE
        })
    end
    for i = 1, MCOUNT do
        table.insert(MBLOCKS, {
            x = (i - 1) * MSIZE,
            y = 0,
            w = MSIZE,
            h = wH
        })
    end

    BALL = {
        x = wW / 2,
        y = wH / 2,
        rad = 20,
        moving = false,
        angle = math.rad(-90),
        speed = 300,
        trail = {},
        timer = 0

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
            speed = 300 -- Second Wise
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
            speed = 300 -- Second Wise
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
            color = { 0.9215686274509803, 0.5607843137254902, 0.2823529411764706 },
            colorDark = { 0.7803921568627451, 0.3215686274509804, 0.2235294117647059 },
            scorePos = { wW / 2 + FONT:getWidth("10"), 30 },
            speed = 300 -- Second Wise
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
        trail = {},
        timer = 0

    }
    for i, v in ipairs(PADDLES) do
        v.y = 10
    end
    TRANSIT = true
end

function resetGame()
    resetState()
    for i, v in ipairs(PADDLES) do
        v.score = 0
    end
end

function love.update(dt)
    if BALL.moving then
        BALL.timer = BALL.timer + 1 * dt
        if BALL.timer > 4 then
            resetState()
        end
    end

    if BALL.moving then
        local offset = 1 - (math.abs(BALL.x - wW / 2) / (wW / 2))
        offset = math.max(0, offset)

        HEIGHT_FACTOR = offset * 10 -- tweak this number
    end

    if MFADE == "FADEOUT" then
        MALPHA = math.max(0, MALPHA - 1 * dt)
        if MALPHA <= 0 then
            MFADE = "TRANSITION"
        end
    elseif MFADE == "TRANSITION" then
        MTRANSIT = true
    end

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

    if TRANSIT then
        TIMER = TIMER + dt

        if TIMER < 2 then
            local t = TIMER / 2
            for i = 1, TCOUNT do
                TBLOCKS[i].w = math.sin(t * math.pi + i * 0.001) * wW
            end
        else
            TIMER = 0
            TRANSIT = false
            for i = 1, TCOUNT do
                TBLOCKS[i].w = 0
            end
        end
    end

    if MTRANSIT then
        MTIMER = MTIMER + 1 * dt
        for i = 1, #MBLOCKS do
            if i <= MTIMER * 100 then
                MBLOCKS[i].h = MBLOCKS[i].h - 1200 * dt
            end
        end
        if MBLOCKS[#MBLOCKS].h <= 0 then
            MTRANSIT = false
            MFADE = "GAME"
        end
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

    local mx, my = love.mouse.getPosition()
    local playX = wW / 2 - FONT2:getWidth("PLAY") / 2
    local playY = wH / 2 - FONT2:getHeight() / 2 + 40
    if mx > playX and mx < playX + FONT2:getWidth("PLAY") and my > playY and my < playY + FONT2:getHeight() then
        hoverPlay = 0
        hoverScalePlay = math.min(1, hoverScalePlay + 2 * dt)
    else
        hoverPlay = 1
        hoverScalePlay = math.max(0, hoverScalePlay - 2 * dt)
    end
end

function love.mousepressed(x, y, button)
    GUI:mousepressed(x, y, button)
    local playX = wW / 2 - FONT2:getWidth("PLAY") / 2
    local playY = wH / 2 - FONT2:getHeight() / 2 + 40
    if x > playX and x < playX + FONT2:getWidth("PLAY") and y > playY and y < playY + FONT2:getHeight() then
        MFADE = "FADEOUT"
    end
end

function love.keypressed(key)
    if key == "e" then
        BALL.moving = not BALL.moving
    elseif key == "r" then
        resetGame()
    elseif key == "escape" then
        -- MTRANSIT = true
        -- MTIMER = 0

        -- for i = 1, MCOUNT do
        --     MBLOCKS[i].h = wH -- FULL BLACK
        -- end
    end
end

function love.draw()
    bgShader:send("time", love.timer.getTime())
    bgShader:send("resolution", { love.graphics.getWidth(), love.graphics.getHeight() })

    love.graphics.setShader(bgShader)
    love.graphics.rectangle("fill", 0, 0, wW, wH)
    love.graphics.setShader()
    -- love.graphics.setBackgroundColor(0.45098039215686275, 0.8745098039215686, 0.9490196078431372)

    if TRANSIT then
        for i = 1, TCOUNT do
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", TBLOCKS[i].x, TBLOCKS[i].y, TBLOCKS[i].w, TBLOCKS[i].h)
        end
    else
        for i = 1, 2 do
            -- love.graphics.rectangle("fill", v.x, v.y, v.w, v.h, 10, 10)
            v = PADDLES[i]
            love.graphics.setColor(0, 0, 0, 0.1)
            love.graphics.draw(v.img, v.x + DEPTH, v.y + DEPTH)
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
        love.graphics.setColor(1, 1, 1, 1)

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
        love.graphics.draw(BALL_IMG, BALL.x + DEPTH + HEIGHT_FACTOR, BALL.y + DEPTH + HEIGHT_FACTOR)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(BALL_IMG, BALL.x, BALL.y)
        love.graphics.pop()

        -- love.graphics.line(wW / 2, 0, wW / 2, wH)

        GUI:draw()
    end



    for i = 1, MCOUNT do
        if i % 2 == 1 then
            love.graphics.setColor(0.451, 0.875, 0.949)
        else
            love.graphics.setColor(0.351, 0.775, 0.849)
        end
        love.graphics.rectangle(
            "fill",
            MBLOCKS[i].x,
            MBLOCKS[i].y,
            MBLOCKS[i].w,
            MBLOCKS[i].h
        )
    end

    if MFADE == "MENU" or MFADE == "FADEOUT" then
        love.graphics.setColor(1, 1, 1, MALPHA)


        love.graphics.push()
        love.graphics.translate(50 + 10 * hoverScalePlay, wH - 200 - 20 * hoverScalePlay)
        love.graphics.scale(2.5, 2.5)
        love.graphics.rotate(math.rad(30))
        love.graphics.draw(PADDLE_IMG, 0, 0)
        love.graphics.pop()

        love.graphics.push()
        love.graphics.translate(wW - 110 - 10 * hoverScalePlay, wH - 160 - 20 * hoverScalePlay)
        love.graphics.scale(2.5, 2.5)
        love.graphics.rotate(math.rad(-30))
        love.graphics.draw(PADDLE2_IMG, 0, 0)
        love.graphics.pop()

        love.graphics.setFont(FONT3)
        love.graphics.setColor(0, 0, 0, MALPHA)
        love.graphics.print("PONGERS", wW / 2 - FONT3:getWidth("PONGERS") / 2, 102 + 2 * hoverScalePlay)
        love.graphics.setColor(1, 1, 1, MALPHA)

        love.graphics.print("PONGERS", wW / 2 - FONT3:getWidth("PONGERS") / 2, 100)
        love.graphics.setFont(FONT2)
        love.graphics.rectangle("fill", wW / 2 - FONT2:getWidth("PLAY") / 2,
            wH / 2 - FONT2:getHeight() / 2 + 40 + FONT2:getHeight(), FONT2:getWidth("PLAY"),
            FONT2:getHeight() * -hoverScalePlay)
        love.graphics.setColor(1 - hoverScalePlay, 1, 1 - hoverScalePlay, MALPHA)
        love.graphics.print("PLAY", wW / 2 - FONT2:getWidth("PLAY") / 2, wH / 2 - FONT2:getHeight() / 2 + 40)
    end
end
