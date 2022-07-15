-- Taken from Gmodwiki include example
D_SCPBase = D_SCPBase or {}

D_SCPBase.AutorunFile = function(File, directory)
	local prefix = string.lower( string.Left( File, 3 ) )

	print("[(D) SCP-Base] Autorun File: " .. File)

	if SERVER and prefix == "sv_" then
		include( directory .. File )
	elseif prefix == "sh_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
		end
		include( directory .. File )
	elseif prefix == "cl_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
		elseif CLIENT then
			include( directory .. File )
		end
	end
end

D_SCPBase.AutorunDirectory = function(directory)
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			D_SCPBase.AutorunFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		print( "[(D) SCP-Base] Autorun Directory: " .. v )
		D_SCPBase.AutorunDirectory( directory .. v )
	end
end

D_SCPBase.AutorunDirectory("deno_scp/config")
D_SCPBase.AutorunDirectory("deno_scp/core")
D_SCPBase.AutorunDirectory("deno_scp/scp")