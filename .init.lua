-- special script called by main redbean process at startup
function Slurp(path)
  local file, err = io.open(path, "r")
  if not file then return nil, err end
  local content = file:read("*a") -- Read the entire file content
  file:close()
  return content
end

ProgramPrivateKey(Slurp('/etc/letsencrypt/live/redbean-ecdsa/privkey.pem'))
ProgramCertificate(Slurp('/etc/letsencrypt/live/redbean-ecdsa/fullchain.pem'))
ProgramPrivateKey(Slurp('/etc/letsencrypt/live/redbean-rsa/privkey.pem'))
ProgramCertificate(Slurp('/etc/letsencrypt/live/redbean-rsa/fullchain.pem'))

if IsDaemon() then 
  ProgramUid(1000)
  ProgramGid(1001)
  ProgramPort(80)
  ProgramPort(443)
  ProgramLogPath('/var/log/redbean.log')
  ProgramPidPath('/var/run/redbean.pid')
end

function OnHttpRequest()
  Write('<p>Hello, World</p>')
  -- path = GetPath()
  -- if path == '/favicon.ico' or
  -- path == '/site.webmanifest' or
  -- path == '/favicon-16x16.png' or
  -- path == '/favicon-32x32.png' or
  -- path == '/apple-touch-icon' then
    -- SetLogLevel(kLogWarn)
  -- end
  -- Route()
  -- SetHeader('Content-Language', 'en-US')
end

HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')
-- -- ;; So you can navigate;
-- (setq lua-imenu-generic-expression `(("Sections" "^--[[:space:]][0-9]+\\.[[:space:]][A-Z]+.*" 0)))
-- (setq imenu-generic-expression lua-imenu-generic-expression)
-- (imenu--make-index-alist)
local hE = require "higherelements"
local testing = require "testing"



-- 1. LIB
strip = function (s,n) return string.sub(s,2+(n or 0)) end -- it's getting hot in here 
sL = function (s) return string.len(s) end
sEqx = function (s,x) return string.sub(s, 1, sL(x) )==x end


-- 2. MAIN

runL = function (s) return hE.parse(s) end
function printFile(path)
   file=io.open(path, "r")
   i=0
   if file then
      for line in file:lines() do
         res= runL(line)
         text = "<p>" .. ple(res.text) .. "</p>"
         print(text)
         i=i+1
      end
      file:close()
   else
      print("Could not open the file")
   end
end

img = function (src) return "<img src='" .. src .. "' alt=''/>" end
anchor=function(href,text) return " <a href='" .. href .. "'>" .. text .. "</a>" end
bold=function(s) return " <span class='bold'>"..s.."</span>" end
italic=function(s) return " <span class='italic'>"..s.."</span>" end
underline=function(s) return " <span class='underline'>"..s.."</span>" end
verbatim=function(s) return " <span class='verbatim'>"..s.."</span>" end
code=function(s) return " <span class='code'>"..s.."</span>" end

function handleA(prev, all, index)
   local t = all:sub(index+2)
   local mem = ""
   for i = 1, #t do
      local s = t:sub(i)
      local char = t:sub(i,i)
      if sEqx(s, "]") then
         -- "deal."
         return anchor(prev,mem) .. ple(strip(s,1))
      else
         mem = mem .. char
      end
   end
   return "<span>[[" .. prev .. "][" .. mem .. "</span>"
end


function handleL(t)
   local mem = ""
   for i = 1, #t do
      local char = t:sub(i,i)
      local s = t:sub(i)
      if sEqx(s,"]]") then
         -- image
         return img(mem) .. ple(strip(s,1))
      elseif sEqx(s, "][") then
         -- anchor
         return handleA(mem, t, i)
      elseif sEqx(s, " ") then
         -- broken link = text
         return "<span>[[" .. mem .. char .. "</span>" .. ple(s)
      else
         -- add to mem
         mem = mem .. char
      end
   end
   return "<span>[[" .. mem .. "</span>"
end 

punct = function (c) return c == "," or c == "." or c == ";" or c==":" end
function handleMeta(t, sign, f)
   local mem = ""
   for i=1, #t do
      local char = t:sub(i,i)
      local s = t:sub(i)
      if sEqx(s, sign .. " ") then
         return f(mem) .. ple(strip(s))
      elseif sEqx(s, sign) and sL(s) == 1 then
         return f(mem) 
      elseif sEqx(s, sign) and punct(s:sub(i+1,i+1)) then
         return f(mem) .. ple(strip(s))
      else
         mem = mem .. char
      end
   end
   return "<span> " .. sign .. mem .. "</span>"
end

handleB = function (s) return handleMeta(s, "*", bold) end
handleI = function (s) return handleMeta(s, "/", italic) end
handleU = function (s) return handleMeta(s, "_", underline) end
handleV = function (s) return handleMeta(s, "~", verbatim) end
handleC = function (s) return handleMeta(s, "=", code) end

cMeta= function(s,v,f) return sEqx(s,v) and f(strip(s,1)) end
cL=function(s) return cMeta(s,"[[",handleL) end
cB=function(s) return cMeta(s," *",handleB) end
cI=function(s) return cMeta(s," /",handleI) end
cU=function(s) return cMeta(s," _",handleU) end
cV=function(s) return cMeta(s," ~",handleV) end
cC=function(s) return cMeta(s," =",handleC) end

function handleP(s)
   rest = sL(s)>0 and ple(s:sub(2)) or ""
   return s:sub(1,1) .. rest 
end

ple=function(t) return cL(t) or cB(t) or cI(t) or cU(t) or cV(t) or cC(t) or handleP(t) end

-- 3. DEBUGGING
function printTable(t, i)
   print("--------------------")
   print("Element number : ", i)
   print("Type : ", hE.types[t.type+1])
   print("Level : ", t.level)
   print("Text : ", t.text)
   print("--------------------")
end

-- 4. TESTING
testing.test(hE.parse)
printFile('text.org')


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
