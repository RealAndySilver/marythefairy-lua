-- Your Loading Scene
-- This is displayed while the next scene loads
-- You can customize it at will as long as it returns a localGroup for director

module(..., package.seeall)

------------------
-- Imports
------------------
local ui = require("ui")

-- Main function - MUST return a display.newGroup()
function new()
		
		local width = display.contentWidth
		local height = display.contentHeight
		
		local viewableContentWidth = display.viewableContentWidth
		local viewableContentHeight = display.viewableContentHeight
		
		local screenOriginX = display.screenOriginX
		local screenOriginY = display.screenOriginY
		
		local sscalex = display.contentScaleX
		local sscaley = display.contentScaleY
		
		local screenRemainingSpace = viewableContentHeight - 250
		
        local localGroup = display.newGroup()
        
        -- Code Start --
        
        local loadingBackground = display.newImageRect("assets/world/fairiesTownBlurred.jpg",display.contentWidth,display.contentHeight)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		
		--ads.show( "banner320x48", { x=80, y=60, interval=5, testMode=true } )
		
		--ads.show( "banner320x48", { x=80, y=212, interval=5, testMode=true } )
		
		--ads.show( "banner300x250", { x=90, y=screenOriginY, interval=5, testMode=true } )
		
		local ssscale = sscalex
		if usingiOS and (not usingiPad) and (sscalex == 1 or sscalex == 0.5) then --iphone normal y retina
			ssscale = 1
		elseif usingiOS and (not usingiPad) then --iphone 5
			ssscale = sscalex*2
		elseif usingiPad then --ipad
			ssscale = 0.41666665673256
		else --resto
		end
		ads.show( "banner300x250", { x=90+(((300/ssscale)-300)/2)*ssscale, y=screenOriginY+((250/ssscale-250)/2)*ssscale, interval=5, testMode=true } )
		
		--if usingiPad then
			--ads.show( "banner300x250", { x=260, y=screenOriginY+141, interval=5, testMode=true } )
		--else
			--ads.show( "banner300x250", { x=90, y=screenOriginY, interval=5, testMode=true } )
		--end
		
        local clickable = false
		local resumeButton
		local makeClickable
		local kill
		-- Loading Mechanism --
        local function loadOn ()
        	ads.hide()
            director:changeScene(adPreloader.plNextLoadScene,adPreloader.plEffect,adPreloader.plArg1,adPreloader.plArg2,adPreloader.plArg3)
        end
        
        local resumeButtonAction = function ( event )
			if event.phase == "release" and clickable then
				clickable = false
				loadOn()
				timer.performWithDelay(500,kill)
			end
		end
        resumeButton = ui.newButton{
						default = "assets/botonBlanco.png",
						onEvent = resumeButtonAction,
						text = "Continue",
						size = 64,
						font = mainFont1,
						--offset = correctOffset(-5),
						emboss = true,
						textColor={66,33,11,255},
						id = "bt01"}
		resumeButton:setFillColor( 202, 202, 202 )
		resumeButton:setTextColor( 63, 63, 63, 255 )
		rbSF = screenRemainingSpace / resumeButton.contentHeight
		if rbSF < 0.75 then
			rbSF = 0.75
		end
		resumeButton.xScale,resumeButton.yScale = rbSF, rbSF
		resumeButton:setReferencePoint(display.CenterReferencePoint)
		resumeButton.x=display.contentWidth/2
		resumeButton.y=screenOriginY + viewableContentHeight - screenRemainingSpace / 2
		if not usingiOS then
			if sscaley <= 0.75 then
				resumeButton.y = resumeButton.y - 25
			else
				resumeButton:setReferencePoint(display.TopCenterReferencePoint)
				resumeButton.xScale,resumeButton.yScale = rbSF*0.75, rbSF*0.75
				resumeButton:setReferencePoint(display.CenterReferencePoint)
			end
		end
		resumeButton.isVisible=false
		localGroup:insert(resumeButton)
		
		local originalLoadingText = "Loading"
		local loadingText = originalLoadingText
		local titleLabel = display.newText( loadingText, 0, 0, mainFont1, 36 )
		
		titleLabel:setTextColor(67,34,15,255)
		titleLabel.y = resumeButton.y
		titleLabel.x = resumeButton.x
		titleLabel.xScale,titleLabel.yScale = rbSF/0.75, rbSF/0.75
		localGroup:insert(titleLabel)
		
		titleLabel.alpha=0
		transition.to(titleLabel,{alpha=1,time=500})
		
		--titleLabel:setReferencePoint(display.TopLeftReferencePoint)
		local textStartsOn = titleLabel.x
		
		local addDots
		addDots = function()
			loadingText = loadingText.."."
			if string.find(loadingText, "%.%.%.%.") then
				loadingText = originalLoadingText
			end
			titleLabel.text = loadingText
			titleLabel.alpha = 1
			
			local dotCount = 0
			for dot in string.gmatch(loadingText, "%.") do
				dotCount = dotCount + 1
			end
			titleLabel.x = display.contentWidth/2 + dotCount*3
			
			timer.performWithDelay(100,addDots)
		end
		timer.performWithDelay(100,addDots)
		
		makeClickable = function ()
			resumeButton:setFillColor( 196, 243, 133 )
			resumeButton:setTextColor( 66, 33, 11, 255 )
			resumeButton.isVisible=true
			clickable = true
			addDots = nil
			titleLabel.isVisible=false
		end
		timer.performWithDelay(5000,makeClickable)
		
		kill = function ()
			resumeButtonAction=nil
			clickable = nil
			resumeButton = nil
			makeClickable = nil
		end
		
        return localGroup
end