module(..., package.seeall)

new = function ( params )
	Runtime:removeEventListener( "system", systemEvent )
	
	soundController.killAll()
	
	------------------
	-- Imports
	------------------
	local ui = require("ui")
	
	------------------
	-- Variables
	------------------
	local showPlayAgainMessage = false
	
	if params then
		showPlayAgainMessage = params.showPlayAgainMessage
	end
	
	local width = display.contentWidth
	local height = display.contentHeight
	
	local viewableContentWidth = display.viewableContentWidth
	local viewableContentHeight = display.viewableContentHeight
	
	local screenOriginX = display.screenOriginX
	local screenOriginY = display.screenOriginY
	
	local timesTouchedSun = 0
	
	local animatingSunRotation = false
	local sunRotation = 0
	local rotateSunToLeft = false
	local timesChangedRotationOfTheSun = 0
	
	local animatingSunY = false
	local sunY = 0
	local sunToUp = true
	local timesChangedYMovementOfTheSun = 0
	
	local playingMarySound = false
	
	isDraggingAnimal = false
	
	local maxUnlockedLevel = 1
	local nextLevel = 1
	
	local pdpath = system.pathForFile( "progressData", system.DocumentsDirectory )
	local fh, reason = io.open( pdpath, "r" )
	if fh then
		local contents = fh:read( "*a" )
		for i=1,#levelIDS do
			if string.find(contents,"-"..levelIDS[i]) then
				maxUnlockedLevel = i+1
			end
			if string.find(contents,"nl"..levelIDS[i]) then
				nextLevel = i
			end
		end
	end
	
	if maxUnlockedLevel>#levelIDS then
		maxUnlockedLevel = #levelIDS
	end
	
	local startAdventure,continueAdventure,startFromAdventure
	local function startButtonFunction()
		if nextLevel == 1 then
			director:openPopUp({startAdventure = startAdventure,continueAdventure = continueAdventure}, "selectDiff", nil )
		else
			director:openPopUp({startAdventure = startAdventure,continueAdventure = continueAdventure}, "contMenu", nil )
		end
	end
	
	local a1t,a2t,a3t,a4t,a5t,a6t
	local function registerAnimalTouch(ab)
		if ab==1 then
			a1t=true
		end
		if ab==2 then
			a2t=true
		end
		if ab==3 then
			a3t=true
		end
		if ab==4 then
			a4t=true
		end
		if ab==5 then
			a5t=true
		end
		if ab==6 then
			a6t=true
		end
		if a1t and a2t and a3t and a4t and a5t and a6t then
			unlockAchievement("com.tapmediagroup.MaryTheFairy.TouchAnimalsMenu","Touch animals on menu","Animals at the menu...")
		end
	end
	
	--====================================================================--
	-- SET UP A LOCAL GROUP THAT WILL BE RETURNED
	--====================================================================--
	local localGroup = display.newGroup()
	
	-- LOWER LAYER, THE BACKGROUND COLOR
	local backgroundColor = display.newRect(0,0,width,height)
	backgroundColor:setFillColor(255,255,235)
	localGroup:insert(backgroundColor)
	
	-- THE SUN
	local sun = display.newImageRect("assets/sun.png",150,150)
	sun:setReferencePoint(display.CenterReferencePoint)
	sun.xScale,sun.yScale = 1.3,1.3
	sun.x = width/2
	sun.y = height/4
	sun.rotation=15
	localGroup:insert(sun)
	
	--====================================================================--
	-- SET UP A GROUP FOR THE MOUNTAINS
	--====================================================================--
	local mountainsGroup = display.newGroup()
	
	local mountain = display.newImageRect("assets/world/mountains.png",width,height)
	mountain:setReferencePoint(display.TopLeftReferencePoint)
	mountain.x = 200
	mountain.y = 0
	mountain:setReferencePoint(display.BottomLeftReferencePoint)
	mountain.xScale,mountain.yScale = 1.25,1.25
	
	local mountain2 = display.newImageRect("assets/world/mountains.png",width,height)
	mountain2:setReferencePoint(display.TopLeftReferencePoint)
	mountain2.x = -width+200
	mountain2.y = 0
	mountain2:setReferencePoint(display.BottomRightReferencePoint)
	mountain2.xScale,mountain2.yScale = 1.25,1.25
	
	mountainsGroup:insert(mountain)
	mountainsGroup:insert(mountain2)
	
	localGroup:insert(mountainsGroup)
	
	-- CLOUD 1
	local cloud1 = display.newImageRect("assets/cloud.png",80,80)
	cloud1:setReferencePoint(display.CenterReferencePoint)
	cloud1.x = 150
	cloud1.y = 80
	localGroup:insert(cloud1)
	
	-- CLOUD 2
	local cloud2 = display.newImageRect("assets/cloud.png",83,83)
	cloud2:setReferencePoint(display.CenterReferencePoint)
	cloud2.x = 350
	cloud2.y = 85
	localGroup:insert(cloud2)
	
	-- CLOUD 3
	local cloud3 = display.newImageRect("assets/cloud.png",86,86)
	cloud3:setReferencePoint(display.CenterReferencePoint)
	cloud3.x = 50
	cloud3.y = 90
	localGroup:insert(cloud3)
	
	-- CLOUD 4
	local cloud4 = display.newImageRect("assets/cloud.png",89,89)
	cloud4:setReferencePoint(display.CenterReferencePoint)
	cloud4.x = 420
	cloud4.y = 95
	localGroup:insert(cloud4)
	
	local function rotateElementInWorld(uiElement,degrees)
		local relativeX = uiElement.x - width*0.5
		local relativeY = uiElement.y - width*1.5
		
		local newX= width*0.5 + (math.cos(degrees*math.pi/180)*relativeX - math.sin(degrees*math.pi/180)*relativeY)
		local newY= width*1.5 + (math.sin(degrees*math.pi/180)*relativeX + math.cos(degrees*math.pi/180)*relativeY)
		
		uiElement.x=newX;
		uiElement.y=newY;
		
		uiElement.rotation = uiElement.rotation+degrees
	end
	
	--======================================
	-- FAR WORLD PLANE
	--======================================
	local farWorldGroup = display.newGroup()
	
	local planeContainer = display.newRect(-width,0,width*3,width*3)
	planeContainer:setFillColor(0,0,0,0)
	
	local plane = display.newImageRect("assets/world/BG3.png",272,273)
	plane:setReferencePoint(display.TopLeftReferencePoint)
	plane.x = 417
	plane.y = 160
	
	farWorldGroup:insert(planeContainer)
	farWorldGroup:insert(plane)
	
	farWorldGroup:setReferencePoint(display.CenterReferencePoint)
	farWorldGroup.rotation=-45
	
	localGroup:insert(farWorldGroup)
	
	--======================================
	-- MIDDLE WORLD PLANE
	--======================================
	local middlePlaneGroup = display.newGroup()
	
	local planeContainer = display.newRect(-width,0,width*3,width*3)
	planeContainer:setFillColor(0,0,0,0)
	middlePlaneGroup:insert(planeContainer)
	
	local plane = display.newImageRect("assets/world/BG2.png",width*3/3,width*1.44233/3)
	plane:setReferencePoint(display.TopLeftReferencePoint)
	plane:setReferencePoint(display.BottomCenterReferencePoint)
	plane.x = width/2
	plane.y = width*1.44233 - 80
	plane.xScale,plane.yScale = 3,3
	middlePlaneGroup:insert(plane)
	
	middlePlaneGroup:setReferencePoint(display.CenterReferencePoint)
	middlePlaneGroup.rotation=-45
	localGroup:insert(middlePlaneGroup)
	
	--====================================================================--
	-- SET UP A BACKGROUND GROUP
	--====================================================================--
	local worldGroup = display.newGroup()
	
	-- SET UP A RECTANGLE TO DEFINE THE BACGROUNDS BOUNDS
	local container = display.newRect(-width,0,width*3,width*3)
	container:setFillColor(0,0,0,0)
	worldGroup:insert(container)
	
	local dropSound = audio.loadSound("assets/sound/drop.mp3")
	local animalSoundChannel = 19
	--======================================
	-- ANIMALS GROUP 2
	--======================================
	local animalsGroup2 = display.newGroup()
	
	local function newAnimal2 (ID, yPos, scale, reg)
			local thisAnimal = {}
			
			local openEyesR = nil
			local closedEyesR = nil
			
			local openEyesC = nil
			local closedEyesC = nil
			
			thisAnimal.isAlive = true
			
			local caughtSound = nil
			
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
			if ID == 1 then
				openEyesR = display.newImage("assets/rabbit/EyesOpen.png")
				closedEyesR = display.newImage("assets/rabbit/EyesClosed.png")
				
				openEyesC = display.newImage("assets/rabbitCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/rabbitCaught/EyesClosed.png")
				
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
					scale = scale * 0.5 * 1.2 * 5,
					y = -200,
					speed = 0.7
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
					x = -50,
					y = -50,
					scale = 0.1 * 3.333,
					speed = 1
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				caughtSound  = audio.loadSound("assets/sound/conejocatch.mp3")
			elseif ID == 2 then
				openEyesR = display.newImage("assets/frog/EyesOpen.png")
				closedEyesR = display.newImage("assets/frog/EyesClosed.png")
				
				openEyesC = display.newImage("assets/frogCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/frogCaught/EyesClosed.png")
				
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
					scale = scale * 0.8 * 3,
					speed = 0.5
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
					x = -60,
					y = -60,
					scale = 0.1 * 5,
					speed = 0.5
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				caughtSound  = audio.loadSound("assets/sound/frogcatch.mp3")
			else
				print("no animal")
			end
			thisAnimal.displayObject.x = -200*scale
			
			local RBlinks = ui.blink(openEyesR,closedEyesR)
			local CBlinks = ui.blink(openEyesC,closedEyesC)
			
			if thisAnimal.runningAnimal.displayObject then
				thisAnimal.displayObject:insert(thisAnimal.runningAnimal.displayObject)
			end
			animalsGroup2:insert(thisAnimal.displayObject)
			
			thisAnimal.addCaughtAnimalLayer = function()
				if thisAnimal.caughtAnimal.displayObject then
					localGroup:insert(thisAnimal.caughtAnimal.displayObject)
				end
			end
			
			thisAnimal.startRunning = function()
				thisAnimal.caughtAnimal.stop()
				thisAnimal.caughtAnimal.hide()
				
				thisAnimal.runningAnimal.start()
				thisAnimal.runningAnimal.appear()
				
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
			
			thisAnimal.kill = function()
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
			
			thisAnimal.appear = function(time)
				thisAnimal.runningAnimal.appear(time)
			end
			
			local function touchScreen (event)
				event = correctTouch(event)
				if event.phase == "moved" then
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x, event.y
				end
				elseif event.phase == "ended" then
					Runtime:removeEventListener( "touch", touchScreen )
					audio.stop(animalSoundChannel)
					
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
					
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
						thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x, event.y
					end
					
					thisAnimal.displayObject.markX = nil
					thisAnimal.displayObject.markY = nil
					
					audio.stop(animalSoundChannel)
					audio.play(dropSound,{loops=0, channel=animalSoundChannel})
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
				end
			end
			
			local function touchAnimal (event)
				event = correctTouch(event)
				if event.phase == "began" then
					registerAnimalTouch(reg)
					if isDraggingAnimal then
						return
					end
					isDraggingAnimal = true
					
					audio.stop(animalSoundChannel)
					audio.play(caughtSound,{loops=-1, channel=animalSoundChannel})
					
					Runtime:addEventListener( "touch", touchScreen )
					
					thisAnimal.displayObject.originalX = thisAnimal.displayObject.x    -- store x location of object
					thisAnimal.displayObject.originalY = thisAnimal.displayObject.y    -- store y location of object
					
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
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
					
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x, event.y
					
					isDragging = true
				end
			end
			
			thisAnimal.displayObject:addEventListener( "touch", touchAnimal )
			
			return thisAnimal
		end
	
	local animal3 = newAnimal2 (1,0,1,3)
	local animal4 = newAnimal2 (2,0,1,4)
	
	animalsGroup2.y = 160
	animalsGroup2.xScale,animalsGroup2.yScale = 0.1,0.1
	
	animal4.displayObject.x = 300
	
	local ag2ToLeft
	local ag2ToRight
	
	ag2ToLeft = function()
		if animalsGroup2 then
			animalsGroup2.xScale = -0.1
			animalsGroup2.x = width + 100
			if ag2ToRight then
				timer.performWithDelay(6000, ag2ToRight)
				transition.to(animalsGroup2,{time = 6000, x = 300})
			end
		end
	end
	
	ag2ToRight = function()
		if animalsGroup2 then
			animalsGroup2.xScale = 0.1
			animalsGroup2.x = 200
			if ag2ToLeft then
				timer.performWithDelay(6000, ag2ToLeft)
				transition.to(animalsGroup2,{time = 6000, x = width})
			end
		end
	end
	
	worldGroup:insert(animalsGroup2)
	
	--======================================
	-- SHEEPS
	--======================================
	local function newSheep (xMin, xMax, scale, reg)
			local thisAnimal = {}
			
			local isDragging = false
			
			local movementDirection = 1
			
			local caughtSound = nil
			
			local loops = 0
			local lastFrame = 0
			
			local minX = xMin
			local maxX = xMax
			
			local animalTimer
			
			thisAnimal.isAlive = true
			
			if not yPos then
				yPos = 0
			end
			
			if not scale then
				scale = 1
			end
			
			local openEyesR = display.newImage("assets/sheep/EyesOpen.png")
			local closedEyesR = display.newImage("assets/sheep/EyesClosed.png")
			
			local openEyesC = display.newImage("assets/sheepCaught/EyesOpen.png")
			local closedEyesC = display.newImage("assets/sheepCaught/EyesClosed.png")
			
			thisAnimal.displayObject = display.newGroup()
			thisAnimal.displayObject.x = math.random(minX,maxX)
			
			thisAnimal.runningAnimal = ui.newAnimation{
					comps = {
						{
							--delanteraDerecha
							path = "assets/sheep/delanterader.png",
							x = { 293.5,293.5,293.5,293.55,293.5,293.5,293.5,293.55 },
							y = { 445.65,440.15,434.65,429.15,434.65,440.15,445.65,451.15 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--traceraDerecha
							path = "assets/sheep/tracerader.png",
							x = { 459.65,459.65,459.65,459.65,459.65,459.65,459.65,459.65 },
							y = { 369.15,363.65,358.15,352.65,358.15,363.65,369.15,374.65 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--delanteraIzquierda
							path = "assets/sheep/delanteraizq.png",
							x = { 377.05,377.05,377.05,377.1,377.05,377.05,377.05,377.1 },
							y = { 469.2,463.7,458.2,452.7,458.2,463.7,469.2,474.7 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--traceraIzquierda
							path = "assets/sheep/traceraizq.png",
							x = { 532.4,532.4,532.4,532.4,532.4,532.4,532.4,532.4 },
							y = { 373.9,368.4,362.9,357.4,362.9,368.4,373.9,379.4 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--body
							path = "assets/sheep/body.png",
							x = { 384.2,384.2,384.2,384.2,384.2,384.2,384.2,384.2 },
							y = { 265.3,258.3,251.35,244.35,251.35,258.3,265.3,272.35 },
							rotation = { 0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--head
							path = "assets/sheep/head.png",
							x = { 241.45,241.5,241.5,241.6,241.5,241.5,241.45,241.45 },
							y = { 329.45,324.3,319.35,314.3,319.35,324.3,329.45,334.45 },
							rotation = { -0.3260955810546875,-0.653045654296875,-0.979949951171875,-1.306793212890625,-0.979949951171875,-0.653045654296875,-0.3260955810546875,-0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesR,
							scaleComponent = true,
							x = { 241.45,241.5,241.5,241.6,241.5,241.5,241.45,241.45 },
							y = { 329.45,324.3,319.35,314.3,319.35,324.3,329.45,334.45 },
							rotation = { -0.3260955810546875,-0.653045654296875,-0.979949951171875,-1.306793212890625,-0.979949951171875,-0.653045654296875,-0.3260955810546875,-0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesR,
							scaleComponent = true,
							x = { 241.45,241.5,241.5,241.6,241.5,241.5,241.45,241.45 },
							y = { 329.45,324.3,319.35,314.3,319.35,324.3,329.45,334.45 },
							rotation = { -0.3260955810546875,-0.653045654296875,-0.979949951171875,-1.306793212890625,-0.979949951171875,-0.653045654296875,-0.3260955810546875,-0.0008697509765625 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},
					},
					x = -380*scale,
					scale = scale*0.75 * 1.666,
					speed = 0.5
				}
			thisAnimal.caughtAnimal = ui.newAnimation{
					comps = {
						{
							--Body
							path = "assets/sheepCaught/body.png",
							x = { 260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95,260.95 },
							y = { 244.85,241.85,238.85,235.85,232.9,235.85,238.85,241.85,244.85,247.85 },
							rotation = { 0,0,0,0,0,0,0,0,0,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--Head
							path = "assets/sheepCaught/head.png",
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = closedEyesC,
							scaleComponent = true,
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							displayObject = openEyesC,
							scaleComponent = true,
							x = { 255,255.2,255.35,255.55,255.7,255.55,255.35,255.2,255,254.85 },
							y = { 118.15,115.05,111.95,108.85,105.75,108.85,111.95,115.05,118.15,121.3 },
							rotation = { 1.506011962890625,3.011688232421875,4.5175628662109375,6.02325439453125,7.52923583984375,6.02325439453125,4.5175628662109375,3.011688232421875,1.506011962890625,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--LArm
							path = "assets/sheepCaught/larm.png",
							x = { 329.5,330.5,331.4,332.3,333.35,332.3,331.4,330.5,329.5,329.05 },
							y = { 239.75,236.35,233.05,229.7,226.35,229.7,233.05,236.35,239.75,242.8 },
							rotation = { 13.017288208007813,11.787277221679688,10.556304931640625,9.324752807617188,8.093017578125,9.324752807617188,10.556304931640625,11.787277221679688,13.017288208007813,14.25408935546875 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--RLeg
							path = "assets/sheepCaught/rleg.png",
							x = { 228.9,229.85,230.85,231.8,232.75,231.8,230.85,229.85,228.9,227.95 },
							y = { 394.95,391.9,388.85,385.75,382.65,385.75,388.85,391.9,394.95,398 },
							rotation = { -1.3513641357421875,-2.702972412109375,-4.0550537109375,-5.406951904296875,-6.758026123046875,-5.406951904296875,-4.0550537109375,-2.702972412109375,-1.3513641357421875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--RArm
							path = "assets/sheepCaught/rarm.png",
							x = { 206.9,206.2,205.5,204.8,204.1,204.8,205.5,206.2,206.9,207.65 },
							y = { 237.55,234.5,231.4,228.3,225.2,228.3,231.4,234.5,237.55,240.65 },
							rotation = { 1.1092987060546875,2.2186431884765625,3.328948974609375,4.4376068115234375,5.54815673828125,4.4376068115234375,3.328948974609375,2.2186431884765625,1.1092987060546875,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},{
							--LLeg
							path = "assets/sheepCaught/lleg.png",
							x = { 310.15,309.05,307.95,306.85,305.75,306.85,307.95,309.05,310.15,311.3 },
							y = { 390.75,387.75,384.75,381.75,378.65,381.75,384.75,387.75,390.75,393.7 },
							rotation = { 1.59075927734375,3.1808013916015625,4.7711639404296875,6.361968994140625,7.952423095703125,6.361968994140625,4.7711639404296875,3.1808013916015625,1.59075927734375,0 },
							coordsXScaleOffset = 0.6,
							coordsYScaleOffset = 0.6,
						},
					},
					x = -20,
					y = -25,
					scale = scale * 1.666,
					speed = 0.5
				}
			
			thisAnimal.runningAnimal.hide()
			thisAnimal.caughtAnimal.hide()
			
			local RBlinks = ui.blink(openEyesR,closedEyesR)
			local CBlinks = ui.blink(openEyesC,closedEyesC)
			
			caughtSound  = nil
			
			worldGroup:insert(thisAnimal.displayObject)
			thisAnimal.addRunningAnimalLayer = function()
				if thisAnimal.runningAnimal.displayObject then
					thisAnimal.displayObject:insert(thisAnimal.runningAnimal.displayObject)
					thisAnimal.displayObject:setReferencePoint(display.TopCenterReferencePoint)
				end
			end
			thisAnimal.addCaughtAnimalLayer = function()
				if thisAnimal.caughtAnimal.displayObject then
					localGroup:insert(thisAnimal.caughtAnimal.displayObject)
				end
			end
			
			local move
			local defineAnimation
			
			move = function()
				if not thisAnimal.displayObject then
					Runtime:removeEventListener( "enterFrame", move )
					return
				end
				if thisAnimal.runningAnimal.isMoving then
					if not isDragging then
						local thisFrame = thisAnimal.runningAnimal.getActualFrame()
						if (thisFrame < lastFrame) then
							loops = loops + 1
							if loops > 3 then
								loops = 0
								thisAnimal.runningAnimal.stop()
								Runtime:removeEventListener( "enterFrame", move )
							end
						end
						lastFrame = thisFrame
						
						local movementSpeed = -1*scale
						movementSpeed = movementSpeed * thisAnimal.displayObject.xScale
						thisAnimal.displayObject.x = thisAnimal.displayObject.x + movementSpeed
					end
				else
					Runtime:removeEventListener( "enterFrame", move )
				end
			end
			
			defineAnimation = function()
				if not thisAnimal then return end
				if not thisAnimal.displayObject then return end
				if not thisAnimal.displayObject.x then return end
				if thisAnimal.displayObject.x < xMax + 125 then
					if thisAnimal.displayObject.x > xMax then
						thisAnimal.displayObject.x = xMax
					end
				end
				if not thisAnimal.displayObject then
					return
				end
				if not isDragging then
					local direction = 1
					local thisX = thisAnimal.displayObject.x + direction*100*scale
					if thisX<minX or thisX>maxX then
						direction = direction*-1
					end
					if thisAnimal.displayObject.x<minX then
						direction = 1
					end
					if thisAnimal.displayObject.x>maxX then
						direction = -1
					end
					
					thisAnimal.displayObject.xScale = -direction
					thisAnimal.displayObject.yScale = 1
					if (math.random(4) > 1 and (not thisAnimal.runningAnimal.isMoving)) then
						if math.random(20) > 10 then
							direction = -1
						end
						if thisAnimal.displayObject.x > width-50*thisAnimal.displayObject.xScale then
							thisAnimal.displayObject.x = math.random(minX,maxX)
							thisAnimal.runningAnimal.appear(500)
							defineAnimation()
							return
						end
						thisAnimal.runningAnimal.start()
						Runtime:addEventListener("enterFrame",move)
					end
					
					animalTimer = timer.performWithDelay(2000, defineAnimation)
				end
			end
			
			thisAnimal.startRunning = function()
				defineAnimation()
				
				thisAnimal.caughtAnimal.stop()
				thisAnimal.runningAnimal.stop()
				
				thisAnimal.runningAnimal.stop()
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
			
			thisAnimal.kill = function()
				Runtime:removeEventListener( "enterFrame", move )
				
				timer.cancel(animalTimer)
				
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
			
			thisAnimal.appear = function(time)
				thisAnimal.runningAnimal.appear(time)
			end
			
			local function touchScreen (event)
				event = correctTouch(event)
				if event.phase == "moved" then
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x, event.y
				end
				elseif event.phase == "ended" then
					Runtime:removeEventListener( "touch", touchScreen )
					audio.stop(animalSoundChannel)
					
					thisAnimal.caughtAnimal.hide()
					thisAnimal.caughtAnimal.stop()
					thisAnimal.runningAnimal.show()
					thisAnimal.runningAnimal.stop()
					
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
					
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
						thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x, event.y
					end
					
					thisAnimal.displayObject.markX = nil
					thisAnimal.displayObject.markY = nil
					
					audio.stop(animalSoundChannel)
					audio.play(dropSound,{loops=0, channel=animalSoundChannel})
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
					defineAnimation ()
				end
			end
			
			local function touchAnimal (event)
				event = correctTouch(event)
				if event.phase == "began" then
					registerAnimalTouch(reg)
					if isDraggingAnimal then
						return
					end
					isDraggingAnimal = true
					
					audio.stop(animalSoundChannel)
					audio.play(caughtSound,{loops=-1, channel=animalSoundChannel})
					
					Runtime:addEventListener( "touch", touchScreen )
					
					thisAnimal.displayObject.originalX = thisAnimal.displayObject.x    -- store x location of object
					thisAnimal.displayObject.originalY = thisAnimal.displayObject.y    -- store y location of object
					
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
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
					
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x,event.y
					
					isDragging = true
				end
			end
			
			thisAnimal.displayObject:addEventListener( "touch", touchAnimal )
			
			return thisAnimal
		end
	
	local sheep1 = newSheep (250, 270, 0.08, 5)
	sheep1.displayObject.y = 100
	sheep1.addRunningAnimalLayer()
	
	--======================================
	-- NEAR WORLD PLANE
	--======================================
	local nearPlaneGroup = display.newGroup()
	
	local planeContainer = display.newRect(-width,0,width*3,width*3)
	planeContainer:setFillColor(0,0,0,0)
	nearPlaneGroup:insert(planeContainer)
	
	local plane = display.newImageRect("assets/world/BG1.png",width*3/3,width*1.44233/3)
	plane:setReferencePoint(display.TopLeftReferencePoint)
	plane:setReferencePoint(display.BottomCenterReferencePoint)
	plane.x = width/2
	plane.y = width*1.44233 - 60
	plane.xScale,plane.yScale = 3,3
	nearPlaneGroup:insert(plane)
	
	nearPlaneGroup:setReferencePoint(display.CenterReferencePoint)
	nearPlaneGroup.rotation=-25
	worldGroup:insert(nearPlaneGroup)
	
	local sheep2 = newSheep (120, 300, 0.2, 6)
	sheep2.displayObject.y = 180
	sheep2.addRunningAnimalLayer()
	
	--======================================
	-- MARY
	--======================================
	local maryGroup = display.newGroup()
	
	local maryOpenEyes = display.newImage("assets/menu/Mary/EyesOpen.png")
	local maryClosedEyes = display.newImage("assets/menu/Mary/EyesClosed.png")
	
	local maryBlinks = ui.blink(maryOpenEyes,maryClosedEyes)
	
	local maryBase = ui.newAnimation{
						 comps = {
						 {
						 path = "assets/menu/Mary/wings.png",
						 x = { 682.45,682.45,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,683.25,684.05,684.85,685.6,686.4,687.15,687.9,688.2,688.45,688.8,687.9,687.1,686.35,685.5,684.6,683.8,683,682.8,682.6,682.5,683.25,684.05,684.85,685.6,686.4,687.15,687.9,688.2,688.45,688.8,687.9,687.1,686.35,685.5,684.6,683.8,683,682.8,682.6,682.5,683.25,684.05,684.85,685.6,686.4,687.15,687.9,688.2,688.45,688.8,687.9,687.1,686.35,685.5,684.6,683.8,683,682.8,682.6,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.5,682.45,682.45,682.45 },
						 y = { 322.45,322.45,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,323.05,323.5,324,324.55,325,325.5,326,326.25,326.5,326.65,326.2,325.55,325.05,324.5,323.85,323.35,322.8,322.75,322.6,322.5,323.05,323.5,324,324.55,325,325.5,326,326.25,326.5,326.65,326.2,325.55,325.05,324.5,323.85,323.35,322.8,322.75,322.6,322.5,323.05,323.5,324,324.55,325,325.5,326,326.25,326.5,326.65,326.2,325.55,325.05,324.5,323.85,323.35,322.8,322.75,322.6,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.5,322.45,322.45,322.45 },
						 rotation = { -0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,0.4747161865234375,0.95111083984375,1.4273834228515625,1.904327392578125,2.3792572021484375,2.8556060791015625,3.3315582275390625,3.520599365234375,3.7104339599609375,3.8993072509765625,3.382965087890625,2.8660736083984375,2.3487091064453125,1.83270263671875,1.3155364990234375,0.797271728515625,0.2806396484375,0.18621826171875,0.0926666259765625,-0.0008697509765625,0.4747161865234375,0.95111083984375,1.4273834228515625,1.904327392578125,2.3792572021484375,2.8556060791015625,3.3315582275390625,3.520599365234375,3.7104339599609375,3.8993072509765625,3.382965087890625,2.8660736083984375,2.3487091064453125,1.83270263671875,1.3155364990234375,0.797271728515625,0.2806396484375,0.18621826171875,0.0926666259765625,-0.0008697509765625,0.4747161865234375,0.95111083984375,1.4273834228515625,1.904327392578125,2.3792572021484375,2.8556060791015625,3.3315582275390625,3.520599365234375,3.7104339599609375,3.8993072509765625,3.382965087890625,2.8660736083984375,2.3487091064453125,1.83270263671875,1.3155364990234375,0.797271728515625,0.2806396484375,0.18621826171875,0.0926666259765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625,-0.0008697509765625 },
						 },
						 {
						 path = "assets/menu/Mary/rarm.png",
						 x = { 612.4,610.8,609.25,607.65,606.2,604.7,603.5,602.25,601.2,600.25,599.5,598.9,598.5,598.35,598.75,599.25,599.75,600.25,600.7,601.3,601.85,602.05,602.3,602.45,601.85,601.3,600.8,600.2,599.65,599.1,598.55,598.4,598.3,598.25,598.7,599.2,599.7,600.2,600.75,601.25,601.85,602.05,602.3,602.45,601.85,601.3,600.8,600.2,599.65,599.1,598.55,598.45,598.35,598.35,598.75,599.25,599.75,600.25,600.7,601.3,601.85,602.05,602.3,602.45,601.85,601.3,600.8,600.2,599.65,599.1,598.55,598.4,598.3,598.25,598.35,598.75,599.35,599.95,600.85,601.75,602.8,604,605.25,606.6,608,609.45,611,612.45,614 },
						 y = { 365.45,365.45,365.15,364.8,364.2,363.5,362.5,361.45,360.2,358.9,357.6,356.05,354.45,352.85,352.5,352.05,351.75,351.35,350.9,350.55,350.15,350.2,350.3,350.35,350.65,350.95,351.35,351.6,351.95,352.35,352.65,352.75,352.8,352.85,352.5,352.05,351.7,351.3,350.9,350.55,350.15,350.2,350.3,350.35,350.65,350.95,351.35,351.6,351.95,352.35,352.65,352.75,352.85,352.85,352.5,352.05,351.75,351.35,350.9,350.55,350.15,350.2,350.3,350.35,350.65,350.95,351.35,351.6,351.95,352.35,352.65,352.75,352.8,352.85,354.3,355.85,357.25,358.55,359.8,361,362.05,362.95,363.75,364.45,364.85,365.2,365.45,365.4,365.3 },
						 rotation = { -47.03511047363281,-40.40165710449219,-33.770111083984375,-27.137771606445313,-20.50543212890625,-13.874038696289063,-7.2403411865234375,-0.60845947265625,6.02325439453125,12.655746459960938,19.28802490234375,25.92010498046875,32.552215576171875,39.1842041015625,40.31434631347656,41.443328857421875,42.572845458984375,43.70268249511719,44.830841064453125,45.958831787109375,47.0894775390625,46.653564453125,46.21836853027344,45.78497314453125,44.88177490234375,43.979217529296875,43.077056884765625,42.17390441894531,41.27091979980469,40.36970520019531,39.46722412109375,39.37226867675781,39.279144287109375,39.1842041015625,40.31434631347656,41.443328857421875,42.572845458984375,43.70268249511719,44.8321533203125,45.958831787109375,47.0894775390625,46.653564453125,46.21836853027344,45.78497314453125,44.88177490234375,43.979217529296875,43.077056884765625,42.17390441894531,41.27091979980469,40.36970520019531,39.46722412109375,39.37226867675781,39.279144287109375,39.1842041015625,40.31434631347656,41.443328857421875,42.572845458984375,43.70268249511719,44.830841064453125,45.958831787109375,47.0894775390625,46.653564453125,46.21836853027344,45.78497314453125,44.88177490234375,43.979217529296875,43.077056884765625,42.17390441894531,41.27091979980469,40.36970520019531,39.46722412109375,39.37226867675781,39.279144287109375,39.1842041015625,32.99659729003906,26.805145263671875,20.614273071289063,14.423965454101563,8.234359741210938,2.0449066162109375,-4.1455078125,-10.335617065429688,-16.526809692382813,-22.716873168945313,-28.906829833984375,-35.09562683105469,-41.28770446777344,-47.47840881347656,-53.66880798339844 },
						 },
						 {
						 path = "assets/menu/Mary/rforearm.png",
						 x = { 602.6,596.9,591.5,586.45,581.75,577.6,573.9,570.9,568.4,566.65,565.65,565.25,565.6,566.55,567.65,568.8,570,571.15,572.35,573.6,574.9,575.35,575.9,576.45,575.2,574.05,572.75,571.55,570.4,569.25,568.05,567.6,567.05,566.45,567.55,568.7,569.85,571.05,572.3,573.5,574.9,575.35,575.9,576.45,575.2,574.05,572.75,571.55,570.4,569.25,568.05,567.65,567.15,566.55,567.65,568.8,570,571.15,572.35,573.6,574.9,575.35,575.9,576.45,575.2,574.05,572.75,571.55,570.4,569.25,568.05,567.6,567.05,566.45,565.5,565.1,565.4,566.25,567.8,569.8,572.4,575.5,579.15,583.25,587.8,592.55,597.7,603,608.45 },
						 y = { 399.6,398,395.6,392.7,389.15,385.1,380.55,375.6,370.45,365,359.4,353.7,348.05,342.45,341.3,340.15,338.95,337.85,336.7,335.8,334.75,334.95,335.15,335.4,336.2,337,337.8,338.75,339.6,340.6,341.5,341.85,342.15,342.55,341.25,340.1,338.95,337.85,336.75,335.8,334.75,334.95,335.15,335.4,336.2,337,337.8,338.75,339.6,340.6,341.5,341.8,342.2,342.45,341.3,340.15,338.95,337.85,336.7,335.75,334.75,334.95,335.15,335.4,336.2,337,337.8,338.75,339.6,340.6,341.5,341.85,342.15,342.55,347.7,353,358.2,363.55,368.6,373.65,378.35,382.75,386.8,390.4,393.55,396.15,398.2,399.7,400.5 },
						 rotation = { 18.693954467773438,26.655197143554688,34.61643981933594,42.579010009765625,50.539031982421875,58.50157165527344,66.46241760253906,74.42431640625,82.38743591308594,90.34707641601563,98.3079833984375,106.27095031738281,114.23268127441406,122.19300842285156,125.12721252441406,128.06155395507813,130.99415588378906,133.92755126953125,136.8609619140625,139.7930908203125,142.72610473632813,144.3943328857422,146.06227111816406,147.73193359375,144.934814453125,142.13951110839844,139.34378051757813,136.54693603515625,133.75198364257813,130.9552764892578,128.15951538085938,126.16972351074219,124.18254089355469,122.19175720214844,125.12605285644531,128.05938720703125,130.99314880371094,133.9261932373047,136.86050415039063,139.79257202148438,142.72610473632813,144.3943328857422,146.06227111816406,147.73193359375,144.93540954589844,142.13951110839844,139.34378051757813,136.54693603515625,133.75198364257813,130.9552764892578,128.15951538085938,126.16972351074219,124.18313598632813,122.19300842285156,125.12721252441406,128.06155395507813,130.99415588378906,133.92755126953125,136.8609619140625,139.79359436035156,142.72610473632813,144.3943328857422,146.06227111816406,147.73193359375,144.93540954589844,142.13951110839844,139.34378051757813,136.54693603515625,133.75198364257813,130.9552764892578,128.15951538085938,126.16972351074219,124.18254089355469,122.19175720214844,114.76043701171875,107.33091735839844,99.89926147460938,92.46914672851563,85.03961181640625,77.60752868652344,70.17788696289063,62.74810791015625,55.31671142578125,47.885223388671875,40.454345703125,33.024261474609375,25.593170166015625,18.162796020507813,10.731948852539063 },
						 },
						 {
						 path = "assets/menu/Mary/rhand.png",
						 x = { 579.8,570.85,562.65,555.35,549.05,543.8,539.85,537.1,535.65,535.45,536.65,538.95,542.55,547.2,550.55,554.05,557.7,561.4,565.25,569.1,573,575.5,577.9,580.35,576.6,572.8,569,565.15,561.45,557.8,554.25,551.75,549.4,547.1,550.5,554,557.6,561.4,565.2,569.05,573,575.5,577.9,580.35,576.6,572.8,569,565.15,561.45,557.8,554.25,551.8,549.45,547.2,550.55,554.05,557.7,561.4,565.25,569.1,573,575.5,577.9,580.35,576.6,572.8,569,565.15,561.45,557.8,554.25,551.75,549.4,547.1,542.8,539.3,537,535.65,535.5,536.35,538.45,541.55,545.75,551.05,557.2,564.2,572,580.4,589.35 },
						 y = { 424.85,419.8,413.65,406.6,398.65,389.9,380.7,371.1,361.25,351.35,341.55,332.1,322.95,314.5,311.75,309.35,307.15,305.2,303.5,302.1,301,301.25,301.75,302.3,302.65,303.3,304.15,305.3,306.7,308.4,310.25,311.55,313,314.55,311.8,309.4,307.15,305.2,303.6,302.1,301,301.25,301.75,302.3,302.65,303.3,304.15,305.3,306.7,308.4,310.25,311.5,312.95,314.5,311.75,309.35,307.15,305.2,303.5,302.1,301,301.25,301.75,302.3,302.65,303.3,304.15,305.3,306.7,308.4,310.25,311.55,313,314.55,322.5,330.85,339.7,348.75,357.95,367.2,376.25,385.05,393.5,401.3,408.55,414.95,420.55,425.1,428.7 },
						 rotation = { -5.86669921875,2.09381103515625,10.0552978515625,18.015869140625,25.978073120117188,33.938323974609375,41.90043640136719,49.86250305175781,57.825164794921875,65.78694152832031,73.74758911132813,81.70828247070313,89.66952514648438,97.63059997558594,103.81881713867188,110.00373840332031,116.19245910644531,122.37796020507813,128.56692504882813,134.7555694580078,140.94261169433594,146.40423583984375,151.86868286132813,157.33297729492188,151.11929321289063,144.9073028564453,138.69601440429688,132.48309326171875,126.27157592773438,120.05950927734375,113.84695434570313,108.440185546875,103.03471374511719,97.62889099121094,103.81715393066406,110.002197265625,116.19175720214844,122.37796020507813,128.56532287597656,134.75425720214844,140.94261169433594,146.40423583984375,151.86868286132813,157.33297729492188,151.11929321289063,144.9073028564453,138.69601440429688,132.48309326171875,126.27157592773438,120.05950927734375,113.84695434570313,108.44097900390625,103.03636169433594,97.63059997558594,103.81881713867188,110.00373840332031,116.19245910644531,122.37796020507813,128.56692504882813,134.7555694580078,140.94261169433594,146.40423583984375,151.86868286132813,157.33297729492188,151.11929321289063,144.9073028564453,138.69601440429688,132.48309326171875,126.27157592773438,120.05950927734375,113.84695434570313,108.440185546875,103.03471374511719,97.62889099121094,90.19671630859375,82.76741027832031,75.33767700195313,67.90782165527344,60.47514343261719,53.04576110839844,45.61570739746094,38.18330383300781,30.754013061523438,23.324127197265625,15.8931884765625,8.462860107421875,1.0323944091796875,-6.3982391357421875,-13.82952880859375 },
						 },
						 {
						 path = "assets/menu/Mary/static.png",
						 x = { 644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8,644.8 },
						 y = { 480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15,480.15 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 },
						 {
						 path = "assets/menu/Mary/body.png",
						 x = { 643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.5,643.95,644.4,645,645.5,645.9,646.45,646.5,646.5,646.65,646.15,645.65,645.3,644.8,644.35,643.75,643.45,643.3,643,643.05,643.5,643.95,644.4,645,645.5,645.9,646.45,646.5,646.5,646.65,646.15,645.65,645.3,644.8,644.35,643.75,643.45,643.3,643,643.05,643.5,643.95,644.4,645,645.5,645.9,646.45,646.5,646.5,646.65,646.15,645.65,645.3,644.8,644.35,643.75,643.45,643.3,643,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05,643.05 },
						 y = { 366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,367.05,367.25,367.45,367.7,367.8,368.05,368.3,368.35,368.35,368.4,368.2,368.05,367.8,367.65,367.4,367.25,367.05,366.95,366.9,366.9,367.05,367.25,367.45,367.75,367.85,368.1,368.3,368.3,368.3,368.4,368.2,368.05,367.8,367.7,367.45,367.3,367.05,366.95,366.9,366.9,367.05,367.3,367.5,367.75,367.85,368.15,368.3,368.3,368.2,368.4,368.15,368.05,367.8,367.65,367.4,367.3,367.05,366.95,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9,366.9 },
						 rotation = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.51580810546875,1.0323944091796875,1.5488128662109375,2.252685546875,2.769256591796875,3.285369873046875,3.954132080078125,4.01068115234375,4.03155517578125,4.2115936279296875,3.5441131591796875,3.0352325439453125,2.52410888671875,2.0160980224609375,1.5051422119140625,0.80950927734375,0.446746826171875,0.2622833251953125,0.03759765625,0,0.51580810546875,1.0323944091796875,1.5488128662109375,2.252685546875,2.769256591796875,3.285369873046875,3.954132080078125,4.01068115234375,4.03155517578125,4.2115936279296875,3.5441131591796875,3.0352325439453125,2.52410888671875,2.0160980224609375,1.5051422119140625,0.80950927734375,0.446746826171875,0.2622833251953125,0.03759765625,0,0.51580810546875,1.0323944091796875,1.5488128662109375,2.252685546875,2.769256591796875,3.285369873046875,3.954132080078125,4.01068115234375,4.03155517578125,4.2115936279296875,3.5441131591796875,3.0352325439453125,2.52410888671875,2.0160980224609375,1.5051422119140625,0.80950927734375,0.446746826171875,0.2622833251953125,0.03759765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
						 },
						 {
						 path = "assets/menu/Mary/rpigtail.png",
						 x = { 664.5,665.9,667.35,668.7,670.05,671.4,672.75,674.1,675.4,676.65,677.95,679.2,680.55,681.7,683.85,686,688.15,690.2,692.25,694.35,696.3,696.4,696.5,696.5,694.3,692.2,689.95,687.7,685.5,683.15,680.9,681.1,681.35,681.65,683.75,685.9,688.1,690.2,692.25,694.35,696.3,696.4,696.5,696.5,694.3,692.2,689.95,687.7,685.5,683.15,680.9,681.1,681.35,681.7,683.85,686,688.15,690.2,692.25,694.35,696.3,696.4,696.5,696.5,694.3,692.2,689.95,687.7,685.5,683.15,680.9,681.1,681.35,681.65,680.45,679.35,678.2,676.95,675.8,674.6,673.35,672.1,670.85,669.65,668.3,667,665.7,664.4,663.1 },
						 y = { 211.4,212.15,212.85,213.55,214.3,215.1,215.9,216.6,217.45,218.25,219.15,219.95,220.8,221.65,222.75,223.95,225.05,226.15,227.4,228.6,229.8,230.1,230.4,230.65,229.4,228.15,226.95,225.7,224.5,223.35,222.2,222,221.75,221.55,222.7,223.85,225,226.15,227.35,228.55,229.8,230.1,230.4,230.65,229.4,228.15,226.95,225.7,224.5,223.35,222.2,222,221.8,221.65,222.75,223.95,225.05,226.15,227.4,228.6,229.8,230.1,230.4,230.65,229.4,228.15,226.95,225.7,224.5,223.35,222.2,222,221.75,221.55,220.75,219.95,219.15,218.4,217.65,216.9,216.2,215.45,214.75,214.05,213.35,212.65,211.95,211.4,210.7 },
						 rotation = { -16.427108764648438,-15.162750244140625,-13.899566650390625,-12.636611938476563,-11.372802734375,-10.109542846679688,-8.846511840820313,-7.5825042724609375,-6.31793212890625,-5.0549468994140625,-3.7922515869140625,-2.528472900390625,-1.264862060546875,-0.0008697509765625,1.5287322998046875,3.05963134765625,4.5905303955078125,6.120941162109375,7.6529388427734375,9.184219360351563,10.715057373046875,11.435806274414063,12.157913208007813,12.878616333007813,11.25762939453125,9.63604736328125,8.0150146484375,6.3930511474609375,4.7729034423828125,3.150299072265625,1.5287322998046875,1.019287109375,0.5096893310546875,-0.0008697509765625,1.52960205078125,3.0613861083984375,4.591400146484375,6.121795654296875,7.6529388427734375,9.184219360351563,10.715057373046875,11.435806274414063,12.157913208007813,12.878616333007813,11.25762939453125,9.63604736328125,8.0150146484375,6.3930511474609375,4.7729034423828125,3.150299072265625,1.5287322998046875,1.019287109375,0.5088043212890625,-0.0008697509765625,1.5287322998046875,3.05963134765625,4.5905303955078125,6.120941162109375,7.6529388427734375,9.184219360351563,10.715057373046875,11.435806274414063,12.157913208007813,12.878616333007813,11.25762939453125,9.63604736328125,8.0150146484375,6.3930511474609375,4.7729034423828125,3.150299072265625,1.5287322998046875,1.019287109375,0.5096893310546875,-0.0008697509765625,-1.1783447265625,-2.358306884765625,-3.5380096435546875,-4.7173309326171875,-5.8969879150390625,-7.0759429931640625,-8.255767822265625,-9.435379028320313,-10.614593505859375,-11.793975830078125,-12.973297119140625,-14.151382446289063,-15.332839965820313,-16.510726928710938,-17.6903076171875 },
						 },
						 {
						 path = "assets/menu/Mary/lpigtail.png",
						 x = { 747.6,748.75,749.95,750.95,752,753,753.95,754.9,755.65,756.45,757.3,757.95,758.7,759.35,761,762.6,764.05,765.55,767,768.35,769.65,769.45,769.2,769.05,767.6,766.2,764.75,763.2,761.6,759.9,758.2,758.55,758.85,759.3,760.9,762.5,764.05,765.5,767,768.3,769.65,769.45,769.2,769.05,767.6,766.2,764.75,763.2,761.6,759.9,758.2,758.55,758.95,759.35,761,762.6,764.05,765.55,767,768.35,769.65,769.45,769.2,769.05,767.6,766.2,764.75,763.2,761.6,759.9,758.2,758.55,758.85,759.3,758.65,758,757.3,756.65,755.9,755.1,754.3,753.5,752.55,751.65,750.7,749.65,748.65,747.55,746.45 },
						 y = { 215.4,217.65,219.85,222.05,224.3,226.55,228.75,230.95,233.2,235.4,237.7,239.8,242.1,244.3,246.95,249.6,252.3,254.9,257.6,260.25,262.95,263.5,264.15,264.65,262,259.15,256.35,253.65,250.85,248.05,245.25,244.95,244.6,244.25,246.9,249.55,252.15,254.9,257.55,260.3,262.95,263.5,264.15,264.65,262,259.15,256.35,253.65,250.85,248.05,245.25,244.95,244.6,244.3,246.95,249.6,252.3,254.9,257.6,260.25,262.95,263.5,264.15,264.65,262,259.15,256.35,253.65,250.85,248.05,245.25,244.95,244.6,244.25,242.15,240.15,238.1,236,233.9,231.8,229.75,227.65,225.65,223.5,221.45,219.4,217.3,215.3,213.2 },
						 rotation = { -18.451202392578125,-17.0308837890625,-15.613800048828125,-14.192474365234375,-12.772216796875,-11.35430908203125,-9.934890747070313,-8.516738891601563,-7.0966033935546875,-5.675445556640625,-4.256805419921875,-2.838165283203125,-1.41864013671875,0,1.60211181640625,3.2043304443359375,4.808502197265625,6.4103240966796875,8.010726928710938,9.61395263671875,11.217269897460938,12.022491455078125,12.83123779296875,13.63812255859375,11.940505981445313,10.244216918945313,8.546661376953125,6.8476715087890625,5.1512298583984375,3.4517822265625,1.7541046142578125,1.17047119140625,0.5883636474609375,0.004364013671875,1.6056060791015625,3.2086944580078125,4.8102264404296875,6.41119384765625,8.011581420898438,9.61480712890625,11.217269897460938,12.022491455078125,12.83123779296875,13.63812255859375,11.940505981445313,10.244216918945313,8.546661376953125,6.8476715087890625,5.1512298583984375,3.4517822265625,1.7541046142578125,1.1696014404296875,0.58660888671875,0,1.60211181640625,3.2043304443359375,4.808502197265625,6.4103240966796875,8.010726928710938,9.61395263671875,11.217269897460938,12.022491455078125,12.83123779296875,13.63812255859375,11.940505981445313,10.244216918945313,8.546661376953125,6.8476715087890625,5.1512298583984375,3.4517822265625,1.7541046142578125,1.17047119140625,0.5883636474609375,0.004364013671875,-1.3199005126953125,-2.6445159912109375,-3.96978759765625,-5.2951507568359375,-6.6208953857421875,-7.9447021484375,-9.271102905273438,-10.59600830078125,-11.919586181640625,-13.24530029296875,-14.56982421875,-15.894805908203125,-17.221710205078125,-18.545562744140625,-19.869308471679688 },
						 },
						 {
						 path = "assets/menu/Mary/head.png",
						 x = { 654.8,656.4,658.15,659.8,661.5,663.1,664.75,666.35,668,669.6,671.25,672.8,674.35,675.95,678.6,681.25,683.85,686.35,689.05,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.9,678.55,681.25,683.85,686.35,689,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.95,678.6,681.25,683.85,686.35,689.05,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.9,674.45,672.95,671.55,670,668.55,667,665.45,663.9,662.4,660.9,659.4,657.85,656.2,654.65,653.1 },
						 y = { 220.35,220.65,221.1,221.45,221.85,222.35,222.8,223.35,223.85,224.4,225,225.65,226.3,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,226.35,225.75,225.15,224.65,224.05,223.55,223.1,222.6,222.15,221.7,221.3,220.95,220.65,220.3,220.05 },
						 rotation = { -12.589141845703125,-11.620468139648438,-10.6534423828125,-9.685333251953125,-8.71673583984375,-7.74737548828125,-6.778717041015625,-5.8113250732421875,-4.84149169921875,-3.8740692138671875,-2.90618896484375,-1.9375,-0.9694671630859375,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,-0.9039154052734375,-1.807373046875,-2.7108154296875,-3.614654541015625,-4.5201568603515625,-5.4216766357421875,-6.326568603515625,-7.2317352294921875,-8.134140014648438,-9.039321899414063,-9.943374633789063,-10.8458251953125,-11.750411987304688,-12.654083251953125,-13.558013916015625 },
						 },
						 {
						 displayObject = maryClosedEyes,
						 x = { 654.8,656.4,658.15,659.8,661.5,663.1,664.75,666.35,668,669.6,671.25,672.8,674.35,675.95,678.6,681.25,683.85,686.35,689.05,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.9,678.55,681.25,683.85,686.35,689,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.95,678.6,681.25,683.85,686.35,689.05,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.9,674.45,672.95,671.55,670,668.55,667,665.45,663.9,662.4,660.9,659.4,657.85,656.2,654.65,653.1 },
						 y = { 220.35,220.65,221.1,221.45,221.85,222.35,222.8,223.35,223.85,224.4,225,225.65,226.3,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,226.35,225.75,225.15,224.65,224.05,223.55,223.1,222.6,222.15,221.7,221.3,220.95,220.65,220.3,220.05 },
						 rotation = { -12.589141845703125,-11.620468139648438,-10.6534423828125,-9.685333251953125,-8.71673583984375,-7.74737548828125,-6.778717041015625,-5.8113250732421875,-4.84149169921875,-3.8740692138671875,-2.90618896484375,-1.9375,-0.9694671630859375,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,-0.9039154052734375,-1.807373046875,-2.7108154296875,-3.614654541015625,-4.5201568603515625,-5.4216766357421875,-6.326568603515625,-7.2317352294921875,-8.134140014648438,-9.039321899414063,-9.943374633789063,-10.8458251953125,-11.750411987304688,-12.654083251953125,-13.558013916015625 },
						 scaleComponent = true,
						 },
						 {
						 displayObject = maryOpenEyes,
						 x = { 654.8,656.4,658.15,659.8,661.5,663.1,664.75,666.35,668,669.6,671.25,672.8,674.35,675.95,678.6,681.25,683.85,686.35,689.05,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.9,678.55,681.25,683.85,686.35,689,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.95,678.6,681.25,683.85,686.35,689.05,691.5,694.05,694.8,695.6,696.35,693.6,690.9,688.15,685.4,682.5,679.75,676.95,676.6,676.25,675.9,674.45,672.95,671.55,670,668.55,667,665.45,663.9,662.4,660.9,659.4,657.85,656.2,654.65,653.1 },
						 y = { 220.35,220.65,221.1,221.45,221.85,222.35,222.8,223.35,223.85,224.4,225,225.65,226.3,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,227.95,228.9,229.85,231,232.1,233.15,234.4,234.7,235.05,235.35,234.05,232.75,231.55,230.45,229.25,228.25,227.2,227.1,227.05,226.95,226.35,225.75,225.15,224.65,224.05,223.55,223.1,222.6,222.15,221.7,221.3,220.95,220.65,220.3,220.05 },
						 rotation = { -12.589141845703125,-11.620468139648438,-10.6534423828125,-9.685333251953125,-8.71673583984375,-7.74737548828125,-6.778717041015625,-5.8113250732421875,-4.84149169921875,-3.8740692138671875,-2.90618896484375,-1.9375,-0.9694671630859375,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,1.1486358642578125,2.2989501953125,3.4491729736328125,4.6009521484375,5.7507476806640625,6.9019622802734375,8.0518798828125,8.328536987304688,8.60736083984375,8.884933471679688,7.663238525390625,6.4405364990234375,5.2197265625,3.99676513671875,2.7744903564453125,1.553192138671875,0.32958984375,0.220306396484375,0.109283447265625,-0.0008697509765625,-0.9039154052734375,-1.807373046875,-2.7108154296875,-3.614654541015625,-4.5201568603515625,-5.4216766357421875,-6.326568603515625,-7.2317352294921875,-8.134140014648438,-9.039321899414063,-9.943374633789063,-10.8458251953125,-11.750411987304688,-12.654083251953125,-13.558013916015625 },
						 scaleComponent = true,
						 },
						 {
						 path = "assets/menu/Mary/larm.png",
						 x = { 676.75,677.05,677.25,677.55,677.7,677.95,678.15,678.4,678.65,678.85,679.05,679.3,679.5,679.7,680.15,680.6,681.15,681.5,681.9,682.4,682.85,683.05,683.2,683.35,682.95,682.35,681.85,681.25,680.8,680.2,679.65,679.7,679.7,679.65,680.15,680.6,681.1,681.45,681.9,682.4,682.85,683.05,683.2,683.35,682.95,682.35,681.85,681.25,680.8,680.2,679.65,679.75,679.75,679.7,680.15,680.6,681.15,681.5,681.9,682.4,682.85,683.05,683.2,683.35,682.95,682.35,681.85,681.25,680.8,680.2,679.65,679.7,679.7,679.65,679.45,679.25,679.05,678.85,678.65,678.5,678.35,678.05,677.9,677.6,677.35,677.25,677,676.7,676.55 },
						 y = { 366.7,366.6,366.5,366.35,366.25,366.1,366,365.9,365.65,365.55,365.4,365.2,365.1,364.95,365.4,365.85,366.35,366.7,367.2,367.65,368.2,368.25,368.5,368.7,368.2,367.75,367.2,366.8,366.35,365.95,365.5,365.25,365.1,364.9,365.35,365.8,366.3,366.7,367.2,367.65,368.2,368.25,368.5,368.7,368.2,367.75,367.2,366.8,366.35,365.95,365.5,365.3,365.1,364.95,365.4,365.85,366.35,366.7,367.2,367.65,368.2,368.25,368.5,368.7,368.2,367.75,367.2,366.8,366.35,365.95,365.5,365.25,365.1,364.9,365.05,365.2,365.35,365.45,365.65,365.75,365.9,366,366.15,366.25,366.35,366.45,366.65,366.7,366.85 },
						 rotation = { 12.028350830078125,11.102813720703125,10.176467895507813,9.252365112304688,8.328536987304688,7.4011688232421875,6.4776611328125,5.550750732421875,4.6261444091796875,3.699981689453125,2.775360107421875,1.851043701171875,0.924896240234375,0.0008697509765625,0.35931396484375,0.7186126708984375,1.0787200927734375,1.439605712890625,1.7995147705078125,2.1592864990234375,2.519744873046875,2.6427764892578125,2.7640228271484375,2.886993408203125,2.700347900390625,2.5153961181640625,2.3286285400390625,2.1427001953125,1.9549713134765625,1.7698211669921875,1.5846405029296875,1.0559844970703125,0.52716064453125,0.0008697509765625,0.35931396484375,0.7186126708984375,1.0787200927734375,1.439605712890625,1.7995147705078125,2.1592864990234375,2.519744873046875,2.6427764892578125,2.7640228271484375,2.886993408203125,2.700347900390625,2.5153961181640625,2.3286285400390625,2.1427001953125,1.9549713134765625,1.7698211669921875,1.5846405029296875,1.0559844970703125,0.52716064453125,0.0008697509765625,0.35931396484375,0.7186126708984375,1.0787200927734375,1.439605712890625,1.7995147705078125,2.1592864990234375,2.519744873046875,2.6427764892578125,2.7640228271484375,2.886993408203125,2.700347900390625,2.5153961181640625,2.3286285400390625,2.1427001953125,1.9549713134765625,1.7698211669921875,1.5846405029296875,1.0559844970703125,0.52716064453125,0.0008697509765625,0.8619537353515625,1.7261505126953125,2.5912933349609375,3.4543914794921875,4.3176727294921875,5.1807098388671875,6.04400634765625,6.907135009765625,7.7714080810546875,8.63555908203125,9.499176025390625,10.362686157226563,11.225677490234375,12.090225219726563,12.953369140625 },
						 },
						 {
						 path = "assets/menu/Mary/lhand.png",
						 x = { 678.95,679.15,679.3,679.45,679.6,679.7,679.85,679.95,680.15,680.3,680.45,680.55,680.65,680.8,680.95,681.05,681.15,681.3,681.45,681.6,681.7,681.65,681.45,681.5,681.3,681,680.85,680.6,680.4,680.2,679.95,680.2,680.45,680.7,680.85,681,681.15,681.25,681.45,681.55,681.7,681.65,681.45,681.5,681.3,681,680.85,680.6,680.4,680.2,679.95,680.25,680.5,680.8,680.95,681.05,681.15,681.3,681.45,681.6,681.7,681.65,681.45,681.5,681.3,681,680.85,680.6,680.4,680.2,679.95,680.2,680.45,680.7,680.55,680.45,680.4,680.25,680.1,680.05,679.8,679.7,679.55,679.45,679.35,679.2,679.1,678.95,678.85 },
						 y = { 414,413.5,413,412.4,411.7,411.15,410.45,409.85,409.1,408.45,407.75,407,406.25,405.55,405.95,406.3,406.75,407.1,407.5,407.95,408.35,408.35,408.45,408.5,408.1,407.75,407.45,407.1,406.85,406.5,406.15,405.95,405.7,405.5,405.95,406.35,406.65,407.1,407.5,407.95,408.35,408.35,408.45,408.5,408.1,407.75,407.45,407.1,406.85,406.5,406.15,405.9,405.7,405.55,405.95,406.3,406.75,407.1,407.5,407.95,408.35,408.35,408.45,408.5,408.1,407.75,407.45,407.1,406.85,406.5,406.15,405.95,405.7,405.5,406.25,406.9,407.55,408.25,408.95,409.5,410.1,410.8,411.35,411.85,412.45,413,413.6,414.05,414.6 },
						 rotation = { -12.4666748046875,-11.345901489257813,-10.2247314453125,-9.103271484375,-7.9815826416015625,-6.8623199462890625,-5.7386322021484375,-4.6183319091796875,-3.4970855712890625,-2.375762939453125,-1.254364013671875,-0.1328887939453125,0.9860687255859375,2.106903076171875,2.6340484619140625,3.163360595703125,3.690399169921875,4.217681884765625,4.7451171875,5.2734832763671875,5.8009490966796875,6.456939697265625,7.110382080078125,7.7653961181640625,7.062164306640625,6.3602447509765625,5.6572723388671875,4.954315185546875,4.2524566650390625,3.550201416015625,2.8468780517578125,2.603515625,2.3574371337890625,2.1121368408203125,2.6392822265625,3.1668548583984375,3.693878173828125,4.21942138671875,4.746856689453125,5.2734832763671875,5.8009490966796875,6.456939697265625,7.110382080078125,7.7653961181640625,7.062164306640625,6.3602447509765625,5.6572723388671875,4.954315185546875,4.2524566650390625,3.550201416015625,2.8468780517578125,2.601776123046875,2.35394287109375,2.106903076171875,2.6340484619140625,3.163360595703125,3.690399169921875,4.217681884765625,4.7451171875,5.2734832763671875,5.8009490966796875,6.456939697265625,7.110382080078125,7.7653961181640625,7.062164306640625,6.3602447509765625,5.6572723388671875,4.954315185546875,4.2524566650390625,3.550201416015625,2.8468780517578125,2.603515625,2.3574371337890625,2.1121368408203125,1.0664825439453125,0.0192413330078125,-1.026275634765625,-2.072845458984375,-3.119781494140625,-4.1672515869140625,-5.2136688232421875,-6.26092529296875,-7.30828857421875,-8.355926513671875,-9.401351928710938,-10.448104858398438,-11.493743896484375,-12.540008544921875,-13.588577270507813 },
						 },
						},
						 x = 0,
						 y = 0,
						 scale = 0.5,
						 speed = 0.8,
						}
	maryBase.displayObject:setReferencePoint(display.BottomRightReferencePoint)
	maryBase.displayObject.x = (screenOriginX+viewableContentWidth)*0.95
	maryBase.displayObject.y = (screenOriginY+viewableContentHeight)*0.95
	maryBase.displayObject.xScale,maryBase.displayObject.yScale = 1.15 * viewableContentHeight/height, 1.15 * viewableContentHeight/height
	maryGroup:insert(maryBase.displayObject)
	
	maryBase.setLoopStart(15)
	maryBase.setLoopEnd(74)
	maryBase.setLoops(0)
	maryBase.start()
	
	maryBlinks.openEyes()
	maryBlinks.startBlinking()
	
	worldGroup:insert(maryGroup)
	
	local moveSky
	
	--======================================
	-- ANIMALS GROUP 1
	--======================================
	local animalsGroup1 = display.newGroup()
	
	local function newAnimal (ID, yPos, scale, reg)
			local thisAnimal = {}
			
			local openEyesR = nil
			local closedEyesR = nil
			
			local openEyesC = nil
			local closedEyesC = nil
			
			local caughtSound = nil
			
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
			
			if ID == 1 then
				openEyesR = display.newImage("assets/cat/EyesOpen.png")
				closedEyesR = display.newImage("assets/cat/EyesClosed.png")
				
				openEyesC = display.newImage("assets/catCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/catCaught/EyesClosed.png")
				
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
					speed = 0.7
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
					x = -85,
					y = -75,
					scale = 0.3 * 1.666,
					speed = 0.5
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				caughtSound  = audio.loadSound("assets/sound/catPurrrrr.mp3")
			elseif ID == 2 then
				openEyesR = display.newImage("assets/dog/EyesOpen.png")
				closedEyesR = display.newImage("assets/dog/EyesClosed.png")
				
				openEyesC = display.newImage("assets/dogCaught/EyesOpen.png")
				closedEyesC = display.newImage("assets/dogCaught/EyesClosed.png")
				
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
					speed = 0.7
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
					x = -70,
					y = -90,
					scale = 0.15 * 3.333,
					speed = 0.5
				}
				
				thisAnimal.runningAnimal.hide()
				thisAnimal.caughtAnimal.hide()
				
				caughtSound  = audio.loadSound("assets/sound/dogWhine.mp3")
			else
				print("no animal")
			end
			
			thisAnimal.displayObject.x = -200*scale
			
			local RBlinks = ui.blink(openEyesR,closedEyesR)
			local CBlinks = ui.blink(openEyesC,closedEyesC)
			
			if thisAnimal.runningAnimal.displayObject then
				thisAnimal.displayObject:insert(thisAnimal.runningAnimal.displayObject)
			end
			animalsGroup1:insert(thisAnimal.displayObject)
			
			thisAnimal.addCaughtAnimalLayer = function()
				if thisAnimal.caughtAnimal.displayObject then
					localGroup:insert(thisAnimal.caughtAnimal.displayObject)
				end
			end
			
			thisAnimal.startRunning = function()
				thisAnimal.caughtAnimal.stop()
				thisAnimal.caughtAnimal.hide()
				
				thisAnimal.runningAnimal.start()
				thisAnimal.runningAnimal.appear()
				
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
			
			thisAnimal.kill = function()
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
			
			thisAnimal.appear = function(time)
				thisAnimal.runningAnimal.appear(time)
			end
			
			local function touchScreen (event)
				event = correctTouch(event)
				if event.phase == "moved" then
					if thisAnimal.displayObject.markX and thisAnimal.displayObject.markY then
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x, event.y
				end
				elseif event.phase == "ended" then
					Runtime:removeEventListener( "touch", touchScreen )
					audio.stop(animalSoundChannel)
					
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
					
					thisAnimal.displayObject.markX = nil
					thisAnimal.displayObject.markY = nil
					
					audio.stop(animalSoundChannel)
					audio.play(dropSound,{loops=0, channel=animalSoundChannel})
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
				end
			end
			
			local function touchAnimal (event)
				event = correctTouch(event)
				if event.phase == "began" then
					registerAnimalTouch(reg)
					if isDraggingAnimal then
						return
					end
					isDraggingAnimal = true
					
					audio.stop(animalSoundChannel)
					audio.play(caughtSound,{loops=-1, channel=animalSoundChannel})
					
					Runtime:addEventListener( "touch", touchScreen )
					
					thisAnimal.displayObject.originalX = thisAnimal.displayObject.x    -- store x location of object
					thisAnimal.displayObject.originalY = thisAnimal.displayObject.y    -- store y location of object
					
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
					
					loops = 0
					Runtime:removeEventListener( "enterFrame", move )
					
					thisAnimal.caughtAnimal.displayObject.x, thisAnimal.caughtAnimal.displayObject.y = event.x, event.y
					
					isDragging = true
				end
			end
			
			thisAnimal.displayObject:addEventListener( "touch", touchAnimal )
			
			return thisAnimal
		end
	
	local animal1 = newAnimal (1,0,1,1)
	local animal2 = newAnimal (2,0,1,2)
	
	animalsGroup1.y = (screenOriginY+viewableContentHeight) * 0.75
	animalsGroup1.xScale,animalsGroup1.yScale = 0.3 * viewableContentHeight/height, 0.3 * viewableContentHeight/height
	
	animal2.displayObject.x = 200
	
	local ag1ToLeft
	local ag1ToRight
	
	ag1ToLeft = function()
		if animalsGroup1 then
			animalsGroup1.xScale = -0.3
			animalsGroup1.x = width + 200
			if ag1ToRight then
				timer.performWithDelay(4000, ag1ToRight)
				transition.to(animalsGroup1,{time = 4000, x = -150})
			end
		end
	end
	
	ag1ToRight = function()
		if animalsGroup1 then
			animalsGroup1.xScale = 0.3
			animalsGroup1.x = -200
			if ag1ToLeft then
				timer.performWithDelay(4000, ag1ToLeft)
				transition.to(animalsGroup1,{time = 4000, x = width + 150})
			end
		end
	end
	
	local function disappearAnimals()
		animal1.vanish(300)
		animal2.vanish(300)
		animal3.vanish(300)
		animal4.vanish(300)
		
		sheep1.vanish(300)
		sheep2.vanish(300)
	end
	
	local function appearAnimals()
		animal1.appear(300)
		animal2.appear(300)
		animal3.appear(300)
		animal4.appear(300)
		timer.performWithDelay(1500,
									function()
									sheep1.appear(300)
									sheep2.appear(300)
									end)
	end
	appearAnimals()
	
	local function killAnimals()
		animal1.kill()
		animal2.kill()
		animal3.kill()
		animal4.kill()
		
		sheep1.kill()
		sheep2.kill()
		
		maryBase.kill()
		
		ag1ToLeft = nil
		ag1ToRight = nil
		ag2ToLeft = nil
		ag2ToRight = nil
		
		animalsGroup1 = nil
		animalsGroup2 = nil
		sheep1 = nil
		sheep2 = nil
		
		killAnimals = nil
	end
	
	worldGroup:insert(animalsGroup1)
	
	local signGroup = display.newGroup()
	
	--======================================
	-- SIGN
	--======================================
	local signGraphic = display.newImageRect("assets/menu/boton_whole.png",151,170)
	signGraphic:setReferencePoint(display.BottomCenterReferencePoint)
	signGraphic.x=screenOriginX+85
	signGraphic.y=screenOriginY + viewableContentHeight + 2
	signGroup:insert(signGraphic)
	
	--======================================
	-- START BUTTON
	--======================================
	-- ACTION
	local startButtonAction = function ( event )
		if isDraggingAnimal then
			return
		end
		local self = event.target
		local phase = event.phase
		if phase == "began" then
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
			elseif "ended" == phase or "cancelled" == phase then 
				if "ended" == phase then
					if isWithinBounds then
						startButtonFunction()
					end
				end
				-- Allow touch events to be sent normally to the objects they "hit"
				display.getCurrentStage():setFocus( self, nil )
				self.isFocus = false
			end
		end
	end
	-- UI ELEMENT
	local startButton = display.newImageRect("assets/menu/boton_start.png",151,115)
	startButton:setReferencePoint(display.CenterReferencePoint)
	startButton.x=screenOriginX+85
	startButton.y=screenOriginY + viewableContentHeight - 110
	signGroup:insert(startButton)
	
	startButton:addEventListener( "touch", startButtonAction )
	
	local MTFLogo = nil
	
	local backHome = function ()
		appearAnimals()
		
		transition.to(mountainsGroup,{time=2200,delay=0,transition=easing.inOutExpo,x=0})
		
		farWorldGroup:setReferencePoint(display.CenterReferencePoint)
		transition.to(farWorldGroup,{time=1800,delay=0,transition=easing.inOutExpo,rotation=-45})
		
		middlePlaneGroup:setReferencePoint(display.CenterReferencePoint)
		transition.to(middlePlaneGroup,{time=1400,transition=easing.inOutExpo,rotation=-45})
		
		worldGroup:setReferencePoint(display.CenterReferencePoint)
		transition.to(worldGroup,{time=1000,transition=easing.inOutExpo,rotation=0})
		
		if MTFLogo then
			transition.to(MTFLogo,{time=1000,delay=1100,transition=easing.inOutExpo,x = 20})
		end
		
		if signGroup then
			transition.to(signGroup,{time=1500,transition=easing.inOutExpo,y = 0})
		end
	end
	
	local openOptionsPopUp = function ()
		director:openPopUp({inGame = false,
							animated=true,
							hideAction = backHome,
							startFromAdventure = startFromAdventure,
							killCaller = nil,
							},
							"igMenu")
	end
	
	--======================================
	-- MENU BUTTON
	--======================================
	-- ACTION
	local function menuButtonAction ( event )
		if isDraggingAnimal then
			return
		end
		local self = event.target
		local phase = event.phase
		if phase == "began" then
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
			elseif "ended" == phase or "cancelled" == phase then 
				if "ended" == phase then
					if isWithinBounds then
						disappearAnimals()
						
						transition.to(mountainsGroup,{time=2200,transition=easing.inOutExpo,x=width*2/3})
						
						farWorldGroup:setReferencePoint(display.CenterReferencePoint)
						transition.to(farWorldGroup,{time=1800,transition=easing.inOutExpo,rotation=-25})
						
						middlePlaneGroup:setReferencePoint(display.CenterReferencePoint)
						transition.to(middlePlaneGroup,{time=1400,transition=easing.inOutExpo,rotation=-10})
						
						worldGroup:setReferencePoint(display.CenterReferencePoint)
						transition.to(worldGroup,{time=1000,transition=easing.inOutExpo,rotation=70,onComplete=openOptionsPopUp})
						
						if MTFLogo then
							transition.to(MTFLogo,{time=500,transition=easing.inOutExpo,x = 500})
						end
						
						if signGroup then
							transition.to(signGroup,{time=500,transition=easing.inOutExpo,y = height})
						end
					end
				end
				-- Allow touch events to be sent normally to the objects they "hit"
				display.getCurrentStage():setFocus( self, nil )
				self.isFocus = false
			end
		end
	end
	-- UI ELEMENT
	local menuButton = display.newImageRect("assets/menu/boton_menu.png",114,42)
	menuButton:setReferencePoint(display.CenterReferencePoint)
	menuButton.x=screenOriginX+80
	menuButton.y=screenOriginY + viewableContentHeight - 36
	signGroup:insert(menuButton)
	
	menuButton:addEventListener( "touch", menuButtonAction )
	
	worldGroup:insert(signGroup)
	
	-- INSERT THE BACKGROUND GROUP IN THE LOCAL GROUP
	localGroup:insert(worldGroup)
	
	sheep1.addCaughtAnimalLayer()
	sheep1.caughtAnimal.displayObject.xScale = 2.5
	sheep1.caughtAnimal.displayObject.yScale = 2.5
	
	sheep2.addCaughtAnimalLayer()
	sheep2.caughtAnimal.displayObject.xScale = 2.5
	sheep2.caughtAnimal.displayObject.yScale = 2.5
	
	animal1.addCaughtAnimalLayer()
	animal2.addCaughtAnimalLayer()
	animal3.addCaughtAnimalLayer()
	animal4.addCaughtAnimalLayer()
	
	--====================================================================--
	-- FUNCTIONS
	--====================================================================--
	
	local function resetCloud(event)
		transition.from(event,{time = math.random(15000,19000), x = width+50, onComplete = resetCloud})
	end
	transition.to(cloud1,{time = math.random(7500,8500) , x = -50, onComplete = resetCloud})
	transition.to(cloud2,{time = math.random(11000,13500) , x = -50, onComplete = resetCloud})
	transition.to(cloud3,{time = math.random(5500,7000) , x = -50, onComplete = resetCloud})
	transition.to(cloud4,{time = math.random(12000,14000) , x = -50, onComplete = resetCloud})
	
	-- SKY ACTIONS
	local function moveSky(event)
		if animatingSunY then
			if (sunY>=1) then
				sunToUp = not(sunToUp)
				timesChangedYMovementOfTheSun = timesChangedYMovementOfTheSun+1
				sunY=0
			end
			sunY = sunY+0.03
			local movementAmount = math.abs(math.abs(sunY-0.5)-0.5)
			if sunToUp then
				sun.y=sun.y-movementAmount
			else
				sun.y=sun.y+movementAmount
			end
			if (timesChangedYMovementOfTheSun>=6) and (movementAmount>=0.45) then
				animatingSunY = false
			end
		end
		
		if animatingSunRotation then
			if (sunRotation>=1) then
				rotateSunToLeft = not(rotateSunToLeft)
				timesChangedRotationOfTheSun = timesChangedRotationOfTheSun+1
				sunRotation=0
			end
			sunRotation = sunRotation+0.03
			local movementAmount = math.abs(math.abs(sunRotation-0.5)-0.5)
			if rotateSunToLeft then
				sun.rotation=sun.rotation+movementAmount
			else
				sun.rotation=sun.rotation-movementAmount
			end
			if (timesChangedRotationOfTheSun>=6) and (movementAmount>=0.45) then
				animatingSunRotation = false
			end
		end
	end
	Runtime:addEventListener("enterFrame",moveSky)
	
	local function sunTouched(event)
		if event.phase == "ended" then
			if (math.fmod(timesTouchedSun,2) == 0) then
				timesChangedYMovementOfTheSun = 0
				animatingSunY = true
			else
				timesChangedRotationOfTheSun = 0
				animatingSunRotation = true
			end
			timesTouchedSun = timesTouchedSun+1
			if (timesTouchedSun == 2) then
				unlockAchievement("com.tapmediagroup.MaryTheFairy.sun","Touch the sun","Sunny Welcome!")
			end
		end
	end
	sun:addEventListener("touch",sunTouched)
	
	--====================================================================--
	-- LOGO
	--====================================================================--
	
	MTFLogo = display.newImageRect("assets/logo.png",200,134)
	MTFLogo:setReferencePoint(display.TopLeftReferencePoint)
	MTFLogo.y = screenOriginY + 10
	MTFLogo.x = screenOriginX + 10
	MTFLogo.rotation = 0
	MTFLogo.xScale = 0.85
	MTFLogo.yScale = 0.85
	rotateElementInWorld(MTFLogo,0)
	worldGroup:insert(MTFLogo)
	
	--====================================================================--
	-- GC buttons
	--====================================================================--
	
	if usingiOS then
		local initGCCallback
		
		--achievements
		local achievementsButtonAction = function ( event )
			if event.phase == "release" then
				if loggedIntoGC then 
					gameNetwork.show( "achievements", { listener=requestCallback } )
				else
					initGameNetwork(initGCCallback)
				end
			end
		end
		-- UI ELEMENT
		local achievementsButton = ui.newButton{
						default = "assets/achievementsIcon"..suffix..".png",
						onEvent = achievementsButtonAction,
						id = "bt01"}
		achievementsButton:setReferencePoint(display.CenterRightReferencePoint)
		achievementsButton.x=display.screenOriginX+display.viewableContentWidth-25
		achievementsButton.y=display.screenOriginY+display.viewableContentHeight-45
		achievementsButton.xScale,achievementsButton.yScale=0.9/screenScale,0.9/screenScale
		signGroup:insert(achievementsButton)
		
		--leaderboards
		local leaderboardsButtonAction = function ( event )
			if event.phase == "release" then
				if loggedIntoGC then
					gameNetwork.show( "leaderboards", { listener=requestCallback } )
				else
					initGameNetwork(initGCCallback)
				end
			end
		end
		-- UI ELEMENT
		local leaderboardsButton = ui.newButton{
						default = "assets/leaderboardsIcon"..suffix..".png",
						onEvent = leaderboardsButtonAction,
						id = "bt01"}
		leaderboardsButton:setReferencePoint(display.CenterRightReferencePoint)
		leaderboardsButton.x=display.screenOriginX+display.viewableContentWidth-76
		leaderboardsButton.y=display.screenOriginY+display.viewableContentHeight-45
		leaderboardsButton.xScale,leaderboardsButton.yScale=0.9/screenScale,0.9/screenScale
		signGroup:insert(leaderboardsButton)
		
		if (not loggedIntoGC) and (not activateGamenetwork) then
			achievementsButton.isVisible = false
			leaderboardsButton.isVisible = false
			
			--achievements
			local gamecenterButtonAction = function ( event )
				if event.phase == "release" then
					transition.to(gamecenterButton, {alpha = 0})
					if loggedIntoGC then 
						activateGamenetwork = true
						initGCCallback({data = true})
					elseif not activateGamenetwork then
						activateGamenetwork = true
						initGameNetwork(initGCCallback)
					end
				end
			end
			-- UI ELEMENT
			gamecenterButton = ui.newButton{
							default = "assets/gamecenterIcon"..suffix..".png",
							onEvent = gamecenterButtonAction,
							id = "bt01"}
			gamecenterButton:setReferencePoint(display.CenterRightReferencePoint)
			gamecenterButton.x=display.screenOriginX+display.viewableContentWidth-50
			gamecenterButton.y=display.screenOriginY+display.viewableContentHeight-45
			gamecenterButton.xScale,gamecenterButton.yScale=0.9/screenScale,0.9/screenScale
			signGroup:insert(gamecenterButton)
		else
			activateGamenetwork = true
			achievementsButton.isVisible = true
			leaderboardsButton.isVisible = true
		end
		
		initGCCallback = function (event)
			if event.data then
				activateGamenetwork = true
				loggedIntoGC = true
				
				transition.from(achievementsButton, {alpha = 0})
				transition.from(leaderboardsButton, {alpha = 0})
				
				achievementsButton.isVisible = true
				leaderboardsButton.isVisible = true
				gamecenterButton.isVisible = false
			end
			initCallback(event)
		end
	end
	
	--======================================
	-- PLAY AGAIN MESSAGE
	--======================================
	local function hidePlayAgainMessage()
		if signGroup then
			signGroup.isVisible = true
			transition.from(signGroup,{time=500,transition=easing.inOutExpo,y = height})
		end
		if MTFLogo then
			MTFLogo.isVisible = true
			transition.from(MTFLogo,{time=1000,transition=easing.inOutExpo,y = -height})
		end
	end
	
	local function goPlayAgain()
		local paView = {params = {hideAction = hidePlayAgainMessage, repeatAction = goPlayAgain, shouldNotPlaySound = true}, name="PlayAgain"}
		director:openPopUp({startFromAdventure = startFromAdventure, adventureToStart = 1, caller = paView}, "selectDiff", nil )
	end
	
	if (showPlayAgainMessage) then
		if signGroup then
			signGroup.isVisible = false
		end
		if MTFLogo then
			MTFLogo.isVisible = false
		end
		
		director:openPopUp({hideAction = hidePlayAgainMessage,
							repeatAction = goPlayAgain,
							},
							"PlayAgain")
	end
	
	--====================================================================--
	-- LOAD SOUNDS AND MUSIC
	--====================================================================--
	
	local backgroundMusicChannel = 1
	local backgroundMusic = audio.loadSound("assets/sound/mainScreen.mp3")
	
	--====================================================================--
	-- PLAY MUSIC
	--====================================================================--
	
	backgroundMusicChannel = audio.play(backgroundMusic,{channel = backgroundMusicChannel, loops=-1, fadein=2500})
	
	local function marySoundFinishedPlaying(event)
		playingMarysSounds = false
	end
	
	local function playMarysSounds(event)
		if event.phase == "ended" then
			if not maryBase.isMoving then
				maryBase.reset()
				maryBase.start()
			end
			if not(playingMarysSounds) then
				local n = math.random(3)
				if n == 1 then
					print ("sound1")
				elseif n == 2 then
					print ("sound2")
				else
					print ("sound3")
				end
				playingMarysSounds = true
			end
		end
	end
	maryGroup:addEventListener("touch",playMarysSounds)
	
	continueAdventure = function()
		killAnimals()
		
		ag1ToLeft = nil
		ag1ToRight = nil
		ag2ToLeft = nil
		ag2ToRight = nil
		
		Runtime:removeEventListener( "enterFrame", moveSky )
		audio.stop(backgroundMusicChannel)
		
		preloader:changeScene("Adventure"..nextLevel,"moveFromRight")
		
		continueAdventure = nil
		startAdventure = nil
	end
	
	startAdventure = function()
		killAnimals()
		
		ag1ToLeft = nil
		ag1ToRight = nil
		ag2ToLeft = nil
		ag2ToRight = nil
		
		Runtime:removeEventListener( "enterFrame", moveSky )
		audio.stop(backgroundMusicChannel)
		
		preloader:changeScene("Adventure1","moveFromRight")
		
		continueAdventure = nil
		startAdventure = nil
	end
	
	startFromAdventure = function(adventureNumber)
		if not adventureNumber then
			return
		end
		if adventureNumber<=0 or adventureNumber>#levelIDS then
			return
		end
		killAnimals()
		
		ag1ToLeft = nil
		ag1ToRight = nil
		ag2ToLeft = nil
		ag2ToRight = nil
		
		Runtime:removeEventListener( "enterFrame", moveSky )
		audio.stop(backgroundMusicChannel)
		
		--preloader:changeScene("Adventure"..adventureNumber,"moveFromRight")
		preloader:changeScene("Interactivity"..adventureNumber,"moveFromRight")
		
		continueAdventure = nil
		startAdventure = nil
	end
	
	animal1.startRunning()
	animal2.startRunning()
	animal3.startRunning()
	animal4.startRunning()
	sheep1.startRunning()
	sheep2.startRunning()
	
	animalsGroup1.x = width + 150
	animalsGroup2.x = width + 150
	
	timer.performWithDelay(1000, 	function()
										if ag1ToRight then ag1ToRight() end
										if ag2ToRight then ag2ToRight() end
									end
									)
	
	return localGroup
end