set alert        [ at alert ]
set body         [ at document body ]
set clearTimeout [ at clearTimeout ]
set decode       [ at decodeURIComponent ]
set document     [ at document ]
set encode       [ at encodeURIComponent ]
set fetch        [ at fetch ]
set JSON         [ at JSON ]
set listen       [ at addEventListener ]
set localStorage [ at localStorage ]
set location     [ at location ]
set setTimeout   [ at setTimeout ]

set tmiApi [ load ./lib/tmi-api.cr, point ]
set tmiMessageBus [ load ./lib/tmi-message-bus.cr, point ]
set tmiOperator [ load ./lib/tmi-operator.cr, point ]

set styleUnique [ object ]
set style [ load ./lib/style.cr ]

at [ load ./lib/global-style.cr ], point

set debounce [ load ./lib/debounce.cr, point ]

set build [
 function parent child [
  get parent appendChild
  call [ get child ]
 ]
]

set element [
 function tagName [
  get document createElement, call [
   get tagName, default div
  ]
 ]
]

set getChannel [
 function [
  at [
   get location hash substring, call 1
   at split, call /
  ] 0
 ]
]

set getPathSegments [
 function [
  at [
   get location hash substring, call 1
   at split, call /
  ] slice, call 1
 ]
]

set switchChannel [
 function newChannel [
  set segments [
   get location hash split, call /
  ]
  set [ get segments ] 0 [ get newChannel ]
  set [ get location ] hash [
   get segments join, call /
  ]
 ]
]

set toolbar [
 at [ load ./lib/toolbar.cr ], point
]

set surface [
 at [ load ./lib/surface.cr ], point
]

set route [
 function [
  get location hash length
  false [
   set [ get location ] hash tagmein
  ]
  true [
   set hash [
    get location hash,
    at substring, call 1
   ]
   set responseData [
    get tmiApi, call [
     template %0?path=%1 /content [
      get hash
     ]
    ]
   ]
   get toolbar setChannels, call [
    get responseData channels
   ] [ get getChannel, call ]
   get surface setNodes, call [
    get responseData nodes
   ]
   get surface setValue, call [
    get responseData value
   ]
   get toolbar refreshAccountLink, call
  ]
 ]
]

get listen, call hashchange [ get route ]
get listen, call message [ get tmiMessageBus ]
get route, call
