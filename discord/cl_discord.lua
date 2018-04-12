
--[[------------------------------------------------------------------------------------------------
	| EDIT CODE BELOW AT YOUR OWN RISK |
	------------------------------------
]]--

--[[
	CONSTANTS
]]--

DISCORD 		= DISCORD 		or {}
DISCORD.State 	= DISCORD.State or "Default"

local CLIENT_ID 	= DISCORD.Client_ID
local PROCESS_ID 	= DISCORD.Process_ID

local net 		= net
local hook 		= hook
local http 		= http
local timer 	= timer
local string 	= string

local tostring 	= tostring
local istable 	= istable
local SysTime 	= SysTime

local MIN_PORT = 6463
local MAX_PORT = 6473

local PORT_COUNT = MAX_PORT - MIN_PORT

local CONNECTION_ADDRESS		= "http://127.0.0.1:%s"
local DISCORD_ASSETS_ADDRESS	= string.format( "https://discordapp.com/api/v6/oauth2/applications/%s/assets", CLIENT_ID )
local RPC_ADDRESS 				= "http://127.0.0.1:%s/rpc?v=1&client_id=%s"

local ACTIVITY_SYNC_COOLDOWN = 15

local FALLBACK_ACTIVITY = {
	details = "N/A",
	state 	= "Doing nothing"
}

--[[
	PRINT FUNCTIONS
]]

local printDebug 	= DISCORD.printDebug
local printSuccess 	= DISCORD.printSuccess
local printWarn 	= DISCORD.printWarn

--[[
	DISCORD HTTP LOADED CHECK

		Wait until http loaded, so we can
		initialize discord
]]--
if not DISCORD.HTTPLoaded then
	printDebug( "Waiting for HTTP to load" )

	timer.Create( "Discord.HTTPLoadedCheck", 3, 0, function()
		http.Fetch( "http://www.google.com/", function()
			DISCORD.HTTPLoaded = true

			printSuccess( "HTTP loaded" )

			hook.Run( "Discord.OnHTTPLoaded" )

			timer.Remove( "Discord.HTTPLoadedCheck" )
		end, function() end )
	end )
end

--[[
	DISCORD ON HTTP LOADED HOOK

		This hook will be called when http was
		successfully loaded, and initializes
		discord
]]--
hook.Add( "Discord.OnHTTPLoaded", "Discord.OnHTTPLoaded", function()
	printDebug( "Starting to initialize" )

	DISCORD:Init()
end )

--[[
	DISCORD INIT

		With this function we will initialize
		our discord rpc, we need to find a
		valid port
]]--
function DISCORD:Init()
	self:CheckPort( MIN_PORT, function()
		RPC_ADDRESS = string.format( RPC_ADDRESS, self.Port, CLIENT_ID )

		self:PostInit()

		self:SetActivity( { state = "Initializing" } )
	end )
end

--[[
	DISCORD CHECK PORT

		With this function we will check if the
		given port is valid for our api calls
]]--
function DISCORD:CheckPort( iPort, fCallback, iTryedPorts )
	iTryedPorts = ( iTryedPorts or 0 ) + 1

	if iTryedPorts == PORT_COUNT then
		printWarn( "Connection failed, unable to find port between: " .. MIN_PORT .. ", " .. MAX_PORT  )

		return
	end

	http.Fetch( string.format( CONNECTION_ADDRESS, iPort ),
	function( sBody )
		if not string.match( sBody, "Authorization Required" ) then return end

		printSuccess( "Connected successfully on port " .. iPort )

		self.Port = iPort

		if fCallback then fCallback() end
	end, function()
		self:CheckPort( iPort + 1, fCallback, iTryedPorts )
	end )
end

--[[
	DISCORD POST INIT

		This function will be callled after our
		rpc client has ben initialized
]]--

function DISCORD:PostInit()
	http.Fetch( DISCORD_ASSETS_ADDRESS, function( sBody )
		printSuccess( "Successfully ran post init" )

		timer.Create( "Discord.GetActitivity", ACTIVITY_SYNC_COOLDOWN, 0, function()
			self:GetActivity()
		end )
	end, function( sError )
		printWarn( "Failed to run post init, trying again in 3 seconds" )

		timer.Simple( 3, self.PostInit )
	end )
end

--[[
	DISCORD SET ACTIVITY

		With this function you will be able to
		the discord acitvity
]]--
function DISCORD:SetActivity( tActivity, fCallback )
	self:SendHTTP( {
		cmd = "SET_ACTIVITY",
		args = {
			pid = PROCESS_ID,
			activity = tActivity
		},
		nonce = tostring( SysTime() )
	}, fCallback, RPC_ADDRESS )
end

--[[
	DISCORD GET ACTIVITY

		With this function you will be able to
		the discord acitvity
]]--
function DISCORD:GetActivity()
	local tActivity = hook.Run( "Discord.GetActivity", self:GetState() )
	if not istable( tActivity ) then
		tActivity = FALLBACK_ACTIVITY
	end

	self:SetActivity( tActivity )
end

--[[
	DISCORD SET STATE

		With this function you will set the
		discord state that will be send with
		each hook
]]--
function DISCORD:SetState( sState )
	self.State = sState
end

--[[
	DISCORD GET STATE

		With this function you can get the current
		discord state
]]--
function DISCORD:GetState()
	return self.State
end

--[[
	DISCORD AUTHORIZE

	With this function you can authorize the
	current localplayer
]]--
function DISCORD:Authorize()
	self:SendHTTP( {
		cmd = "AUTHORIZE",
		args = {
			client_id = CLIENT_ID,
			scopes = { "identify", "guilds.join" }
		},
		nonce = tostring( SysTime() )
	}, function( tBody, sError )
		if not tBody then
			printWarn( "Failed to authorize, error : " .. sError )

			return
		end

		local tData = tBody.data
		if not tData then
			printWarn( "Failed to authorize, error : Invalid data" )

			return
		end


		local sCode = tData.code
		if not sCode then
			printWarn( "Failed to authorize, error : Invalid code" )

			return
		end

		net.Start( "Discord.SendAuthCode" )
			net.WriteString( sCode )
		net.SendToServer()
	end, RPC_ADDRESS )
end

--[[
	DISCORD AUTHORIZE HOOK

		If this hook is called it will start the
		client authorize process
]]--
hook.Add( "Discord.Authorize", "Discord.Authorize", function()
	DISCORD:Authorize()
end )

--[[
	DISCORD CHANGE STATE HOOK

		If this hook is called with a string state
		it will set the discord state to the given
		state
]]--
hook.Add( "Discord.ChangeState", "Discord.ChangeState", function( sState )
	if not sState or #sState <= 0 then return end

	DISCORD:SetState( sState )
end )
