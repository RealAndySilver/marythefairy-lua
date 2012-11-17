-- Your Loading Scene
-- This is displayed while the next scene loads
-- You can customize it at will as long as it returns a localGroup for director

module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
		Runtime:removeEventListener( "system", systemEvent )
		
        local localGroup = display.newGroup()
        
        -- Code Start --
        
        local loadingBackground = display.newImageRect("assets/world/silverGardenSky.jpg",display.contentWidth,display.contentHeight)
		loadingBackground:setReferencePoint(display.TopLeftReferencePoint)
		loadingBackground.x = 0
		loadingBackground.y = 0
		localGroup:insert(loadingBackground)
		
		local originalLoadingText = "Loading"
		local loadingText = originalLoadingText
		local titleLabel = display.newText( loadingText, 0, 0, mainFont1, 36 )
		
		titleLabel:setTextColor(67,34,15,255)
		titleLabel.y = 85
		titleLabel.x = display.contentWidth/2
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
			
			local dotCount = 0
			for dot in string.gmatch(loadingText, "%.") do
				dotCount = dotCount + 1
			end
			titleLabel.x = display.contentWidth/2 + dotCount*3
			titleLabel.alpha = 1
			
			timer.performWithDelay(100,addDots)
		end
		timer.performWithDelay(100,addDots)
		
        -- Loading Mechanism --
        local function loadOn ()
        	director:changeScene(preloader.plNextLoadScene,preloader.plEffect,preloader.plArg1,preloader.plArg2,preloader.plArg3)
        	addDots = nil
        end
        timer.performWithDelay(510,loadOn)
        -- Code End --

        return localGroup
end