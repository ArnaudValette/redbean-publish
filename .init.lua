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

--   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
-- ;;
-- ;; Control room
-- ;;
-- ;;   - begins with * : heading,
-- ;;   - begins with #+begin_ : you know what is is
-- ;;   - begins with #+end_ : same
-- ;;   - begins with <two spaces> : list | paragraph
-- ;;   - first non space is dash : list
-- ;;   - anything else : paragraph
-- ;;
--;;
--
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
         printTable(processLine(line), i)
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
-- any of these should be true

print("test 1:")
test1 = parse('* Heading')
print(test1.type==1)
print(test1.text=="Heading")
print(test1.level==1)

print("test 2:")
test2 = parse('** Heading')
print(test2.type==1)
print(test2.text=="Heading")
print(test2.level==2)

print("test 3:")
test3 = parse(' ** paragraph bad shape')
print(test3.type==0)
print(test3.text=="** paragraph bad shape")
print(test3.level==0)

print("test 4:")
test4 = parse(' - malformatted list')
print(test4.type==0)
print(test4.text=="- malformatted list")
print(test4.level==0)

print("test 5:")
test5 = parse('  - list')
print(test5.type==2)
print(test5.text=="list")
print(test5.level==1)

print("test 6:")
test6 = parse('- list')
print(test6.type==2)
print(test6.text=="list")
print(test6.level==0)

print("test 7:")
test7 = parse('paragraph')
print(test7.type==0)
print(test7.text=="paragraph")
print(test7.level==0)

print("test 8:")
test8 = parse('#+begin_src js')
print(test8.type==3)
print(test8.text=="js")
print(test8.level==0)

print("test 9:")
test9 = parse('#+begin_verse')
print(test9.type==4)
print(test9.text=="")
print(test9.level==0)

print("test 10:")
test10 = parse('#+begin_example')
print(test10.type==7)
print(test10.text=="")
print(test10.level==0)

print("test 11:")
test11 = parse('#+begin_quote')
print(test11.type==5)
print(test11.text=="")
print(test11.level==0)

print("test 12:")
test12 = parse('#+begin_')
print(test12.type==10)
print(test12.text=="")
print(test12.level==0)

print("test 13:")
test13 = parse('#+end_src')
print(test13.type==11)
print(test13.text=="src")
print(test13.level==0)
