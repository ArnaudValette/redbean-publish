-- -- ;; So you can navigate;
-- (setq lua-imenu-generic-expression `(("Sections" "^--[[:space:]][0-9]+\\.[[:space:]][A-Z]+.*" 0)))
-- (setq imenu-generic-expression lua-imenu-generic-expression)
-- (imenu--make-index-alist)

-- special script called by main redbean process at startup
HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')

-- 1. TYPINGS
--  0 : paragraph
--  1 : heading
--  2 : list
--  3 : begin src
--  4 : begin verse
--  5 : begin quote
--  6 : begin export
--  7 : begin example
--  8 : begin comment
--  9 : begin center
--  10 : unknown = empty
--  11 : end template #+end_<whatever> (this is optimistic)
-- 12 : literal
types = {"paragraph", "heading", "list", "src", "verse", "quote", "export", "example", "comment", "center", "empty", "end", "literal" }
-- 2. CONDITIONS
hc = function (s) return string.sub(s,1,1)=='*' end -- Type reveal headings 
sc1 = function (s) return string.sub(s,1,1)==' ' end -- single whitespace
sc2 = function (s) return string.sub(s,1,2)=='  ' end -- double whitespaces (yes)
dashc = function (s) return string.sub(s,1,1)=='-' end -- single dash
sTemp = function (s) return string.sub(s,1,8)=='#+begin_' end -- #+begin_
eTemp = function (s) return string.sub(s,1,6)=='#+end_' end -- #+end
litc = function (s) return string.sub(s,1,1)==':' end -- : litterally

-- 3. DATA, Chivalrous data structure
Elem = function (s,l,t) return {text=s, level=l, type=t} end  -- {-} <- that's an helmet

-- 4. LIB
strip = function (s,n) return string.sub(s,2+(n or 0)) end -- it's getting hot in here 
sL = function (s) return string.len(s) end
sEqx = function (s,x) return string.sub(s, 1, sL(x) )==x end

-- 5. CONTROL
paragraph = function (s) return sc1(s) and paragraph(strip(s)) or litc(s) and Elem(strip(s), 0, 12) or Elem(s,0,0) end -- (sic)
heading = function (s,l) return hc(s) and heading(strip(s),l+1) or Elem(strip(s),l,1)  end
list = function (s,l) return Elem(s,l,2) end  
space = function (s,l) return sc2(s) and space(strip(s,1),l+1) or dashc(s) and list(strip(s,1),l) or paragraph(s) end

function sTemplate (s)
	arr = {"src", "verse", "quote", "export","example","comment","center"}
	for i = 1, #arr do
		if sEqx(s, arr[i]) then
			return Elem(string.sub(s, sL(arr[i])+2), 0 , i+2)
		end
	end
	return Elem('',0,10)
end

function eTemplate (s)
	return Elem(s,0,11) 
end

-- 6. PARSE
handleH = function (s) return hc(s) and heading(strip(s),1) end -- HEADINGS
handleT = function (s) return sTemp(s) and sTemplate(strip(s,7)) end -- BEGIN_
handleE = function (s) return eTemp(s) and eTemplate(strip(s,5)) end -- END_
parse = function (s) return handleH(s) or handleT(s) or handleE(s) or space(s,0) end

-- 7. MAIN
runL = function (s) return parse(s) end
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

-- 8. DEBUGGING
function printTable(t, i)
   print("--------------------")
   print("Element number : ", i)
   print("Type : ", types[t.type+1])
   print("Level : ", t.level)
   print("Text : ", t.text)
   print("--------------------")
end

-- 9. TESTING
local testing = require "testing"
testing.test(parse)
