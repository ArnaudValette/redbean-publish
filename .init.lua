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
local route= require "router".route
local urlencode = require "router".urlencode
local nav = require "router".nav


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

function state()
   return {m=-1,l=0,xml="",acc={}, link=""}
end

notFirstH = function (e, st) return e.type==1 and sL(st.xml)>0 and e.level==1 end
closingTag= function (st) return st.m >= 0 and const.cT[st.m+1] or "" end
push = function (st)
   st.acc[st.link] = (st.xml .. closingTag(st))
end
newEntry = function (st, r) return {link="",m=1, l=0, xml=const.oT[r.type+1],acc=st.acc} end
diff = function (a,b) return (not (a == b)) end

function printFile(path)
   file=io.open(path, "r")
   st = state()
      --{m=-1,l=0,xml="",acc={}}
   if file then
      for line in file:lines() do
         parsed=''
         res= runL(line)
         print(res.text)
         if notFirstH(res, st) then -- if new heading => new entry
            push(st)
            st = newEntry(st, res) 
         elseif diff(st.m, res.type) then -- if new node type => commit previous node
            parsed = closingTag(st) .. const.oT[res.type+1] -- close prev tag, open next one
            st.m = res.type  
         end
         if res.type == 2 then -- if node = list
            if res.level > st.l then -- if list level > prev List level 
               parsed=parsed.."<ul>"
               st.l = res.level
            elseif res.level < st.l then -- if list level < prev list level
               parsed= parsed.."</ul>"
               st.l = res.level
            end
         end
         if res.type == 1 and res.level == 1 then st.link=urlencode(res.text) end
         parsed= parsed .. handleSurr(res.type, lE.parse(escape(res.text)), res.level)
         st.xml= st.xml .. parsed
      end
      st.xml = st.xml .. closingTag(st) 
      --table.insert(st.acc, st.xml)
      push(st)
      file:close()
      return st.acc 
   else
      print("Could not open the file")
      return "<p>not found</p>"
   end
end

pages = printFile('text.org')
navigation = nav(pages)

function OnHttpRequest()
  path = GetPath()
  if path == '/favicon.ico' or
  path == '/site.webmanifest' or
  path == '/favicon-16x16.png' or
  path == '/favicon-32x32.png' or
  path == '/apple-touch-icon' then
    SetLogLevel(kLogWarn)
  end
  if path == '/' then
     Write(navigation)
  else
     p = strip("" .. path)
     Write(route(pages,p))
  end
  SetHeader('Content-Language', 'en-US')
end

--testing.test(hE.parse)
