
--[[]
--loads a file
local function AddFile(File, directory)
	local prefix = string.lower(string.Left(File, 3))

	if SERVER and prefix == "sv_" then
		--include server
		include(directory .. File)
	elseif prefix == "sh_" or prefix == "kb_" then
		--include server and add to client
		if SERVER then
			AddCSLuaFile(directory .. File)
		end
		include(directory .. File)
	elseif prefix == "cl_" then
		--add to client and include in client
		if SERVER then
			AddCSLuaFile(directory .. File)
		elseif CLIENT then
			include(directory .. File)
		end
	end
end

local function IncludeDir(directory, path)
    path = path or "LUA"
	directory = directory .. "/"

	--finds files and folders in the directory
	local files, directories = file.Find(directory .. "*", path)

	--for each file, add the file
	for _, v in ipairs(files) do
		if string.EndsWith(v, ".lua") then
			AddFile(v, directory)
		end
	end

	--for each directory found, do this function again
	for _, v in ipairs(directories) do
		IncludeDir(directory .. v)
	end
end

IncludeDir("kitbash/gamemode")
]]