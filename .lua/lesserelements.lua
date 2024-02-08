local img = function (src) return "<img src='" .. src .. "' alt=''/>" end
local anchor=function(href,text) return " <a href='" .. href .. "'>" .. text .. "</a>" end
local bold=function(s) return " <span class='bold'>"..s.."</span>" end
local italic=function(s) return " <span class='italic'>"..s.."</span>" end
local underline=function(s) return " <span class='underline'>"..s.."</span>" end
local verbatim=function(s) return " <span class='verbatim'>"..s.."</span>" end
local code=function(s) return " <span class='code'>"..s.."</span>" end

local function handleA(prev, all, index)
   local t = all:sub(index+2)
   local mem = ""
   for i = 1, #t do
      local s = t:sub(i)
      local char = t:sub(i,i)
      if sEqx(s, "]") then
         -- "deal."
         return anchor(prev,mem) .. parse(strip(s,1))
      else
         mem = mem .. char
      end
   end
   return "<span>[[" .. prev .. "][" .. mem .. "</span>"
end


local function handleL(t)
   local mem = ""
   for i = 1, #t do
      local char = t:sub(i,i)
      local s = t:sub(i)
      if sEqx(s,"]]") then
         -- image
         return img(mem) .. parse(strip(s,1))
      elseif sEqx(s, "][") then
         -- anchor
         return handleA(mem, t, i)
      elseif sEqx(s, " ") then
         -- broken link = text
         return "<span>[[" .. mem .. char .. "</span>" .. parse(s)
      else
         -- add to mem
         mem = mem .. char
      end
   end
   return "<span>[[" .. mem .. "</span>"
end 

local punct = function (c) return c == "," or c == "." or c == ";" or c==":" end
local function handleMeta(t, sign, f)
   local mem = ""
   for i=1, #t do
      local char = t:sub(i,i)
      local s = t:sub(i)
      if sEqx(s, sign .. " ") then
         return f(mem) .. parse(strip(s))
      elseif sEqx(s, sign) and sL(s) == 1 then
         return f(mem) 
      elseif sEqx(s, sign) and punct(s:sub(i+1,i+1)) then
         return f(mem) .. parse(strip(s))
      else
         mem = mem .. char
      end
   end
   return "<span> " .. sign .. mem .. "</span>"
end

local handleB = function (s) return handleMeta(s, "*", bold) end
local handleI = function (s) return handleMeta(s, "/", italic) end
local handleU = function (s) return handleMeta(s, "_", underline) end
local handleV = function (s) return handleMeta(s, "~", verbatim) end
local handleC = function (s) return handleMeta(s, "=", code) end

local cMeta= function(s,v,f) return sEqx(s,v) and f(strip(s,1)) end
local cL=function(s) return cMeta(s,"[[",handleL) end
local cB=function(s) return cMeta(s," *",handleB) end
local cI=function(s) return cMeta(s," /",handleI) end
local cU=function(s) return cMeta(s," _",handleU) end
local cV=function(s) return cMeta(s," ~",handleV) end
local cC=function(s) return cMeta(s," =",handleC) end

local function handleP(s)
   rest = sL(s)>0 and parse(s:sub(2)) or ""
   return s:sub(1,1) .. rest 
end

parse=function(t) return cL(t) or cB(t) or cI(t) or cU(t) or cV(t) or cC(t) or handleP(t) end

return{
   parse=parse
}
