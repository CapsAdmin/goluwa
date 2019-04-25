local utility = ... or _G.utility

function utility.DownloadLineStickers(id, cb)
	local out = {
		stickers = {},
		icon_path = "https://stickershop.line-scdn.net/stickershop/v1/product/"..id.."/LINEStorePC/main.png",
	}

	http.Download("https://store.line.me/stickershop/product/" .. id):Then(function(content)
		out.title = content:match("<title>(.-) – .-</title>"):gsub("&#%d-;", "")
		out.stickers = {}

		for url in content:gmatch("(https://stickershop%S-sticker/%d-/ANDROID%S-%.png)") do
			table.insert(out.stickers, url)
		end

		if out.stickers[1] then
			cb(out)
		else
			http.Download("http://dl.stickershop.line.naver.jp/products/0/0/1/"..id.."/android/productInfo.meta"):Then(function(content)
				local tbl = serializer.Decode("json", content)
				for i,v in ipairs(tbl.stickers) do
					table.insert(out.stickers, "http://stickershop.line-cdn.net/products/0/0/1/"..tbl.packageId.."/PC/stickers/"..v.id..".png")
				end
				cb(out)
			end)
		end
	end)
end

do
	local urls = {
		"http://stickershop.line-cdn.net/products/0/0/2/1073/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/1/9880/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/3/1071/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/3/1072/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/2/1070/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/100/1/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/100/2/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/100/3/BlackBerryHD/stickers.zip",
		"http://stickershop.line-cdn.net/products/0/0/100/4/BlackBerryHD/stickers.zip",
	}

	function utility.DownloadDefaultLineStickers(cb)
		for _, url in ipairs(urls) do
			local package_id = url:match("products/(.+)/BlackBerryHD")

			local out = {
				stickers = {},
				icon_path = "https://stickershop.line-scdn.net//stickershop/v1/product/"..package_id:match(".+/(%d+)").."/android/main.png"
			}

			http.Download(url):Then(function(data)
				out.title = data:match([=["en":"(.-)"]=])

				for id in data:match([=["stickers":%b[]]=], 0):gmatch([=["id":(%d+)]=]) do
					table.insert(out.stickers, "http://stickershop.line-cdn.net/products/"..package_id.."/PC/stickers/"..id..".png")
				end

				cb(out)
			end)
		end

		return default
	end
end