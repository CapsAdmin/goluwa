local name = "bullet"
solution(name)
language("C++")
configurations{"Release"}
location("../project_files/" .. _ACTION)

local function add_arch(arch)
		project(name .. " " .. arch)
		platforms(arch)
	
		local tbl = {"USE_MINICL"}
		if os.get() == "windows" then
			table.insert(tbl, "_WINDOWS")
		end
		defines(tbl)
		
	
		location("../project_files/" .. _ACTION)

		flags("NoMinimalRebuild")

		buildoptions("/MD")

		language("C++")
		kind("SharedLib")
	
		targetdir("../../" .. os.get() .. "/" .. arch)
		targetname(name)

		objdir("../obj/")
		
		includedirs("../src/bullet/")
		includedirs("../src/")

		files("../src/**.c")
		files("../src/**.cpp")
		files("../src/**.h")

		flags("Optimize")
end

add_arch("x86")
add_arch("x64")