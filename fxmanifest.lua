fx_version "adamant"

description "Script By Lxr Dev discord.gg/R9KgyCkXJp"
author "By Toxic"
version '1.0.0'
repository 'https://discord.com/invite/R9KgyCkXJp'

game "gta5"

client_script { 
"main/client.lua"
}

server_script {
  "main/server.lua",
  '@mysql-async/lib/MySQL.lua',  -- MYSQL ASYNC
  '@oxmysql/lib/MySQL.lua', -- OXMYSQL
} 

shared_script "main/shared.lua"


ui_page "index.html"

files {
  'index.html',
  'vue.js',
  'assets/**/*.*',
  'assets/font/*.otf',  
  'assets/font/Mark_Simonson_Proxima_Nova_Extra_Condensed_Light_Italic_TheFontsMaster.com.otf',
  'assets/font/Mark_Simonson_Proxima_Nova_Condensed_Light_Italic_TheFontsMaster.com.otf',  
  'assets/font/Mark_Simonson_Proxima_Nova_Condensed_Thin_TheFontsMaster.com.otf',
}

escrow_ignore { 'main/shared.lua' }

lua54 'yes'
