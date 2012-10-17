module(..., package.seeall)

local util = require("util")

-----------------
-- Helper function for newButton utility function below
local function newButtonHandler( self, event )

	local result = true

	local default = self[1]
	local over = self[2]
	
	if over then
		if over.tag ~= 2 then
			over=nil
		end
	end
	
	-- General "onEvent" function overrides onPress and onRelease, if present
	local onEvent = self._onEvent
	
	local onPress = self._onPress
	local onRelease = self._onRelease

	local buttonEvent = {}
	if (self._id) then
		buttonEvent.id = self._id
	end

	local phase = event.phase
	if "began" == phase then
		if over then 
			default.isVisible = false
			over.isVisible = true
		end

		if onEvent then
			buttonEvent.phase = "press"
			result = onEvent( buttonEvent )
		elseif onPress then
			result = onPress( event )
		end

		-- Subsequent touch events will target button even if they are outside the stageBounds of button
		display.getCurrentStage():setFocus( self, event.id )
		self.isFocus = true
	elseif not self.isFocus and "moved" == phase then
		local bounds = self.stageBounds
		local x,y = event.x,event.y
		local isWithinBounds = 
			bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
		if isWithinBounds then
			-- Subsequent touch events will target button even if they are outside the stageBounds of button
			display.getCurrentStage():setFocus( self, event.id )
			self.isFocus = true
		end
	elseif self.isFocus then
		local bounds = self.stageBounds
		local x,y = event.x,event.y
		local isWithinBounds = 
			bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
		if not isWithinBounds then
			-- Allow touch events to be sent normally to the objects they "hit"
			display.getCurrentStage():setFocus( self, nil )
			self.isFocus = false
		end
		
		if "moved" == phase then
			if over then
				-- The rollover image should only be visible while the finger is within button's stageBounds
				default.isVisible = not isWithinBounds
				over.isVisible = isWithinBounds
			end
			
		elseif "ended" == phase or "cancelled" == phase then 
			if over then 
				default.isVisible = true
				over.isVisible = false
			end
			
			if "ended" == phase then
				-- Only consider this a "click" if the user lifts their finger inside button's stageBounds
				if isWithinBounds then
					if onEvent then
						buttonEvent.phase = "release"
						result = onEvent( buttonEvent )
					elseif onRelease then
						result = onRelease( event )
					end
				end
			end
			
			-- Allow touch events to be sent normally to the objects they "hit"
			display.getCurrentStage():setFocus( self, nil )
			self.isFocus = false
		end
	end

	return result
end

---------------
-- Button class

function newButton( params )
	local button, default, over, size, font, textColor, offset
	
	if params.default then
		button = display.newGroup()
		default = display.newImage( params.default )
		button:insert( default, true )
	end
	
	if params.over then
		over = display.newImage( params.over )
		over.isVisible = false
		over.tag=2
		button:insert( over, true )
	end
	
	-- Public methods
	function button:setText( newText )
	
		local labelText = self.text
		if ( labelText ) then
			labelText:removeSelf()
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			labelShadow:removeSelf()
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			labelHighlight:removeSelf()
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		
		-- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.emboss ) then
			-- Make the label text look "embossed" (also adjusts effect for textColor brightness)
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			button:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			button:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
		labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		button:insert( labelText, true )
		labelText.y = labelText.y + offset
		self.text = labelText
	end
	
	function button:setFillColor( r, g, b)
		if default then
			default:setFillColor( r, g, b)
		end
		if over then
			over:setFillColor( r, g, b)
		end
	end
	
	function button:setTextColor( r, g, b, a)
		local labelText = self.text
		if labelText then
			labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		end
	end
	
	if params.text then
		button:setText( params.text )
	end
	
	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		button._onPress = params.onPress
	end
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		button._onRelease = params.onRelease
	end
	
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		button._onEvent = params.onEvent
	end
		
	-- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
	button.touch = newButtonHandler
	button:addEventListener( "touch", button )

	if params.x then
		button.x = params.x
	end
	
	if params.y then
		button.y = params.y
	end
	
	if params.id then
		button._id = params.id
	end

	return button
end

---------------
-- Simple Button
function newSimpleButton( params )
	local buttonWidth = 150
	local buttonHeight = 150
	
	local button, size, font, textColor, offset
	local default, over, defaultGroup, overGroup
	
	button = display.newGroup()
	defaultGroup = display.newGroup()
	overGroup = display.newGroup()
	
	if params.buttonSize then
		buttonWidth = params.buttonSize[1]
		buttonHeight = params.buttonSize[2]
	end
	
	default = display.newRect(0,0,buttonWidth,buttonHeight)
	over = display.newRect(0,0,buttonWidth,buttonHeight)
	
	if params.default then
		if params.default.color then
			if params.default.color[4] then
				default:setFillColor(params.default.color[1],params.default.color[2],params.default.color[3],params.default.color[4])
			else
				default:setFillColor(params.default.color[1],params.default.color[2],params.default.color[3])
			end
		end
		local strokeWidth = 0
		if params.default.strokeWidth then
			strokeWidth=params.default.strokeWidth
			default.strokeWidth=1
		end
		if params.default.strokeColor then
			if params.default.strokeColor[4] then
				default:setStrokeColor(params.default.strokeColor[1],params.default.strokeColor[2],params.default.strokeColor[3],params.default.strokeColor[4])
			else
				default:setStrokeColor(params.default.strokeColor[1],params.default.strokeColor[2],params.default.strokeColor[3])
			end
		end
		
		defaultGroup:insert(default,true)
		
		if params.default.effect then
			local defaultEffect = display.newRect(0,0,buttonWidth-strokeWidth,buttonHeight/4-strokeWidth/2)
			defaultEffect:setFillColor((params.default.color[1]+255)/2,
									   (params.default.color[2]+255)/2,
									   (params.default.color[3]+255)/2)
			defaultEffect:setReferencePoint(display.CenterReferencePoint)
			defaultEffect.x=0
			defaultEffect:setReferencePoint(display.TopLeftReferencePoint)
			defaultEffect.y=-buttonHeight/2+strokeWidth/2
			defaultGroup:insert(defaultEffect,false)
		end
	end
	button:insert(defaultGroup,true)
	
	if params.over then
		if params.over.color then
			if params.over.color[4] then
				over:setFillColor(params.over.color[1],params.over.color[2],params.over.color[3],params.over.color[4])
			else
				over:setFillColor(params.over.color[1],params.over.color[2],params.over.color[3])
			end
		end
		local strokeWidth = 0
		if params.over.strokeWidth then
			strokeWidth=params.over.strokeWidth
			over.strokeWidth=1
		end
		if params.over.strokeColor then
			if params.default.strokeColor[4] then
				over:setStrokeColor(params.over.strokeColor[1],params.over.strokeColor[2],params.over.strokeColor[3],params.over.strokeColor[4])
			else
				over:setStrokeColor(params.over.strokeColor[1],params.over.strokeColor[2],params.over.strokeColor[3])
			end
		end
		overGroup:insert(over,true)
		
		if params.over.effect then
			local overEffect = display.newRect(0,0,buttonWidth-strokeWidth,buttonHeight/4-strokeWidth/2)
			overEffect:setFillColor((params.over.color[1]+255)/2,
									(params.over.color[2]+255)/2,
									(params.over.color[3]+255)/2)
			overEffect:setReferencePoint(display.CenterReferencePoint)
			overEffect.x=0
			overEffect:setReferencePoint(display.TopLeftReferencePoint)
			overEffect.y=-buttonHeight/2+strokeWidth/2
			overGroup:insert(overEffect,false)
		end
		overGroup.isVisible = false;
		overGroup.tag=2
		button:insert(overGroup,true)
	end
	
	-- Public methods
	function button:setText( newText )
	
		local labelText = self.text
		if ( labelText ) then
			labelText:removeSelf()
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			labelShadow:removeSelf()
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			labelHighlight:removeSelf()
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		
		-- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.emboss ) then
			-- Make the label text look "embossed" (also adjusts effect for textColor brightness)
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			button:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			button:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
		labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		button:insert( labelText, true )
		labelText.y = labelText.y + offset
		self.text = labelText
	end
	
	if params.text then
		button:setText( params.text )
	end
	
	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		button._onPress = params.onPress
	end
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		button._onRelease = params.onRelease
	end
	
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		button._onEvent = params.onEvent
	end
		
	-- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
	button.touch = newButtonHandler
	button:addEventListener( "touch", button )

	if params.x then
		button.x = params.x
	end
	
	if params.y then
		button.y = params.y
	end
	
	if params.id then
		button._id = params.id
	end

	return button
end

--------------
-- Label class
function newLabel( params )
	local labelText
	local size, font, textColor, align
	local t = display.newGroup()
	
	if ( params.bounds ) then
		local bounds = params.bounds
		local left = bounds[1]
		local top = bounds[2]
		local width = bounds[3]
		local height = bounds[4]
	
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		if ( params.align ) then align = params.align else align = "center" end
		
		if ( params.text ) then
			labelText = display.newText( params.text, 0, 0, font, size )
			labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
			t:insert( labelText )
			-- TODO: handle no-initial-text case by creating a field with an empty string?
	
			if ( align == "left" ) then
				labelText.x = left + labelText.stageWidth * 0.5
			elseif ( align == "right" ) then
				labelText.x = (left + width) - labelText.stageWidth * 0.5
			else
				labelText.x = ((2 * left) + width) * 0.5
			end
		end
		
		labelText.y = top + labelText.stageHeight * 0.5

		-- Public methods
		function t:setText( newText )
			if ( newText ) then
				labelText.text = newText
				
				if ( "left" == align ) then
					labelText.x = left + labelText.stageWidth / 2
				elseif ( "right" == align ) then
					labelText.x = (left + width) - labelText.stageWidth / 2
				else
					labelText.x = ((2 * left) + width) / 2
				end
			end
		end
		
		function t:setTextColor( r, g, b, a )
			local newR = 255
			local newG = 255
			local newB = 255
			local newA = 255

			if ( r and type(r) == "number" ) then newR = r end
			if ( g and type(g) == "number" ) then newG = g end
			if ( b and type(b) == "number" ) then newB = b end
			if ( a and type(a) == "number" ) then newA = a end

			labelText:setTextColor( r, g, b, a )
		end
	end
	
	-- Return instance (as display group)
	return t
	
end

--------------
-- Component Animation
function newAnimation( params )
	if params.comps then
		local thisAnimation = {}
		
		local loopStart = nil
		local loopEnd = nil
		
		local xPosition = 0
		local yPosition = 0
		local scale = 1
		local speed = 1
		
		local actualFrame = 1
		local alive = true
		
		local loops = 0
		local loopCount = 0
		
		local prevTime = 0
		
		thisAnimation.isMoving = false
		
		thisAnimation.publicComponents = {}
		
		if params.x then
			xPosition = params.x
		end
		if params.y then
			yPosition = params.y
		end
		if params.scale then
			scale = params.scale
		end
		if params.speed then
			speed = params.speed
		end
		
		local frameCount = -1
		thisAnimation.displayObject = display.newGroup()
		for i=1, #params.comps do
			if not params.comps[i].scale then
				params.comps[i].scale = 1
			end
			if not params.comps[i].scaleCX then
				params.comps[i].scaleCX = 1
			end
			if not params.comps[i].scaleCY then
				params.comps[i].scaleCY = 1
			end
			if not params.comps[i].rotationC then
				params.comps[i].rotationC = 0
			end
			if not params.comps[i].displayObject then
				if params.comps[i].path then
					params.comps[i].displayObject = display.newImage(params.comps[i].path)
				else
					params.comps[i].displayObject = display.newRect(0,0,30,30)
					params.comps[i].displayObject:setFillColor(255,0,255,255)
				end
				params.comps[i].displayObject.xScale , params.comps[i].displayObject.yScale = scale*params.comps[i].scale*params.comps[i].scaleCX, scale*params.comps[i].scale*params.comps[i].scaleCY
			end
			if params.comps[i].scaleComponent then
				params.comps[i].displayObject.xScale , params.comps[i].displayObject.yScale = scale*params.comps[i].scale*params.comps[i].scaleCX, scale*params.comps[i].scale*params.comps[i].scaleCY
			end
			thisAnimation.displayObject:insert(params.comps[i].displayObject)
			
			thisComponentsFrameCount = -1
			if params.comps[i].x then
				thisComponentsFrameCount = #params.comps[i].x
			end
			if params.comps[i].y then
				if thisComponentsFrameCount > #params.comps[i].y or thisComponentsFrameCount == -1 then
					thisComponentsFrameCount = #params.comps[i].y
				end
			end
			if params.comps[i].rotation then
				if thisComponentsFrameCount > #params.comps[i].rotation or thisComponentsFrameCount == -1 then
					thisComponentsFrameCount = #params.comps[i].rotation
				end
			end
			if params.comps[i].xScale then
				if thisComponentsFrameCount > #params.comps[i].xScale or thisComponentsFrameCount == -1 then
					thisComponentsFrameCount = #params.comps[i].xScale
				end
			end
			if params.comps[i].yScale then
				if thisComponentsFrameCount > #params.comps[i].yScale or thisComponentsFrameCount == -1 then
					thisComponentsFrameCount = #params.comps[i].yScale
				end
			end
			if params.comps[i].alpha then
				if thisComponentsFrameCount > #params.comps[i].alpha or thisComponentsFrameCount == -1 then
					thisComponentsFrameCount = #params.comps[i].alpha
				end
			end
			if thisComponentsFrameCount == -1 then
				thisComponentsFrameCount = 0
			end
			
			if not params.comps[i].xOffset then
				params.comps[i].xOffset = 0
			end
			
			if not params.comps[i].yOffset then
				params.comps[i].yOffset = 0
			end
			
			if frameCount == -1 or frameCount>thisComponentsFrameCount then
				frameCount = thisComponentsFrameCount
			end
			
			if params.comps[i].public then
				thisAnimation.publicComponents[#thisAnimation.publicComponents+1] = params.comps[i]
			end
		end
		
		local function setFrame (frameNumber)
			local frame1 = 1 - (frameNumber - math.floor(frameNumber))
			local frame2 = (frameNumber - math.floor(frameNumber))
			
			frameNumber = math.floor(frameNumber)
			local secondFrameNumber = math.fmod((frameNumber),(frameCount))+1
			
			if loops<=0 or loopCount<loops-1 then
				if loopStart and not loopEnd then
					secondFrameNumber = math.fmod((frameNumber-loopStart),(frameCount-loopStart))+loopStart+1
				elseif loopEnd then
					if frameNumber>loopEnd then
						if loopStart then
							secondFrameNumber = math.fmod((frameNumber-loopStart),(loopEnd-loopStart))+loopStart+1
						else
							secondFrameNumber = math.fmod((frameNumber),(loopEnd))+1
						end
					end
				end
			end
			
			for i=1, #params.comps do
				
				--alpha
				if params.comps[i].alpha then
					params.comps[i].displayObject.alpha = params.comps[i].alpha[frameNumber]*frame1 + params.comps[i].alpha[secondFrameNumber]*frame2
				end
				
				--scale
				if params.comps[i].xScale then
					params.comps[i].displayObject.xScale = (params.comps[i].xScale[frameNumber]*frame1 + params.comps[i].xScale[secondFrameNumber]*frame2)*scale*params.comps[i].scale*params.comps[i].scaleCX
				end
				
				if params.comps[i].yScale then
					params.comps[i].displayObject.yScale = (params.comps[i].yScale[frameNumber]*frame1 + params.comps[i].yScale[secondFrameNumber]*frame2)*scale*params.comps[i].scale*params.comps[i].scaleCY
				end
				
				--rotation
				params.comps[i].displayObject.rotation = 0
				if params.comps[i].rotation then
					params.comps[i].displayObject.rotation = params.comps[i].rotation[frameNumber]*frame1 + params.comps[i].rotation[secondFrameNumber]*frame2
				end
				params.comps[i].displayObject.rotation = params.comps[i].displayObject.rotation + params.comps[i].rotationC
				
				--translation
				local coordsXScaleOffset = 1
				local coordsYScaleOffset = 1
				if params.comps[i].coordsXScaleOffset then
					coordsXScaleOffset = params.comps[i].coordsXScaleOffset
				end
				if params.comps[i].coordsYScaleOffset then
					coordsYScaleOffset = params.comps[i].coordsYScaleOffset
				end
				if params.comps[i].x then
					params.comps[i].displayObject.x = (params.comps[i].x[frameNumber]*frame1 + params.comps[i].x[secondFrameNumber]*frame2)*scale*params.comps[i].scaleCX*coordsXScaleOffset
					params.comps[i].displayObject.x = params.comps[i].displayObject.x + params.comps[i].xOffset*scale + xPosition
				else
					params.comps[i].displayObject.x = params.comps[i].xOffset*scale + xPosition
				end
				
				if params.comps[i].y then
					params.comps[i].displayObject.y = (params.comps[i].y[frameNumber]*frame1 + params.comps[i].y[secondFrameNumber]*frame2)*scale*params.comps[i].scaleCY*coordsYScaleOffset
					params.comps[i].displayObject.y = params.comps[i].displayObject.y + params.comps[i].yOffset*scale + yPosition
				else
					params.comps[i].displayObject.y = params.comps[i].yOffset*scale + yPosition
				end
			end
		end
		setFrame(1)
		
		thisAnimation.isAlive = function()
			return alive
		end
		
		thisAnimation.getFrameCount = function()
			return frameCount
		end
		
		thisAnimation.getActualFrame = function()
			return actualFrame
		end
		
		thisAnimation.goToFrame = function(frame)
			actualFrame = frame
			if actualFrame <= frameCount then
				setFrame(actualFrame)
			else
				actualFrame = 1
			end
		end
		
		local function animate()
			if not thisAnimation then return end
			if thisAnimation.isMoving then
				local startloop = 1
				local endloop = frameCount
				if loops<=0 or loopCount<loops-1 then
					if loopStart then
						startloop = loopStart
					end
					if loopEnd then
						endloop = loopEnd
					end
				end
				if actualFrame <= endloop then
					setFrame(actualFrame)
					
					if params.animateAction then
						params.animateAction()
					end
					
					local curTime = system.getTimer();
					local dt = curTime - prevTime;
					local fps = 1000/dt
					prevTime = curTime;
    	        	
					actualFrame = actualFrame + (speed * 60/fps)
				else
					if loops > 0 then
						loopCount = loopCount + 1
						if loopCount >= loops then
							loopCount = 0
							thisAnimation.stop()
							
							if params.onComplete then
								if type(params.onComplete) == "function" then
									params.onComplete()
								end
							end
						else
							actualFrame = startloop
						end
					else
						actualFrame = startloop
					end
				end
			else
				thisAnimation.stop()
			end
		end
		
		thisAnimation.setLoopStart = function(value)
			loopStart = value
		end
		
		thisAnimation.setLoopEnd = function(value)
			loopEnd = value
		end
		
		thisAnimation.setLoops = function(loopsCount)
			loops = loopsCount
		end
		
		thisAnimation.getTimesLooped = function()
			return loopCount
		end
		
		thisAnimation.hide = function()
			if not thisAnimation then return end
			for i=1, #params.comps do
				if params.comps[i].x then
					params.comps[i].displayObject.alpha = 0
					params.comps[i].displayObject.isVisible = false
				end
			end
		end
		
		thisAnimation.show = function()
			if not thisAnimation then return end
			for i=1, #params.comps do
				if params.comps[i].x then
					params.comps[i].displayObject.alpha = 1
					params.comps[i].displayObject.isVisible = true
				end
			end
		end
		
		thisAnimation.vanish = function(fxtime)
			if not thisAnimation then return end
			for i=1, #params.comps do
				if params.comps[i].x then
					transition.to(params.comps[i].displayObject,{alpha = 0,time=fxtime})
				end
			end
		end
		
		thisAnimation.appear = function(fxtime)
			if not thisAnimation then return end
			for i=1, #params.comps do
				if params.comps[i].displayObject then
					params.comps[i].displayObject.isVisible = true
					transition.to(params.comps[i].displayObject,{alpha = 1,time=fxtime})
				end
			end
		end
		
		thisAnimation.reset = function()
			if not thisAnimation then return end
			actualFrame = 1
		end
		
		thisAnimation.start = function()
			if not thisAnimation then return end
			if alive then
				prevTime = system.getTimer();
				Runtime:addEventListener( "enterFrame", animate )
				thisAnimation.isMoving = true
			end
		end
		
		thisAnimation.stop = function()
			if not thisAnimation then return end
			Runtime:removeEventListener( "enterFrame", animate )
			thisAnimation.isMoving = false
		end
		
		thisAnimation.kill = function()
			if not thisAnimation then return end
			alive = false
			thisAnimation.stop()
			if thisAnimation.displayObject then
				if thisAnimation.displayObject.parent then
					thisAnimation.displayObject.parent:remove(thisAnimation.displayObject)
				else
					--if thisAnimation.displayObject:removeSelf then
					--	thisAnimation.displayObject:removeSelf()
					--else
						thisAnimation.displayObject = nil
					--end
				end
			end
			thisAnimation = nil
		end
		
		thisAnimation.sayHello = function()
			print ("hello")
		end
		
		thisAnimation.setSpeed = function(newSpeed)
			speed = newSpeed
		end
		
		return thisAnimation
	end
	print("no components given")
end

--------------
-- Blinks
function blink(openEyes,closedEyes,mode)
		if (not closedEyes) or (not openEyes) then
			print("Error loading eyes")
			return
		end
		
		if not mode then
			mode = 0
		end
		
		local self = {}
		
		self.isBlinking = false
		self.OE = openEyes
		self.CE = closedEyes
		
		self.openEyes = function()
			self.OE.isVisible = true
			self.CE.isVisible = false
		end
		
		self.closeEyes = function()
			self.OE.isVisible = false
			self.CE.isVisible = true
		end
		
		local function blink()
			if (not closedEyes) or (not openEyes) then
				self.isBlinking = false
				self = nil
				return
			end
			if not self.isBlinking then
				self.stopBlinking()
				return
			end
			if math.random(20) >= 10 then
				if self.OE.isVisible then
					self.closeEyes()
					if mode == 0 then
						timer.performWithDelay(200, self.openEyes)
					end
				else
					self.openEyes()
				end
			end
			timer.performWithDelay(1000, blink)
		end
		
		self.startBlinking = function()
			if not self.isBlinking then
				timer.performWithDelay(500, blink)
				self.isBlinking = true
			end
		end
		
		self.stopBlinking = function()
			self.isBlinking = false
		end
		
		return self
	end

--------------
-- inScreen Messages

function newScreenMessages()
	local thisSMController = {}
	local displayObject = display.newGroup()
	thisSMController.displayObject = displayObject
	
	local animating = false
	local paused = false
	
	thisSMController.sendToFront = function()
		if displayObject.parent then
			displayObject:toFront()
		end
	end
	
	local function animate()
		if (not animating) or paused or (displayObject.numChildren <= 0) then
			Runtime:removeEventListener("enterFrame",animate)
		end
		
		for i=1,displayObject.numChildren do
			if i <= 0  then
				i = 1
			end
			
			local obj = displayObject[i]
			
			if obj then
				local newAlpha = 1 - (1-obj.alpha)^0.975
				
				newAlpha = (newAlpha>=1) and 0.99 or newAlpha
				newAlpha = (newAlpha<0) and 0 or newAlpha
				
				obj.alpha = newAlpha
				
				if obj.alpha < 0.01 then
					obj:removeSelf()
					i = i-1
				end
			end
		end
		
		if displayObject.numChildren <= 0 then
			animating = false
			Runtime:removeEventListener("enterFrame",animate)
		end
	end
	
	thisSMController.newMessage = function(messageText, x, y)
		local screenOriginX = display.screenOriginX
		local screenWidth = display.viewableContentWidth
		local screenOriginY = display.screenOriginY
		local screenHeight = display.viewableContentHeight
		
		x = (x<screenOriginX+15) and screenOriginX+15 or x
		x = (x>screenOriginX+screenWidth-15) and screenOriginX+screenWidth-15 or x
		
		y = (y<screenOriginY+15) and screenOriginY+15 or y
		y = (y>screenOriginY+screenHeight-15) and screenOriginY+screenHeight-15 or y
		
		local xP = (x-screenOriginX)/screenWidth - 0.5
		
		--local messageDO = display.newText( messageText, 0, 0, mainFont1, 24 )
		local messageDO = display.newEmbossedText( messageText, 0, 0, mainFont1, 24 )
		messageDO:setReferencePoint(display.CenterReferencePoint)
		messageDO.x = x - messageDO.contentWidth*xP
		messageDO.y = y - correctOffset(15)
		
		if util.startWith(messageText,"-") then
			messageDO:setTextColor(255,255,255)
			local theNotif = display.newGroup()
			local theBG = display.newImageRect("assets/xImage.png",80,73)
			theBG:setReferencePoint(display.CenterReferencePoint)
			theBG.x,theBG.y = messageDO.x,messageDO.y
			theBG.xScale,theBG.yScale = 0.75,0.75
			theNotif:insert(theBG)
			theNotif:insert(messageDO)
			
			displayObject:insert(theNotif)
		elseif util.startWith(messageText,"+") then
			messageDO:setTextColor(57,181,74)
			local theNotif = display.newGroup()
			local theBG = display.newImageRect("assets/starImage.png",75,73)
			theBG:setReferencePoint(display.CenterReferencePoint)
			theBG.x,theBG.y = messageDO.x,messageDO.y
			theBG.xScale,theBG.yScale = 0.75,0.75
			theNotif:insert(theBG)
			theNotif:insert(messageDO)
			
			displayObject:insert(theNotif)
		else
			displayObject:insert(messageDO)
		end
		
		if (not animating) and (not paused) then
			thisSMController.play()
		end
	end
	
	thisSMController.pause = function()
		if animating then
			Runtime:removeEventListener("enterFrame",animate)
		end
		animating = false
		paused = true
	end
	
	thisSMController.resume = function()
		paused = false
		if displayObject.numChildren>0 and (not animating) then
			animating = true
			Runtime:addEventListener("enterFrame",animate)
		end
	end
	
	thisSMController.play = function()
		if not paused then
			thisSMController.resume()
		end
	end
	
	thisSMController.stop = function()
		thisSMController.removeAllMessages()
	end
	
	thisSMController.removeAllMessages = function()
		for i=1,displayObject.numChildren do
			if i <= 0  then
				i = 1
			end
			
			local obj = displayObject[i]
			
			if obj then
				obj:removeSelf()
				i = i-1
			end
		end
		paused = false
		animating = false
	end
	
	thisSMController.kill = function()
		thisSMController.removeAllMessages()
		Runtime:removeEventListener("enterFrame",animate)
		
		displayObject:removeSelf()
		
		animating = nil
		paused = nil
		animate = nil
		
		thisSMController.sendToFront = nil
		thisSMController.newMessage = nil
		thisSMController.pause = nil
		thisSMController.resume = nil
		thisSMController.play = nil
		thisSMController.stop = nil
		thisSMController.removeAllMessages = nil
		thisSMController.kill = nil
		--print("killed messages")
	end
	
	return thisSMController
end
