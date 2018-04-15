
--[[
	-----------------
	| DISCORD INFOS |
	-----------------

	String: CLIENT_ID

		local CLIENT_ID = "1234567891011121314"

		Value: (String)		= The Client ID from the discord application

]]--

--[[------------------------------------------------------------------------------------------------
	| EDITABLE VALUES |
	-------------------
]]--

local CLIENT_ID 	= "1234567891011121314"

--[[------------------------------------------------------------------------------------------------
	| EDIT CODE BELOW AT YOUR OWN RISK |
	------------------------------------
]]--

--[[
	CONSTANTS
]]--

DISCORD 			= DISCORD or {}
DISCORD.Client_ID 	= CLIENT_ID

DISCORD.Initialized = DISCORD.Initialized 	or false
DISCORD.HTTPLoaded 	= DISCORD.HTTPLoaded 	or false
DISCORD.Port 		= DISCORD.Port 			or nil

local HTTP = HTTP
local util = util

local isstring 	= isstring
local tostring 	= tostring
local MsgC 		= MsgC

local PREFIX 			= "[DISCORD] "
local PREFIX_SUCCESS	= PREFIX .. "[SUCCESS] "
local PREFIX_WARN		= PREFIX .. "[WARN] "

local COL_WHITE	= Color( 255, 255, 255 )
local COL_BLUE	= Color( 0, 0, 255 )
local COL_GREEN	= Color( 0, 255, 0 )
local COL_RED	= Color( 255, 0, 0 )

--[[
	PRINT FUNCTIONS
]]--
local function printDebug( sText )
	MsgC( COL_BLUE, PREFIX, COL_WHITE, sText, "\n" )
end

local function printSuccess( sText )
	MsgC( COL_GREEN, PREFIX_SUCCESS, COL_WHITE, sText, "\n" )
end

local function printWarn( sText )
	MsgC( COL_RED, PREFIX_WARN, COL_WHITE, sText, "\n" )
end

--[[
	CONSTANTS
]]--

DISCORD.printDebug 		= DISCORD.printDebug 	or printDebug
DISCORD.printSuccess 	= DISCORD.printSuccess 	or printSuccess
DISCORD.printWarn 		= DISCORD.printWarn 	or printWarn

--[[
	DISCORD SEND HTTP

		With this function you can send HTTP request
		to the discord API
]]--
function DISCORD:SendHTTP( tBody, fCallback, tHeaders, sURL )
	if tHeaders and isstring( tHeaders ) then
		sURL = tHeaders

		tHeaders = nil
	end

	HTTP {
		method = SERVER and "GET" or "POST",
		url = sURL,

		type = SERVER and "application/x-www-form-urlencoded" or "application/json",
		body = util.TableToJSON( tBody ),

		headers = tHeaders,

		success = function( iStatus, sBody )
			if not fCallback then return end

			tBody = util.JSONToTable( sBody )
			if tBody and tBody.evt != "ERROR" then
				fCallback( tBody )
			else
				local sError = tostring( tBody and tBody.data and tBody.data.message or "unknown" )

				fCallback( false, "DISCORD Error: " .. sError )
			end
		end,

		failed = function( sError )
			if not fCallback then return end

			fCallback( false, "HTTP Error: " .. sError )
		end
	}
end
