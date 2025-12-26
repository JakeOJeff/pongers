
function bounceBall()
    local paddleIndex = checkBallCollision()
    local outOfBounds = checkOutOfBounds()
    if i == 3 then return end
    if outOfBounds == 1 then
        PADDLES[2].score = PADDLES[2].score + 10
    elseif outOfBounds == 2 then
        PADDLES[1].score = PADDLES[1].score + 10
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
            BALL.timer = 0
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
