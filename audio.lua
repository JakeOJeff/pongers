local audio = {
    paddle = love.audio.newSource("sfx/hit.mp3", "static"),
    death = love.audio.newSource("sfx/death.mp3", "static"),
    bgm = love.audio.newSource("sfx/bgm.mp3", "stream")

}



return audio