steam.DownloadWorkshopCollection("427843415", function(ids)
	for _, id in ipairs(ids) do
		gine.CheckWorkshopAddon(id, true)
	end
end)