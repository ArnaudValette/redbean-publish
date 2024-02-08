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

local hE = require "higherelements"
local lE = require "lesserelements"
local testing = require "testing"
local const = require "constants"
local escape = require "html".escape
local htmlify = require "html".htmlify


-- 1. LIB
strip = function (s,n) return string.sub(s,2+(n or 0)) end -- it's getting hot in here 
sL = function (s) return string.len(s) end
sEqx = function (s,x) return string.sub(s, 1, sL(x) )==x end


-- 2. MAIN
function handleSurr(t,txt,l)
   rest=""
   if t==1 then rest = "" .. l end
   return "<".. const.sB[t+1].. rest..">" .. txt .. "</".. const.sE[t+1].. rest..">"
end

runL = function (s) return hE.parse(s) end

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
         if res.type == 1 and sL(html)>0 and res.level == 1 then
            table.insert(htmls, html .. const.cT[mode > -1 and mode + 1 or 2])
            metaHtmls = metaHtmls + 1
            html = const.oT[res.type+1] 
            level=0
            mode=1
         elseif (not (mode == res.type)) then
            -- we change modes
            parsed = const.cT[mode > - 1 and mode + 1 or 2] .. const.oT[res.type+1]
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
      html = html .. const.cT[mode+1]
      table.insert(htmls, html)
      file:close()
      return htmls
   else
      print("Could not open the file")
      return "<p>not found</p>"
   end
end

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

--testing.test(hE.parse)
