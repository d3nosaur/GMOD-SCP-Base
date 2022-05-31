-- Taken from Gmodwiki include example

local function AddFile( File, directory )
	local prefix = string.lower( string.Left( File, 3 ) )

	if SERVER and prefix == "sv_" then
		include( directory .. File )
		print( "[(D) SCP-Base Loader] SERVER INCLUDE: " .. File )
	elseif prefix == "sh_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[(D) SCP-Base Loader] SHARED ADDCS: " .. File )
		end
		include( directory .. File )
		print( "[(D) SCP-Base Loader] SHARED INCLUDE: " .. File )
	elseif prefix == "cl_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[(D) SCP-Base Loader] CLIENT ADDCS: " .. File )
		elseif CLIENT then
			include( directory .. File )
			print( "[(D) SCP-Base Loader] CLIENT INCLUDE: " .. File )
		end
	end
end

local function IncludeDir( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		print( "[(D) SCP-Base Loader] Directory: " .. v )
		IncludeDir( directory .. v )
	end
end

IncludeDir( "deno_scp" )