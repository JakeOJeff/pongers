function love.load()
    wW, wH = love.graphics.getDimensions()
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
        }
    }
end

function love.update(dt)
    for i, v in ipairs(PADDLES) do
        if love.keyboard.isDown(v.posKey) then
            v.x = math.min(v.ranges[2][1], v.x + 10 * dt)
            v.y = math.min(v.ranges[2][2], v.y + 10 * dt)
        elseif love.keyboard.isDown(v.negKey) then
            v.x = math.max(v.ranges[1][1], v.x - 10 * dt)
            v.y = math.max(v.ranges[1][2], v.y - 10 * dt)
        end
    end
end

function love.draw()
    for i, v in ipairs(PADDLES) do
        love.graphics.rectangle("fill", v.x, v.y, v.w, v.h, 10, 10)
    end
end

