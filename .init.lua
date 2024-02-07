-- special script called by main redbean process at startup
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
         printTable(runL(line), i)
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
