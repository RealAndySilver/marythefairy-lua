module(..., package.seeall)

new = function (params)
	local thisView = {params = params, name="PlayAgain"}
	
	local ui = require("ui")
	local util = require("util")
	local gPS = require( "gPS" )
	
	local points = 0
	if params.points then
		if type(params.points) == "number" then
			points = params.points
		end
	end
	
	local setPointsText
	
	local starValue = 15000
	
	local localGroup = display.newGroup()
	
	local w, h = display.contentWidth, display.contentHeight
	local realw, realh = display.viewableContentWidth, display.viewableContentHeight
	
	local background = display.newRect(0,0,480,640)
	background:setReferencePoint(display.TopLeftReferencePoint)
	--background.xScale,background.yScale=800/background.contentWidth,571/background.contentHeight
	background.isVisible=false
	
	local windowGroup = display.newGroup()
	local windowGroup2
	windowGroup:insert(background)
	
	local realBG = display.newImage( "assets/menu/fondoMiniMiniMenu.png" )
	realBG:setReferencePoint(display.BottomCenterReferencePoint)
	local rbgScaleFactor = (windowGroup.contentWidth / realBG.contentWidth)*1.25
	realBG.xScale,realBG.yScale = rbgScaleFactor*1.5,rbgScaleFactor*1.5
	realBG.x = windowGroup.contentWidth/2
	realBG.y = windowGroup.contentHeight-10
	windowGroup:insert(realBG)
	
	local myText = display.newText("Play Again?", 0, 0, mainFont1, 104)
	myText:setReferencePoint(display.CenterReferencePoint)
	myText.x=realBG.x
	myText.y=330
	myText:setTextColor(193,39,45,255)
	windowGroup:insert(myText)
	
	local congratsMSG = display.newImage( "assets/congratulationsFinalMessage.png" )
	congratsMSG:setReferencePoint(display.TopCenterReferencePoint)
	local cmsgScaleFactor = (windowGroup.contentWidth / realBG.contentWidth)*1.25
	congratsMSG.xScale,congratsMSG.yScale = cmsgScaleFactor*1.3,cmsgScaleFactor*1.3
	congratsMSG.x = realBG.x
	congratsMSG.y = -(realBG.contentHeight*3/5)
	windowGroup:insert(congratsMSG)
	
	local retryButtonAction = function ( event )
		if event.phase == "release" then
			local function action()
				director:closePopUp()
				if params.repeatAction then
					params.repeatAction()
				end
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*0.1,yScale=windowGroup.yScale*0.1,time=200,onComplete=action})
			if windowGroup2 then
				transition.to(windowGroup2,{alpha=0,xScale=windowGroup.xScale*0.1,yScale=windowGroup.yScale*0.1,time=200})
			end
			retryButtonAction=nil
		end
	end
	local resumeButtonAction = function ( event )
		if event.phase == "release" then
			local function action()
				director:closePopUp()
				if params.hideAction then
					params.hideAction()
				end
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200,onComplete=action})
			if windowGroup2 then
				transition.to(windowGroup2,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200})
			end
			resumeButtonAction=nil
		end
	end
	local mainMenuButtonAction = function ( event )
		if event.phase == "release" then
			setPointsText(points)
			local function action()
				director:closePopUp()
				if params.killCaller then
					params.killCaller()
				end
				preloader:changeScene("mainMenu","crossfade")
			end
			transition.to(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200,onComplete=action})
			mainMenuButtonAction=nil
		end
	end
	
	local resumeButton = ui.newButton{
					default = "assets/botonAzulPequeno.png",
					onEvent = resumeButtonAction,
					text = "Later",
					size = 72,
					font = mainFont1,
					--offset = correctOffset(-10),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	resumeButton:setReferencePoint(display.BottomLeftReferencePoint)
	resumeButton.x=realBG.x-300
	resumeButton.y=background.contentHeight-70
	resumeButton.xScale,resumeButton.yScale = 1.5,1.5
	windowGroup:insert(resumeButton)
	resumeButton.isVisible=true
	
	local retryButton = ui.newButton{
					default = "assets/botonAmarilloPequeno.png",
					onEvent = retryButtonAction,
					text = "Yes",
					size = 72,
					font = mainFont1,
					--offset = correctOffset(-10),
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	retryButton:setReferencePoint(display.BottomRightReferencePoint)
	retryButton.x=realBG.x+300
	retryButton.y=background.contentHeight-70
	retryButton.xScale,retryButton.yScale = 1.5,1.5
	windowGroup:insert(retryButton)
	retryButton.isVisible=true
	
	
	local windowWScaleFactor = realw/windowGroup.contentWidth
	local windowHScaleFactor = realh/windowGroup.contentHeight
	local wSF = ((windowWScaleFactor > windowHScaleFactor) and windowHScaleFactor) or windowWScaleFactor
	windowGroup:setReferencePoint(display.CenterReferencePoint)
	windowGroup.x = display.contentWidth/2 - realw/5
	windowGroup.y = display.contentHeight/2 + display.contentHeight*0.05
	windowGroup.xScale = wSF * 0.8
	windowGroup.yScale = wSF * 0.8
	
	if params.animated then
		transition.from(windowGroup,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200})
	end
	localGroup:insert( windowGroup )
	
	--promo
	
	local background2 = display.newRect(0,0,480,640)
	background2:setReferencePoint(display.TopLeftReferencePoint)
	--background.xScale,background.yScale=800/background.contentWidth,571/background.contentHeight
	background2.isVisible=false
	
	windowGroup2 = display.newGroup()
	windowGroup2:insert(background2)
	
	local realBG2 = display.newImage( "assets/menu/promo.png" )
	realBG2:setReferencePoint(display.BottomCenterReferencePoint)
	realBG2.xScale,realBG2.yScale = rbgScaleFactor,rbgScaleFactor
	realBG2.x = windowGroup2.contentWidth/2
	realBG2.y = windowGroup2.contentHeight+212.5
	windowGroup2:insert(realBG2)
	
	windowGroup2:setReferencePoint(display.CenterReferencePoint)
	windowGroup2.x = (display.contentWidth - display.screenOriginX) - (realw - windowGroup.contentWidth) / 2
	windowGroup2.y = display.contentHeight/2
	windowGroup2.xScale = wSF * 0.8
	windowGroup2.yScale = wSF * 0.8
	
	if params.animated then
		transition.from(windowGroup2,{alpha=0,xScale=windowGroup.xScale*2,yScale=windowGroup.yScale*2,time=200})
	end
	localGroup:insert( windowGroup2 )
	
	if not params.shouldNotPlaySound then
		soundController.playNew{
						path = "assets/sound/voices/outro/NarratorsRealOutro.mp3",
						duration = 14000,
						actionTimes = {0},
						action =	function()
									end,
						onComplete = function()
									end
						}
	end
	
	return localGroup
end