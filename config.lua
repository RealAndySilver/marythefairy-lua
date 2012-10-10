application =
{
	content =
	{
		width = 320,
		height = 480,
		scale = "zoomEven",
		xAlign = "center",
		yAlign = "center",
		fps = 60,
		imageSuffix =
        {
        	["@150"] = 1.5,
        	["@180"] = 1.8,
            ["@200"] = 2,
            ["@300"] = 3,
        }
	},
	notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert"
            }
        }
    }
}