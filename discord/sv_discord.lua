
--[[
	-----------------
	| DISCORD INFOS |
	-----------------

	String: CLIENT_SECRET

		local CLIENT_SECRET = "4ASasd534ASDashdj3463463ASDaDg23"

		Value: (String)		= The Client Secret from the discord application

	String: REDIRECT_URI

		local REDIRECT_URI = "https://discord.gg/1234abc"

		Value: (String) 	= The Redirect URI for your discord, the same exact URI needs
							  to be saved in the application
]]--

--[[------------------------------------------------------------------------------------------------
	| EDITABLE VALUES |
	-------------------
]]--

local CLIENT_SECRET = "4ASasd534ASDashdj3463463ASDaDg23"
local REDIRECT_URI 	= "https://discord.gg/1234abc"

--[[------------------------------------------------------------------------------------------------
	| EDIT CODE BELOW AT YOUR OWN RISK |
	------------------------------------
]]--

--[[
	CONSTANTS
]]--

DISCORD 				= DISCORD or {}
DISCORD.Client_Secret 	= CLIENT_SECRET

local CLIENT_ID = DISCORD.Client_ID

local http 	= http
local util 	= util
local net 	= net
local hook 	= hook

local CurTime = CurTime
local IsValid = IsValid

local API_ENDPOINT = "https://discordapp.com/api/v6"

local TOKEN_ADDRESS = API_ENDPOINT .. "/oauth2/token"
local INFO_ADDRESS 	= API_ENDPOINT .. "/users/@me"

local AUTHENTICATE_COOLDOWN = 25

--[[
	NETWORK STRINGS
]]--

util.AddNetworkString( "Discord.SendAuthCode" )

--[[
	PRINT FUNCTIONS
]]--

local printSuccess 	= DISCORD.printSuccess
local printWarn 	= DISCORD.printWarn

--[[
	DISCORD CONVERT CODE

		This function will convert the code into a
		access token
]]--
function DISCORD:ConvertCode( sCode, fCallback, pPlayer )
	http.Post( TOKEN_ADDRESS, {
		grant_type = "authorization_code",
		code = sCode,
		client_id = CLIENT_ID,
		client_secret = CLIENT_SECRET,
		redirect_uri = REDIRECT_URI
	}, function( sRes )
		local tData = util.JSONToTable( sRes )
		if tData and not tData.error then
			if fCallback then fCallback( tData ) end
		else
			printWarn( "Failed to authorize " .. pPlayer:SteamID64() .. ", code: " .. sCode .. ", error: "  .. ( tData.error or "unknown" ) )
		end
	end )
end

--[[
	DISCORD AUTHENTICATE CODE

		THis function will authenticate the user
		with the given access code
]]--
function DISCORD:AuthenticateCode( sCode, pPlayer )
	self:ConvertCode( sCode, function( tData )
		self:Authenticate( tData.access_token, pPlayer )
	end, pPlayer )
end

--[[
	DISCORD AUTHENTICATE

		This function will authenticate the user with
		given access token
]]--
function DISCORD:Authenticate( sToken, pPlayer )
	if not IsValid( pPlayer ) or not sToken then return end

	self:SendHTTP( nil, function( tBody, sError )
		if not tBody then
			printWarn( "Failed to authenticate: " .. pPlayer:SteamID64() .. " , error: " .. sError )

			return
		end

		printSuccess( "Succsessfully authenticated: " .. pPlayer:SteamID64() )

		hook.Run( "Discord.UserAuthenticated", tBody, pPlayer )
	end, {
		[ "Authorization" ] = "Bearer " .. sToken,
		[ "User-Agent" ] = "DiscordBot (https://github.com/7Flixs/glua_discord, 1.0.0)",
		[ "Content-Length" ] = "0"
	}, INFO_ADDRESS )
end

--[[
	DISCORD SEND AUTH CODE

		This netmessage will receive the authorize code
		from the client and with authenticate the user
]]--
net.Receive( "Discord.SendAuthCode", function( iLen, pPlayer )
	if not IsValid( pPlayer ) then return end

	local flCurTime = CurTime()
	if pPlayer.LastSendAuthCode and pPlayer.LastSendAuthCode >= flCurTime then return end
	pPlayer.LastSendAuthCode = flCurTime + AUTHENTICATE_COOLDOWN

	local sCode = net.ReadString()
	if not sCode or #sCode <= 0 then return end

	DISCORD:AuthenticateCode( sCode, pPlayer )
end )
