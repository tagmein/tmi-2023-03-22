set alert        [ at alert ]
set clearTimeout [ at clearTimeout ]
set document     [ at document ]
set encode       [ at encodeURIComponent ]
set fetch        [ at fetch ]
set JSON         [ at JSON ]
set listen       [ at addEventListener ]
set location     [ at location ]
set setTimeout   [ at setTimeout ]

set debounce [ load ./lib/debounce.cr, point ]
set tmiMessageBus [ load ./lib/tmi-message-bus.cr, point ]
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

set getChannel [
 function [
  at [
   at [ get location ] hash substring, call 1
   at split, call /
  ] 0
 ]
]

set getPathSegments [
 function [
  at [
   at [ get location ] hash substring, call 1
   at split, call /
  ] slice, call 1
 ]
]

set switchChannel [
 function newChannel [
  set segments [
   at [ get location ] hash split, call /
  ]
  set [ get segments ] 0 [ get newChannel ]
  set [ get location ] hash [
   at [ get segments ] join, call /
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
  at [ get location ] hash length
  false [
   set [ get location ] hash tagmein
  ]
  true [
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
   set responseData [
    at [ get response ] json, call
   ]
   at [ get toolbar ] setChannels, call [
    get responseData channels
   ] [ at [ get getChannel ], call ]
   at [ get surface ] setNodes, call [
    get responseData nodes
   ]
   at [ get surface ] setValue, call [
    get responseData value
   ]
  ]
 ]
]

at [ get listen ], call hashchange [ get route ]
at [ get route ], call

at [ get listen ], call message [ get tmiMessageBus ]
