module(..., package.seeall)

local function restartIt()
	preloader:changeScene("Interactivity1","crossfade")
end

new = function ( params )
	soundController.killAll()
	
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
	
	------------------
	-- Variables
	------------------
	local width = display.contentWidth
	local height = display.contentHeight
	
	local basketFrontPath = ""
	basketFrontPath = "assets/interactivity1/basket/1f.png"
	
	local basketBackPath = ""
	basketBackPath = "assets/interactivity1/basket/1b.png"
	
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
	
	local gameOver
	local pauseIt
	local continueIt
	
	local function killAll()
		paused = nil
		gameOver = nil
		pauseIt = nil
		continueIt = nil
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
		
		local titleLabel = util.centeredWrappedText("Adventure 1\nCatch all the funny animals", 30, 36, mainFont1, {67,34,15,255})
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
						path = "assets/sound/voices/cap1/int1_N1.mp3",
						actionTimes = {4500},
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
	
	--======================================
	-- DEMO LOOP
	--======================================
	local function prepareDemoLoop()
		local started = false
		
		local loadingBackground = display.newImageRect("assets/world/silverGarden.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = -75
		localGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local basketBack = display.newImage(basketBackPath)
		basketBack:setReferencePoint(display.CenterReferencePoint)
		basketBack.xScale,basketBack.yScale = 0.3,0.3
		basketBack.x = width/2
		basketBack.y = height/2 + 20
		localGroup:insert(basketBack)
		basketBack.isVisible = false
		
		local animalImage = display.newImage("assets/interactivity1/caughtAnimals/cat.png")
		animalImage:setReferencePoint(display.TopCenterReferencePoint)
		animalImage.x = width/2 + math.random(-40,40)
		animalImage.y = height/2 + 20 + math.random(85,100) - 150
		animalImage.xScale,animalImage.yScale = 0.25,0.25
		animalImage.alpha = 0
		localGroup:insert(animalImage)
		
		local basketFront = display.newImage(basketFrontPath)
		basketFront:setReferencePoint(display.CenterReferencePoint)
		basketFront.xScale,basketFront.yScale = 0.3,0.3
		basketFront.x = width/2
		basketFront.y = height/2 + 20
		localGroup:insert(basketFront)
		basketFront.isVisible = false
		
		local openEyesR = nil
		local closedEyesR = nil
		
		local openEyesC = nil
		local closedEyesC = nil
		
		openEyesR = display.newImage("assets/cat/EyesOpen.png")
		closedEyesR = display.newImage("assets/cat/EyesClosed.png")
		
		openEyesC = display.newImage("assets/catCaught/EyesOpen.png")
		closedEyesC = display.newImage("assets/catCaught/EyesClosed.png")
		
		local runningAnimal = ui.newAnimation{
					comps = {
						{
							--tail
							path = "assets/cat/tail.png",
							x = { 37.85,36,40.05,44.4,49.15,50.5,51.95,47.8,43.75,39.95 },
							y = { 115.75,117.15,112.1,107.35,103.1,103.25,103.6,107.1,110.8,114.8 },
							rotation = { -33.51014709472656,-39.37852478027344,-33.28041076660156,-27.186904907226563,-21.088394165039063,-16.932525634765625,-12.77471923828125,-17.72918701171875,-22.685623168945313,-27.640914916992188 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--larm
							path = "assets/cat/larm.png",
							x = { 219.4,213.95,208.65,203.65,199.1,203.65,208.7,213.95,219.4,224.8 },
							y = { 207.4,209,209.4,208.9,207.35,208.9,209.35,209,207.4,204.8 },
							rotation = { 29.1588134765625,40.210479736328125,51.26298522949219,62.31587219238281,73.36959838867188,62.31587219238281,51.26298522949219,40.20997619628906,29.1588134765625,18.10516357421875 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--lleg
							path = "assets/cat/lleg.png",
							x = { 67.4,70.75,74.35,78.25,82.3,78.2,74.35,70.7,67.35,64.4 },
							y = { 203.65,204.75,205.5,205.85,205.75,205.85,205.45,204.75,203.65,202.2 },
							rotation = { -66.32954406738281,-73.04988098144531,-79.77272033691406,-86.49421691894531,-93.21566772460938,-86.49334716796875,-79.77102661132813,-73.05067443847656,-66.32881164550781,-59.60957336425781 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--body
							path = "assets/cat/body.png",
							x = { 152.3,152.7,153.2,153.7,154.2,153.7,153.2,152.7,152.3,151.8 },
							y = { 167.15,167.35,167.5,167.7,167.85,167.7,167.5,167.3,167.1,167.05 },
							rotation = { -26.330978393554688,-25.020858764648438,-23.708572387695313,-22.398513793945313,-21.087631225585938,-22.398513793945313,-23.710769653320313,-25.019424438476563,-26.332382202148438,-27.642974853515625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/cat/head.png",
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							--rleg
							path = "assets/cat/rleg.png",
							x = { 90.8,86.05,81.65,77.65,74.4,77.65,81.6,85.95,90.8,96 },
							y = { 227.9,224.85,221.1,216.65,211.65,216.65,221.1,224.85,227.85,230.25 },
							rotation = { -41.13728332519531,-32.019866943359375,-22.901107788085938,-13.7841796875,-4.6634979248046875,-13.7841796875,-22.900375366210938,-32.01924133300781,-41.137786865234375,-50.25514221191406 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rarm
							path = "assets/cat/rarm.png",
							x = { 167.1,170.55,175.9,181.05,185.7,180.1,173.95,170.5,167.05,163.55 },
							y = { 236.25,236.65,236.1,234.7,232.3,235.1,236.65,236.7,236.3,235.35 },
							rotation = { 11.56005859375,4.7555389404296875,-5.5282440185546875,-15.8106689453125,-26.093826293945313,-14.074081420898438,-2.0536346435546875,4.7529296875,11.559219360351563,18.366195678710938 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						}
					},
					scale = 0.3 * 1.666,
					speed = 0.2
				}
		local caughtAnimal = ui.newAnimation{
					comps = {
						{
							--body
							path = "assets/catCaught/body.png",
							x = { 290.6,290.6,290.6,290.6,290.6,290.6,290.6,290.6,290.6,290.6 },
							y = { 260.7,259.3,257.9,256.5,255.1,256.45,257.9,259.25,260.7,262.05 },
							rotation = { 0,0,0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--tail
							path = "assets/catCaught/tail.png",
							x = { 277.25,278,278.8,279.7,280.55,279.7,278.8,278,277.25,276.45 },
							y = { 397.85,396.9,396,395,394,395,396,396.9,397.85,398.75 },
							rotation = { 6.66058349609375,4.996826171875,3.3306884765625,1.665008544921875,0,1.665008544921875,3.3306884765625,4.996826171875,6.66058349609375,8.326812744140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--larm
							path = "assets/catCaught/larm.png",
							x = { 336.4,337.2,338.1,338.95,339.75,338.95,338.1,337.2,336.4,335.5 },
							y = { 210.45,208.85,207.15,205.55,203.85,205.55,207.15,208.85,210.45,212 },
							rotation = { -1.978546142578125,-3.9550018310546875,-5.934173583984375,-7.9121246337890625,-9.889083862304688,-7.9121246337890625,-5.934173583984375,-3.9550018310546875,-1.978546142578125,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rarm
							path = "assets/catCaught/rarm.png",
							x = { 245.3,244.5,243.8,243.1,242.35,243.1,243.8,244.5,245.3,246.05 },
							y = { 211.25,209.75,208.3,206.8,205.15,206.8,208.3,209.75,211.25,212.65 },
							rotation = { 2.0492706298828125,4.0976715087890625,6.1442718505859375,8.192398071289063,10.240829467773438,8.192398071289063,6.1442718505859375,4.0976715087890625,2.0492706298828125,0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/catCaught/head.png",
							x = { 288.1,289,289.85,290.7,291.55,290.7,289.85,289,288.1,287.35 },
							y = { 126.05,124.6,123.2,121.85,120.5,121.85,123.2,124.6,126.05,127.45 },
							rotation = { 0.8741912841796875,1.749725341796875,2.6253204345703125,3.49969482421875,4.3733062744140625,3.49969482421875,2.6253204345703125,1.749725341796875,0.8741912841796875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesC,
							scaleComponent = true,
							x = { 288.1,289,289.85,290.7,291.55,290.7,289.85,289,288.1,287.35 },
							y = { 126.05,124.6,123.2,121.85,120.5,121.85,123.2,124.6,126.05,127.45 },
							rotation = { 0.8741912841796875,1.749725341796875,2.6253204345703125,3.49969482421875,4.3733062744140625,3.49969482421875,2.6253204345703125,1.749725341796875,0.8741912841796875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesC,
							scaleComponent = true,
							x = { 288.1,289,289.85,290.7,291.55,290.7,289.85,289,288.1,287.35 },
							y = { 126.05,124.6,123.2,121.85,120.5,121.85,123.2,124.6,126.05,127.45 },
							rotation = { 0.8741912841796875,1.749725341796875,2.6253204345703125,3.49969482421875,4.3733062744140625,3.49969482421875,2.6253204345703125,1.749725341796875,0.8741912841796875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--lleg
							path = "assets/catCaught/lleg.png",
							x = { 343.35,342.75,342.1,341.4,340.75,341.4,342.1,342.75,343.35,344 },
							y = { 347.75,346.55,345.2,343.9,342.6,343.9,345.2,346.55,347.75,349 },
							rotation = { 1.2342681884765625,2.469146728515625,3.7043304443359375,4.938690185546875,6.1736602783203125,4.938690185546875,3.7043304443359375,2.469146728515625,1.2342681884765625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rleg
							path = "assets/catCaught/rleg.png",
							x = { 239.6,240.1,240.55,241.05,241.5,241.05,240.55,240.1,239.6,239.15 },
							y = { 356.4,355.05,353.65,352.3,350.9,352.3,353.65,355.05,356.4,357.75 },
							rotation = { -0.88818359375,-1.7768096923828125,-2.664581298828125,-3.5536956787109375,-4.4410858154296875,-3.5536956787109375,-2.664581298828125,-1.7768096923828125,-0.88818359375,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						}
					},
					x = -150*0.3,
					scale = 0.3*1.666,
					speed = 0.5
				}
		
		local RBlinks = ui.blink(openEyesR,closedEyesR)
		local CBlinks = ui.blink(openEyesC,closedEyesC)
		
		localGroup:insert(runningAnimal.displayObject)
		runningAnimal.hide()
		
		localGroup:insert(caughtAnimal.displayObject)
		caughtAnimal.hide()
		
		runningAnimal.displayObject:setReferencePoint(display.CenterReferencePoint)
		runningAnimal.displayObject.y = 150
		runningAnimal.displayObject.x = width - 100
		runningAnimal.displayObject.xScale = -1
		
		caughtAnimal.displayObject:setReferencePoint(display.CenterReferencePoint)
		
		local handComponent = {
							path = "assets/hand.png",
							x = { 820.05,821,821.6,821.8,821.75,821.35,820.7,819.8,818.65,817.3,815.7,813.9,811.95,809.8,804.5,797.9,791,784.2,777.25,770.35,763.5,756.6,749.75,742.85,736,729.15,722.3,715.45,708.65,701.8,694.95,688.1,681.3,674.45,667.6,660.8,653.95,647.1,640.25,633.45,626.6,619.75,612.9,606.05,599.2,592.35,585.45,578.6,571.75,564.85,558,551.1,544.2,537.35,530.45,523.55,516.7,509.85,503.05,496.45,490.2,484.95,481.95,482,479.95,479.55,479.9,480.65,481.55,482.6,483.7,484.8,485.85,486.8,487.6,488.1,488,486.5,482,476.25,472.25,469.65,467.95,466.95,466.45,466.4,466.75,467.55,468.75,470.35,472.45,475.1,478.25,482,484.5,488.7,494.1,500.05,506.45,513.1,519.9,526.75,533.75,540.75,547.8,554.85,561.95,569.1,576.2,583.35,590.5,597.65,604.8,611.95,619.15,626.3,633.45,640.6,647.75,654.9,662.05,669.2,676.35,683.5,690.6,697.75,704.85,711.95,719.05,726.15,733.2,740.25,747.3,754.3,761.3,768.25,775.2,782.05,788.85,795.6,802.15,808.4,814.25,818.7,820.8,822.7,824.3,825.7,826.8,827.55,828,828.1,827.85,827.25,826.3,825,823.3,821.2,818.7 },
							y = { 333.65,329.3,324.9,320.45,316,311.6,307.2,302.8,298.5,294.25,290.1,286.05,282.05,278.1,274,272.1,271.2,270.8,270.75,270.85,271.15,271.6,272.1,272.7,273.35,274.05,274.8,275.6,276.4,277.2,278.05,278.9,279.75,280.6,281.5,282.35,283.2,284.05,284.9,285.75,286.55,287.3,288.1,288.8,289.5,290.2,290.8,291.35,291.85,292.3,292.65,292.95,293.1,293.15,293,292.7,292.15,291.3,290,288.05,285.2,280.8,274.7,267.8,272.85,278.45,284.1,289.65,295.2,300.7,306.15,311.65,317.15,322.65,328.2,333.8,339.35,344.75,347.8,346.35,341.95,336.55,330.75,324.7,318.65,312.6,306.6,300.6,294.65,288.85,283.15,277.7,272.55,267.8,261.15,255.4,250.6,246.75,243.5,240.8,238.5,236.5,234.8,233.35,232.1,231,230.1,229.3,228.65,228.1,227.7,227.35,227.1,226.95,226.9,226.9,227,227.15,227.4,227.75,228.1,228.55,229.1,229.7,230.35,231.1,231.9,232.8,233.75,234.8,235.95,237.15,238.5,239.9,241.5,243.15,245,247.05,249.3,251.85,254.75,258.15,262.35,267.8,272.25,276.75,281.35,286.05,290.9,295.7,300.55,305.45,310.3,315.15,319.95,324.65,329.25,333.65,337.8 },
							scale = 0.7,
						}
		local handAnimation = ui.newAnimation{
					comps = {
						handComponent,
					},
					scale = 0.5,
					speed = 0.5,
				}
				
		localGroup:insert(handAnimation.displayObject)
		handAnimation.hide()
		
		local whiteSquare = display.newImageRect("assets/pedazoDeMadera.png",width,95.5)
		whiteSquare:setReferencePoint(display.TopLeftReferencePoint)
		whiteSquare.x,whiteSquare.y=0,display.screenOriginY+display.viewableContentHeight-95
		localGroup:insert(whiteSquare)
		whiteSquare.isVisible = false
		
		local function prepareHandAnimation()
			local alive = true
			
			local function moveRunning()
				if paused then return end
				if not runningAnimal then Runtime:removeEventListener("enterFrame",moveRunning);return end
				if not runningAnimal.displayObject then Runtime:removeEventListener("enterFrame",moveRunning);return end
				if runningAnimal.displayObject.x > width-100 then
					runningAnimal.displayObject.x = runningAnimal.displayObject.x - 0.5
				else
					Runtime:removeEventListener("enterFrame",moveRunning)
				end
			end
			
			local function animateHand()
				if paused then return end
				if handAnimation.getActualFrame() >= 0 and handAnimation.getActualFrame() <=80 then
					caughtAnimal.displayObject.x = handComponent.displayObject.x - 20
					caughtAnimal.displayObject.y = handComponent.displayObject.y - 30
					
					if not caughtAnimal.isMoving and not started then
						caughtAnimal.start()
						caughtAnimal.show()
						
						runningAnimal.stop()
						runningAnimal.hide()
						
						if RBlinks then
							RBlinks.openEyes()
							RBlinks.stopBlinking()
						end
						if CBlinks then
							CBlinks.openEyes()
							CBlinks.startBlinking()
						end
					end
				else 
					if caughtAnimal.isMoving and not started then
						caughtAnimal.stop()
						caughtAnimal.hide()
						
						runningAnimal.appear(500)
						runningAnimal.start()
						
						if RBlinks then
							RBlinks.openEyes()
							RBlinks.startBlinking()
						end
						if CBlinks then
							CBlinks.openEyes()
							CBlinks.stopBlinking()
						end
						
						animalImage.x = basketBack.x + math.random(-40,40)
						animalImage.y = basketBack.y + math.random(85,100) - 150
						transition.from(animalImage,{alpha = 1,time = 1500,transition = easing.inExpo})
						runningAnimal.displayObject.x = width
						Runtime:addEventListener("enterFrame",moveRunning)
					end
				end
			end
			
			startHandAnimation = function ()
				if alive then
					handAnimation.start()
					if RBlinks then
						RBlinks.openEyes()
						RBlinks.startBlinking()
					end
					if CBlinks then
						CBlinks.openEyes()
						CBlinks.stopBlinking()
					end
					Runtime:addEventListener("enterFrame",animateHand)
				end
			end
			
			stopHandAnimation = function ()
				handAnimation.stop()
				Runtime:removeEventListener("enterFrame",animateHand)
			end
			
			killHandAnimation = function ()
				alive = false
				handAnimation.kill()
				stopHandAnimation()
			end
		end
		prepareHandAnimation()
		
		local function continue()
			killHandAnimation()
			
			handAnimation = nil
			handComponent = nil
			
			runningAnimal.kill()
			runningAnimal = nil
			
			caughtAnimal.kill()
			caughtAnimal = nil
			
			openEyesR = nil
			closedEyesR = nil
			
			openEyesC = nil
			closedEyesC = nil
			
			localGroup:remove(animalImage)
			localGroup:remove(loadingBackground)
			localGroup:remove(whiteSquare)
			
			animalImage = nil
			loadingBackground = nil
			whiteSquare = nil
			
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
		
		local someInfoText = "Help Mary to catch the funny animals that escape from the Palace Garden. TAP on each animal to catch it. DRAG and DROP it into the Basket."
		
		local infoDisplayObject = util.wrappedText(someInfoText, 55, 16, mainFont1, {67,34,15,255})
		infoDisplayObject.y=whiteSquare.y+whiteSquare.contentHeight*5/9-infoDisplayObject.contentHeight/2 - 0
		infoDisplayObject.x=startButton.x+startButton.contentWidth/2+20
		infoDisplayObject.isVisible=false
		localGroup:insert(infoDisplayObject)
		
		local result
		vanish = function()
			pauseIt = nil
			continueIt = nil
			
			transition.to(whiteSquare,{y=height, time = 550})
			transition.to(startButton,{alpha=0,y=startButton.y+whiteSquare.contentHeight,time=550})
			transition.to(infoDisplayObject,{alpha=0,y=infoDisplayObject.y+whiteSquare.contentHeight,time=550})
			
			transition.to(basketBack,{y=basketBack.y+75,time=500})
			transition.to(basketFront,{y=basketFront.y+75,time=500})
			transition.to(animalImage,{y=animalImage.y+75,time=500})
			transition.to(loadingBackground,{y=0,time = 500})
			
			runningAnimal.vanish(300)
			caughtAnimal.vanish(300)
			handAnimation.vanish(300)
			
			timer.performWithDelay(1000, startInteraction)
			timer.performWithDelay(1500, continue)
			
			vanish = nil
		end
		
		startDemoLoop = function()
			basketBack.isVisible = true
			basketFront.isVisible = true
			
			loadingBackground.isVisible = true
			
			basketBack.alpha = 0
			basketFront.alpha = 0
			loadingBackground.alpha = 0
			
			transition.to(basketBack,{alpha=1,time=300})
			transition.to(basketFront,{alpha=1,time=300})
			transition.to(loadingBackground,{alpha=1,time=300})
			
			handAnimation.appear(300)
			
			whiteSquare.isVisible = true
			whiteSquare.alpha = 0
			startButton.isVisible = true
			infoDisplayObject.isVisible = true
			startButton.alpha=0
			infoDisplayObject.alpha=0
			
			transition.to(startButton,{alpha=1,time=300})
			transition.to(infoDisplayObject,{alpha=1,time=300})
			transition.to(whiteSquare,{alpha=1,time=300})
			
			startHandAnimation()
			
			pauseIt = function()
				handAnimation.stop()
				
				if runningAnimal.isMoving then
					runningAnimal.wasMoving = true
					runningAnimal.stop()
					RBlinks.stopBlinking()
				end
				if caughtAnimal.isMoving then
					caughtAnimal.wasMoving = true
					caughtAnimal.stop()
					CBlinks.stopBlinking()
				end
			end
			
			continueIt = function()
				handAnimation.start()
				
				if runningAnimal.wasMoving then
					runningAnimal.wasMoving = nil
					runningAnimal.start()
					RBlinks.startBlinking()
				end
				if caughtAnimal.wasMoving then
					caughtAnimal.wasMoving = nil
					caughtAnimal.start()
					CBlinks.startBlinking()
				end
			end
			
			startDemoLoop = nil
		end
	end
	prepareDemoLoop()
	
	--====================================================================--
	-- INTERACTION
	--====================================================================--
	local function prepareInteraction()
		local loadingBackground = display.newImageRect("assets/world/silverGarden.jpg",width,height)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		loadingBackground.isVisible = false
		
		local basketBack = display.newImage(basketBackPath)
		basketBack:setReferencePoint(display.CenterReferencePoint)
		basketBack.xScale,basketBack.yScale = 0.3,0.3
		basketBack.x = width/2
		basketBack.y = height/2 + 20 + 75
		basketBack.isVisible = false
		
		local kidnappedAnimalsGroup = display.newGroup()
		
		local basketFront = display.newImage(basketFrontPath)
		basketFront:setReferencePoint(display.CenterReferencePoint)
		basketFront.xScale,basketFront.yScale = 0.3,0.3
		basketFront.x = width/2
		basketFront.y = height/2 + 20 + 75
		basketFront.isVisible = false
		
		local animalLimit = (difficultyLevel==1 and 10) or (difficultyLevel==2 and 15) or (difficultyLevel==3 and 15) or (difficultyLevel<1 and 10) or (difficultyLevel>3 and 15)
		local timeLimit = (difficultyLevel==1 and 60) or (difficultyLevel==2 and 40) or (difficultyLevel==3 and 20) or (difficultyLevel<1 and 60) or (difficultyLevel>3 and 20)
		
		local timeLeft = timeLimit
		
		local finished = false
		local kidnappedAnimalsCount = 0
		local vanish
		local showPoints
		
		local kidnapTimes = {}
		local kidnappedCats = 0
		local kidnappedDogs = 0
		local kidnappedRabbits = 0
		local kidnappedFrogs = 0
		
		local isCongratulatingPlayer = false
		local function congratulatePlayer(special)
			if not isCongratulatingPlayer then
				isCongratulatingPlayer = true
				local function completeFunction()
					timer.performWithDelay(3000,function() isCongratulatingPlayer = false; end)
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
		
		local isCheeringUpPlayer = false
		local firstCheerUp = true
		local function cheerUpPlayer()
			if not isCheeringUpPlayer then
				isCheeringUpPlayer = true
				local function completeFunction()
					timer.performWithDelay(5000,function() isCheeringUpPlayer = false; end)
				end
				
				if firstCheerUp or math.random(2) == 1 then
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/catchAnimal.mp3",
									onComplete = completeFunction
									}
					firstCheerUp = false
				else
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/comeOn.mp3",
									onComplete = completeFunction
									}
				end
			end
		end
		local function checkPlayerActivity()
			if #kidnapTimes<=0 then
				if startTime then
					if system.getTimer() - startTime > 3000 then
						cheerUpPlayer()
					end
				end
			else
				if system.getTimer() - kidnapTimes[#kidnapTimes] > 3000 then
					cheerUpPlayer()
				end
			end
		end
		
		local function kidnapAnimal(ID)
			local animalPath = ""
			if ID == 1 then
				animalPath = "assets/interactivity1/caughtAnimals/cat.png"
				kidnappedCats = kidnappedCats + 1
			elseif ID == 2 then
				animalPath = "assets/interactivity1/caughtAnimals/dog.png"
				kidnappedDogs = kidnappedDogs + 1
			elseif ID == 3 then
				animalPath = "assets/interactivity1/caughtAnimals/rabbit.png"
				kidnappedRabbits = kidnappedRabbits + 1
			elseif ID == 4 then
				animalPath = "assets/interactivity1/caughtAnimals/frog.png"
				kidnappedFrogs = kidnappedFrogs + 1
			end
			animalImage = display.newImage(animalPath)
			animalImage.x = basketBack.x + math.random(-40,40)
			animalImage.y = basketBack.y + math.random(85,100)
			animalImage:setReferencePoint(display.TopCenterReferencePoint)
			animalImage.xScale,animalImage.yScale = 0.25,0.25
			kidnappedAnimalsGroup:insert(animalImage)
			
			kidnapTimes[#kidnapTimes + 1] = system.getTimer()
			
			if math.floor(animalLimit/3) == kidnappedAnimalsCount then
				congratulatePlayer()
			elseif math.floor(animalLimit*2/3) == kidnappedAnimalsCount then
				congratulatePlayer()
			end
			
			----------------------------
			--ACHIEVEMENTS
			----------------------------
			--5 in 3
			if #kidnapTimes >= 5 then
				if kidnapTimes[#kidnapTimes] - kidnapTimes[#kidnapTimes-4] < 3000 then
					addExtras("5 in 3",4,animalImage.x,animalImage.y)
					unlockAchievement("com.tapmediagroup.MaryTheFairy.5in3","5 in 3","5 in 3")
					congratulatePlayer()
				end
				if kidnapTimes[#kidnapTimes] - kidnapTimes[#kidnapTimes-4] < 2000 then
					congratulatePlayer(true)
				end
			end
			--COLLECTOR
			if kidnappedCats == 1 and kidnappedDogs == 1 and kidnappedFrogs == 1 and kidnappedRabbits == 1 then
				addExtras("Collector",3,animalImage.x,animalImage.y)
				unlockAchievement("com.tapmediagroup.MaryTheFairy.Collector","Collector","Collector")
				congratulatePlayer()
			end
			--NOAH
			if kidnappedCats == 2 and kidnappedDogs == 2 and kidnappedFrogs == 2 and kidnappedRabbits == 2 then
				addExtras("Noah",6,animalImage.x,animalImage.y)
				unlockAchievement("com.tapmediagroup.MaryTheFairy.Noah","Noah","Noah")
				congratulatePlayer(true)
			end
			if kidnappedAnimalsCount >= animalLimit then
				--FINISHED (DON'T RUN AWAY)
				unlockAchievement("com.tapmediagroup.MaryTheFairy.DontRun","Don't run away","Don't run away")
				--NO MISTAKES
				if misses == 0 then
					addExtras("No Mistakes", (3^difficultyLevel), width/2, height/2)
					--NO MISTAKES (HARD)
					if difficultyLevel == 3 then
						unlockAchievement("com.tapmediagroup.MaryTheFairy.adv1NoMistakesHard","Adv 1 No Mistakes - Hard","Don't miss any funny animal -  Hard difficulty")
					end
				end
				--EXCLUSIVE
				if kidnappedCats == kidnappedAnimalsCount or kidnappedCats == kidnappedAnimalsCount or kidnappedCats == kidnappedAnimalsCount or kidnappedCats == kidnappedAnimalsCount then
					addExtras("Exclusive",(kidnappedAnimalsCount * difficultyLevel * 1.5), animalImage.x, animalImage.y)
					unlockAchievement("com.tapmediagroup.MaryTheFairy.Exclusive","Exclusive","Exclusive")
				end
				--LAST SECOND
				if timeLeft <= 1 then
					addExtras("Last Second",10,animalImage.x,animalImage.y)
					unlockAchievement("com.tapmediagroup.MaryTheFairy.Last Second","Last Second","Last Second")
				end
			end
			
			----------------------------
			--WINNING CONDITION
			----------------------------
			if kidnappedAnimalsCount >= animalLimit then
				if not finished then
					vanish()
				end
				finished = true
			end
			
			showPoints()
		end
		
		local function releaseAnimal(ID)
		end
		
		local function captureAnimal()
		end
		
		local isDraggingAnimal = false
		
		local counterCircle = display.newImage("assets/contadorAnimales.png")
		counterCircle:setReferencePoint(display.CenterReferencePoint)
		counterCircle.x=display.screenOriginX+85
		counterCircle.y=display.screenOriginY+22
        counterCircle.xScale,counterCircle.yScale=0.45,0.45
		counterCircle.isVisible = false
		
		local text1 = display.newText("", 0, 0, mainFont1, retinaConditional(28,36))
        text1:setTextColor(67,34,15,255)
        text1.x = counterCircle.x - 10
        text1.y = counterCircle.y + retinaConditional(0,5)
        text1.isVisible=false
        
		local timerCircle = display.newImage("assets/reloj.png")
		timerCircle:setReferencePoint(display.CenterReferencePoint)
		timerCircle.x = width/2
        timerCircle.y = display.screenOriginY+25
        timerCircle.xScale,timerCircle.yScale=0.45,0.45
		localGroup:insert(timerCircle)
		timerCircle.isVisible = false
		
		local text2size = retinaConditional(28,36)
		local text2 = display.newText("", 0, 0, mainFont1, text2size)
		text2:setReferencePoint(display.CenterReferencePoint)
		--text2.size = text2size
        text2:setTextColor(107,18,22,255)
        text2.x = timerCircle.x+10
        text2.y = timerCircle.y - retinaConditional(3,-2)
        text2.text = ""..timeLeft
        text2.isVisible=false
		
		local countdownTimer = nil
		local function updateTimer()
			if finished then return end
			timeLeft = timeLeft-1
			text2.text = ""..timeLeft
			checkPlayerActivity()
			if timeLeft<=0 then
				if gameOver then gameOver() end
			else
				if timeLeft==5 or timeLeft==13 then
					soundController.playNew{
									path = "assets/sound/voices/SonidosNarrador/hurryUp.mp3",
									}
				end
				if timeLeft<=5 then
					text2:setTextColor(220,55,44,255)
					--text2.size = text2size*1.5
					text2.xScale = 1.25
					text2.yScale = 1.25
				elseif timeLeft<=13 then
					if math.fmod(timeLeft,2) == 1 then
						text2:setTextColor(190,49,40,255)
					else
						text2:setTextColor(107,18,22,255)
					end
					--text2.size = text2size*1.25
					text2.xScale = 1.125
					text2.yScale = 1.125
				end
				countdownTimer = timer.performWithDelay(1000, updateTimer)
			end
		end
		
		showPoints = function()
			text1.text = ""..kidnappedAnimalsCount.."/"..animalLimit
			text1.x = counterCircle.x - 10
	        text1.y = counterCircle.y + retinaConditional(0,5)
		end
		showPoints()
		
		local function newAnimal (ID, yPos, scale, number)
			local thisAnimal = {}
			
			local openEyesR = nil
			local closedEyesR = nil
			
			local openEyesC = nil
			local closedEyesC = nil
			
			local isDragging = false
			
			local positivePoints = 1
			local negativePoints = 0
			
			local distanceScale = 1
			
			local runningSound
			local caughtSound
			local dropSound = audio.loadSound("assets/sound/drop.mp3")
			local animalSoundChannel = nil
			
			local animalSpeed = 1
			
			thisAnimal.isAlive = true
			
			if not ID then
				ID = 1
			end
			
			if not yPos then
				yPos = 0
			end
			
			if not scale then
				scale = 1
			end
			
			thisAnimal.displayObject = display.newGroup()
			
			speedMultiplier = 1
			
			if ID == 1 then
				openEyesR = display.newImage("assets/cat/EyesOpen.png")
				closedEyesR = display.newImage("assets/cat/EyesClosed.png")
				
				openEyesC = display.newImage("assets/catCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/catCaught/EyesClosed.png")
				
				speedMultiplier = 1
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--tail
							path = "assets/cat/tail.png",
							x = { 37.85,36,40.05,44.4,49.15,50.5,51.95,47.8,43.75,39.95 },
							y = { 115.75,117.15,112.1,107.35,103.1,103.25,103.6,107.1,110.8,114.8 },
							rotation = { -33.51014709472656,-39.37852478027344,-33.28041076660156,-27.186904907226563,-21.088394165039063,-16.932525634765625,-12.77471923828125,-17.72918701171875,-22.685623168945313,-27.640914916992188 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--larm
							path = "assets/cat/larm.png",
							x = { 219.4,213.95,208.65,203.65,199.1,203.65,208.7,213.95,219.4,224.8 },
							y = { 207.4,209,209.4,208.9,207.35,208.9,209.35,209,207.4,204.8 },
							rotation = { 29.1588134765625,40.210479736328125,51.26298522949219,62.31587219238281,73.36959838867188,62.31587219238281,51.26298522949219,40.20997619628906,29.1588134765625,18.10516357421875 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--lleg
							path = "assets/cat/lleg.png",
							x = { 67.4,70.75,74.35,78.25,82.3,78.2,74.35,70.7,67.35,64.4 },
							y = { 203.65,204.75,205.5,205.85,205.75,205.85,205.45,204.75,203.65,202.2 },
							rotation = { -66.32954406738281,-73.04988098144531,-79.77272033691406,-86.49421691894531,-93.21566772460938,-86.49334716796875,-79.77102661132813,-73.05067443847656,-66.32881164550781,-59.60957336425781 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--body
							path = "assets/cat/body.png",
							x = { 152.3,152.7,153.2,153.7,154.2,153.7,153.2,152.7,152.3,151.8 },
							y = { 167.15,167.35,167.5,167.7,167.85,167.7,167.5,167.3,167.1,167.05 },
							rotation = { -26.330978393554688,-25.020858764648438,-23.708572387695313,-22.398513793945313,-21.087631225585938,-22.398513793945313,-23.710769653320313,-25.019424438476563,-26.332382202148438,-27.642974853515625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/cat/head.png",
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 208.95,207.85,206.7,205.55,204.3,205.55,206.65,207.85,208.95,210.05 },
							y = { 85.4,86.8,88.35,90.05,91.95,90.05,88.35,86.85,85.45,84.15 },
							rotation = { -8.8072509765625,-11.87689208984375,-14.945892333984375,-18.016647338867188,-21.08612060546875,-18.016647338867188,-14.945892333984375,-11.876052856445313,-8.806396484375,-5.736907958984375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
							yOffset = 0
						},{
							--rleg
							path = "assets/cat/rleg.png",
							x = { 90.8,86.05,81.65,77.65,74.4,77.65,81.6,85.95,90.8,96 },
							y = { 227.9,224.85,221.1,216.65,211.65,216.65,221.1,224.85,227.85,230.25 },
							rotation = { -41.13728332519531,-32.019866943359375,-22.901107788085938,-13.7841796875,-4.6634979248046875,-13.7841796875,-22.900375366210938,-32.01924133300781,-41.137786865234375,-50.25514221191406 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rarm
							path = "assets/cat/rarm.png",
							x = { 167.1,170.55,175.9,181.05,185.7,180.1,173.95,170.5,167.05,163.55 },
							y = { 236.25,236.65,236.1,234.7,232.3,235.1,236.65,236.7,236.3,235.35 },
							rotation = { 11.56005859375,4.7555389404296875,-5.5282440185546875,-15.8106689453125,-26.093826293945313,-14.074081420898438,-2.0536346435546875,4.7529296875,11.559219360351563,18.366195678710938 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						}
					},
					scale = scale * 1.666,
					speed = 0.2 * speedMultiplier
				}
				thisAnimal.caughtAnimal = ui.newAnimation{
					comps = {
						{
							--body
							path = "assets/catCaught/body.png",
							x = { 290.6,290.6,290.6,290.6,290.6,290.6,290.6,290.6,290.6,290.6 },
							y = { 260.7,259.3,257.9,256.5,255.1,256.45,257.9,259.25,260.7,262.05 },
							rotation = { 0,0,0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--tail
							path = "assets/catCaught/tail.png",
							x = { 277.25,278,278.8,279.7,280.55,279.7,278.8,278,277.25,276.45 },
							y = { 397.85,396.9,396,395,394,395,396,396.9,397.85,398.75 },
							rotation = { 6.66058349609375,4.996826171875,3.3306884765625,1.665008544921875,0,1.665008544921875,3.3306884765625,4.996826171875,6.66058349609375,8.326812744140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--larm
							path = "assets/catCaught/larm.png",
							x = { 336.4,337.2,338.1,338.95,339.75,338.95,338.1,337.2,336.4,335.5 },
							y = { 210.45,208.85,207.15,205.55,203.85,205.55,207.15,208.85,210.45,212 },
							rotation = { -1.978546142578125,-3.9550018310546875,-5.934173583984375,-7.9121246337890625,-9.889083862304688,-7.9121246337890625,-5.934173583984375,-3.9550018310546875,-1.978546142578125,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rarm
							path = "assets/catCaught/rarm.png",
							x = { 245.3,244.5,243.8,243.1,242.35,243.1,243.8,244.5,245.3,246.05 },
							y = { 211.25,209.75,208.3,206.8,205.15,206.8,208.3,209.75,211.25,212.65 },
							rotation = { 2.0492706298828125,4.0976715087890625,6.1442718505859375,8.192398071289063,10.240829467773438,8.192398071289063,6.1442718505859375,4.0976715087890625,2.0492706298828125,0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/catCaught/head.png",
							x = { 288.1,289,289.85,290.7,291.55,290.7,289.85,289,288.1,287.35 },
							y = { 126.05,124.6,123.2,121.85,120.5,121.85,123.2,124.6,126.05,127.45 },
							rotation = { 0.8741912841796875,1.749725341796875,2.6253204345703125,3.49969482421875,4.3733062744140625,3.49969482421875,2.6253204345703125,1.749725341796875,0.8741912841796875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesC,
							scaleComponent = true,
							x = { 288.1,289,289.85,290.7,291.55,290.7,289.85,289,288.1,287.35 },
							y = { 126.05,124.6,123.2,121.85,120.5,121.85,123.2,124.6,126.05,127.45 },
							rotation = { 0.8741912841796875,1.749725341796875,2.6253204345703125,3.49969482421875,4.3733062744140625,3.49969482421875,2.6253204345703125,1.749725341796875,0.8741912841796875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesC,
							scaleComponent = true,
							x = { 288.1,289,289.85,290.7,291.55,290.7,289.85,289,288.1,287.35 },
							y = { 126.05,124.6,123.2,121.85,120.5,121.85,123.2,124.6,126.05,127.45 },
							rotation = { 0.8741912841796875,1.749725341796875,2.6253204345703125,3.49969482421875,4.3733062744140625,3.49969482421875,2.6253204345703125,1.749725341796875,0.8741912841796875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--lleg
							path = "assets/catCaught/lleg.png",
							x = { 343.35,342.75,342.1,341.4,340.75,341.4,342.1,342.75,343.35,344 },
							y = { 347.75,346.55,345.2,343.9,342.6,343.9,345.2,346.55,347.75,349 },
							rotation = { 1.2342681884765625,2.469146728515625,3.7043304443359375,4.938690185546875,6.1736602783203125,4.938690185546875,3.7043304443359375,2.469146728515625,1.2342681884765625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rleg
							path = "assets/catCaught/rleg.png",
							x = { 239.6,240.1,240.55,241.05,241.5,241.05,240.55,240.1,239.6,239.15 },
							y = { 356.4,355.05,353.65,352.3,350.9,352.3,353.65,355.05,356.4,357.75 },
							rotation = { -0.88818359375,-1.7768096923828125,-2.664581298828125,-3.5536956787109375,-4.4410858154296875,-3.5536956787109375,-2.664581298828125,-1.7768096923828125,-0.88818359375,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						}
					},
					x = -150*scale,
					scale = scale*1.666,
					speed = 0.5
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				runningSound = audio.loadSound("assets/sound/catMeow.mp3")
				caughtSound  = audio.loadSound("assets/sound/catPurrrrr.mp3")
			elseif ID == 2 then
				openEyesR = display.newImage("assets/dog/EyesOpen.png")
				closedEyesR = display.newImage("assets/dog/EyesClosed.png")
				
				openEyesC = display.newImage("assets/dogCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/dogCaught/EyesClosed.png")
				
				speedMultiplier = 1
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--tail
							path = "assets/dog/tail.png",
							x = { 25.85,25.9,26,27.35,28.8,30.3,31.9,32.1,32.6,33,33.6,30.95,28.25,25.9 },
							y = { 144.1,143.5,142.9,140.75,138.7,136.55,134.65,135.1,135.75,136.45,137.4,139.6,142,144.9 },
							rotation = { -37.489715576171875,-41.768890380859375,-46.047515869140625,-42.41693115234375,-38.78326416015625,-35.14884948730469,-31.515594482421875,-25.603134155273438,-19.685821533203125,-13.7742919921875,-7.86065673828125,-16.312026977539063,-24.76043701171875,-33.21070861816406 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--body
							path = "assets/dog/body.png",
							x = { 128.55,128.9,129.25,129.55,129.9,130.25,130.55,130.25,129.9,129.55,129.25,128.9,128.55,128.2 },
							y = { 178.95,178.95,179,179,179.1,179.25,179.35,179.25,179.1,179,179,178.95,178.95,178.9 },
							rotation = { -0.5061798095703125,0.4231414794921875,1.3557281494140625,2.285858154296875,3.2174072265625,4.14898681640625,5.0774993896484375,4.14898681640625,3.2174072265625,2.285858154296875,1.3557281494140625,0.4231414794921875,-0.5061798095703125,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/dog/head.png",
							x = { 200.25,202.35,204.3,206.5,208.45,210.45,212.45,210.45,208.45,206.5,204.3,202.35,200.25,198.15 },
							y = { 95.3,96.65,97.95,99.4,100.85,102.35,103.85,102.35,100.85,99.4,97.95,96.65,95.3,94.05 },
							rotation = { 0.1451263427734375,1.7278900146484375,3.3106536865234375,4.8927001953125,6.4733428955078125,8.057876586914063,9.640289306640625,8.057876586914063,6.4733428955078125,4.8927001953125,3.3106536865234375,1.7278900146484375,0.1451263427734375,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 200.25,202.35,204.3,206.5,208.45,210.45,212.45,210.45,208.45,206.5,204.3,202.35,200.25,198.15 },
							y = { 95.3,96.65,97.95,99.4,100.85,102.35,103.85,102.35,100.85,99.4,97.95,96.65,95.3,94.05 },
							rotation = { 0.1451263427734375,1.7278900146484375,3.3106536865234375,4.8927001953125,6.4733428955078125,8.057876586914063,9.640289306640625,8.057876586914063,6.4733428955078125,4.8927001953125,3.3106536865234375,1.7278900146484375,0.1451263427734375,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 200.25,202.35,204.3,206.5,208.45,210.45,212.45,210.45,208.45,206.5,204.3,202.35,200.25,198.15 },
							y = { 95.3,96.65,97.95,99.4,100.85,102.35,103.85,102.35,100.85,99.4,97.95,96.65,95.3,94.05 },
							rotation = { 0.1451263427734375,1.7278900146484375,3.3106536865234375,4.8927001953125,6.4733428955078125,8.057876586914063,9.640289306640625,8.057876586914063,6.4733428955078125,4.8927001953125,3.3106536865234375,1.7278900146484375,0.1451263427734375,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rarm
							path = "assets/dog/rarm.png",
							x = { 187.85,190.5,192.9,195.15,197.1,198.7,200.05,198.7,197.1,195.15,192.9,190.5,187.85,185.2 },
							y = { 227.65,227.35,226.8,225.9,224.65,223.2,221.55,223.2,224.65,225.9,226.8,227.35,227.65,227.55 },
							rotation = { 41.54829406738281,34.25605773925781,26.961639404296875,19.6695556640625,12.377456665039063,5.084442138671875,-2.210784912109375,5.084442138671875,12.377456665039063,19.6695556640625,26.961639404296875,34.25605773925781,41.54829406738281,48.84040832519531 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--larm
							path = "assets/dog/larm.png",
							x = { 233.4,231.1,227.95,224,219.55,214.75,209.65,214.75,219.55,224,227.95,231.1,233.4,234.7 },
							y = { 196.95,202.65,207.65,212,215.6,218.2,219.7,218.2,215.6,212,207.65,202.65,196.95,190.9 },
							rotation = { 10.557144165039063,22.55377197265625,34.553619384765625,46.5501708984375,58.546722412109375,70.54391479492188,82.53952026367188,70.54391479492188,58.546722412109375,46.5501708984375,34.553619384765625,22.55377197265625,10.557144165039063,-1.4387359619140625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--rleg
							path = "assets/dog/rleg.png",
							x = { 50.6,53.5,56.7,60.1,63.6,67.3,70.85,67.3,63.6,60.1,56.7,53.5,50.6,48.15 },
							y = { 232.15,233.2,233.95,234.1,233.7,232.75,231.3,232.75,233.7,234.1,233.95,233.2,232.15,230.5 },
							rotation = { -9.980697631835938,-18.525909423828125,-27.070571899414063,-35.61375427246094,-44.15928649902344,-52.70396423339844,-61.24681091308594,-52.70396423339844,-44.15928649902344,-35.61375427246094,-27.070571899414063,-18.525909423828125,-9.980697631835938,-1.4369964599609375 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--lleg
							path = "assets/dog/lleg.png",
							x = { 42.85,39.35,36.15,33.15,30.6,28.3,26.6,28.3,30.6,33.15,36.15,39.35,42.85,46.35 },
							y = { 219.6,217.3,214.5,211.3,207.65,203.6,199.3,203.6,207.65,211.3,214.5,217.3,219.6,221.3 },
							rotation = { -65.19200134277344,-56.47222900390625,-47.74983215332031,-39.02784729003906,-30.307098388671875,-21.585983276367188,-12.864486694335938,-21.585983276367188,-30.307098388671875,-39.02784729003906,-47.74983215332031,-56.47222900390625,-65.19271850585938,-73.91532897949219 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},
					},
					scale = scale * 1.666,
					speed = 0.2 * speedMultiplier
				}
				thisAnimal.caughtAnimal = ui.newAnimation{
					comps = {
						{
							-- tail
							path = "assets/dogCaught/tail.png",
							x = { 558.85,554.65,550.45,554.65,558.85,563.05 },
							y = { 844.45,847.05,849.4,847.05,844.45,841.4 },
							rotation = { 4.762481689453125,9.524688720703125,14.28692626953125,9.524688720703125,4.762481689453125,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
							xOffset = 3,
							yOffset = -30
						},{
							-- body
							path = "assets/dogCaught/body.png",
							x = { 557.35,557.35,557.35,557.35,557.35,557.35 },
							y = { 505.75,508.45,511.15,508.45,505.75,503.05 },
							rotation = { 0,0,0,0,0,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},{
							-- tongue
							path = "assets/dogCaught/tongue.png",
							x = { 512.95,512.45,512.75,512.45,512.95,514.05 },
							y = { 391.5,388.4,385.35,388.4,391.5,394.6 },
							rotation = { 7.568756103515625,15.141586303710938,22.713897705078125,15.141586303710938,7.568756103515625,-0.00262451171875 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},{
							-- head
							path = "assets/dogCaught/head.png",
							x = { 566.55,570.15,573.9,570.15,566.55,562.8 },
							y = { 295.85,298.9,301.95,298.9,295.85,292.7 },
							rotation = { -2.410675048828125,0.672271728515625,3.75830078125,0.672271728515625,-2.410675048828125,-5.4979248046875 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},{
							displayObject = closedEyesC,
							scaleComponent = true,
							x = { 566.55,570.15,573.9,570.15,566.55,562.8 },
							y = { 295.85,298.9,301.95,298.9,295.85,292.7 },
							rotation = { -2.410675048828125,0.672271728515625,3.75830078125,0.672271728515625,-2.410675048828125,-5.4979248046875 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},{
							displayObject = openEyesC,
							scaleComponent = true,
							x = { 566.55,570.15,573.9,570.15,566.55,562.8 },
							y = { 295.85,298.9,301.95,298.9,295.85,292.7 },
							rotation = { -2.410675048828125,0.672271728515625,3.75830078125,0.672271728515625,-2.410675048828125,-5.4979248046875 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},{
							-- rarm
							path = "assets/dogCaught/rarm.png",
							x = { 446.15,440.3,434.65,440.3,446.15,452.05 },
							y = { 495.7,498.1,500.05,498.1,495.7,493 },
							rotation = { 4.6035614013671875,9.207229614257813,13.811386108398438,9.207229614257813,4.6035614013671875,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},{
							-- larm
							path = "assets/dogCaught/larm.png",
							x = { 682.5,686.15,689.7,686.15,682.5,678.65 },
							y = { 493.8,494.25,494.5,494.25,493.8,492.95 },
							rotation = { -4.0663604736328125,-8.134140014648438,-12.20135498046875,-8.134140014648438,-4.0663604736328125,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},{
							-- lleg
							path = "assets/dogCaught/lleg.png",
							x = { 653,652.85,652.6,652.85,653,653.1 },
							y = { 789.8,791.5,792.95,791.5,789.8,787.85 },
							rotation = { 3.77484130859375,7.5498504638671875,11.326583862304688,7.5498504638671875,3.77484130859375,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
							xOffset = -20  / 3.333,
							yOffset = -20  / 3.333
						},{
							-- rleg
							path = "assets/dogCaught/rleg.png",
							x = { 479.55,479.85,480.2,479.85,479.55,479.25 },
							y = { 789.5,791.05,792.5,791.05,789.5,787.85 },
							rotation = { -3.0709686279296875,-6.1442718505859375,-9.214889526367188,-6.1442718505859375,-3.0709686279296875,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
							xOffset = 10  / 3.333,
							yOffset = -10  / 3.333
						}
					},
					x = -150*scale,
					scale = scale*0.5*3.333,
					speed = 0.5
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				runningSound = audio.loadSound("assets/sound/dogBark.mp3")
				caughtSound  = audio.loadSound("assets/sound/dogWhine.mp3")
			elseif ID == 3 then
				openEyesR = display.newImage("assets/rabbit/EyesOpen.png")
				closedEyesR = display.newImage("assets/rabbit/EyesClosed.png")
				
				openEyesC = display.newImage("assets/rabbitCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/rabbitCaught/EyesClosed.png")
				
				speedMultiplier = 2
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--lear
							path = "assets/rabbit/lear.png",
							x = { 591.5,584,576.55,569.2,561.9,565.55,569.2,572.85,576.5,580.25,584.9,589.6,594.4,599.3 },
							y = { 372.5,340.5,308.7,277,245.6,227.3,209.15,191,172.85,154.8,217.15,279.6,342.1,404.75 },
							rotation = { -2.4098052978515625,-4.81805419921875,-7.2257080078125,-9.633499145507813,-12.0408935546875,-10.836563110351563,-9.632644653320313,-8.42694091796875,-7.2239837646484375,-6.021514892578125,-4.5140838623046875,-3.009063720703125,-1.5051422119140625,-0.0008697509765625 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--head
							path = "assets/rabbit/head.png",
							x = { 683,678.6,674.1,669.5,664.75,667.15,669.5,671.8,674.15,676.35,679.05,681.9,684.65,687.3 },
							y = { 567.55,530.65,493.85,457.15,420.6,404.95,389.25,373.65,358.1,342.55,408.05,473.55,539.1,604.65 },
							rotation = { -0.5656280517578125,-1.132904052734375,-1.699066162109375,-2.2649078369140625,-2.8329315185546875,-2.5494232177734375,-2.26666259765625,-1.9846649169921875,-1.7008209228515625,-1.4177703857421875,-1.062103271484375,-0.7081146240234375,-0.35406494140625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 683,678.6,674.1,669.5,664.75,667.15,669.5,671.8,674.15,676.35,679.05,681.9,684.65,687.3 },
							y = { 567.55,530.65,493.85,457.15,420.6,404.95,389.25,373.65,358.1,342.55,408.05,473.55,539.1,604.65 },
							rotation = { -0.5656280517578125,-1.132904052734375,-1.699066162109375,-2.2649078369140625,-2.8329315185546875,-2.5494232177734375,-2.26666259765625,-1.9846649169921875,-1.7008209228515625,-1.4177703857421875,-1.062103271484375,-0.7081146240234375,-0.35406494140625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 683,678.6,674.1,669.5,664.75,667.15,669.5,671.8,674.15,676.35,679.05,681.9,684.65,687.3 },
							y = { 567.55,530.65,493.85,457.15,420.6,404.95,389.25,373.65,358.1,342.55,408.05,473.55,539.1,604.65 },
							rotation = { -0.5656280517578125,-1.132904052734375,-1.699066162109375,-2.2649078369140625,-2.8329315185546875,-2.5494232177734375,-2.26666259765625,-1.9846649169921875,-1.7008209228515625,-1.4177703857421875,-1.062103271484375,-0.7081146240234375,-0.35406494140625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rear
							path = "assets/rabbit/rear.png",
							x = { 429,422.6,416.55,410.75,405.35,408,410.8,413.65,416.55,419.5,423.3,427.35,431.5,435.8 },
							y = { 448.65,420.6,392.75,365.05,337.4,317.3,297.2,277.05,256.9,236.8,296.8,356.7,416.75,476.85 },
							rotation = { -3.076202392578125,-6.1503143310546875,-9.225967407226563,-12.301544189453125,-15.374298095703125,-13.83612060546875,-12.298202514648438,-10.759796142578125,-9.221710205078125,-7.6838531494140625,-5.7646026611328125,-3.8418731689453125,-1.9209136962890625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--lgemelo
							path = "assets/rabbit/lgemelo.png",
							x = { 357.85,351.1,346.3,343.8,343.6,343.5,343.9,344.9,346.4,348.4,351.65,355.75,360.8,366.65 },
							y = { 877.45,856.4,834.55,811.55,787.25,765.65,743.65,721.3,698.65,675.7,731.6,787.2,842.6,898 },
							rotation = { -9.095596313476563,-18.190414428710938,-27.287124633789063,-36.38165283203125,-45.47674560546875,-40.92933654785156,-36.380523681640625,-31.833465576171875,-27.28643798828125,-22.738449096679688,-17.053253173828125,-11.36859130859375,-5.6840972900390625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--lfoot
							path = "assets/rabbit/lfoot.png",
							x = { 322.95,318.15,315.3,315,318.05,316.1,315,314.75,315.2,316.25,318.35,321.25,324.75,328.7 },
							y = { 954.7,947.5,935.25,916.85,892.25,871.45,849,824.95,799.4,772.25,821.3,868.3,913.7,957.6 },
							rotation = { 18.65472412109375,37.307647705078125,55.962493896484375,74.61512756347656,93.26620483398438,83.94044494628906,74.61431884765625,65.28715515136719,55.96009826660156,46.63276672363281,34.97430419921875,23.316757202148438,11.659042358398438,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--body
							path = "assets/rabbit/body.png",
							x = { 448.6,447.2,445.7,444.4,442.9,443.65,444.35,445.05,445.7,446.45,447.35,448.2,449.25,450.2 },
							y = { 716.15,684.2,652.4,620.55,588.85,570.75,552.7,534.6,516.65,498.5,560.9,623.3,685.7,748.1 },
							rotation = { -1.4972686767578125,-2.99163818359375,-4.487152099609375,-5.98260498046875,-7.4768218994140625,-6.72784423828125,-5.9808807373046875,-5.23187255859375,-4.4845428466796875,-3.736541748046875,-2.802398681640625,-1.8685150146484375,-0.93450927734375,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--larm
							path = "assets/rabbit/larm.png",
							x = { 738.9,738.5,737.75,737,735.9,739.3,742.15,744.05,745.4,745.9,744.95,747.4,748.15,747.15 },
							y = { 766.9,728.1,689.4,650.65,611.9,589.5,566.95,544.2,521.35,498.5,551.4,628.95,706.55,784.05 },
							rotation = { 14.927932739257813,13.986038208007813,13.043014526367188,12.101089477539063,11.158370971679688,5.8693084716796875,0.58135986328125,-4.7069091796875,-9.9951171875,-15.284042358398438,-24.328567504882813,-16.21856689453125,-8.108444213867188,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rarm
							path = "assets/rabbit/rarm.png",
							x = { 600.85,600.3,599.15,597.55,595.4,600.35,604.6,608,610.35,611.85,610.6,611.35,610.9,609.05 },
							y = { 829.05,798.85,768.6,737.95,706.95,679.05,650.45,621.35,592.15,563.1,615.3,689.3,763.5,837.45 },
							rotation = { 13.70745849609375,11.4080810546875,9.108383178710938,6.8088836669921875,4.5088653564453125,0.8995513916015625,-2.7082061767578125,-6.3170623779296875,-9.926422119140625,-13.53570556640625,-21.483108520507813,-14.3214111328125,-7.161163330078125,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--tail
							path = "assets/rabbit/tail.png",
							x = { 146.35,141.1,137.75,136.5,137.45,136.65,136.6,136.95,137.85,139.35,141.65,144.9,148.85,153.4 },
							y = { 757.45,740.5,724.55,709.3,694.2,667.75,641.35,615.05,588.75,562.7,615.2,668.15,721.6,775.65 },
							rotation = { -11.441680908203125,-22.88330078125,-34.32469177246094,-45.76611328125,-57.206817626953125,-51.48548889160156,-45.7647705078125,-40.04435729980469,-34.3240966796875,-28.602447509765625,-21.453567504882813,-14.302536010742188,-7.1508331298828125,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rmuslo
							path = "assets/rabbit/rmuslo.png",
							x = { 313.25,312.15,310.7,308.95,307.05,308.05,309,309.9,310.75,311.45,312.35,313.05,313.65,314.1 },
							y = { 876.8,853.25,829.2,804.6,779.5,758.15,736.8,715.2,693.45,671.6,729.05,786.15,843.2,900.05 },
							rotation = { 6.758880615234375,13.518356323242188,20.277297973632813,27.03729248046875,33.79608154296875,30.415802001953125,27.035202026367188,23.656509399414063,20.276535034179688,16.895706176757813,12.673233032226563,8.449172973632813,4.2237701416015625,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rgemelo
							path = "assets/rabbit/rgemelo.png",
							x = { 266,264,261.4,258.6,255.45,257.05,258.65,260.1,261.5,262.85,264.35,265.6,266.75,267.6 },
							y = { 906.75,889.85,872.3,853.9,834.55,810.45,786.05,761.45,736.55,711.55,764.8,817.75,870.5,922.95 },
							rotation = { -2.9776763916015625,-5.9523468017578125,-8.927597045898438,-11.902847290039063,-14.8773193359375,-13.391006469726563,-11.902008056640625,-10.414291381835938,-8.925888061523438,-7.4364166259765625,-5.5784759521484375,-3.7191314697265625,-1.86065673828125,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
						{
							--rfoot
							path = "assets/rabbit/rfoot.png",
							x = { 252.75,252.6,248.45,240.55,229.3,235.35,240.5,244.95,248.45,251.05,252.95,253.1,251.65,248.65 },
							y = { 942.65,946.7,949.3,949.6,946.55,914.6,881.65,848,813.5,778.4,818.85,858.8,898.4,938.1 },
							rotation = { 13.351287841796875,26.70196533203125,40.053070068359375,53.40473937988281,66.75479125976563,60.07887268066406,53.4041748046875,46.7271728515625,40.05204772949219,33.37745666503906,25.033065795898438,16.68817138671875,8.34393310546875,0 },
							coordsXScaleOffset = 0.2,
							coordsYScaleOffset = 0.2,
						},
					},
					scale = scale*0.3 * 5,
					speed = 0.2 * speedMultiplier
				}
				thisAnimal.caughtAnimal = ui.newAnimation{
					comps = {
						{
							--lear
							path = "assets/rabbitCaught/lear.png",
							x = { 713.55,715.45,717.3,719.15,720.95,719.15,717.3,715.45,713.55,711.6 },
							y = { 450.3,454.4,458.55,462.75,466.85,462.75,458.55,454.4,450.3,446.2 },
							rotation = { -0.3208465576171875,-0.6425628662109375,-0.9642181396484375,-1.287567138671875,-1.6082305908203125,-1.287567138671875,-0.9642181396484375,-0.6425628662109375,-0.3208465576171875,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--rear
							path = "assets/rabbitCaught/rear.png",
							x = { 353.4,354.5,355.65,356.85,358,356.85,355.65,354.5,353.4,352.35 },
							y = { 477.9,477.35,476.75,476.2,475.7,476.2,476.75,477.35,477.9,478.5 },
							rotation = { -0.101409912109375,-0.2028350830078125,-0.3042449951171875,-0.4056549072265625,-0.5070648193359375,-0.4056549072265625,-0.3042449951171875,-0.2028350830078125,-0.101409912109375,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--larm
							path = "assets/rabbitCaught/larm.png",
							x = { 685.2,684.4,683.6,682.9,682,682.9,683.6,684.4,685.2,685.85 },
							y = { 458.6,461.55,464.4,467.25,470.1,467.25,464.4,461.55,458.6,455.65 },
							rotation = { 1.8248443603515625,3.6503448486328125,5.4745330810546875,7.3005523681640625,9.12542724609375,7.3005523681640625,5.4745330810546875,3.6503448486328125,1.8248443603515625,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--rarm
							path = "assets/rabbitCaught/rarm.png",
							x = { 402.05,402.75,403.5,404.25,405.05,404.25,403.5,402.75,402.05,401.35 },
							y = { 461.45,463.85,466.3,468.6,471,468.6,466.3,463.85,461.45,459 },
							rotation = { -1.6772308349609375,-3.3550872802734375,-5.0323944091796875,-6.7088775634765625,-8.38671875,-6.7088775634765625,-5.0323944091796875,-3.3550872802734375,-1.6772308349609375,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--lleg
							path = "assets/rabbitCaught/lleg.png",
							x = { 635.85,639.2,642.5,645.7,648.8,645.7,642.5,639.2,635.85,632.5 },
							y = { 821.45,822.1,822.55,822.75,822.8,822.75,822.55,822.1,821.45,820.6 },
							rotation = { -3.7208709716796875,-7.4424285888671875,-11.164260864257813,-14.885482788085938,-18.606048583984375,-14.885482788085938,-11.164260864257813,-7.4424285888671875,-3.7208709716796875,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--rleg
							path = "assets/rabbitCaught/rleg.png",
							x = { 420.15,418.6,417,415.4,413.85,415.4,417,418.6,420.15,421.75 },
							y = { 822.4,823.45,824.4,825.35,826.25,825.35,824.4,823.45,822.4,821.35 },
							rotation = { 1.8204803466796875,3.64251708984375,5.4632720947265625,7.285064697265625,9.105819702148438,7.285064697265625,5.4632720947265625,3.64251708984375,1.8204803466796875,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--tail
							path = "assets/rabbitCaught/tail.png",
							x = { 536.6,538.15,539.5,540.95,542.25,540.95,539.5,538.15,536.6,535.1 },
							y = { 859.45,860.6,861.7,862.6,863.4,862.6,861.7,860.6,859.45,858.15 },
							rotation = { -4.193328857421875,-8.3858642578125,-12.580825805664063,-16.772369384765625,-20.966522216796875,-16.772369384765625,-12.580825805664063,-8.3858642578125,-4.193328857421875,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--body
							path = "assets/rabbitCaught/body.png",
							x = { 528.55,528.55,528.55,528.55,528.55,528.55,528.55,528.55,528.55,528.55 },
							y = { 591.75,593.35,594.9,596.55,598.15,596.55,594.95,593.35,591.75,590.15 },
							rotation = { 0,0,0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							--head
							path = "assets/rabbitCaught/head.png",
							x = { 537.4,539.55,541.7,543.85,545.95,543.85,541.7,539.55,537.4,535.25 },
							y = { 218.4,220,221.7,223.4,225.1,223.4,221.7,220,218.4,216.75 },
							rotation = { 0.8042755126953125,1.6073455810546875,2.410675048828125,3.21478271484375,4.019378662109375,3.21478271484375,2.410675048828125,1.6073455810546875,0.8042755126953125,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							displayObject = openEyesC,
							scaleComponent = true,
							x = { 537.4,539.55,541.7,543.85,545.95,543.85,541.7,539.55,537.4,535.25 },
							y = { 218.4,220,221.7,223.4,225.1,223.4,221.7,220,218.4,216.75 },
							rotation = { 0.8042755126953125,1.6073455810546875,2.410675048828125,3.21478271484375,4.019378662109375,3.21478271484375,2.410675048828125,1.6073455810546875,0.8042755126953125,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						{
							displayObject = closedEyesC,
							scaleComponent = true,
							x = { 537.4,539.55,541.7,543.85,545.95,543.85,541.7,539.55,537.4,535.25 },
							y = { 218.4,220,221.7,223.4,225.1,223.4,221.7,220,218.4,216.75 },
							rotation = { 0.8042755126953125,1.6073455810546875,2.410675048828125,3.21478271484375,4.019378662109375,3.21478271484375,2.410675048828125,1.6073455810546875,0.8042755126953125,0 },
							coordsXScaleOffset = 0.3,
							coordsYScaleOffset = 0.3,
						},
						
					},
					scale = scale*0.4*3.333,
					speed = 1
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				runningSound = nil
				caughtSound  = audio.loadSound("assets/sound/conejocatch.mp3")
			elseif ID == 4 then
				openEyesR = display.newImage("assets/frog/EyesOpen.png")
				closedEyesR = display.newImage("assets/frog/EyesClosed.png")
				
				openEyesC = display.newImage("assets/frogCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/frogCaught/EyesClosed.png")
				
				speedMultiplier = 2
				thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
						 --body
						 path = "assets/frog/body.png",
						 x = { 263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8 },
						 y = { 227.1,214.5,201.85,189.25,191.15,193.1,195.05,201.1,207.25,213.75,220.25,226.75,233.25,239.75 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 displayObject = closedEyesR,
						 scaleComponent = true,
						 x = { 263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8 },
						 y = { 227.1,214.5,201.85,189.25,191.15,193.1,195.05,201.1,207.25,213.75,220.25,226.75,233.25,239.75 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 displayObject = openEyesR,
						 scaleComponent = true,
						 x = { 263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8,263.8 },
						 y = { 227.1,214.5,201.85,189.25,191.15,193.1,195.05,201.1,207.25,213.75,220.25,226.75,233.25,239.75 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rleg
						 path = "assets/frog/rleg.png",
						 x = { 184.15,179.6,175,170.6,173.65,176.95,180.2,183.5,186.85,187.1,187.45,187.8,188.05,188.45 },
						 y = { 315.3,308,299.75,290.4,291.15,291.55,291.55,295,298.15,302.85,307.55,312.2,316.9,321.75 },
						 rotation = { 11.175201416015625,22.350662231445313,33.52412414550781,44.697784423828125,36.772369384765625,28.84716796875,20.921539306640625,12.996536254882813,5.0731658935546875,4.05853271484375,3.0448150634765625,2.03094482421875,1.0157928466796875,0.0017547607421875 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rknee
						 path = "assets/frog/rknee.png",
						 x = { 160.85,154.75,149.45,145.2,149.85,155.05,160.45,165.9,171.3,170.3,169.45,168.55,167.95,168.5 },
						 y = { 369.7,368.1,363.3,355.05,355.9,355.15,352.7,352.65,351.4,354.8,358.25,361.65,364.95,367.85 },
						 rotation = { -10.126480102539063,-20.245758056640625,-30.366363525390625,-40.48419189453125,-34.862030029296875,-29.246078491210938,-23.631576538085938,-18.01348876953125,-12.40081787109375,-9.92047119140625,-7.4407196044921875,-4.9621124267578125,-2.4822235107421875,-0.0218505859375 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rfoot
						 path = "assets/frog/rfoot.png",
						 x = { 148.9,144.65,141.65,139.75,143.35,147.5,151.85,156.15,160.35,158.8,157.5,156.25,155.05,154.45 },
						 y = { 408.05,411.35,410.05,404.15,404.2,401.9,397.3,394.35,389.3,391.65,393.95,396.2,398.35,400.85 },
						 rotation = { -11.723587036132813,-4.3593902587890625,3.001220703125,10.366073608398438,4.4749755859375,-1.414276123046875,-7.302276611328125,-13.189788818359375,-19.078231811523438,-19.078231811523438,-19.080581665039063,-19.083694458007813,-19.086044311523438,-19.083694458007813 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 -- lknee
						 path = "assets/frog/lknee.png",
						 x = { 222.65,220.95,219.95,219.9,221.05,222.3,223.9,225.85,227.8,227,226.45,225.85,225.4,225.15 },
						 y = { 349.35,340.35,329.35,316.85,319.15,320.75,321.65,325.95,329.35,335,340.55,346.05,351.4,356.1 },
						 rotation = { -8.752593994140625,-17.502044677734375,-26.25225830078125,-35.0001220703125,-31.657058715820313,-28.317291259765625,-24.977767944335938,-21.636611938476563,-18.29766845703125,-14.637771606445313,-10.978179931640625,-7.3194732666015625,-3.6599273681640625,-0.0113677978515625 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --lfoot
						 path = "assets/frog/lfoot.png",
						 x = { 213.5,212.15,212,213.15,214.6,216.4,218.3,220.4,222.5,220.75,219.15,217.85,216.7,215.95 },
						 y = { 374.1,369.4,362.25,352.8,353.95,354.25,353.6,355.75,357,361.1,365.15,369.1,372.9,376.9 },
						 rotation = { -15.1708984375,-6.047454833984375,3.0770721435546875,12.200515747070313,4.5644683837890625,-3.067474365234375,-10.701553344726563,-18.33233642578125,-25.963943481445313,-25.629440307617188,-25.295196533203125,-24.963409423828125,-24.629104614257813,-24.300262451171875 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rarm
						 path = "assets/frog/rarm.png",
						 x = { 294.05,295.5,297,298.45,297.55,296.65,295.8,294.8,293.95,293.65,293.4,293.1,292.85,293.25 },
						 y = { 318.55,306.35,294.05,281.8,283.5,285.05,286.65,292.5,298.35,304.8,311.3,317.75,324.25,330.1 },
						 rotation = { -1.967193603515625,-3.93585205078125,-5.903900146484375,-7.8726654052734375,-7.085418701171875,-6.298065185546875,-5.5100555419921875,-4.7234039306640625,-3.9349822998046875,-3.1494140625,-2.3618011474609375,-1.5750274658203125,-0.78765869140625,-0.0008697509765625 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rforearm
						 path = "assets/frog/rforearm.png",
						 x = { 303.55,304.15,304.65,305.1,304.3,304.15,304,303.8,303.8,303.65,303.4,303.2,302.9,304.95 },
						 y = { 348.45,337.05,325.6,314,315.3,316.05,316.9,322.3,327.4,334,340.5,347.05,353.6,357.75 },
						 rotation = { 3.278411865234375,6.55792236328125,9.836471557617188,13.115997314453125,11.802352905273438,10.487838745117188,9.174850463867188,7.8597869873046875,6.5467071533203125,5.2370758056640625,3.9280242919921875,2.61834716796875,1.3085479736328125,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --rhand
						 path = "assets/frog/rhand.png",
						 x = { 341.2,340.95,340.5,339.7,339.6,339.5,339.45,339.2,339,339.55,340.1,340.5,340.9,341.15 },
						 y = { 364.3,355.55,346.7,337.7,338.1,338.45,338.9,343.2,347.65,352.8,357.9,362.95,368,372.95 },
						 rotation = { 3.278411865234375,6.55792236328125,9.836471557617188,13.115997314453125,11.802352905273438,10.487838745117188,9.174850463867188,7.8597869873046875,6.5467071533203125,5.2370758056640625,3.9280242919921875,2.61834716796875,1.3085479736328125,0 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --lforearm
						 path = "assets/frog/lforearm.png",
						 x = { 359.8,359.75,359.85,359.7,359.7,359.45,359.3,359.2,359.05,359.2,359.4,359.45,359.65,360.4 },
						 y = { 322.4,310.4,298.55,286.6,287.95,289.9,291.9,297.6,303.65,309.7,315.75,321.8,327.85,334.1 },
						 rotation = { -2.239593505859375,0.74920654296875,3.73828125,6.72784423828125,6.05438232421875,5.380096435546875,4.7069091796875,4.0350341796875,3.3664093017578125,1.6475372314453125,-0.071685791015625,-1.7899169921875,-3.50927734375,-5.2188568115234375 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},{
						 --lhand
						 path = "assets/frog/lhand.png",
						 x = { 393.05,391.65,390.05,388.35,388.4,389.15,389.9,390.1,390.65,391.4,392.15,392.85,393.5,395.2 },
						 y = { 334.95,324.55,314,303.35,305.1,306.9,308.6,314.6,320.65,325.65,330.6,335.55,340.45,345.4 },
						 rotation = { -2.239593505859375,0.74920654296875,3.73828125,6.72784423828125,6.05438232421875,5.380096435546875,4.7069091796875,4.0350341796875,3.3664093017578125,1.6475372314453125,-0.071685791015625,-1.7899169921875,-3.50927734375,-5.2188568115234375 },
						 coordsXScaleOffset = 0.3,
						 coordsYScaleOffset = 0.3,
						},
					},
					scale = scale*0.5 * 3,
					speed = 0.2 * speedMultiplier
				}
				thisAnimal.caughtAnimal = ui.newAnimation{
					comps = {
						{
						 path = "assets/frogCaught/Peanut.png",
						 x = { 578.4,578.4,578.4,578.4,578.4,578.4,578.4,578.4,578.4 },
						 y = { 389.05,384.05,379.05,374.05,378.05,382.05,386.05,390.05,394.05 },
						 rotation = { 0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.2,
						 coordsYScaleOffset = 0.2,
						},{
						 displayObject = closedEyesC,
						 scaleComponent = true,
						 x = { 578.4,578.4,578.4,578.4,578.4,578.4,578.4,578.4,578.4 },
						 y = { 389.05,384.05,379.05,374.05,378.05,382.05,386.05,390.05,394.05 },
						 rotation = { 0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.2,
						 coordsYScaleOffset = 0.2,
						},{
						 displayObject = openEyesC,
						 scaleComponent = true,
						 x = { 578.4,578.4,578.4,578.4,578.4,578.4,578.4,578.4,578.4 },
						 y = { 389.05,384.05,379.05,374.05,378.05,382.05,386.05,390.05,394.05 },
						 rotation = { 0,0,0,0,0,0,0,0,0 },
						 coordsXScaleOffset = 0.2,
						 coordsYScaleOffset = 0.2,
						},{
						 path = "assets/frogCaught/LArm.png",
						 x = { 781.05,783.9,786.7,789.4,787.25,785.05,782.8,780.55,778.2 },
						 y = { 535,527.95,520.75,513.55,519.35,525.1,530.8,536.45,541.95 },
						 rotation = { -2.0178375244140625,-4.036773681640625,-6.05438232421875,-8.07244873046875,-6.4578094482421875,-4.844085693359375,-3.228729248046875,-1.61346435546875,0 },
						 coordsXScaleOffset = 0.2,
						 coordsYScaleOffset = 0.2,
						},{
						 path = "assets/frogCaught/LLeg.png",
						 x = { 704.1,700.85,697.6,694.35,696.95,699.55,702.15,704.75,707.35 },
						 y = { 774.4,770.3,766.1,761.85,765.25,768.65,771.95,775.2,778.4 },
						 rotation = { 1.49639892578125,2.993377685546875,4.48974609375,5.9869384765625,4.7885284423828125,3.5911407470703125,2.3940887451171875,1.1967010498046875,0 },
						 coordsXScaleOffset = 0.2,
						 coordsYScaleOffset = 0.2,
						},{
						 path = "assets/frogCaught/RArm.png",
						 x = { 353.6,351.35,349,346.8,348.55,350.4,352.2,354.1,356 },
						 y = { 550.95,544.35,537.5,530.7,536.15,541.65,546.95,552.3,557.6 },
						 rotation = { 1.5444488525390625,3.0910186767578125,4.636566162109375,6.18316650390625,4.9456329345703125,3.709564208984375,2.472625732421875,1.2368927001953125,0 },
						 coordsXScaleOffset = 0.2,
						 coordsYScaleOffset = 0.2,
						},{
						 path = "assets/frogCaught/RLeg.png",
						 x = { 438.85,440.9,443,445.05,443.35,441.75,440.1,438.4,436.85 },
						 y = { 774.1,769.7,765.2,760.7,764.25,767.85,771.35,774.95,778.55 },
						 rotation = { -1.04376220703125,-2.0859527587890625,-3.1293792724609375,-4.17333984375,-3.338531494140625,-2.5040435791015625,-1.6685028076171875,-0.833984375,0 },
						 coordsXScaleOffset = 0.2,
						 coordsYScaleOffset = 0.2,
						},
					},
					x = -50*scale,
					scale = scale*0.3 * 5,
					speed = 0.5
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				runningSound = nil
				caughtSound  = audio.loadSound("assets/sound/frogcatch.mp3")
			else
				print("no animal")
			end
			
			local RBlinks = ui.blink(openEyesR,closedEyesR)
			local CBlinks = ui.blink(openEyesC,closedEyesC)
			
			thisAnimal.ignoreNegative = true
			thisAnimal.displayObject.x = -200*scale
			
			localGroup:insert(thisAnimal.displayObject)
			thisAnimal.addRunningAnimalLayer = function()
				if thisAnimal.runningAnimal.displayObject then
					thisAnimal.displayObject:insert(thisAnimal.runningAnimal.displayObject)
				end
			end
			thisAnimal.addCaughtAnimalLayer = function()
				if thisAnimal.caughtAnimal.displayObject then
					localGroup:insert(thisAnimal.caughtAnimal.displayObject)
				end
			end
			local defineAnimation
			
			local function move()
				if animalPaused then return end
				if not thisAnimal then Runtime:removeEventListener( "enterFrame", move ); return end
				if not thisAnimal.displayObject then Runtime:removeEventListener( "enterFrame", move ); return end
				if not thisAnimal.displayObject.xScale then Runtime:removeEventListener( "enterFrame", move ); return end
				if not isDragging then
					local movementSpeed = 2*scale
					movementSpeed = movementSpeed * thisAnimal.displayObject.xScale * animalSpeed
					thisAnimal.displayObject.x = thisAnimal.displayObject.x + movementSpeed
					
					if  thisAnimal.displayObject.x < -50*scale then
						
						thisAnimal.displayObject.y = yPos
						kidnappedAnimalsCount = kidnappedAnimalsCount - negativePoints
						if not thisAnimal.ignoreNegative then
							addMisses(1, thisAnimal.displayObject.x, thisAnimal.displayObject.y)
						else
							thisAnimal.ignoreNegative = nil
						end
						if kidnappedAnimalsCount < 0 then
							kidnappedAnimalsCount = 0
						end
						
						animalSpeed = math.random() * 3 + 0.5
						thisAnimal.runningAnimal.setSpeed((animalSpeed * 0.1) * speedMultiplier)
						
						thisAnimal.runningAnimal.hide()
						thisAnimal.caughtAnimal.hide()
						
						thisAnimal.displayObject.x = width+200*scale
						
						thisAnimal.displayObject.y = yPos
						defineAnimation()
						
						Runtime:removeEventListener( "enterFrame", move )
						thisAnimal.startRunning ()
					end
				end
			end
			
			local function talk()
				if thisAnimal.isAlive and thisAnimal.isRunning then
					if math.random(40) > 35 then
						if not isDragging and not animalPaused then
							if animalSoundChannel then
								if animalSoundChannel>4 then
									audio.stop(animalSoundChannel)
								end
							end
							animalSoundChannel = audio.play(runningSound,{loops=0})
						end
					end
				end
				timer.performWithDelay(5000, talk)
			end
			talk()
			
			thisAnimal.startRunning = function()
				Runtime:addEventListener( "enterFrame", move )
				
				thisAnimal.caughtAnimal.stop()
				thisAnimal.runningAnimal.stop()
				
				thisAnimal.runningAnimal.start()
				thisAnimal.runningAnimal.appear()
				thisAnimal.caughtAnimal.hide()
				
				if RBlinks then
					RBlinks.openEyes()
					RBlinks.startBlinking()
				end
				if CBlinks then
					CBlinks.openEyes()
					CBlinks.stopBlinking()
				end
				
				thisAnimal.isRunning = true
			end
			
			thisAnimal.pauseAnimal = function()
				if thisAnimal.caughtAnimal.isMoving then
					thisAnimal.caughtAnimal.wasMoving = true
					thisAnimal.caughtAnimal.stop()
					CBlinks.stopBlinking()
				end
				if thisAnimal.runningAnimal.isMoving then
					thisAnimal.runningAnimal.wasMoving = true
					thisAnimal.runningAnimal.stop()
					RBlinks.stopBlinking()
				end
				animalPaused=true
			end
			
			thisAnimal.resumeAnimal = function()
				if thisAnimal.caughtAnimal.wasMoving then
					thisAnimal.caughtAnimal.wasMoving = nil
					thisAnimal.caughtAnimal.start()
					CBlinks.startBlinking()
				end
				if thisAnimal.runningAnimal.wasMoving then
					thisAnimal.runningAnimal.wasMoving = nil
					thisAnimal.runningAnimal.start()
					RBlinks.startBlinking()
				end
				animalPaused=nil
			end
			
			defineAnimation = function ()
				if not thisAnimal then return end
				if not thisAnimal.displayObject then return end
				if not thisAnimal.displayObject.xScale then return end
				distanceScale = (thisAnimal.displayObject.y / (height/2))^(0.65)
				if distanceScale == 0 then
					distanceScale = 1
				end
				if not isDragging then
					if not
					(	thisAnimal.displayObject.x < (width/2) + 100 and
						thisAnimal.displayObject.x > (width/2) - 100 and
						thisAnimal.displayObject.y < height and
						thisAnimal.displayObject.y > height/3 - 100)
					then
						thisAnimal.displayObject.xScale = -1 * distanceScale
						thisAnimal.displayObject.yScale = distanceScale
					else
						kidnappedAnimalsCount = kidnappedAnimalsCount + positivePoints
						thisAnimal.displayObject.x = -100*scale
						thisAnimal.ignoreNegative = true
						kidnapAnimal(ID,positivePoints,negativePoints)
					end
				end
			end
			defineAnimation()
			
			thisAnimal.sayHello = function ()
				print("hello")
			end
			
			thisAnimal.kill = function()
				Runtime:removeEventListener( "enterFrame", move )
				
				if thisAnimal.runningAnimal then
					thisAnimal.runningAnimal.kill()
				end
				if thisAnimal.caughtAnimal then
					thisAnimal.caughtAnimal.kill()
				end
				
				if thisAnimal.displayObject then
					if thisAnimal.displayObject.parent then
						thisAnimal.displayObject.parent: remove(thisAnimal.displayObject)
					end
				end
				
				thisAnimal.isAlive = false
			end
			
			thisAnimal.vanish = function(time)
				thisAnimal.runningAnimal.vanish(time)
				thisAnimal.caughtAnimal.vanish(time)
			end
			
			local function touchScreen (event)
				lastAnimalTime = system.getTimer()
				if event.phase == "moved" then
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
					local x = (event.x - event.xStart) + thisAnimal.displayObject.markX
					local y = (event.y - event.yStart) + thisAnimal.displayObject.markY
					thisAnimal.displayObject.x, thisAnimal.displayObject.y = x, y    -- move object based on calculations above
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = x-250*scale, y
				end
				elseif event.phase == "ended" then
					Runtime:removeEventListener( "touch", touchScreen )
					if animalSoundChannel then
						if animalSoundChannel>4 then
							audio.stop(animalSoundChannel)
						end
					end
					
					thisAnimal.caughtAnimal.hide()
					thisAnimal.caughtAnimal.stop()
					thisAnimal.runningAnimal.show()
					thisAnimal.runningAnimal.start()
					
					if RBlinks then
						RBlinks.openEyes()
						RBlinks.startBlinking()
					end
					if CBlinks then
						CBlinks.openEyes()
						CBlinks.stopBlinking()
					end
					
					isDragging = false
					isDraggingAnimal = false
					
					if (event.y < 150) then
						event.y = 150
					end
					if (event.y > 300) then
						event.y = 300
					end
					
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
					local x = (event.x - event.xStart) + thisAnimal.displayObject.markX
					local y = (event.y - event.yStart) + thisAnimal.displayObject.markY
					thisAnimal.displayObject.x, thisAnimal.displayObject.y = x, y    -- move object based on calculations above
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = x-250*scale, y
					end
					
					thisAnimal.displayObject.markX = nil
					thisAnimal.displayObject.markY = nil
					
					if animalSoundChannel then
						if animalSoundChannel>4 then
							audio.stop(animalSoundChannel)
						end
					end
					animalSoundChannel = audio.play(dropSound,{loops=0})
					
					defineAnimation ()
					releaseAnimal(ID)
				end
			end
			
			local function touchAnimal (event)
				if event.phase == "began" then
					if isDraggingAnimal then
						return
					end
					isDraggingAnimal = true
					
					if animalSoundChannel then
						if animalSoundChannel>4 then
							audio.stop(animalSoundChannel)
						end
					end
					animalSoundChannel = audio.play(caughtSound,{loops=-1})
					
					Runtime:addEventListener( "touch", touchScreen )
					
					thisAnimal.displayObject.markX = thisAnimal.displayObject.x    -- store x location of object
					thisAnimal.displayObject.markY = thisAnimal.displayObject.y    -- store y location of object
					
					thisAnimal.caughtAnimal.show()
					thisAnimal.caughtAnimal.start()
					thisAnimal.runningAnimal.hide()
					thisAnimal.runningAnimal.stop()
					
					if RBlinks then
						RBlinks.openEyes()
						RBlinks.stopBlinking()
					end
					if CBlinks then
						CBlinks.openEyes()
						CBlinks.startBlinking()
					end
					
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = thisAnimal.displayObject.x-250*scale, thisAnimal.displayObject.y
					
					isDragging = true
					
					captureAnimal()
				end
			end
			
			thisAnimal.displayObject:addEventListener( "touch", touchAnimal )
			
			return thisAnimal
		end
		
		local animal1 = newAnimal(1,100,0.3,1)
		local animal2 = newAnimal(2,120,0.3,2)
		local animal3 = newAnimal(4,125,0.3,3)
		local animal4 = newAnimal(2,150,0.3,4)
		local animal5 = newAnimal(1,150,0.3,5)
		local animal6 = newAnimal(3,200,0.3,6)
		
		animal1.addRunningAnimalLayer()
		animal2.addRunningAnimalLayer()
		animal3.addRunningAnimalLayer()
		animal4.addRunningAnimalLayer()
		animal5.addRunningAnimalLayer()
		animal6.addRunningAnimalLayer()
		
		localGroup:insert(basketBack)
		localGroup:insert(kidnappedAnimalsGroup)
		localGroup:insert(basketFront)
		
		animal1.addCaughtAnimalLayer()
		animal2.addCaughtAnimalLayer()
		animal3.addCaughtAnimalLayer()
		animal4.addCaughtAnimalLayer()
		animal5.addCaughtAnimalLayer()
		animal6.addCaughtAnimalLayer()
		
		localGroup:insert(counterCircle)
		localGroup:insert(text1)
		
		localGroup:insert(timerCircle)
		localGroup:insert(text2)
		
		local function continue()
			localGroup:remove(basket)
			localGroup:remove(loadingBackground)
			
			localGroup:remove(counterCircle)
			localGroup:remove(text1)
			
			localGroup:remove(timerCircle)
			localGroup:remove(text2)
			
			animal1.kill()
			animal2.kill()
			animal3.kill()
			animal4.kill()
			animal5.kill()
			animal6.kill()
			
			animal1=nil
			animal2=nil
			animal3=nil
			animal4=nil
			animal5=nil
			animal6=nil
			
			if countdownTimer then
				timer.cancel(countdownTimer)
			end
			
			continue = nil
			killInteraction = nil
		end
		killInteraction = function()
			startInteraction=nil
			vanish=nil
			continue()
		end
		
		vanish = function ()
			finishTime = system.getTimer()
			
			pauseIt = nil
			continueIt=nil
			
			if countdownTimer then
				timer.cancel(countdownTimer)
			end
			
			startTheParty()
			timer.performWithDelay(300, continue)
			
			vanish = nil
		end
		
		startInteraction = function()
			startTime = system.getTimer()
			local aat1 = timer.performWithDelay(1300, animal1.startRunning)
			local aat2 = timer.performWithDelay(3000, animal2.startRunning)
			local aat3 = timer.performWithDelay(4000, animal3.startRunning)
			local aat4 = timer.performWithDelay(7600, animal4.startRunning)
			local aat5 = timer.performWithDelay(6000, animal5.startRunning)
			local aat6 = timer.performWithDelay(5500, animal6.startRunning)
			
			loadingBackground.isVisible = true
			basketBack.isVisible = true
			basketFront.isVisible = true
			
			counterCircle.alpha = 0
			counterCircle.isVisible = true
			transition.to(counterCircle,{alpha = 1,time = 300})
			
			text1.isVisible = true
			text1.alpha = 0
			transition.to(text1,{alpha = 1,time = 300})
			
			if timeLimit>0 then
				timerCircle.alpha = 0
				timerCircle.isVisible = true
				transition.to(timerCircle,{alpha = 1,time = 300})
				
				text2.alpha = 0
				text2.isVisible = true
				transition.to(text2,{alpha = 1,time = 300})
				
				timer.performWithDelay(1000, updateTimer)
			end
			
			local pausedTime = 0
			pauseIt = function()
				pausedTime = system.getTimer()
				if countdownTimer then
					timer.pause(countdownTimer)
				end
				if aat1 then timer.pause(aat1) end
				if aat2 then timer.pause(aat2) end
				if aat3 then timer.pause(aat3) end
				if aat4 then timer.pause(aat4) end
				if aat5 then timer.pause(aat5) end
				if aat6 then timer.pause(aat6) end
				animal1.pauseAnimal()
				animal2.pauseAnimal()
				animal3.pauseAnimal()
				animal4.pauseAnimal()
				animal5.pauseAnimal()
				animal6.pauseAnimal()
			end
			
			continueIt = function()
				if pausedTime ~= 0 then
					startTime = startTime + (system.getTimer() - pausedTime)
				end
				pausedTime = 0
				if countdownTimer then
					timer.resume(countdownTimer)
				end
				if aat1 then timer.resume(aat1) end
				if aat2 then timer.resume(aat2) end
				if aat3 then timer.resume(aat3) end
				if aat4 then timer.resume(aat4) end
				if aat5 then timer.resume(aat5) end
				if aat6 then timer.resume(aat6) end
				animal1.resumeAnimal()
				animal2.resumeAnimal()
				animal3.resumeAnimal()
				animal4.resumeAnimal()
				animal5.resumeAnimal()
				animal6.resumeAnimal()
			end
			
			pauseIt()
			continueIt()
			
			startInteraction = nil
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
		
		local maryWings = display.newImage("assets/budsDeFrente.png")
		maryWings.x,maryWings.y,maryWings.xScale,maryWings.yScale = 525.75/2.5 +142 ,776.30/2.5 -65 ,1/7 ,1/7
		
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
			
			saveData(1,2)
			
			soundController.kill("bgsound")
			soundController.playNew{
						path = "assets/sound/voices/cap1/int1_MWellDone.mp3",
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
			
			local points = calculatePoints(misses, extras, startTime, finishTime, difficultyLevel, "com.tapmediagroup.catchanimals")
			
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
			director:changeScene("Interactivity1","crossFade")
			repeatScene=nil
		end
		
		local function changeScene()
			adPreloader:changeScene("Adventure2","crossFade")
			--director:changeScene("Adventure2","crossFade")
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
			local whiteBackground = display.newRect(0,0,width,height)
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
			
			transition.to(star1,{alpha=1,time=700})
			transition.to(star2,{alpha=1,time=700})
			transition.to(star3,{alpha=1,time=700})
			transition.to(star4,{alpha=1,time=700})
			
			transition.to(star1,{xScale=3,yScale=3,		time=1500,transition=easing.inExpo})
			transition.to(star2,{xScale=2.5,yScale=2.5,	time=1500,transition=easing.inExpo})
			transition.to(star3,{xScale=2,yScale=2,		time=1500,transition=easing.inExpo})
			transition.to(star4,{xScale=3.5,yScale=3.5,	time=1500,transition=easing.inExpo})
			
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