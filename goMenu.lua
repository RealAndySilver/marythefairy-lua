module(..., package.seeall)

new = function (params)
	local ui = require("ui")
	
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
	local myText = display.newText("Let's try again!", 0, 0, mainFont1, 64)
	myText:setReferencePoint(display.CenterReferencePoint)
	myText.x=windowGroup.contentWidth/2
	myText.y=windowGroup.contentHeight/2-130
	myText:setTextColor(67,34,15,255)
	windowGroup:insert(myText)
	
	
	-- ACTIONS
	local resumeButtonAction = function ( event )
		if event.phase == "release" then
			director:closePopUp()
			if params.killCaller then
				params.killCaller()
			end
			if params.hideAction then
				params.hideAction()
			end
		end
	end
	local mainMenuButtonAction = function ( event )
		if event.phase == "release" then
			director:closePopUp()
			if params.killCaller then
				params.killCaller()
				preloader:changeScene("mainMenu","crossfade")
			end
		end
	end
	
	-- BUTTONS
	local restartButton = ui.newButton{
					default = "assets/botonFlechaVerde.png",
					onEvent = resumeButtonAction,
					text = "GO",
					size = 72,
					font = mainFont1,
					offset = -5,
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	restartButton.x=windowGroup.contentWidth/2
	restartButton.y=windowGroup.contentHeight/2-0+50
	restartButton.xScale,restartButton.yScale=1.25,1.25
	windowGroup:insert(restartButton)
	
	local homeButton = ui.newButton{
					default = "assets/homeButton.png",
					onEvent = mainMenuButtonAction,
					id = "bt01"}
	homeButton.x,homeButton.y=70,40
	homeButton.xScale,homeButton.yScale=0.65,0.65
	windowGroup:insert(homeButton)
	
	local titleLabel = ui.newButton{
					default = "assets/botonMadera.png",
					text = "Retry",
					size = 84,
					font = mainFont1,
					offset = -10,
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	titleLabel.x=windowGroup.contentWidth/2
	titleLabel.y=35
	titleLabel.xScale,titleLabel.yScale=1.1,1.1
	windowGroup:insert(titleLabel)
	
	windowGroup:setReferencePoint(display.CenterReferencePoint)
	windowGroup.x = display.contentWidth/2
	windowGroup.y = display.contentHeight/2
	windowGroup.xScale = scaleFactor*0.9
	windowGroup.yScale = scaleFactor*0.9
	
	soundController.playNew{
					path = "assets/sound/voices/SonidosNarrador/tryAgain.mp3",
					}
	
	localGroup:insert( windowGroup )
	return localGroup
	
end