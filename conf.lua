function love.conf(t)
    t.identity = nil
    --t.version = "whatever"
    t.console = true

    t.window.title = "Nixbot"
    t.window.icon = nil
    t.window.width = 128
    t.window.height = 128
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 1
    t.window.minheight = 1
    t.window.fullscreen = false
    t.window.fullscreentype = "normal"
    t.window.vsync = true
    t.window.fsaa = 0
    t.window.display = 1

    t.modules.audio = false
    t.modules.event = true
    t.modules.graphics = false
    t.modules.image = false
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.system = false
    t.modules.timer = false
    t.modules.window = true
end