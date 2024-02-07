-- higherelements.lua
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
local types = {"paragraph", "heading", "list", "src", "verse", "quote", "export", "example", "comment", "center", "empty", "end", "literal" }
-- 2. CONDITIONS
local hc = function (s) return string.sub(s,1,1)=='*' end -- Type reveal headings 
local sc1 = function (s) return string.sub(s,1,1)==' ' end -- single whitespace
local sc2 = function (s) return string.sub(s,1,2)=='  ' end -- double whitespaces (yes)
local dashc = function (s) return string.sub(s,1,1)=='-' end -- single dash
local sTemp = function (s) return string.sub(s,1,8)=='#+begin_' end -- #+begin_
local eTemp = function (s) return string.sub(s,1,6)=='#+end_' end -- #+end
local litc = function (s) return string.sub(s,1,1)==':' end -- : litterally

-- 3. DATA, Chivalrous data structure
local Elem = function (s,l,t) return {text=s, level=l, type=t} end  -- {-} <- that's an helmet

-- 4. CONTROL
local paragraph; paragraph = function (s) return sc1(s) and paragraph(strip(s)) or litc(s) and Elem(strip(s), 0, 12) or Elem(s,0,0) end -- (sic)
local heading; heading = function (s,l) return hc(s) and heading(strip(s),l+1) or Elem(strip(s),l,1)  end
local list; list = function (s,l) return Elem(s,l,2) end  
local space; space = function (s,l) return sc2(s) and space(strip(s,1),l+1) or dashc(s) and list(strip(s,1),l) or paragraph(s) end

local function sTemplate (s)
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

-- 5. PARSE
local handleH = function (s) return hc(s) and heading(strip(s),1) end -- HEADINGS
local handleT = function (s) return sTemp(s) and sTemplate(strip(s,7)) end -- BEGIN_
local handleE = function (s) return eTemp(s) and eTemplate(strip(s,5)) end -- END_
local parse = function (s) return handleH(s) or handleT(s) or handleE(s) or space(s,0) end

return {
   parse=parse,
   types=types
}
