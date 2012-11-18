--[[
	
 PROPER ORIENTATION ROTATION WITH ANIMATION

 - Version: 1.3
 - Made by E. Gonenc - Pixel Envision @ 2011
 - http://www.pixelenvision.com/
 - support@pixelenvision.com

 LICENSE
 - You may freely to use this library in any work commercial or otherwise
 - If you make any enhancements or new features please send me a copy...

 HISTORY
 - 13-MAY-2011 Created
 - 15-MAY-2011 Optimization & bugfixes
 - 16-MAY-2011 Complete structure update
 - 6-JUN-2011 Fix to match iPAD's default loading image behavior

 INFORMATION
 - Designed for proper 180 degree rotations with animation for iOS orientation changes
 - Should also work for Android if/when orientation support is added
 - Sample setup below (build.settings) allows rotation of Native UI elements such as Popups
 - Screen coordinates won't be changed, so if you are using code based on it use isRotated global variable

 USAGE
 - Add content statement to build.settings so OpenGL canvas won't be rotated
 - Edit below mainOr & altOr variables to match your supported orientations
 - Add require ("rotationfix") in the main.lua, thats it!
 - For screen coordinates use isRotated global variable to check current rotation (boolean)

 QUICK DEMO WITH DIRECTOR CLASS
 - Include rotationfix.lua to director folder
 - Add require ("rotationfix") to the top of main.lua
 - Run the director demo and rotate your device ;)

	CODE SAMPLES
	To correct screen coordinates for rotated state you may use following code in your functions
	
	local onTouch = function( event )
	       if isRotated then
                event.x = display.contentWidth - event.x
                event.y = display.contentHeight - event.y
        end
        --*REST OF YOUR CODE HERE*--
 end
	Runtime:addEventListener( "touch", onTouch )
	
	CONFIG SAMPLES
	
	orientation =
 	{
		default = portrait, -- or landscapeRight
		content = portrait, -- or landscapeRight
		supported =
		{
			portrait, portraitUpsideDown -- or "landscapeLeft", "landscapeRight" 
		}
	},

--]]

-- SET YOUR ORIENTATIONS HERE
--local mainOr = "landscapeLeft"
--local altOr = "landscapeRight"
local mainOr = "landscapeRight"
local altOr = "landscapeLeft"

-- MASTER CODE
local stage = display.getCurrentStage( )
stage:setReferencePoint(display.CenterReferencePoint)	

isRotated = false
local rotatefilter --function reserve
local rotatestart --function reserve
local rotatecomplete --function reserve
local curOrientation = mainOr --inital launch always match mainOr
local rota = 0
local isrotating = false
local rd = 600

-- iPad rotates slower
if system.getInfo("model") == "iPad" then rd = 750 end

function rotatefilter( )
	if (system.orientation == mainOr or system.orientation == altOr ) then
		return system.orientation
	else
		if curOrientation then return curOrientation else return mainOr end
	end
end

function rotatestart( val, initial )
	if isrotating == false and curOrientation ~= val then
		if val == mainOr then
			rota = 180
			curOrientation = mainOr
			invertedRotation = false
		elseif val == altOr then
			rota = -180
			curOrientation = altOr
			invertedRotation = true
		end
	isrotating = true
	if initial and rd == 750 then
	transition.to( stage, { rotation=rota, time=0, delta=true, onComplete=rotatecomplete } )
	else
	transition.to( stage, { rotation=rota, time=rd, delta=true, transition=easing.inOutQuad, onComplete=rotatecomplete } )
	end
	end
end

function rotatecomplete( )
	isrotating = false
	if curOrientation == altOr then isRotated = true else isRotated = false end
	if curOrientation ~= rotatefilter() then rotatestart(rotatefilter()) end
end

--Check initial orientation and and rotate if needed
if ( system.orientation == altOr and isrotating == false) then rotatestart(altOr,true) end

local function onOrientationChange( event )	
	local type = event.type
	if ( type == mainOr or type == altOr ) then rotatestart(type) end
end

Runtime:addEventListener( "orientation", onOrientationChange )