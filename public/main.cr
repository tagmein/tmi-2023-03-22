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
  get child, false [
   log Missing child when appending to [ get parent ]
  ], true [
   get parent appendChild
   call [ get child ]
  ]
 ]
]

set element [
 function tagName [
  get document createElement, call [
   get tagName, default div
  ]
 ]
]

set getChannelKey [
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
 function newChannel maintainPath [
  get maintainPath, true [
   set segments [
    get location hash split, call /
   ]
   set [ get segments ] 0 [ get newChannel ]
   set [ get location ] hash [
    get segments join, call /
   ]
  ], false [
   set [ get location ] hash [ get newChannel ]
  ]
 ]
]

set isViewOnly [
 get location pathname startsWith, call /view
]

set toolbar [ object ]

get isViewOnly, false [
 set [ get toolbar ] current [
  at [ load ./lib/toolbar.cr ], point
 ]
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
   set currentChannelKey [
    get getChannelKey, call
   ]
   set currentChannel [
    get responseData channels find, call [
     function candidateChannel [
      get candidateChannel key, is [
       get currentChannelKey
      ]
     ]
    ]
   ]
   get toolbar current, true [
    get toolbar current setChannels, call [
     get responseData channels
    ] [ get currentChannelKey ]
    get toolbar current refreshAccountLink, call
   ]
   get isViewOnly, false [
    get surface setNodes, call [
     get responseData nodes
    ] [
     get responseData permissions
    ] [
     get currentChannel
    ]
   ]
   get surface setValue, call [
    get responseData value
   ] [
    get responseData permissions
   ]
  ]
 ]
]

get listen, call hashchange [ get route ]
get listen, call message [ get tmiMessageBus ]
get route, call
