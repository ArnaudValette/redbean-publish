local sB={ -- surround-begin
   "span",
   "h",
   "li",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
}

local sE={ -- surround-end
   "span",
   "h",
   "li",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
   "span",
}

local oT={ -- opening tags
   "<p>",
   "",
   "<ul>",
   "<pre>",
   "<div class='verse'>",
   "<div class='quote'>",
   "<div class='export'>",
   "<div class='example'>",
   "<div class='comment'>",
   "<div class='center'>",
   "<div class='empty'>",
   "<div class='empty'>",
   "<div class='literal'>",
}

local cT={ -- closing tags
   "</p>",
   "",
   "</ul>",
   "</pre>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
   "</div>",
}

return {
   cT=cT,
   oT=oT,
   sB=sB,
   sE=sE
}
