module(..., package.seeall)

local function restartIt()
	preloader:changeScene("Interactivity2","crossfade")
end

require "sprite"

new = function ( params )
	soundController.killAll()
	Runtime:removeEventListener( "system", systemEvent )
	
	soundController.playNew{
					path = "assets/sound/interactivity1a4.mp3",
					loops = -1,
					identifier = "bgsound",
					pausable = false,
					staticChannel = 1,
					actionTimes = {},
					action =	function()
								end,
					onComplete = function()
								end
					}
	------------------
	-- Imports
	------------------
	local ui = require("ui")
	local util = require("util")
	local gPS = require( "gPS" )
	
	------------------
	-- Variables
	------------------
	local width = display.contentWidth
	local height = display.contentHeight
	
	local scaleSheets = 1
	if display.contentScaleX<=0.5 then --this wonderful new API will let you know if you're scaling your content and thus if it's playing on a highres device. Since my config.lua has an x size of 480 and the device x is 960, we get the .5.
		scaleSheets = 0.5
	end
	
	local paused = false
	
	local menuButton
	local overlay
	
	local screenMessages = ui.newScreenMessages()
	
	local misses = 0
	local extras = 0
	local startTime = 0
	local finishTime = 0
	
	local function addMisses(message,value,x,y)
		if type(message) ~= "string" then
			message,value,x,y = "",message,value,x
		end
		misses = misses + value
		if message and message ~= "" then message = message.." " end
		--screenMessages.newMessage(message.."-"..value*1000,x,y)
		screenMessages.newMessage("-"..value*1000,x,y)
	end
	
	local function addExtras(message,value,x,y)
		if type(message) ~= "string" then
			message,value,x,y = "",message,value,x
		end
		extras = extras + value
		if message and message ~= "" then message = message.." " end
		--screenMessages.newMessage(message.."+"..value*1000,x,y)
		screenMessages.newMessage("+"..value*1000,x,y)
	end
	
	--====================================================================--
	-- SET UP A LOCAL GROUP THAT WILL BE RETURNED
	--====================================================================--
	local localGroup = display.newGroup()
	localGroup:insert(screenMessages.displayObject)
	
	-- LOWER LAYER, THE BACKGROUND COLOR
	local backgroundColor = display.newRect(0,0,width,height)
	backgroundColor:setFillColor(255,255,235)
	localGroup:insert(backgroundColor)
	
	local startAdventure
	local startDemoLoop
	local startInteraction
	local startTheParty
	local startTransition
	
	local killAdventure
	local killDemoLoop
	local killInteraction
	local killTheParty
	local killTransition
	
	local bGroup
	
	local rdm = math.random
	
	local rightDrop,leftDrop
	
	local gameOver
	local pauseIt
	local continueIt
	
	local function killAll()
		paused = nil
		gameOver = nil
		pauseIt = nil
		continueIt = nil
		killAll = nil
		bGroup = nil
		rdm = nil
		rightDrop = nil
		leftDrop = nil
		screenMessages.kill()
		if killAdventure then
			killAdventure()
		end
		if killDemoLoop then
			killDemoLoop()
		end
		if killInteraction then
			killInteraction()
		end
		if killTheParty then
			killTheParty()
		end
		if killTransition then
			killTransition()
		end
	end
	
	local difficultyLevel = getDifficulty()
	
	--======================================
	-- START ADVENTURE
	--======================================
	local function prepareWelcomeScreen()
		local loadingBackground = display.newImageRect("assets/world/silverGardenSky.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local titleLabel = util.centeredWrappedText("Adventure 2\nDry Mary's Wings", 30, 36, mainFont1, {67,34,15,255})
		titleLabel.y = 0
		titleLabel.x = width/2
		localGroup:insert(titleLabel)
		titleLabel.isVisible = false
		
		titleLabel.alpha=0
		transition.to(titleLabel,{alpha=1,time=1500})
		
		local function continue()
			localGroup:remove(loadingBackground)
			localGroup:remove(titleLabel)
			
			loadingBackground = nil
			titleLabel = nil
			
			continue = nil
			killAdventure = nil
		end
		killAdventure = function()
			startAdventure=nil
			vanish=nil
			continue()
		end
		
		local function vanish()
			pauseIt = nil
			continueIt = nil
			
			startDemoLoop()
			timer.performWithDelay(300, continue)
			
			vanish = nil
		end
		
		startAdventure = function()
			soundController.playNew{
						path = "assets/sound/voices/cap2/int2_N1.mp3",
						duration = 13000,
						actionTimes = {3500},
						identifier = "directions",
						action =	function()
										if vanish then
											vanish()
										end
									end,
						onComplete = function()
										if vanish then
											vanish()
										end
									end
						}
			--local thisTimer = timer.performWithDelay(3000, vanish)
			
			loadingBackground.isVisible = true
			titleLabel.isVisible = true
			
			pauseIt = function()
				--timer.pause(thisTimer)
			end
			
			continueIt = function()
				--timer.resume(thisTimer)
			end
			
			startAdventure = nil
		end
	end
	prepareWelcomeScreen()
	
	--====================================================================--
	-- particle system
	--====================================================================--
	local bGroup = display.newGroup()
	
	---------------------------------------------------------------------------------------------------------
	rightDrop = function()
		if not bGroup then return end
		local star1 = { imgStart = { life = rdm(1000,1500), alpha = 1, size = {rdm(2,4),rdm(2,4)}, stroke={0,0,0,0}, pos = {0,0,rdm(20,50),rdm(-15,15)},color={50,50,255,255}},
						imgEnd = { onComplete = nil, alpha = 0.8, scale ={1.2,1.2},pos={0,0,rdm(250,450),rdm(-300,300),move = 1, ease = easing.outQuad}},
						imgInfo = { group = bGroup, max = 60}}
		gPS.newCircle(star1)
	end
	
	leftDrop = function()
		if not bGroup then return end
		local star1 = { imgStart = { life = rdm(1000,1500), alpha = 1, size = {rdm(2,4),rdm(2,4)}, stroke={0,0,0,0}, pos = {0,0,rdm(-50,-20),rdm(-15,15)},color={50,50,255,255}},
						imgEnd = { onComplete = nil, alpha = 0.8, scale ={1.2,1.2},pos={0,0,rdm(-550,-350),rdm(-300,300),move = 1, ease = easing.outQuad}},
						imgInfo = { group = bGroup, max = 60}}
		gPS.newCircle(star1)
	end
	
	local background = display.newImageRect("assets/world/silverGardenCloseup.jpg",width,height)
	background:setReferencePoint(display.TopLeftReferencePoint)
	background.xScale,background.yScale = 1.25,1.25
	background.x = 0
	background.y = -75
	localGroup:insert(background)
	background.isVisible = false
	
	local mary = {}
	
	mary.wingsGroup = display.newGroup()
	mary.wing1 = display.newImage("assets/mary/wing.png")
	mary.wing1.xScale,mary.wing1.yScale = 0.3,0.3
	mary.wingsGroup:insert(mary.wing1)
	mary.wing1.isVisible = false
	mary.wing1:setReferencePoint(display.CenterRightReferencePoint)
	
	mary.wing2 = display.newImage("assets/mary/wing.png")
	mary.wing2.xScale,mary.wing2.yScale = -0.25,0.25
	mary.wingsGroup:insert(mary.wing2)
	mary.wing2.isVisible = false
	mary.wing2:setReferencePoint(display.CenterRightReferencePoint)
	
	mary.eyesOpen = display.newImage("assets/mary/laughing2/eyesOpen.png")
	
	mary.laughingAnimation = ui.newAnimation{
						 comps = {
						 {
						  displayObject = mary.wingsGroup,
						  x = { 313.3,313.3,313.3,313.25,313.35,313.25,313.3,313.3,313.3,313.3 },
						  y = { 318.6,318.5,318.4,318.3,318.25,318.3,318.4,318.5,318.6,318.75 },
						  rotation = { 5.5109100341796875,5.93157958984375,6.35333251953125,6.7743988037109375,7.1964569091796875,6.7743988037109375,6.35333251953125,5.93157958984375,5.5109100341796875,5.087921142578125 },
						 },
						 {
						  displayObject = bGroup,
						  x = { 313.3,313.3,313.3,313.25,313.35,313.25,313.3,313.3,313.3,313.3 },
						  y = { 318.6,318.5,318.4,318.3,318.25,318.3,318.4,318.5,318.6,318.75 },
						  rotation = { 5.5109100341796875,5.93157958984375,6.35333251953125,6.7743988037109375,7.1964569091796875,6.7743988037109375,6.35333251953125,5.93157958984375,5.5109100341796875,5.087921142578125 },
						  yOffset = -50,
						  scaleComponent = true,
						 },
						 {
						  --body
						  path = "assets/mary/laughing2/body.png",
						  x = { 313.3,313.3,313.3,313.25,313.35,313.25,313.3,313.3,313.3,313.3 },
						  y = { 318.6,318.5,318.4,318.3,318.25,318.3,318.4,318.5,318.6,318.75 },
						  rotation = { 5.5109100341796875,5.93157958984375,6.35333251953125,6.7743988037109375,7.1964569091796875,6.7743988037109375,6.35333251953125,5.93157958984375,5.5109100341796875,5.087921142578125 },
						 },
						 {
						  --rleg
						  path = "assets/mary/laughing2/rleg.png",
						  x = { 298.9,298.65,298.35,298,297.7,298,298.35,298.65,298.9,299.2 },
						  y = { 409.4,409.15,408.9,408.6,408.4,408.6,408.9,409.15,409.4,409.6 },
						  rotation = { -2.213409423828125,-2.2282562255859375,-2.24395751953125,-2.259674072265625,-2.2745208740234375,-2.259674072265625,-2.24395751953125,-2.2282562255859375,-2.213409423828125,-2.19769287109375 },
						 },
						 {
						  --lleg
						  path = "assets/mary/laughing2/lleg.png",
						  x = { 329.7,329.45,329.25,329,328.85,329,329.25,329.45,329.7,329.95 },
						  y = { 412.85,412.9,412.95,412.9,412.95,412.9,412.95,412.9,412.85,412.85 },
						  rotation = { -0.3243560791015625,-0.398651123046875,-0.4720916748046875,-0.5455169677734375,-0.61895751953125,-0.5455169677734375,-0.4720916748046875,-0.398651123046875,-0.3243560791015625,-0.250030517578125 },
						 },
						 {
						  --lpigtail
						  path = "assets/mary/laughing2/lpigtail.png",
						  x = { 332.35,337.35,342.3,347.2,352.15,347.2,342.3,337.35,332.35,327.4 },
						  y = { 118.25,119.3,120.45,121.7,123.05,121.7,120.45,119.3,118.25,117.15 },
						  rotation = { 4.7494659423828125,4.408935546875,4.0698394775390625,3.7287139892578125,3.38818359375,3.7287139892578125,4.0698394775390625,4.408935546875,4.7494659423828125,5.09051513671875 },
						  yOffset = 10
						 },
						 {
						  --larm
						  path = "assets/mary/laughing2/larm.png",
						  x = { 362.85,363.35,363.8,364.2,364.6,364.2,363.8,363.35,362.85,362.4 },
						  y = { 270.3,270.4,270.6,270.8,270.95,270.8,270.6,270.4,270.3,270.05 },
						  rotation = { -63.964019775390625,-63.86177062988281,-63.75898742675781,-63.65708923339844,-63.55326843261719,-63.65708923339844,-63.75898742675781,-63.86177062988281,-63.964019775390625,-64.06716918945313 },
						 },
						 {
						  --body
						  path = "assets/mary/laughing2/body.png",
						  x = { 313.3,313.3,313.3,313.25,313.35,313.25,313.3,313.3,313.3,313.3 },
						  y = { 318.6,318.5,318.4,318.3,318.25,318.3,318.4,318.5,318.6,318.75 },
						  rotation = { 5.5109100341796875,5.93157958984375,6.35333251953125,6.7743988037109375,7.1964569091796875,6.7743988037109375,6.35333251953125,5.93157958984375,5.5109100341796875,5.087921142578125 },
						 },
						 {
						  --head
						  path = "assets/mary/laughing2/head.png",
						  x = { 330.35,332.8,335.4,337.9,340.4,337.9,335.4,332.8,330.35,327.8 },
						  y = { 138.1,138.15,138.25,138.4,138.6,138.4,138.25,138.15,138.1,138.1 },
						  rotation = { 6.1788330078125,7.2678680419921875,8.356781005859375,9.445587158203125,10.534332275390625,9.445587158203125,8.356781005859375,7.2678680419921875,6.1788330078125,5.0913848876953125 },
						 },
						 {
						  --eyesOpen
						  displayObject = mary.eyesOpen,
						  x = { 330.35,332.8,335.4,337.9,340.4,337.9,335.4,332.8,330.35,327.8 },
						  y = { 138.1,138.15,138.25,138.4,138.6,138.4,138.25,138.15,138.1,138.1 },
						  rotation = { 6.1788330078125,7.2678680419921875,8.356781005859375,9.445587158203125,10.534332275390625,9.445587158203125,8.356781005859375,7.2678680419921875,6.1788330078125,5.0913848876953125 },
						  scaleComponent = true
						 },
						 {
						  --rpigtail
						  path = "assets/mary/laughing2/rpigtail.png",
						  x = { 249.4,254.2,259.05,263.95,268.85,263.95,259.05,254.2,249.4,244.6 },
						  y = { 115.9,114.75,113.75,112.85,111.9,112.85,113.75,114.75,115.9,117.05 },
						  rotation = { 4.96820068359375,4.8458251953125,4.72601318359375,4.6053009033203125,4.4845428466796875,4.6053009033203125,4.72601318359375,4.8466949462890625,4.96820068359375,5.087921142578125 },
						  yOffset = 5
						 },
						 {
						  --lantearm
						  path = "assets/mary/laughing2/lhand.png",
						  x = { 372.25,372.75,373.2,373.65,374.1,373.65,373.2,372.75,372.25,371.8 },
						  y = { 241.7,242.05,242.35,242.65,242.95,242.65,242.35,242.05,241.7,241.55 },
						  rotation = { 172.97055053710938,172.8603515625,172.7501983642578,172.64010620117188,172.52920532226563,172.64010620117188,172.7501983642578,172.8603515625,172.97055053710938,173.08253479003906 },
						 },
						 {
						  --rarm
						  path = "assets/mary/laughing2/rarm.png",
						  x = { 322.3,322.8,323.35,323.95,324.5,323.95,323.35,322.8,322.3,321.65 },
						  y = { 269.8,269.55,269.3,269,268.75,269,269.3,269.55,269.8,270.15 },
						  rotation = { -125.92913818359375,-125.02474975585938,-124.1220703125,-123.21743774414063,-122.31367492675781,-123.21743774414063,-124.1220703125,-125.02474975585938,-125.92913818359375,-126.83233642578125 },
						 },
						 {
						  --rantearm
						  path = "assets/mary/laughing2/rhand.png",
						  x = { 361.7,362.35,363.05,363.7,364.4,363.7,363.05,362.35,361.7,360.9 },
						  y = { 244.95,245.25,245.55,245.9,246.15,245.9,245.55,245.25,244.95,244.6 },
						  rotation = { 173.59140014648438,174.02517700195313,174.45703125,174.89039611816406,175.32261657714844,174.89039611816406,174.45703125,174.02517700195313,173.59140014648438,173.1592254638672 },
						 },
						},
						 x = 0,
						 y = 0,
						 scale = 1/2,
						 speed = 0.4
						}
	mary.laughingAnimation.displayObject.x = 50
	mary.laughingAnimation.displayObject.y = -50
	mary.laughingAnimation.displayObject.xScale = 1.5
	mary.laughingAnimation.displayObject.yScale = 1.5
	mary.laughingAnimation.hide()
	
	mary.open_close_eyes = function()
		if mary.eyesOpen then
			if math.random(20) > 10 and not paused then
				mary.eyesOpen.isVisible = not mary.eyesOpen.isVisible
			end
			timer.performWithDelay(500, mary.open_close_eyes)
		end
	end
	
	localGroup:insert(mary.laughingAnimation.displayObject)
	
	--======================================
	-- DEMO LOOP
	--======================================
	local function prepareDemoLoop()
		local arrows = display.newImageRect("assets/interactivity2/flechas.png",60,114)
		localGroup:insert(arrows)
		arrows.isVisible = false
		arrows:setReferencePoint(display.CenterReferencePoint)
		arrows.y = height/2 - 30
		arrows.x = width/2 - 50
		
		local hand = display.newImageRect("assets/hand.png",54.4,64)
		localGroup:insert(hand)
		hand.isVisible = false
		hand:setReferencePoint(display.BottomRightReferencePoint)
		
		local whiteSquare = display.newImageRect("assets/pedazoDeMadera.png",width,95.5)
		whiteSquare:setReferencePoint(display.TopLeftReferencePoint)
		whiteSquare.x,whiteSquare.y=0,display.screenOriginY+display.viewableContentHeight-95
		localGroup:insert(whiteSquare)
		whiteSquare.isVisible = false
		
		local startHandAnimation
		local stopHandAnimation
		local killHandAnimation
		
		local multiplier = 1
		local function prepareHandAnimation()
			hand.x = 275
			hand.y = 145
			
			mary.wing1.x = 0
			mary.wing1.y = -20
			
			mary.wing2.x = 0
			mary.wing2.y = -20
			
			local rotationDelta = 10
			local rotationDirection = -rotationDelta
			
			local alive = true
			
			local localPauseState = paused
			local function animateHand()
				if not hand then
					stopHandAnimation()
					return
				end
				
				if localPauseState ~= paused then
					localPauseState = paused
					if paused then
						mary.laughingAnimation.stop()
					else
						mary.laughingAnimation.start()
					end
					return
				end
				if localPauseState then
					return
				end
				
				rotationDirection = rotationDirection*multiplier
				rotationDelta = rotationDelta*multiplier
				
				if math.random(10) > 2 then
					if rightDrop then
						rightDrop()
					end
				end
				
				if math.random(10) > 2 then
					if leftDrop then
						leftDrop()
					end
				end
				
				hand.rotation = hand.rotation+rotationDirection
				mary.wing1.rotation = mary.wing1.rotation+rotationDirection*0.4
				mary.wing2.rotation = mary.wing2.rotation-rotationDirection*0.4
				
				if hand.rotation < -90 then
					rotationDirection = rotationDelta
				elseif hand.rotation > 0 then
					rotationDirection = -rotationDelta
				end
			end
			
			startHandAnimation = function ()
				if alive then
					Runtime:addEventListener("enterFrame",animateHand)
				end
			end
			
			stopHandAnimation = function ()
				Runtime:removeEventListener("enterFrame",animateHand)
			end
			
			killHandAnimation = function ()
				alive = false
				stopHandAnimation()
			end
		end
		prepareHandAnimation()
		
		local function continue()
			killHandAnimation()
			
			localGroup:remove(whiteSquare)
			localGroup:remove(hand)
			localGroup:remove(arrows)
			
			continue=nil
			killDemoLoop=nil
		end
		killDemoLoop = function()
			startDemoLoop=nil
			vanish=nil
			continue()
		end
		
		local vanish
		
		--START BUTTON
		local started = false
		local startButtonAction = function ( event )
			if event.phase == "release" and not started then
				soundController.kill("directions")
				vanish()
				started = true
			end
		end
		-- UI ELEMENT
		local startButton = ui.newButton{
						default = "assets/botonAzulGigante.png",
						onEvent = startButtonAction,
						text = "Start",
						size = 112,
						font = mainFont1,
						offset = correctOffset(0),
						emboss = true,
						textColor={66,33,11,255},
						id = "bt01"}
		startButton.xScale,startButton.yScale = 0.4,0.4
		startButton.x=display.screenOriginX+startButton.contentWidth/2+20
		startButton.y=whiteSquare.y+whiteSquare.contentHeight*5/8-2
		startButton.isVisible = false
		localGroup:insert(startButton)
		
		local someInfoText = "Help Mary to dry her wings.\nRUB her wings with your finger to make them SHAKE so they become dry."
		
		local infoDisplayObject = util.wrappedText(someInfoText, 55, 16, mainFont1, {67,34,15,255})
		infoDisplayObject.y=whiteSquare.y+whiteSquare.contentHeight*5/9-infoDisplayObject.contentHeight/2 - 0
		infoDisplayObject.x=startButton.x+startButton.contentWidth/2+20
		infoDisplayObject.isVisible=false
		localGroup:insert(infoDisplayObject)
		
		vanish = function()
			pauseIt = nil
			continueIt = nil
			
			startButton.isVisible = false
			
			multiplier = 0.95
			
			transition.to(whiteSquare,{y=height, time = 550})
			transition.to(startButton,{alpha=0,y=startButton.y+whiteSquare.contentHeight,time=550})
			transition.to(infoDisplayObject,{alpha=0,y=infoDisplayObject.y+whiteSquare.contentHeight,time=550})
			
			local newMLADOY=mary.laughingAnimation.displayObject.y+60
			transition.to(mary.laughingAnimation.displayObject,{y=mary.laughingAnimation.displayObject.y+60,time = 500})
			transition.to(background,{y=0,time = 500})
			transition.to(hand,{alpha=0, time = 300})
			transition.to(arrows,{alpha=0, time = 300})
			
			timer.performWithDelay(600, function()
											whiteSquare.y=height
											startButton.alpha=0
											infoDisplayObject.alpha=0
											mary.laughingAnimation.displayObject.y=newMLADOY
											background.y=0
											hand.alpha=0
											arrows.alpha=0
										end)
			
			timer.performWithDelay(1000, startInteraction)
			timer.performWithDelay(1500, continue)
			vanish=nil
		end
		
		startDemoLoop = function()
			background.isVisible = true
			
			arrows.isVisible = true
			hand.isVisible = true
			mary.wing1.isVisible = true
			mary.wing2.isVisible = true
			
			background.alpha = 0
			
			arrows.alpha = 0
			hand.alpha = 0
			mary.wing1.alpha = 0
			mary.wing2.alpha = 0
			
			mary.laughingAnimation.start()
			mary.laughingAnimation.appear(300)
			mary.eyesOpen.isVisible = false
			
			transition.to(background,{alpha=1,time=300})
			transition.to(arrows,{alpha=1,time=300})
			transition.to(hand,{alpha=1,time=300})
			transition.to(mary.wing1,{alpha=1,time=300})
			transition.to(mary.wing2,{alpha=1,time=300})
			
			whiteSquare.isVisible = true
			whiteSquare.alpha = 0
			startButton.isVisible = true
			infoDisplayObject.isVisible = true
			startButton.alpha=0
			infoDisplayObject.alpha=0
			
			transition.to(startButton,{alpha=1,time=300})
			transition.to(infoDisplayObject,{alpha=1,time=300})
			transition.to(whiteSquare,{alpha=1,time=300})
			
			timer.performWithDelay(500, mary.open_close_eyes)
			
			startHandAnimation()
			startDemoLoop=nil
			
			pauseIt = function()
			end
			
			continueIt = function()
			end
		end
	end
	prepareDemoLoop()
	
	--====================================================================--
	-- INTERACTION
	--====================================================================--
	local function prepareInteraction()
		local isShakingWings = false
		local showingWarning = false
		
		local loseTimer = nil
		
		local warning = display.newImageRect("assets/interactivity2/flechas.png",60,114)
		warning:setReferencePoint(display.CenterReferencePoint)
		warning.y = height/2
		warning.x = width/2 - 50
		warning.xScale,warning.yScale = 5,5
		warning.alpha = 0
		
		local wingTouches = 0
		
		local finished = false
		local vanish
		
		local points = 0
		local targetPoints = 2000
		
		local function getWaterSpriteSheetData ()
			local totalFrames = 15
			local frameWidth = 50
			
			local imageWidth = 187
			local imageHeight = 20
			
			local frames = {}
			
			for i=1, totalFrames do
				local name = ""
				if i/10 < 1 then
					name = name.."0"
				end
				name = name..i..".png"
				
				frames[i] = {
					name = name,
					spriteColorRect = { x = 0, y = 0, width = frameWidth, height = imageHeight },
					textureRect = { x = ((imageWidth-frameWidth)/totalFrames)*i-1, y = 0, width = frameWidth, height = imageHeight },
					spriteSourceSize = { width = imageWidth, height = imageHeight },
					spriteTrimmed = true,
					textureRotated = false
				}
			end
			
			local sheet = {
				frames = frames
			}
			
			return sheet
		end
		local spriteData = getWaterSpriteSheetData()
		local waterWavesSpriteSheet = sprite.newSpriteSheetFromData("assets/interactivity2/puntita.png",spriteData)
		local waterWavesSpriteSet = sprite.newSpriteSet(waterWavesSpriteSheet, 1, 12)
		sprite.add( waterWavesSpriteSet, "waterWaves", 1, 15, 500, 0 )
		
		local waterWavesInstance = sprite.newSprite( waterWavesSpriteSet )
		waterWavesInstance.isVisible = false
		waterWavesInstance.alpha = 0
		waterWavesInstance:prepare("waterWaves")
		
		local waterRect = display.newRect(0,0,50,170)
		waterRect:setFillColor(41,171,226)
		waterWavesInstance:setReferencePoint(display.BottomCenterReferencePoint)
		waterRect:setReferencePoint(display.TopCenterReferencePoint)
		waterRect.x = -width/6+11.5
		waterRect.y = waterWavesInstance.y
		waterRect.isVisible = false
		waterRect.alpha = 0
		
		local waterGroup = display.newGroup()
		waterGroup:insert(waterRect)
		waterGroup:insert(waterWavesInstance)
		
		waterGroup:setReferencePoint(display.CenterReferencePoint)
		waterGroup.xScale = 0.575
		
		local waterContainer = display.newImageRect("assets/interactivity2/container.png",35,250)
		waterContainer:setReferencePoint(display.CenterReferencePoint)
		waterContainer.x = width/6
		waterContainer.y = height/2
		waterContainer.alpha = 0
		waterContainer.isVisible = false
		
		localGroup:insert(waterGroup)
		localGroup:insert(waterContainer)
		localGroup:insert(warning)
		
		local maxPoints = 0
		local aCounter = 0
		local function echarleAguitaAlTuboEse()
			if paused then return end
			aCounter = aCounter + 0.15
			if aCounter>6.28318531 then aCounter=0 end
			warning.y = height/2 + math.sin(aCounter)*30
			if points>maxPoints then maxPoints=points end
			local previousPoints = points
			points = points - (difficultyLevel-1) * 0.25
			local completed = points/targetPoints
			if completed < 0 then
				completed = 0
				points = 0
			elseif completed > 1 then
				completed = 1
				points = targetPoints
			end
			if previousPoints>0 and previousPoints>points and points<=0 and maxPoints>targetPoints/10 then
				if loseTimer then
					timer.cancel(loseTimer)
					loseTimer=nil
				end
				loseTimer = timer.performWithDelay(5000,gameOver)
				addMisses(1, waterContainer.x + 45, height/2)
			end
			waterRect.yScale = 1-completed+0.05
			waterContainer:setReferencePoint(display.BottomLeftReferencePoint)
			waterGroup:setReferencePoint(display.BottomLeftReferencePoint)
			waterGroup.x = waterContainer.x + 3.5
			waterGroup.y = waterContainer.y - 15
		end
		echarleAguitaAlTuboEse()
		
		local function continue()
			Runtime:removeEventListener("enterFrame",echarleAguitaAlTuboEse)
			Runtime:removeEventListener( "touch", touchScreen )
			Runtime:removeEventListener("enterFrame",impulseWings)
			--mary.wingsGroup:removeEventListener( "touch", touchWings )
			
			soundController.kill("water")
			
			localGroup:remove(background)
			localGroup:remove(warning)
			
			localGroup:remove(waterGroup)
			localGroup:remove(waterContainer)
			
			local function killMary()
				mary.laughingAnimation.kill()
			end
			timer.performWithDelay(2000, killMary)
			
			mary.laughingAnimation.stop()
			
			continue=nil
			killInteraction=nil
		end
		killInteraction = function()
			startInteraction=nil
			vanish=nil
			continue()
		end
		
		vanish = function ()
			finishTime = system.getTimer()
			
			soundController.kill("bubbles")
			soundController.kill("water")
			
			startTheParty()
			timer.performWithDelay(300, continue)
			Runtime:removeEventListener("enterFrame",echarleAguitaAlTuboEse)
			Runtime:removeEventListener("touch", touchScreen )
			Runtime:removeEventListener("enterFrame",impulseWings)
			--mary.wingsGroup:removeEventListener( "touch", touchWings )
			vanish=nil
		end
		
		local isCongratulatingPlayer = false
		local function congratulatePlayer(special)
			if not isCongratulatingPlayer then
				isCongratulatingPlayer = true
				local function completeFunction()
					timer.performWithDelay(10000,function() isCongratulatingPlayer = false; end)
				end
				if special then
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/wellDone.mp3",
									onComplete = completeFunction
									}
				else
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/great.mp3",
									onComplete = completeFunction
									}
				end
			end
		end
		
		local warningTimer
		
		local function showWarning()
			if isShakingWings then
				return
			end
			if not showingWarning then
				transition.to(warning,{alpha=0.7,xScale=1,yScale=1,time=300})
				if math.random(4) == 1 then
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/rubWings.mp3",
									}
				else
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/comeOn.mp3",
									}
				end
			end
			showingWarning = true
			addMisses(1, waterContainer.x + 45, height/2)
		end
		
		local function hideWarning()
			if not isShakingWings then
				return
			end
			if showingWarning then
				transition.to(warning,{alpha=0,xScale=5,yScale=5,time=300})
			end
			showingWarning = false
		end
		
		local minRotation = -30
		local maxRotation = -5
		
		local acc = 0
		local function addToAcc(val)
			acc = acc+val
			if acc > 100 then
				addExtras(1, waterContainer.x + 45, height/2)
				acc = acc - 100
			end
		end
		
		local function impulseWings ()
			if not mary then
				Runtime:removeEventListener("enterFrame",impulseWings)
				soundController.kill("water")
				impulseWings = nil
				if finished then
					vanish()
				end
				return
			end
			if (not mary.wing1) or (not mary.wing2) or (not mary.wing1.rotation) or (not mary.wing2.rotation) then
				Runtime:removeEventListener("enterFrame",impulseWings)
				soundController.kill("water")
				impulseWings = nil
				if finished then
					vanish()
				end
				return
			end
			if loseTimer then
				timer.cancel(loseTimer)
				loseTimer=nil
			end
			if paused then return end
			if mary.lastMovementY then
				mary.lastMovementY = mary.lastMovementY * 0.95
				
				local w1rA = math.abs(mary.wing1.rotation)
				local lmyA = math.abs(mary.lastMovementY*0.001)
				local newPoints = points + 0.1 * math.abs(w1rA - lmyA) * 0.1
				if (newPoints - points) > 0.3 then
					local times = math.floor((newPoints-points)/0.3)
					for i = 1,times do
						if math.random(10)>5 then
							if rightDrop then
								rightDrop()
							end
						else
							if leftDrop then
								leftDrop()
							end
						end
					end
				end
				if (newPoints - points) > 0.7 then
					if math.random(5) == 1 then
						addToAcc(newPoints-points)
					end
				end
				points = newPoints
				if points >= targetPoints and not finished then
					addExtras("Impulse",5*difficultyLevel,width/2,height/2)
					unlockAchievement("com.tapmediagroup.MaryTheFairy.Impulse","Impulse","Impulse")
					finished = true
				end
				--echarleAguitaAlTuboEse()
				
				if mary.wing1.rotation < minRotation then
					mary.wing1.rotation = minRotation
					mary.wing2.rotation = -minRotation
					mary.lastMovementY = mary.lastMovementY * -1
				elseif mary.wing1.rotation > maxRotation then
					mary.wing1.rotation = maxRotation
					mary.wing2.rotation = -maxRotation
					mary.lastMovementY = mary.lastMovementY * -1
				end
				
				mary.wing1.rotation = mary.wing1.rotation-mary.lastMovementY*0.2
				mary.wing2.rotation = mary.wing2.rotation+mary.lastMovementY*0.2
				
				if math.abs(mary.lastMovementY) < 0.1 then
					mary.lastMovementY = nil
					if finished then
						vanish()
					end
				end
			else
				Runtime:removeEventListener("enterFrame",impulseWings)
				soundController.kill("water")
			end
		end
		
		local function touchScreen (event)
			if loseTimer then
				timer.cancel(loseTimer)
				loseTimer=nil
			end
			if warningTimer then
				timer.cancel(warningTimer)
				warningTimer=nil
			end
			hideWarning()
			if paused then
				Runtime:removeEventListener( "touch", touchScreen )
				if impulseWings then
					Runtime:addEventListener("enterFrame",impulseWings)
				else
					vanish()
				end
				return
			end
			isShakingWings = true
			if finished then
				Runtime:removeEventListener( "touch", touchScreen )
				if impulseWings then
					Runtime:addEventListener("enterFrame",impulseWings)
				else
					vanish()
				end
				return
			end
			if event.phase == "began" then
				mary.lastTouchY = event.y
			elseif event.phase == "moved" then
				mary.lastMovementY = (event.y - mary.lastTouchY)
				
				local newPoints = points + math.abs(math.abs(mary.wing1.rotation) - math.abs(mary.lastMovementY*0.001)) * 0.15
				if (newPoints - points) > 3 then
					congratulatePlayer(true)
				elseif (newPoints - points) > 2 then
					congratulatePlayer(false)
				end
				if (newPoints - points) > 0.3 then
					local times = math.floor((newPoints-points)/0.3)
					for i = 1,times do
						if math.random(10)>5 then
							rightDrop()
						else
							leftDrop()
						end
					end
				end
				if (newPoints - points) > 0.7 then
					if math.random(5) == 1 then
						addToAcc(newPoints-points)
					end
				end
				points = newPoints
				if points >= targetPoints  and not finished then
					finished = true
					addExtras(1.5*difficultyLevel,event.x,event.y)
					unlockAchievement("com.tapmediagroup.MaryTheFairy.ManualDryer","Manual dryer","Manual dryer")
					
					if wingTouches==1 then
						unlockAchievement("com.tapmediagroup.MaryTheFairy.OneTouch","One touch dryer","One touch dryer")
					end
				end
				--echarleAguitaAlTuboEse()
				
				if (mary.wing1.rotation < minRotation and mary.lastMovementY < 0) or (mary.wing1.rotation > maxRotation  and mary.lastMovementY > 0) or (mary.wing1.rotation > minRotation and mary.wing1.rotation < maxRotation) then
					mary.wing1.rotation = mary.wing1.rotation-mary.lastMovementY*0.15
					mary.wing2.rotation = mary.wing2.rotation+mary.lastMovementY*0.15
				end
				
				mary.lastTouchY = event.y
			elseif event.phase == "ended" then
				misses = misses + 1
				
				warningTimer = timer.performWithDelay(2000,showWarning)
				isShakingWings = false
				mary.lastTouchY = nil
				
				Runtime:removeEventListener( "touch", touchScreen )
				if impulseWings then
					Runtime:addEventListener("enterFrame",impulseWings)
				end
			end
		end
		
		local function touchWings (event)
			if loseTimer then
				timer.cancel(loseTimer)
				loseTimer=nil
			end
			if warningTimer then
				timer.cancel(warningTimer)
				warningTimer=nil
			end
			if finished then
				event.target:removeEventListener( "touch", touchWings )
				return
			end
			if event.phase == "began" then
				wingTouches = wingTouches+1
				Runtime:addEventListener( "touch", touchScreen )
				Runtime:removeEventListener("enterFrame",impulseWings)
				soundController.playNew{
						path = "assets/sound/effects/cap2/watersound.mp3",
						identifier = "water",
						loops = -1,
						staticChannel = 15,
						actionTimes = nil,
						action =	nil,
						onComplete = nil
						}
			end
		end
		
		startInteraction = function()
			soundController.playNew{
						path = "assets/sound/effects/cap2/bubbles.mp3",
						identifier = "bubbles",
						staticChannel = 2,
						actionTimes = nil,
						action =	nil,
						onComplete = nil
						}
			
			startTime = system.getTimer()
			showingWarning = false
			warningTimer = timer.performWithDelay(2000,showWarning)
			
			mary.wingsGroup:addEventListener( "touch", touchWings )
			
			waterWavesInstance:play()
			
			waterContainer.isVisible = true
			transition.to(waterContainer,{alpha=1,time=300})
			
			waterWavesInstance.isVisible = true
			transition.to(waterWavesInstance,{alpha=1,time=300})
			
			waterRect.isVisible = true
			transition.to(waterRect,{alpha=1,time=300})
			
			Runtime:addEventListener("enterFrame",echarleAguitaAlTuboEse)
			
			local pausedTime = 0
			pauseIt=function()
				pausedTime = system.getTimer()
				if loseTimer then
					timer.pause(loseTimer)
				end
				mary.laughingAnimation.stop()
				waterWavesInstance:pause()
				if warningTimer then
					timer.pause(warningTimer)
				end
			end
			
			continueIt=function()
				if pausedTime ~= 0 then
					startTime = startTime + (system.getTimer() - pausedTime)
				end
				pausedTime = 0
				if loseTimer then
					timer.resume(loseTimer)
				end
				mary.laughingAnimation.start()
				waterWavesInstance:play()
				if warningTimer then
					timer.resume(warningTimer)
				end
			end
			
			pauseIt()
			continueIt()
			
			startInteraction=nil
		end
	end
	prepareInteraction()
	
	--======================================
	-- PARTY
	--======================================
	local function prepareTheParty()
		local loadingBackground = display.newImageRect("assets/world/silverGardenSky.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local gPS = require( "gPS" )
		local rdm = math.random
		
		local mGroup = display.newGroup()
		local fGroup = display.newGroup()
		localGroup:insert(mGroup)
		localGroup:insert(fGroup)
		
		local colors = {
						{193,39,45},
						{140,198,63},
						{63,255,63},
						{140,214,234},
						}
		
		local fireIt, explodeIt
		
		---------------------------------------------------------------------------------------------------------
		function fireIt()
			local star1 = { imgStart = { life = rdm(800,1000), alpha = 1, size = {1,1}, stroke={}, pos = {((display.viewableContentWidth-display.screenOriginX)*0.35)+display.screenOriginX+rdm(-50,50),height/2+rdm(-50,50),rdm(-70,70),height},color={0,0,0,255}},
							imgEnd = { onComplete = explodeIt, alpha = 1, scale ={1,1},pos={0,0,0,0,move = 1, ease = easing.outQuad}},
							imgInfo = { group = fGroup, max = 5}}
			gPS.newCircle(star1)
		end
		
		
		---------------------------------------------------------------------------------------------------------
		function explodeIt(params)
			local radius = (rdm()*3+7)*10
			local life = rdm(1000,1200)
			local colorIndex=rdm(1,#colors)
			for a = 1, 50 do
				local angle = rdm()*3.1416*2
				local radiusVariation=(rdm()*2+9)*0.1
				local onComplete
				if a==1 then
					--onComplete = fireIt
				end
				local thisLife = life*(rdm()*6+7)*0.1
				local star2 = { imgStart = { life = thisLife, alpha = 1, size = {2,2},stroke={0,0,0,0}, pos = {params.pos[1],params.pos[2],0,0},color=colors[colorIndex]},
								imgEnd = { onComplete = onComplete, alpha = 0.8, scale ={1.2,1.2},pos={math.cos(angle)*radius*radiusVariation*thisLife/life,math.sin(angle)*radius*radiusVariation*thisLife/life,0,0,move = 1, ease = easing.outQuad}},
								imgInfo = { group = mGroup, max = 150}}
				gPS.newCircle(star2)	
			end
		end
		
		local maryWings = display.newImage("assets/mary/wings.png")
		maryWings.x,maryWings.y,maryWings.xScale,maryWings.yScale = 525.75/2.5 +142 ,776.30/2.5 -60 ,(1/2.5)*0.5 ,(1/2.5)*0.5
		
		local maryBodyAndNeck = display.newImage("assets/mary/greetingAnimation/Body.png")
		maryBodyAndNeck.x,maryBodyAndNeck.y,maryBodyAndNeck.xScale,maryBodyAndNeck.yScale = 525.75/2.5 +150 ,776.30/2.5 -6 ,1/2.5 ,1/2.5
		
		local maryBody = display.newImage("assets/mary/greetingAnimation/Body_noNeck.png")
		maryBody.x,maryBody.y,maryBody.xScale,maryBody.yScale = 525.75/2.5 +150 ,776.30/2.5 -6 ,1/2.5 ,1/2.5
		
		local maryOpenEyes = display.newImage("assets/mary/greetingAnimation/eyesOpen.png")
		local maryClosedEyes = display.newImage("assets/mary/greetingAnimation/eyesClosed.png")
		
		local maryBlinks = ui.blink(maryOpenEyes,maryClosedEyes)
		
		local maryAnimation = ui.newAnimation{
						 comps = {
						 {
						  path = "assets/mary/greetingAnimation/Head.png",
						  x = { 491.25,492.7,494.15,495.45,496.9,498.3,499.7,501.15,502.6,501.3,500.05,498.7,497.45,496.2,494.95,493.7,492.35,491.15,489.9 },
						  y = { 455.3,455.2,455.05,454.95,454.8,454.75,454.65,454.65,454.55,454.65,454.7,454.75,454.75,454.9,454.95,455.05,455.2,455.4,455.55 },
						  rotation = { 0.6023406982421875,1.204559326171875,1.808258056640625,2.4115447998046875,3.0142974853515625,3.6172637939453125,4.21942138671875,4.8223876953125,5.4251556396484375,4.883148193359375,4.34027099609375,3.7974853515625,3.2548828125,2.712554931640625,2.1697540283203125,1.62744140625,1.0848388671875,0.542022705078125,0 },
						 },
						 {
						  displayObject = maryOpenEyes,
						  x = { 491.25,492.7,494.15,495.45,496.9,498.3,499.7,501.15,502.6,501.3,500.05,498.7,497.45,496.2,494.95,493.7,492.35,491.15,489.9 },
						  y = { 455.3,455.2,455.05,454.95,454.8,454.75,454.65,454.65,454.55,454.65,454.7,454.75,454.75,454.9,454.95,455.05,455.2,455.4,455.55 },
						  rotation = { 0.6023406982421875,1.204559326171875,1.808258056640625,2.4115447998046875,3.0142974853515625,3.6172637939453125,4.21942138671875,4.8223876953125,5.4251556396484375,4.883148193359375,4.34027099609375,3.7974853515625,3.2548828125,2.712554931640625,2.1697540283203125,1.62744140625,1.0848388671875,0.542022705078125,0 },
						  scaleComponent = true,
						 },
						 {
						  displayObject = maryClosedEyes,
						  x = { 491.25,492.7,494.15,495.45,496.9,498.3,499.7,501.15,502.6,501.3,500.05,498.7,497.45,496.2,494.95,493.7,492.35,491.15,489.9 },
						  y = { 455.3,455.2,455.05,454.95,454.8,454.75,454.65,454.65,454.55,454.65,454.7,454.75,454.75,454.9,454.95,455.05,455.2,455.4,455.55 },
						  rotation = { 0.6023406982421875,1.204559326171875,1.808258056640625,2.4115447998046875,3.0142974853515625,3.6172637939453125,4.21942138671875,4.8223876953125,5.4251556396484375,4.883148193359375,4.34027099609375,3.7974853515625,3.2548828125,2.712554931640625,2.1697540283203125,1.62744140625,1.0848388671875,0.542022705078125,0 },
						  scaleComponent = true,
						 },
						 {
						  path = "assets/mary/greetingAnimation/LeftArm.png",
						  x = { 583.65,583.4,583.1,582.75,582.4,582.15,581.8,581.4,581.1,581.4,581.7,582,582.35,582.6,582.85,583.2,583.4,583.7,584 },
						  y = { 656.15,656.55,656.95,657.3,657.7,658.1,658.4,658.85,659.15,658.8,658.55,658.2,657.85,657.5,657.15,656.85,656.5,656.1,655.8 },
						  rotation = { 0.5761260986328125,1.1512451171875,1.7278900146484375,2.30419921875,2.8800201416015625,3.456146240234375,4.033294677734375,4.6087646484375,5.1859130859375,4.666961669921875,4.1481170654296875,3.62945556640625,3.110198974609375,2.5921783447265625,2.07373046875,1.5558013916015625,1.0367584228515625,0.5184173583984375,0 },
						  yOffset = 30,
						  xOffset = 15
						 },
						 {
						  path = "assets/mary/greetingAnimation/RightForearm.png",
						  x = { 379.55,380.55,381.6,382.9,384.15,385.65,387.25,388.85,390.65,389.05,387.55,386.1,384.75,383.5,382.35,381.3,380.35,379.45,378.75 },
						  y = { 626.15,623.6,621.05,618.55,616.1,613.8,611.6,609.45,607.5,609.3,611.15,613.15,615.25,617.4,619.6,621.75,624.1,626.45,628.85 },
						  rotation = { 3.8175048828125,7.6357574462890625,11.453445434570313,15.27020263671875,19.087600708007813,22.905563354492188,26.723602294921875,30.54046630859375,34.358062744140625,30.9222412109375,27.487701416015625,24.051406860351563,20.615036010742188,17.180221557617188,13.742935180664063,10.307693481445313,6.871795654296875,3.4352264404296875,0 },
						  yOffset = 32,
						  xOffset = 2
						 },
						 {
						  path = "assets/mary/greetingAnimation/RightArm.png",
						  x = { 442.15,442.15,442.15,442.2,442.2,442.25,442.3,442.3,442.4,442.35,442.3,442.25,442.2,442.2,442.15,442.15,442.15,442.15,442.15 },
						  y = { 632.3,631.85,631.35,630.9,630.45,629.95,629.5,629.05,628.6,629,629.4,629.85,630.25,630.65,631.1,631.5,631.95,632.35,632.8 },
						  rotation = { 0.731719970703125,1.464080810546875,2.195953369140625,2.9271087646484375,3.6599273681640625,4.3915557861328125,5.12347412109375,5.8554534912109375,6.5881195068359375,5.9281158447265625,5.27001953125,4.6113739013671875,3.952392578125,3.293212890625,2.634918212890625,1.975921630859375,1.31640625,0.658294677734375,0 },
						  yOffset = 32,
						  xOffset = 2
						 },
						 {
						  path = "assets/mary/greetingAnimation/LeftHand.png",
						  x = { 651.7,651.35,651,650.7,650.3,649.95,649.65,649.25,648.85,649.2,649.5,649.85,650.15,650.5,650.8,651.15,651.4,651.75,652 },
						  y = { 783.1,783.9,784.7,785.4,786.15,786.95,787.7,788.45,789.15,788.5,787.8,787.2,786.5,785.8,785.15,784.4,783.75,783.05,782.3 },
						  rotation = { -0.3059844970703125,-0.611968994140625,-0.9178924560546875,-1.223785400390625,-1.531341552734375,-1.837066650390625,-2.1435699462890625,-2.4499359130859375,-2.7561798095703125,-2.4804840087890625,-2.204681396484375,-1.92877197265625,-1.653656005859375,-1.378448486328125,-1.1014404296875,-0.8261260986328125,-0.5507659912109375,-0.275390625,0 },
						  yOffset = 30,
						  xOffset = 15
						 },
						 {
						  path = "assets/mary/greetingAnimation/RightHand.png",
						  x = { 333.7,338,342.7,347.95,353.55,359.6,365.9,372.45,379.2,373.1,367.2,361.4,355.95,350.75,345.85,341.25,337.1,333.3,330 },
						  y = { 592.7,586.15,579.95,574.15,568.9,564.25,560.05,556.5,553.45,556.1,559.3,562.95,567,571.55,576.45,581.75,587.4,593.4,599.7 },
						  rotation = { 6.4828338623046875,12.967483520507813,19.451416015625,25.934951782226563,32.41908264160156,38.903656005859375,45.3875732421875,51.87184143066406,58.35560607910156,52.51963806152344,46.68363952636719,40.84889221191406,35.01301574707031,29.178131103515625,23.341827392578125,17.506027221679688,11.6707763671875,5.8347015380859375,0 },
						  yOffset = 30
						 }
						},
						 x = 150,
						 y = -15,
						 scale = 1/2.5,
						 speed = 0.75
						}
						
		maryWings.isVisible = false
		maryBody.isVisible = false
		maryBodyAndNeck.isVisible = false
		maryAnimation.hide()
		
		local maryGroup = display.newGroup()
		maryGroup:insert(maryWings)
		maryGroup:insert(maryBodyAndNeck)
		maryGroup:insert(maryBody)
		maryGroup:insert(maryAnimation.displayObject)
		
		localGroup:insert(maryGroup)
		maryGroup.xScale, maryGroup.yScale = 1.25,1.25
		maryGroup.y = maryGroup.y + 225
		maryGroup.x = maryGroup.x - 130
		maryGroup.rotation = -30
		
		local winSound = audio.loadSound("assets/sound/win.mp3")
		local winSoundChannel
		
		local function continue()
			localGroup:remove(loadingBackground)
			localGroup:remove(message)
			
			maryBlinks.stopBlinking()
			maryAnimation.kill()
			
			localGroup:remove(maryGroup)
			
			continue=nil
			killTheParty=nil
		end
		killTheParty = function()
			startTheParty =nil
			vanish=nil
			continue()
		end
		
		local fireTimer = nil
		local function vanish()
			timer.performWithDelay(300, continue)
		end
		
		startTheParty = function()
			pauseIt = nil
			continueIt = nil
			
			saveData(2,3)
			
			soundController.kill("water")
			soundController.kill("bgsound")
			soundController.playNew{
						path = "assets/sound/voices/cap2/int2_MThanksDry.mp3",
						duration = 4000,
						actionTimes = {0},
						action =	function()
									end,
						onComplete = function()
									end
						}
						
			winSoundChannel = audio.play(winSound,{loops=0})
			
			local function continueToNextScene()
				startTransition(false)
				timer.cancel(fireTimer)
				fireTimer=nil
				timer.performWithDelay(1500, vanish)
			end
			
			local function repeatThisScene()
				startTransition(true)
				timer.cancel(fireTimer)
				fireTimer=nil
				timer.performWithDelay(1500, vanish)
			end
			
			local points = calculatePoints(misses, extras, startTime, finishTime, difficultyLevel, "com.tapmediagroup.drywings")
			
			director:openPopUp({points = points,
								hideAction = continueToNextScene,
								repeatAction = repeatThisScene,
								killCaller = killAll
								},
								"pointsView")
			
			maryAnimation.start()
			maryAnimation.appear(300)
			
			maryBlinks.openEyes()
			maryBlinks.startBlinking()
			
			loadingBackground.isVisible = true
			maryWings.isVisible = true
			maryBody.isVisible = true
			maryBodyAndNeck.isVisible = true
			
			loadingBackground.alpha = 0
			maryWings.alpha = 0
			maryBody.alpha = 0
			maryBodyAndNeck.alpha = 0
			
			transition.to(loadingBackground,{alpha=1,time=300})
			transition.to(maryWings,{alpha=1,time=300})
			transition.to(maryBody,{alpha=1,time=300})
			transition.to(maryBodyAndNeck,{alpha=1,time=300})
			
			local function newBomb()
				fireIt()
				fireTimer = timer.performWithDelay(500, newBomb )
			end
			fireTimer = timer.performWithDelay(500, newBomb )
		end
	end
	prepareTheParty()
	
	--======================================
	-- TRANSITION TO INTERACTIVITY
	--======================================
	local function prepareTransition()
		local star1 = display.newImage("assets/whiteStar.png")
		star1:setReferencePoint(display.TopLeftReferencePoint)
		star1.x = 10
		star1.y = 20
		star1.xScale = 0.1
		star1.yScale = 0.1
		star1.isVisible = false
		star1:setReferencePoint(display.CenterReferencePoint)
		localGroup:insert(star1)
		
		local star2 = display.newImage("assets/whiteStar.png")
		star2:setReferencePoint(display.CenterReferencePoint)
		star2.x = 350
		star2.y = 40
		star2.xScale = 0.5
		star2.yScale = 0.5
		star2.isVisible = false
		localGroup:insert(star2)
		
		local star3 = display.newImage("assets/whiteStar.png")
		star3:setReferencePoint(display.CenterReferencePoint)
		star3.x = 320
		star3.y = 300
		star3.xScale = 0.05
		star3.yScale = 0.05
		star3.isVisible = false
		localGroup:insert(star3)
		
		local star4 = display.newImage("assets/whiteStar.png")
		star4:setReferencePoint(display.CenterReferencePoint)
		star4.x = 30
		star4.y = 280
		star4.xScale = 0.2
		star4.yScale = 0.2
		star4.isVisible = false
		localGroup:insert(star4)
		
		star1:setFillColor(193,39,45)
		star2:setFillColor(140,198,63)
		star3:setFillColor(140,214,234)
		star4:setFillColor(255,255,0)
		
		killTransition = function()
			changeScene=nil
			loadInteraction=nil
			continue=nil
			vanish=nil
			startTransition =nil
			killTransition=nil
			
			localGroup:remove(star1)
			localGroup:remove(star2)
			localGroup:remove(star3)
			localGroup:remove(star4)
		end
		
		local repeatInteraction
		
		local function repeatScene()
			director:changeScene("Interactivity2","crossFade")
			repeatScene=nil
		end
		
		local function changeScene()
			adPreloader:changeScene("Adventure3","crossFade")
			--director:changeScene("Adventure3","crossFade")
			changeScene=nil
		end
		
		local function loadInteraction()
			localGroup:remove(star1)
			localGroup:remove(star2)
			localGroup:remove(star3)
			localGroup:remove(star4)
			
			if repeatInteraction then
				timer.performWithDelay(500, repeatScene)
			else
				timer.performWithDelay(500, changeScene)
			end
			
			loadInteraction=nil
		end
		
		local function continue()
			local whiteBackground
			if repeatInteraction then
				whiteBackground = display.newRect(0,0,width,height)
				whiteBackground:setFillColor(255,255,255)
			else
				whiteBackground = display.newImageRect("assets/world/fairiesTownBlurred.jpg",width,height)
				whiteBackground:setReferencePoint(display.TopLeftReferencePoint)
				whiteBackground.x = 0
				whiteBackground.y = 0
			end
			whiteBackground:setFillColor(255,255,255)
			whiteBackground.alpha=0
			localGroup:insert(whiteBackground)
			transition.to(whiteBackground,{alpha=1,time=1000,onComplete=loadInteraction})
			continue=nil
		end
		
		local growStars
		
		local function vanish()
			continue()
			vanish=nil
		end
		
		startTransition = function(shouldRepeat)
			if shouldRepeat then repeatInteraction = shouldRepeat end
			
			star1.isVisible = true
			star2.isVisible = true
			star3.isVisible = true
			star4.isVisible = true
			
			star1.alpha = 0
			star2.alpha = 0
			star3.alpha = 0
			star4.alpha = 0
			
			local function animateStars()
				transition.to(star1,{alpha=1,time=700})
				transition.to(star2,{alpha=1,time=700})
				transition.to(star3,{alpha=1,time=700})
				transition.to(star4,{alpha=1,time=700})
				
				transition.to(star1,{xScale=3,yScale=3,		time=1500,transition=easing.inExpo})
				transition.to(star2,{xScale=2.5,yScale=2.5,	time=1500,transition=easing.inExpo})
				transition.to(star3,{xScale=2,yScale=2,		time=1500,transition=easing.inExpo})
				transition.to(star4,{xScale=3.5,yScale=3.5,	time=1500,transition=easing.inExpo})
			end
			timer.performWithDelay(200, animateStars)
			
			timer.performWithDelay(500, vanish)
			startTransition=nil
		end
	end
	prepareTransition()
	
	--====================================================================--
	-- SET UP A PAUSE OVERLAY
	--====================================================================--
	overlay = display.newRect(0,0,width,height)
	overlay:setFillColor(0,0,0,64)
	overlay.alpha=0
	localGroup:insert(overlay)
	
	gameOver = function()
		if overlay then
			transition.to( overlay, { alpha=1, time=300, delay=0 } )
		end
		director:openPopUp({hideAction = restartIt,
							killCaller = killAll,
							},
							"goMenu")
	end
	
	--======================================
	-- MENU BUTTON
	--======================================
	-- ACTION
	local continueTimer
	local function continueGame( event )
		paused=false;
		if continueIt then
			screenMessages.resume()
			continueIt()
			soundController.resume()
		end
    end
	local hideMenu = function ()
		if overlay then
			transition.to( overlay, { alpha=0, time=300, delay=0 } )
		end
		continueTimer = timer.performWithDelay(300, continueGame )
	end
	local menuButtonAction = function ( event )
		if event.phase == "release" then
			if continueTimer then
				timer.cancel(continueTimer)
			end
			if pauseIt and continueIt then
				screenMessages.pause()
				paused=true
				pauseIt()
				soundController.pause()
				if overlay then
					transition.to( overlay, { alpha=1, time=300, delay=0 } )
				end
				director:openPopUp({inGame = true,
									animated = true,
									hideAction = hideMenu,
									startFromAdventure = nil,
									killCaller = killAll,
									},
									"igMenu")
			end
		end
	end
	local function systemEvent(event)
		if event.type == "applicationSuspend" and not paused then
			menuButtonAction({phase="release"})
		end
	end
	Runtime:addEventListener( "system", systemEvent )
	-- UI ELEMENT
	local menuButton = ui.newButton{
					default = "assets/botonMenu.png",
					onEvent = menuButtonAction,
					text = "Menu",
					size = 72,
					font = mainFont1,
					emboss = true,
					textColor={66,33,11,255},
					id = "bt01"}
	menuButton:setReferencePoint(display.CenterRightReferencePoint)
	menuButton.x=display.screenOriginX+display.viewableContentWidth-15
	menuButton.y=display.screenOriginY+25
	menuButton.xScale,menuButton.yScale=0.45,0.45
	localGroup:insert(menuButton)
	
	screenMessages.sendToFront()
	overlay:toFront()
	
	--======================================
	-- EXECUTE FIRST ACTION, THEY WILL BE CHAINEXECUTED
	--======================================
	startAdventure()
	
	return localGroup
end