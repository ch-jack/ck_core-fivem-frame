fx_version 'adamant'

game 'gta5'
lua54 'yes'

files {

}

client_script 'server/Ashared.lua'
client_script 'server/event.lua'
client_script 'client/*.lua'

server_scripts{
	'@mysql-async/lib/MySQL.lua',
	'server/*.lua'
}
