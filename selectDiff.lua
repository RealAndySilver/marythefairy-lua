module(..., package.seeall)

new = function (params)
	
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
	
	local function saveDifficulty (newDiff)
		if newDiff == nil then
			return
		end
		if newDiff>3 or newDiff<1 then
			newDiff = 1
		end
		local path = system.pathForFile( "difficultyLevel", system.DocumentsDirectory )
		local fh
		
		fh = io.open( path, "w" )
		
		if fh then
			fh:write("",newDiff)
			io.close(fh)
		else
			print( "difficultylevel file creation failed" )
		end
	end
	
	--======================================
	-- TEXT
	--======================================
	local myText = display.newText("Select the level of difficulty", 0, 0, mainFont1, 48)
	myText:setReferencePoint(display.CenterReferencePoint)
	myText.x=windowGroup.contentWidth/2
	myText.y=windowGroup.contentHeight/2-140
	myText:setTextColor(67,34,15,255)
	windowGroup:insert(myText)
	
	--======================================
	-- EASY BUTTON
	--======================================
	-- ACTION
	local easyButtonAction = function ( event )
		if event.phase == "release" then
			saveDifficulty(1)
			director:closePopUp()
			if params.startFromAdventure and params.adventureToStart then
				params.startFromAdventure(params.adventureToStart)
			else
				params.startAdventure()
			end
		end
	end
	-- UI ELEMENT
	local easyButton = ui.newButton{
					default = "assets/botonAmarillo.png",
					onEvent = easyButtonAction,
					text = "Easy",
					size = 55,
					font = mainFont1,
					offset = 0,
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	easyButton.x=windowGroup.contentWidth/2
	easyButton.y=windowGroup.contentHeight/2-100+50
	windowGroup:insert(easyButton)
	
	--======================================
	-- MEDIUM BUTTON
	--======================================
	-- ACTION
	local mediumButtonAction = function ( event )
		if event.phase == "release" then
			saveDifficulty(2)
			director:closePopUp()
			if params.startFromAdventure and params.adventureToStart then
				params.startFromAdventure(params.adventureToStart)
			else
				params.startAdventure()
			end
		end
	end
	-- UI ELEMENT
	local mediumButton = ui.newButton{
					default = "assets/botonAzul.png",
					onEvent = mediumButtonAction,
					text = "Medium",
					size = 55,
					font = mainFont1,
					offset = 0,
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	mediumButton.x=windowGroup.contentWidth/2
	mediumButton.y=windowGroup.contentHeight/2+50
	windowGroup:insert(mediumButton)
	
	--======================================
	-- HARD BUTTON
	--======================================
	-- ACTION
	local hardButtonAction = function ( event )
		if event.phase == "release" then
			saveDifficulty(3)
			director:closePopUp()
			if params.startFromAdventure and params.adventureToStart then
				params.startFromAdventure(params.adventureToStart)
			else
				params.startAdventure()
			end
		end
	end
	-- UI ELEMENT
	local hardButton = ui.newButton{
					default = "assets/botonRojo.png",
					onEvent = hardButtonAction,
					text = "Hard",
					size = 55,
					font = mainFont1,
					offset = 0,
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	hardButton.x=windowGroup.contentWidth/2
	hardButton.y=windowGroup.contentHeight/2+100+50
	windowGroup:insert(hardButton)
	
	--======================================
	-- BACK BUTTON
	--======================================
	local resumeButtonAction = function ( event )
		if event.phase == "release" then
			director:closePopUp()
			if params.caller then
				local callerParams = nil
				if params.caller.params then
					callerParams = params.caller.params
					callerParams.animated = false
				end
				if callerParams == nil then
					callerParams = {}
				end
				director:openPopUp(callerParams, params.caller.name, nil )
			end
		end
	end
	
	local titleLabel = ui.newButton{
					default = "assets/botonMadera.png",
					text = "Difficulty",
					size = 72,
					font = mainFont1,
					offset = -10,
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