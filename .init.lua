-- special script called by main redbean process at startup
function Slurp(path)
  local file, err = io.open(path, "r")
  if not file then return nil, err end
  local content = file:read("*a") -- Read the entire file content
  file:close()
  return content
end

if IsDaemon() then -- call it production mode
  ProgramPrivateKey(Slurp('/etc/letsencrypt/live/redbean-ecdsa/privkey.pem'))
  ProgramCertificate(Slurp('/etc/letsencrypt/live/redbean-ecdsa/fullchain.pem'))
  ProgramPrivateKey(Slurp('/etc/letsencrypt/live/redbean-rsa/privkey.pem'))
  ProgramCertificate(Slurp('/etc/letsencrypt/live/redbean-rsa/fullchain.pem'))
  ProgramUid(1000)
  ProgramGid(1001)
  ProgramPort(80)
  ProgramPort(443)
  ProgramLogPath('/var/log/redbean.log')
  ProgramPidPath('/var/run/redbean.pid')
end


HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')
-- -- ;; So you can navigate;
-- (setq lua-imenu-generic-expression `(("Sections" "^--[[:space:]][0-9]+\\.[[:space:]][A-Z]+.*" 0)))
-- (setq imenu-generic-expression lua-imenu-generic-expression)
-- (imenu--make-index-alist)
local hE = require "higherelements"
local lE = require "lesserelements"
local testing = require "testing"


-- 1. LIB
strip = function (s,n) return string.sub(s,2+(n or 0)) end -- it's getting hot in here 
sL = function (s) return string.len(s) end
sEqx = function (s,x) return string.sub(s, 1, sL(x) )==x end


-- 2. MAIN

surr={
   "span",
   "h",
   "li",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
}
surrEnd={
   "span",
   "h",
   "li",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
}
function handleSurr(t,txt,l)
   rest=""
   if t==1 then rest = "" .. l end
   return "<"..surr[t+1].. rest..">" .. txt .. "</"..surrEnd[t+1].. rest..">"
end

runL = function (s) return hE.parse(s) end

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


opening={
   "<p>",
   "",
   "<ul>",
   "<pre>",
   "<div class='verse'>",
   "<div class='quote'>",
   "<div class='export'>",
   "<div class='example'>",
   "<div class='comment'>",
   "<div class='center'>",
   "<div class='empty'>",
   "<div class='empty'>",
   "<div class='literal'>",
}
closing={
   "</p>",
   "",
   "</ul>",
   "</pre>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
}
function printFile(path)
   file=io.open(path, "r")
   i=0
   mode=-1
   level=0
   html = ""
   htmls={}
   metaHtmls=0
   if file then
      for line in file:lines() do
         parsed=''
         res= runL(line)
         if res.type == 1 and sL(html)>0 then
            table.insert(htmls, html .. closing[mode > -1 and mode + 1 or 2])
            metaHtmls = metaHtmls + 1
            html = opening[res.type+1] 
            level=0
            mode=1
         elseif (not (mode == res.type)) then
            -- we change modes
            parsed = closing[mode > - 1 and mode + 1 or 2] .. opening[res.type+1]
            mode = res.type
         end
         if res.type == 2 then
            if res.level > level then
               parsed=parsed.."<ul>"
               level = res.level
            elseif res.level < level then
               parsed=parsed.."</ul>"
               level=res.level
            end
         end
         parsed= parsed .. handleSurr(res.type, lE.parse(escape(res.text)), res.level)
         html = html .. parsed
         i=i+1
      end
      html = html .. closing[mode+1]
      table.insert(htmls, html)
      file:close()
      return htmls
   else
      print("Could not open the file")
      return "<p>not found</p>"
   end
end

-- 3. DEBUGGING
function printTable(t, i)
   print("--------------------")
   print("Element number : ", i)
   print("Type : ", hE.types[t.type+1])
   print("Level : ", t.level)
   print("Text : ", t.text)
   print("--------------------")
end

style=[[
<style>
body, main, h1, h2, h3, h4, h5, h6, h7, h8, h9, p, span, div, ul, li{
   padding:0;
   margin:0;
   font-family: sans-serif;
}
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
]] .. s[1]..[[</main></body>]]..style..[[</html>]]
end

-- 4. TESTING
testing.test(hE.parse)
page = htmlify(printFile('text.org'))

function OnHttpRequest()
  path = GetPath()
  if path == '/favicon.ico' or
  path == '/site.webmanifest' or
  path == '/favicon-16x16.png' or
  path == '/favicon-32x32.png' or
  path == '/apple-touch-icon' then
    SetLogLevel(kLogWarn)
  end
  Write(page)
  SetHeader('Content-Language', 'en-US')
end

-- important :
-- Emphasis and Monospace: *bold*, /italic/, _underline_, =verbatim=, ~code~
-- Links: [[link][description]] or
-- Images: [[link]]
-- not urgent :
-- Footnotes: [fn:label] for definition, fn:label for reference
-- Timestamps: <YYYY-MM-DD Day> for dates, <YYYY-MM-DD Day HH:MM> for date and time
-- Tags: :tag1:tag2: at the end of headlines
-- Properties: :PROPERTIES: block within a headline
-- LaTeX fragments: \(formula\) or \[formula\] for inline and block, respectively
-- Macros: {{{macro(args)}}} 

