local suit = require 'suit'

math.randomseed(os.clock()*1000000)

function love.load()
    video = love.graphics

    fontsize = 22
    font = love.graphics.setNewFont(fontsize)

    -- love.window.setMode(800, 600, {resizable = true})
    love.graphics.setBackgroundColor(1, 1, 1)
    color_grid = {0.5, 0.5, 0.5}
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    love.window.setMode(width, height, {resizable = true})
    offset_x = width / 2
    offset_y = height / 2
    center_x = 0
    center_y = 0

    zoom = 40
    lines = 0
    scale = 0

    e = 2.718281828
    sin = math.sin
    cos = math.cos
    tan = math.tan
    asin = math.asin
    acos = math.acos

    floor = math.floor
    ceil = math.ceil
    abs = math.abs
    log = math.log
    sqrt = math.sqrt

    teste = ''
    love.graphics.setLineWidth( 1 )

    functions = {
        {button = false, text = "sin((x²)*(2*x^( -sqrt(2*x))/sin(coth(10*x))^(2*x)))", color = {255, 0, 0}},
        {button = false, text = "sin(cos(x))^(e^x)", color = {0, 255, 0}},
        {button = false, text = "x²", color = {0, 0, 255}},
        {button = false, text = "sin(x)", color = {0, 155, 155}},
        }

    new_textbox = false
end

function cosh(x)
    return (math.exp(x) + math.exp(-x)) / 2
end

function sinh(x)
    return (math.exp(x) - math.exp(-x)) / 2
end

function coth(x)
    return cosh(x) / sinh(x)
end

function love.update(dt)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    controls_wasd()
    fps = tostring(love.timer.getFPS( ))

    suit.layout:reset()

    for i = 1, #functions do
        suit.Input(functions[i], 10 , (10*i)+(i-1)*fontsize*2, 400,fontsize*2)
        functions[i].button = suit.Button('X', {id = i}, 410 ,(10*i)+(i-1)*fontsize*2, fontsize*2,fontsize*2).hit
    end

    for i = 1, #functions do
        if functions[i].button then 
            table.remove(functions, i)
            break
        end
    end


    i = #functions+1
    new_textbox = suit.Button('+', 410 , (10*i)+(i-1)*fontsize*2, fontsize*2,fontsize*2).hit

    if new_textbox then
        table.insert(functions,{button = false, text =functions[#functions].text, color = {math.random(0,255), math.random(0,255), math.random(0,255)}})
    end

end

function love.draw()
    -- love.graphics.setPointSize( 2 )
    -- love.graphics.points(width/2, height/2)
    draw_grid()
    points = 0
    functions_to_plot()
    -- love.graphics.print(fps..' '..((200*#functions)/(zoom*width)))
    lines=0

    love.graphics.setColor(rgb({0,0,0}))
    if love.mouse.isDown(1)then
        x, y = love.mouse.getPosition()
        love.graphics.print(-(offset_x-x)/zoom.." "..(offset_y-y)/zoom, x+15, y)
    end

    suit.draw()

end

function love.wheelmoved( dx, dy )

    --focus on mouse
    center_x = (-love.mouse.getX( )+offset_x)/zoom
    center_y = (-love.mouse.getY( )+offset_y)/zoom
    zoom = zoom + dy * zoom/10
    if zoom <0.001 then zoom = 0.001 end --prevent from going negative
    offset_x = love.mouse.getX( ) + center_x*zoom
    offset_y = love.mouse.getY( ) + center_y*zoom

    -- focus on center of screen
    -- center_x = (offset_x-width/2)/zoom
    -- center_y = (offset_y-height/2)/zoom
    -- zoom = zoom + dy * zoom/10
    -- if zoom <0.001 then zoom = 0.001 end --prevent from going negative
    -- offset_x = width/2+center_x*zoom
    -- offset_y = height/2+center_y*zoom

end

function love.mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) then
        offset_x = offset_x + dx
        offset_y = offset_y + dy
    end
end



function controls_wasd()

--     offset_x = offset_x + (love.keyboard.isDown("a") and 1 or 0)*10
--     offset_x = offset_x - (love.keyboard.isDown("d") and 1 or 0)*10

--     offset_y = offset_y + (love.keyboard.isDown("w") and 1 or 0)*10
--     offset_y = offset_y - (love.keyboard.isDown("s") and 1 or 0)*10

end
 
function closest_divisible(x, y)
    q = floor(x, y)
    return (q*y-y)
end

function get_closest_multiple_of_the_power(x, s)
    i = x - 1 
    while i%s ~= 0 do 
        i = i - 1 
    end 
    return i
end

function draw_grid()

    love.graphics.setColor(color_grid)
    love.graphics.setLineWidth(0.5)
    scale = (floor(50/zoom)*10)
    -- makes it so it will only be a power of ten
    scale_power_of_ten = "1"
    for i = 1, #tostring(scale)-1 do
        scale_power_of_ten = scale_power_of_ten..'0'
    end

    beginning = ceil(-offset_x/zoom)
    beginning = get_closest_multiple_of_the_power(beginning, scale_power_of_ten)

    for i = beginning, (width-offset_x)/zoom, scale_power_of_ten do
        x = i*zoom + offset_x 
        love.graphics.line(x, 0, x, height)
        love.graphics.print(i, x+zoom/10, offset_y+zoom/10)
    end

    beginning = ceil(-offset_y/zoom)
    beginning = get_closest_multiple_of_the_power(beginning, scale_power_of_ten)

    for j = beginning, (height-offset_y)/zoom, scale_power_of_ten do
        y = j*zoom + offset_y 
        love.graphics.line(0, y, width, y)
        if j ~=0 then
            love.graphics.print(-j, offset_x+zoom/10, y+zoom/10)
        end
    end

    love.graphics.setLineWidth(2)
    love.graphics.line(offset_x, 0, offset_x, height)
    love.graphics.line(0, offset_y, width, offset_y)

end

--line based
function plot_graph(expression, color_)
    love.graphics.setPointSize( 3 )
    love.graphics.setColor(rgb(color_))

    lx = nil

    loadstring('f = function(x) return '..expression..' end')()

    for x = -offset_x/zoom, (-offset_x + width)/zoom, ((1/smoothness)*250*#functions)/(zoom*width) do
        y = f(x)
 
        x = x * zoom + offset_x
        y = -y * zoom + offset_y

        if y+100>0 and y-100<height and ly+100>0 and ly-100<height and lx ~= nil and y == y then
            love.graphics.line(lx, ly,x,y)
        end
        lx = x
        ly = y
    end

end

--dot based
-- function plot_graph(f, color_)
--     love.graphics.setPointSize( 3 )
--     love.graphics.setColor(rgb(color_))

--     for x = -offset_x/zoom, (-offset_x + width)/zoom, ((1/smoothness)*100*#functions)/(zoom*width) do
--         y = f(x)

--         if y ~= y then
--             y = 0
--         end
        
--         x = x * zoom + offset_x
--         y = -y * zoom + offset_y

--         if y>0 and y<height then
--             love.graphics.points(x,y)
--         end
--     end
-- end

function functions_to_plot()
    smoothness = 1

    for i = 1, #functions do
        pcall(function()
            text_ = functions[i].text
            text_ = text_:gsub('²','^2')
            text_ = text_:gsub('³','^3')
            plot_graph(text_, functions[i].color)
        end)
    end
end

function rgb(x)
    return {x[1]/255, x[2]/255, x[3]/255}
end

function love.textinput(t)
    suit.textinput(t)
end

function love.keypressed(key)
    suit.keypressed(key)
end

function love.textedited(text, start, length)
    suit.textedited(text, start, length)
end