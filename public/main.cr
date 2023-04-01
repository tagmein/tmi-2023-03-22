set document [ at document ]
set encode   [ at encodeURIComponent ]
set fetch    [ at fetch ]
set listen   [ at addEventListener ]
set location [ at location ]

set styleUnique [ object ]
set style [ load ./lib/style.cr ]

at [ load ./lib/global-style.cr ], point

set build [
 function parent child [
  at [ get parent ] appendChild
  call [ get child ]
 ]
]

set element [
 function tagName [
  at [ get document ] createElement, call [
   get tagName, default div
  ]
 ]
]

at [ load ./lib/toolbar.cr ], point
at [ load ./lib/surface.cr ], point

set route [
 function [
  set hash [
   get location hash,
   at substring, call 1
  ]
  set response [
   at [ get fetch ], call [
    template %0?path=%1 /content [
     at [ get encode ], call [ get hash ]
    ]
   ]
  ]
  set responseText [
   at [ get response ] text, call
  ]
  log [ get responseText ]
 ]
]

at [ get listen ], call hashchange [ get route ]
at [ get route ], call