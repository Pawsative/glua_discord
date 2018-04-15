
# GLua Discord Libary

With this Libary you are able to set an clients status over the discord api and authorize users with the discord API.

***

# HOW TO USE

You have to edit the constants to fit your discord application. And add the hooks to your addon or gamemode.

***

**Constants**

**Shared**
`CLIENT_ID`
The Client ID from the discord application.

The Process ID from the discord application.

    local CLIENT_ID 	= "1234567891011121314"

**Server**
`CLIENT_SECRET`
The Client Secret from the discord application.

`REDIRECT_URI`
The Redirect URI for your discord, the same exact URI needs to be saved in the application.

    local CLIENT_SECRET = "4ASasd534ASDashdj3463463ASDaDg23"
    local REDIRECT_URI  = "https://discord.gg/1234abc"

***

**Serverside**

It is possible for 2 people to send both their codes over to the server so both will receive the first users permissions example, so it's important to make sure that a user only authenticates with one discord user id, if he calls it with 2 different user ids he is trying to exploit the system.

**Hooks**
`"Discord.UserAuthenticated"`
This hook will be called when a user has au
thenticated himself.

    hook.Add( "Discord.UserAuthenticated", "ADDON.UniqueName", function( tData, pPlayer )
		local discriminator 	= tData.discriminator
		local id 		= tData.id
		local username 		= tData.username
		local avatar 		= tData.avatar
		local mfa_enabled 	= tData.mfa_enabled

		print( discriminator, id, username, avatar, mfa_enabled )
		--> "7070", "280432211818184705", "Flixs", "0a1c8879bbdf7e97a319b4db0465ce8d", true
    end )

***

**Clientside**

The client can authenticate himself to the server and also set up his activity in discord.

**Hooks**
`"Discord.GetActivity"`
This hook will be called in a certain time every so often, returning a table will then set the activity.

	local START_TIME = os.time()
    hook.Add( "Discord.GetActivity", "ADDON.UniqueName", sState )
        if sState == "Default" then
			local tActivity = {
				details = "My Cool Server",
				state = GetHostName() .. " (" .. player.GetCount() .. " / " .. game.MaxPlayers() .. ")",
				timestamps = {
					start = START_TIME
				},
				assets = {
					large_image = "your_cool_large_image",
					large_text = "Cool Large Image Hover Text",

					small_image = "your_cool_small_image",
					small_text = "Cool Small Image Hover Text"
				}
			}

			return tActivity
        end
    end )

**Callable Hooks**
`"Discord.Authorize"`
If this hook is called it will start the authorize process.

    hook.Run( "Discord.Authorize" )

`"Discord.ChangeState"`
If this hook is called with a state it will set the discord state.

    hook.Run( "Discord.ChangeState", "YourNewState" )

***

# Special Thanks To
    @DevulTj (https://github.com/DevulTj)
    @Tenrys (https://github.com/Tenrys)
