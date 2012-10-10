module(..., package.seeall)

new = function (params)
	
	local thisView = {params = params, name="contMenu"}
	
	------------------
	-- Imports
	------------------
	local ui = require("ui")
	
	------------------
	-- Groups
	------------------
	
	local localGroup = display.newGroup()
	
	------------------
	-- Display Objects
	------------------
	
	local w, h = display.contentWidth, display.contentHeight
	local realw, realh = display.viewableContentWidth, display.viewableContentHeight
	
	local ratioM = (w/h)/(realw/realh)
	if ratioM>1 then ratioM = 1/ratioM end
	local ratioM2 = ratioM^2
	local scaleFactor = (0.65+ratioM2^4*0.1)^2
	
	local background = display.newImage( "assets/menu/fondoMenu"..suffix..".png" )
	background:setReferencePoint(display.TopLeftReferencePoint)
	background.xScale,background.yScale=800/background.contentWidth,571/background.contentHeight
	
	local windowGroup = display.newGroup()
	windowGroup:insert(background)
	
	--======================================
	-- TEXT
	--======================================
	local myText = display.newText("Let's get started!", 0, 0, mainFont1, 48)
	myText:setReferencePoint(display.CenterReferencePoint)
	myText.x=windowGroup.contentWidth/2
	myText.y=windowGroup.contentHeight/2-140
	myText:setTextColor(67,34,15,255)
	windowGroup:insert(myText)
	
	--======================================
	-- CONTINUE BUTTON
	--======================================
	-- ACTION
	local continueButtonAction = function ( event )
		if event.phase == "release" then
			director:closePopUp()
			params.continueAdventure()
		end
	end
	-- UI ELEMENT
	local continueButton = ui.newButton{
					default = "assets/botonVerdeB2.png",
					onEvent = continueButtonAction,
					text = "Resume",
					size = 55,
					font = mainFont1,
					--offset = correctOffset(0),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	continueButton.x=windowGroup.contentWidth/2
	continueButton.y=windowGroup.contentHeight/2+50+50
	windowGroup:insert(continueButton)
	
	--======================================
	-- RESTART BUTTON
	--======================================
	-- ACTION
	local restartButtonAction = function ( event )
		if event.phase == "release" then
			director:closePopUp()
			director:openPopUp({startAdventure = params.startAdventure,continueAdventure = params.continueAdventure, caller = thisView}, "selectDiff", nil )
		end
	end
	-- UI ELEMENT
	local restartButton = ui.newButton{
					default = "assets/botonAmarillo.png",
					onEvent = restartButtonAction,
					text = "New",
					size = 55,
					font = mainFont1,
					--offset = correctOffset(0),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	restartButton.x=windowGroup.contentWidth/2
	restartButton.y=windowGroup.contentHeight/2-50+50
	windowGroup:insert(restartButton)
	
	--======================================
	-- BACK BUTTON
	--======================================
	local resumeButtonAction = function ( event )
		if event.phase == "release" then
			director:closePopUp()
			if params.caller then
				params.caller.params.animated=false
				director:openPopUp(params.caller.params, params.caller.name, nil )
			end
		end
	end
	
	local titleLabel = ui.newButton{
					default = "assets/botonMadera.png",
					text = "Start",
					size = 72,
					font = mainFont1,
					--offset = correctOffset(-10),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	titleLabel.x=windowGroup.contentWidth/2
	titleLabel.y=35
	titleLabel.xScale,titleLabel.yScale=1.1,1.1
	windowGroup:insert(titleLabel)
	
	local closeButton = ui.newButton{
					default = "assets/xButton.png",
					onEvent = resumeButtonAction,
					id = "bt02"}
	closeButton.x,closeButton.y=windowGroup.contentWidth-40,30
	closeButton.xScale,closeButton.yScale=0.65,0.65
	windowGroup:insert(closeButton)
	
	--====================================================================--
	-- INITIALIZE
	--====================================================================--
	
	local function initVars ()
		windowGroup:setReferencePoint(display.CenterReferencePoint)
		windowGroup.x = display.contentWidth/2
		windowGroup.y = display.contentHeight/2
		windowGroup.xScale = scaleFactor*0.9
		windowGroup.yScale = scaleFactor*0.9
		localGroup:insert(windowGroup)
	end
	
	------------------
	-- Initiate variables
	------------------
	
	initVars()
	
	------------------
	-- MUST return a display.newGroup()
	------------------
	
	return localGroup
	
end