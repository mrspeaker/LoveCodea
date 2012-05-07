--[[
LoveCodea is an update of LoveCodify.
See https://github.com/SiENcE/lovecodify
2012 Stephan Effelsberg

Main topics of the update:
- Make the wrapper running with Love2D 0.8.0.
  Do not use it with versions < 0.8.0, they made incompatible changes.
- Make Asteroyds run. Like the original LoveCodify, work on LoveCodea wasn't
  started to get a full featured wrapper (I'd be glad if we get there, however)
  but with a specific target in mind.

Changes:
- Love 0.8.0: all times in seconds now
- Improve mirroring (TODO need to test the MIRROR variable at some places)
- Correct touch control (Love 0.8.0 calls events before update)
- Implement tint()
- Get rid of bogus _resetColor()
- Implement sprite scaling
- Implement font size
- Implement different colors used by lines, text, ...
- Implement framed rectangles and circles
- Require vector only if present
- Load sprite packs with or without .spritepack extension
]]--

--[[
LoveCodify is a Wrapper Class to run Codify/Codea Scripts with Love2D
Copyright (c) 2010 Florian^SiENcE^schattenkind.net

Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

You can use the http://love2d.org/ runtime to code Codify Apps on MacOSX/Linux/Windows.
Beware, it's unfinished, but samples are running.

Just include the this in your Codify project:
dofile ("loveCodify.lua")
]]--

------------------------
-- loveCodify SETTINGS
------------------------
if MIRROR == nil then
	MIRROR = true
end
if LOVECODIFYHUD == nil then
	LOVECODIFYHUD = true
end

-- CODEA Dump https://gist.github.com/1375114
--------------------------------------------------
--[[ CODEA Constants, Variables and Functions ]]--
--------------------------------------------------
background = background or function() end
BEGAN = 1
CENTER = 2
class = class or function() end
color = color or function() end
CORNER = 0
CORNERS = 1
CurrentOrientation = "LANDSCAPE"
CurrentTouch = {} --[[ Touch
x:0.000000, y:0.000000
prevX:0.000000, prevY:0.000000
id:0
state:0
tapCount:0]]--
DeltaTime = 0
draw = draw or function() end
ElapsedTime = 0
ellipse = ellipse or function() end
ellipseMode = ellipseMode or function() end
ENDED = 4
fill = fill or function() end
Gravity = {} --[[ (0.000000, 0.000000, 0.000000)]]--
HEIGHT = 748
iparameter = iparameter or function() end
iwatch = iwatch or function() end
LANDSCAPE = "LANDSCAPE"
line = line or function() end
lineCapMode = lineCapMode or function() end
MOVING = 2
noFill = noFill or function() end
noise = noise or function() end
noSmooth = noSmooth or function() end
noStroke = noStroke or function() end
noTint = noTint or function() end
parameter = parameter or function() end
point = point or function() end
pointSize = pointSize or function() end
popMatrix = popMatrix or function() end
popStyle = popStyle or function() end
PORTRAIT = "PORTRAIT"
print = print or function() end
PROJECT = 2
pushMatrix = pushMatrix or function() end
pushStyle = pushStyle or function() end
RADIUS = 3
rect = rect or function() end
rectMode = rectMode or function() end
resetMatrix = resetMatrix or function() end
resetStyle = resetStyle or function() end
rotate = rotate or function() end
ROUND = 0
rsqrt = rsqrt or function() end
scale = scale or function() end
setInstructionLimit = setInstructionLimit or function() end
setup = setup or function() end
smooth = smooth or function() end
sound = sound or function() end
SOUND_BLIT = "blit"
SOUND_EXPLODE = "explode"
SOUND_HIT = "hit"
SOUND_JUMP = "jump"
SOUND_PICKUP = "pickup"
SOUND_RANDOM = "random"
SOUND_SHOOT = "shoot"
sprite = sprite or function() end
SQUARE = 1
STATIONARY = 3
stroke = stroke or function() end
strokeWidth = strokeWidth or function() end
tint = tint or function() end
translate = translate or function() end
UserAcceleration = {} --[[ (0.000000, 0.000000, 0.000000)]]--
vec2 = vec2 or function() end
vec3 = vec3 or function() end
watch = watch or function() end
WIDTH = 748
zLevel = zLevel or function() end


FULLSCREEN = 1
LANDSCAPE_ANY = 1


-------------------
-- Drawing
-------------------
spriteList = {}

iparameterList = {}
parameterList = {}
iwatchList = {}
watchList = {}

CurrentTouch = {}
CurrentTouch.x = 0
CurrentTouch.y = 0
CurrentTouch.prevX = 0
CurrentTouch.prevY = 0
CurrentTouch.deltaX = 0
CurrentTouch.deltaY = 0
CurrentTouch.id = 0
CurrentTouch.state = ENDED
CurrentTouch.tapCount = 0

Gravity = {}
Gravity.x = 0
Gravity.y = 0
Gravity.z = 0

-- Fill Modes - line | fill
fillMode="line"

rectangleMode = CORNER

-- LineCap Modes
lineCapsMode = ROUND

-- Ellipse Modes
ellipMode = CENTER

-- Class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base)
    local c = {}    -- a new class instance
    if type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
        for i,v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end

    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    c.__index = c

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj,c)
        if class_tbl.init then
            class_tbl.init(obj,...)
        else 
            -- make sure that any stuff from the base class is initialized!
            if base and base.init then
                base.init(obj, ...)
            end
        end
        
        return obj
    end

    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do 
            if m == klass then return true end
            m = m._base
        end
        return false
    end

    setmetatable(c, mt)
    return c
end


-------------------
-- Graphics
-------------------

function color(r,g,b,a)
	local color = {}
	color.r=r
	color.g=g
	color.b=b
	color.a=a
	return color
end

function background(red,green,blue,alpha)
--alpha is ignored
	if (red and green and blue) then
		love.graphics.setBackgroundColor( red, green, blue)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setBackgroundColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setBackgroundColor( red, red, red, 255)
	elseif red and (red.r and red.g and red.b) then
		love.graphics.setBackgroundColor( red.r, red.g, red.b)
	else
		love.graphics.setBackgroundColor( 0, 0, 0)
	end
end

function ellipse( x, y, width, height)
	if height == nil or width == height then
		local radius = width
		if ellipMode == CENTER then radius = width / 2 end
		--love.graphics.circle( fillMode, x, y, width/2, 50 )
		if fillMode == "fill" then
			love.graphics.setColor(unpack{_fillcolor})
			love.graphics.circle("fill", x, y, radius, 50)
		end
		-- A bug in Love 0.8.0? getLineWidth() always returns 1
		--local lw = love.graphics.getLineWidth()
		local lw = _strokewidth
        if lw > 0 then
            love.graphics.setColor(unpack{_strokecolor})
            love.graphics.circle("line", x, y, radius - lw / 2, 50)
        end
	else
        if fillMode == "fill" then
            ellipse3( 'fill', x, y, width/2, height/2)
        end
		local lw = _strokewidth
        if lw > 0 then
            ellipse2(x, y, width/2, height/2)
        end
        love.graphics.setColor(unpack{_strokecolor})
	end
end

-- Love2d does not have a ellipse function, so we have todo it by ourself
-- TODO: the ellipse is not filled right now
-- a & b are axis-radius
function ellipse2(x,y,a,b) --,stp,rot)
	local stp=50	-- Step is # of line segments (more is "better")
	local rot=0	-- Rotation in degrees
	local n,m=math,rad,al,sa,ca,sb,cb,ox,oy,x1,y1,ast
	m = math; rad = m.pi/180; ast = rad * 360/stp;
	sb = m.sin(-rot * rad); cb = m.cos(-rot * rad)
	love.graphics.setColor(unpack{_strokecolor})
	for n = 0, stp, 1 do
		ox = x1; oy = y1;
		sa = m.sin(ast*n) * b; ca = m.cos(ast*n) * a
		x1 = x + ca * cb - sa * sb
		y1 = y + ca * sb + sa * cb
		if (n > 0) then line(ox,oy,x1,y1); end
	end
end

-- Ellipse in general parametric form 
-- (See http://en.wikipedia.org/wiki/Ellipse#General_parametric_form)
-- (Hat tip to IdahoEv: https://love2d.org/forums/viewtopic.php?f=4&t=2687)
--
-- The center of the ellipse is (x,y)
-- a and b are semi-major and semi-minor axes respectively
-- phi is the angle in radians between the x-axis and the major axis

function ellipse3(mode, x, y, a, b, phi, points)
  phi = phi or 0
  points = points or 10
  if points <= 0 then points = 1 end

  local two_pi = math.pi*2
  local angle_shift = two_pi/points
  local theta = 0
  local sin_phi = math.sin(phi)
  local cos_phi = math.cos(phi)

  local coords = {}
  for i = 1, points do
    theta = theta + angle_shift
    coords[2*i-1] = x + a * math.cos(theta) * cos_phi 
                      - b * math.sin(theta) * sin_phi
    coords[2*i] = y + a * math.cos(theta) * sin_phi 
                    + b * math.sin(theta) * cos_phi
  end

  coords[2*points+1] = coords[1]
  coords[2*points+2] = coords[2]
  love.graphics.setColor(unpack{_fillcolor})
  love.graphics.polygon(mode, coords)
end

function line(x1,y1,x2,y2)
--number width
--The width of the line.
--LineStyle style ("smooth")
--The LineStyle to use.
	love.graphics.setColor(unpack{_strokecolor})
	if (x1==x2 and y1==y2) then
		love.graphics.point(x1, y1)
	else
		love.graphics.line( x1, y1, x2, y2)
	end
end

function rect(x,y,width,height)
	--love.graphics.rectangle(fillMode,x,y,width,height)
	--local c = {love.graphics.getColor()}
	if rectangleMode == CENTER then
		x = x - width / 2
		y = y - height / 2
	end
	if fillMode == "fill" then
		love.graphics.setColor(unpack{_fillcolor})
		love.graphics.rectangle("fill",x,y,width,height)
	end
	local lw = _strokewidth
    if lw > 0 then
	    love.graphics.setColor(unpack{_strokecolor})
	    love.graphics.rectangle("line",x+lw/2,y+lw/2,width-lw,height-lw)
    end
	--love.graphics.setColor(unpack{c})
end

-- Load & Register Sprite and Draw it
function sprite(filename,x,y,width,height)
	if spriteList[filename] == nil then
		local realname1 = filename:gsub("\:",".spritepack/") .. ".png"
		local realname2 = filename:gsub("\:","/") .. ".png"
		if love.filesystem.isFile(realname1) then
			spriteList[filename] = love.graphics.newImage(realname1)
		else
			spriteList[filename] = love.graphics.newImage(realname2)
		end
	end
	_sprite_draw(spriteList[filename], x or 0, y or 0, width, height )
end

-------------------
-- Transform
-------------------
function translate(dx, dy)
	love.graphics.translate( dx, dy )
end

function rotate(angle)
	love.graphics.rotate(angle / 180.0 * math.pi)
end

-- TODO: add scale(amount)
function scale(sx, sy)
	love.graphics.scale( sx, sy )
end

-------------------
-- Vector
-------------------

if love.filesystem.isFile("vector.lua") then
	require ("vector")
end

-------------------
-- Transform Management
-------------------
function pushMatrix()
	love.graphics.push()
end

function popMatrix()
	love.graphics.pop()
end

function resetMatrix()
	-- TODO
end

-------------------
-- Style Management
-------------------
function popStyle()
	-- TODO
end

function pushStyle()
	-- TODO
end

function resetStyle()
	-- TODO
end

-------------------
-- Sound
-------------------
function sound(name)
	-- TODO
end

-------------------
-- Style
-------------------
function ellipseMode(mode)
	ellipMode = mode
end

-- fills elipse & rect
_fillcolor = {}
function fill(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 255)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 255)
	elseif (red.r and red.g and red.b and red.a) then
		love.graphics.setColor( red.r, red.g, red.b, red.a)
	end
	_fillcolor = {love.graphics.getColor()}
	fillMode = "fill"
end

function lineCapMode(mode)
	lineCapsMode = mode
end

function noSmooth()
	-- TODO
end

function noFill()
	fillMode = "line"
end

function noStroke()
    _strokeWidth = 0
end

function rectMode(mode)
	rectangleMode=mode
end

function smooth()
	-- TODO
end

_strokecolor = {}
function stroke(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 255)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 255)
	elseif (red.r and red.g and red.b and red.a) then
		love.graphics.setColor( red.r, red.g, red.b, red.a)
	end
	_strokecolor = {love.graphics.getColor()}
end

_strokewidth = 0
function strokeWidth(width)
	love.graphics.setLineWidth( width )
	_strokewidth = width
end

_tint_active = false
_tintcolor = {}
function tint(red,green,blue,alpha)
	if (red and green and blue and alpha) then
		love.graphics.setColor( red, green, blue, alpha)
	elseif (red and green and blue) then
		love.graphics.setColor( red, green, blue, 255)
	elseif (type(red) == "number" and type(green) == "number") then
		love.graphics.setColor( red, red, red, green)
	elseif (type(red) == "number") then
		love.graphics.setColor( red, red, red, 255)
	elseif (red.r and red.g and red.b and red.a) then
		love.graphics.setColor( red.r, red.g, red.b, red.a)
	end
	_tint_active = true
	_tintcolor = {love.graphics.getColor()}
	--love.graphics.setColorMode("modulate")
end

function noTint()
	_tint_active = false
	--love.graphics.setColorMode("replace")
end

-------------------
-- Parameters
-------------------
function iparameter(name,mini,maxi,initial)
	if initial ~= nil then
		_G[name] = initial
		iparameterList[name] = initial
	else
		_G[name] = mini
		iparameterList[name] = mini
	end
end

function parameter(name,mini,maxi,initial)
	if initial ~= nil then
		_G[name] = initial
		parameterList[name] = initial
	else
		_G[name] = mini
		parameterList[name] = mini
	end
end

function watch(name)
	watchList[name] = 0
end

function iwatch(name)
	iwatchList[name] = 0
end

-------------------
-- Touch
-------------------
-- already done in love.update(dt)

-------------------
-- Math
-------------------
function rsqrt(value)
	return math.pow(value, -0.5);
end

-------------------
-- love functions
-------------------
function love.load()
	_saveInitialState()
	fontSize(17)
	love.graphics.setLine(1, "rough")
	noTint()
	fill(255, 255, 255, 255)
	stroke(255, 255, 255, 255)
	love.graphics.setColorMode("modulate")
	setup()
end

--[[
-- Love 0.8.0: events are processed BEFORE update()!
-- All touch processing now done in update().
function love.mousepressed(x, y, button)
	if button == "l" then
		CurrentTouch.state = BEGAN
	end
end

function love.mousereleased(x, y, button)
	if button == "l" then
		CurrentTouch.state = ENDED
	end
end
]]--

function love.keypressed(key)
	if keyboard then
		keyboard(key)
	end
end

function love.update(dt)

	-- Use sleep to cap FPS at 30
	if dt < 1/30 then
		love.timer.sleep(1/30 - dt)
	end

	-- use Mouse for Touch interaction
	local touch_changed = false
    local prevX = CurrentTouch.prevX
    local prevY = CurrentTouch.prevY
	if love.mouse.isDown("l") then
		-- get Mouse position as Touch position
		-- publish globally
		if CurrentTouch.x ~= love.mouse.getX() or CurrentTouch.y ~= love.mouse.getY() then
			touch_changed = true
		end
		if CurrentTouch.state == ENDED then
			touch_changed = true
		end
		if touch_changed then
			CurrentTouch.prevX = CurrentTouch.x
			CurrentTouch.prevY = CurrentTouch.y
			CurrentTouch.x = love.mouse.getX()
			if MIRROR then
				CurrentTouch.y = HEIGHT - 1 - love.mouse.getY()
			else
				CurrentTouch.y = love.mouse.getY()
			end
			if CurrentTouch.state == ENDED then
				CurrentTouch.state = BEGAN
				CurrentTouch.prevX = CurrentTouch.x
				CurrentTouch.prevY = CurrentTouch.y
			else
				CurrentTouch.state = MOVING
			end
		end
	else
		if CurrentTouch.state ~= ENDED then
			CurrentTouch.state = ENDED
			touch_changed = true
		end
	end

	-- has to be outside of mouse.isDown
	if touched and touch_changed then
		-- publish to touched callback
		local touch = {}
		touch.x = CurrentTouch.x
		touch.y = CurrentTouch.y
        touch.deltaX = touch.x - prevX
        touch.deltaY = touch.y - prevY
		touch.state = CurrentTouch.state
		touch.id = 1 -- TODO: What does ID this mean?
		touched(touch)
	end

	-- use Up,Down,Left,Right Keys to change Gravity
	if love.keyboard.isDown("up") then
		Gravity.y = Gravity.y + 0.01
	elseif love.keyboard.isDown("down") then
		Gravity.y = Gravity.y - 0.01
	elseif love.keyboard.isDown("left") then
		Gravity.x = Gravity.x + 0.01
	elseif love.keyboard.isDown("right") then
		Gravity.x = Gravity.x - 0.01
	elseif love.keyboard.isDown("pageup") then
		Gravity.z = Gravity.z + 0.01
	elseif love.keyboard.isDown("pagedown") then
		Gravity.z = Gravity.z - 0.01
	end

	-- set Time Values
	DeltaTime = love.timer.getDelta()
	ElapsedTime = love.timer.getTime()
end

function love.draw()
	-- Reset
	if love.keyboard.isDown("return") then
		if not _restarting then
			_restarting = true
			_reset()
		end
		return
	else
		_restarting = false
	end

	_mirrorScreenBegin()
	noTint()
	draw()
	_mirrorScreenEnd()

	if (LOVECODIFYHUD) then
		local l_fontsize = _fontsize
		fontSize(12)
		love.graphics.setColor( 125, 125, 125)
		love.graphics.print( "iparameter", 5, 14)
		local i=2
		for k,v in pairs(iparameterList) do
			iparameterList[k]=_G[k]
			love.graphics.print( k, 5, 14*i)
			love.graphics.print( tostring(v), 80, 14*i)
			i=i+1
		end

		love.graphics.print( "parameter", 5, 200+14)
		i=2
		for k,v in pairs(parameterList) do
			parameterList[k]=_G[k]
			love.graphics.print( k, 5, 200+14*i)
			love.graphics.print( tostring(v), 80, 200+14*i)
			i=i+1
		end

		love.graphics.print( "watch", 5, 400+14)
		i=2
		for k,v in pairs(watchList) do
			watchList[k]=_G[k]
			love.graphics.print( k, 5, 400+14*i)
			love.graphics.print( tostring(watchList[k]), 80, 400+14*i)
			i=i+1
		end

		love.graphics.print( "iwatch", 5, 600+14)
		i=2
		for k,v in pairs(iwatchList) do
			iwatchList[k]=_G[k]
			love.graphics.print( k, 5, 600+14*i)
			love.graphics.print( tostring(iwatchList[k]), 80, 600+14*i)
			i=i+1
		end

		-- print FPS
		love.graphics.setColor(255,0,0,255)
		love.graphics.print( "FPS: ", WIDTH-65, 14)
		love.graphics.print( love.timer.getFPS( ), WIDTH-35, 14)

		-- print Gravity
		love.graphics.print( "GravityX: ", WIDTH-92, 34)
		love.graphics.print( Gravity.x, WIDTH-35, 34)
		love.graphics.print( "GravityY: ", WIDTH-92, 54)
		love.graphics.print( Gravity.y, WIDTH-35, 54)
		love.graphics.print( "GravityZ: ", WIDTH-92, 74)
		love.graphics.print( Gravity.z, WIDTH-35, 74)

		fontSize(l_fontsize)
	end -- if (LOVECODIFYHUD)
end

-- initial before main is called
WIDTH=love.graphics.getWidth()
HEIGHT=love.graphics.getHeight()

-------------------------
-- loveCodify Internals
-------------------------

-- deepcopy http://lua-users.org/wiki/CopyTable
function _deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function _saveInitialState()
	_INIT_STATE = _deepcopy(_G)
	_INIT_STATE["_G"] = nil
end

function _restoreInitialState()
	for k, v in pairs(_INIT_STATE) do
		_G[k] = v
	end
	_saveInitialState(_G)
end

function _reset()
	_restoreInitialState()
	setup()
end

function _mirrorScreenBegin()
	if MIRROR then
		love.graphics.push()
		love.graphics.translate(0, HEIGHT - 1)
		love.graphics.scale(1, -1)
	end
end

function _mirrorScreenEnd()
	if MIRROR then
		love.graphics.pop()
	end
end

_spritemode = CENTER
function spriteMode(mode)
	_spritemode = mode
end

-- Draws a Sprite (Mirror it first)
function _sprite_draw( image, x, y, width, height )
	-- image dimensions
	local w = image:getWidth()
	local h = image:getHeight()
	-- image dimension scale factors
	local sx = 1
	local sy = 1
	if width ~= nil then
		sx = width / w
		-- scale height properly if only width is given
		if height == nil then
			sy = sx
			height = h * sy
		end
	end
	if height ~= nil then
		sy = height / h
	end
	width = width or w
	height = height or h

	if _tint_active then
		love.graphics.setColorMode("modulate")
	else
		love.graphics.setColorMode("replace")
	end
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.scale(1, -1)
	if _spritemode == CENTER then
		love.graphics.draw(image, -width / 2, -height / 2, 0, sx, sy)
	else
		-- CORNER (upper left)
		love.graphics.draw(image, 0, 0, 0, sx, sy)
	end
	love.graphics.pop()
	love.graphics.setColorMode("modulate")
end


function displayMode(mode)
end

function supportedOrientations(orient)
end

_localdata = {}

function readLocalData(name, default)
	return _localdata[name] or default
end

function saveLocalData(name, value)
	_localdata[name] = value
end

_textmode = CENTER
function text(str, x, y)
	x = x or 0
	y = y or 0
	love.graphics.push()
	local f = love.graphics.getFont()
	local w = f:getWidth(str)
	local h = f:getHeight()
	love.graphics.setColor(unpack{_fillcolor})
	love.graphics.translate(x, y)
	love.graphics.scale(1, -1)
	if _textmode == CENTER then
		love.graphics.print(str, -w / 2, -h / 2)
	else
		-- CORNER (lower left)
		love.graphics.print(str, 0, -h)
	end
	love.graphics.pop()
end

function textMode(mode)
	_textmode = mode
end

function textWrapWidth(w)
end

_fontcache = {}
_fontsize = 17
function fontSize(size)
	if _fontcache[size] == nil then
		_fontcache[size] = love.graphics.newFont(size)
	end
	love.graphics.setFont(_fontcache[size])
	_fontsize = size
end

function font(fontname)
end

function showKeyboard()
end

function hideKeyboard()
end
