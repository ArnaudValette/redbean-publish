local navcss =require "css".navcss
local pagecss =require "css".pagecss
function escape(s)
   local entities = {
        ["&"] = "&amp;",
        ['"'] = "&quot;",
        ["'"] = "&apos;",
        ["<"] = "&lt;",
        [">"] = "&gt;"
    }
    
    return s:gsub("[&\"'<>]", function(c) return entities[c] end)
end

style=[[
<style>
body, main, h1, h2, h3, h4, h5, h6, h7, h8, h9, p, span, div, ul, li{
   padding:0;
   margin:0;
   font-family: sans-serif;
}
]]..navcss .. pagecss.. [[
</style>
]]

function htmlify(s)
   return [[
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8'>
<link rel="icon" type="image/x-icon" href="/favicon.ico">
<meta name='viewport' content='width=device-with; initial-scale=1.0'>
<title>valettearnaud</title>
</head>
<body>
<main>
]] .. s..[[</main></body>]]..style..[[</html>]]
end


return {
   escape=escape,
   htmlify=htmlify,
   style=style
}
