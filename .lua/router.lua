local function urldecode(str)
   return string.gsub(str, "-", " ")
end

local function urlencode(str)
   if (str) then
      return string.gsub(str, "[^%a]", "-")
   end
end

local function route(pages, p)
   print(p)
   print(urlencode(p))
   return pages[p]
end


local function getroutes(p)
   local routes=""
   for key,_ in pairs(p) do
      routes=routes.. [[<a href="]] .. key .. [[">]] .. urldecode(key) .. [[</a>]]
   end
   return routes
end

local function nav(pages)
   routes=getroutes(pages)
   return [[<nav>]] .. routes .. [[</nav>]]
end


return {
   route=route,
   urlencode=urlencode,
   nav=nav
}
