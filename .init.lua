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
local lE = require "lesserelements"
local testing = require "testing"


-- 1. LIB
strip = function (s,n) return string.sub(s,2+(n or 0)) end -- it's getting hot in here 
sL = function (s) return string.len(s) end
sEqx = function (s,x) return string.sub(s, 1, sL(x) )==x end


-- 2. MAIN

function handleSurr(t,txt)
   return "<p>" .. txt .. "</p>"
end

runL = function (s) return hE.parse(s) end
function printFile(path)
   file=io.open(path, "r")
   i=0
   if file then
      for line in file:lines() do
         res= runL(line)
         text = handleSurr(res.type, lE.parse(res.text))
         print(text)
         i=i+1
      end
      file:close()
   else
      print("Could not open the file")
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
