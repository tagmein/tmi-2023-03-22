set respondWithJson [
 function data [
  set [ get response ] statusCode 200
  do [
   get response
   do [ at setHeader, call Content-Type application/json ]
   do [
    at end, call [
     get JSON stringify, call [ get data ]
    ]
   ]
  ]
 ]
]

set createNode [
 function searchPath nodeName [
  promise [
   function resolve reject [
    set newDirPath [
     get path join,
     call [ get searchPath ] [ get nodeName ]
    ]
    set mkdirCallback [
     function err [
      get err, true [
       get resolve, call false
      ]
      false [
       get resolve, call true
      ]
     ]
    ]
    get fileSystem mkdir
    call [ get newDirPath ] [ get mkdirCallback ]
   ]
  ]
 ]
]

set channelKey [
 get requestParams path split, call /
 at [ current ] 0
]

set channelGroup [
 set output [ list ]
 get requestParams path split, call /
 at [ current ] 0
 is tagmein, true [
  set [ get output ] 0 system
 ]
 false [
  set [ get output ] 0 data
 ]
 get output 0
]

set searchPath [
 get path join
 call [ get publicBase ] [ get channelGroup ] [ get requestParams path ]
]

set currentSession [
 get session fromApiKey, call [
  get request headers x-tmi-api-key
 ]
]

get currentSession, true [
 get channelGroup
 do [
  is system, true [
   get currentSession email, is hello@nateferrero.com, true [
    get respondWithJson, call [
     object [
      success [
       get createNode
       call [ get searchPath ] [ get requestBody name ]
      ]
     ]
    ]
   ], false [
    get respondWithJson, call [
     object [
      success false
     ]
    ]
   ]
  ]
 ]
 do [
  is data, true [
   set channelData [
    get channelTools byKey, call [ get channelKey ]
   ]
   get channelData, true [
    get channelData owner, is [ get currentSession email ], true [
     get respondWithJson, call [
      object [
       success [
        get createNode
        call [ get searchPath ] [ get requestBody name ]
       ]
      ]
     ]
    ], false [
     get respondWithJson, call [
      object [
       success false
      ]
     ]
    ]
   ], false [
    get respondWithJson, call [
     object [
      success false
     ]
    ]
   ]
  ]
 ]
], false [
 get respondWithJson, call [
  object [
   success false
  ]
 ]
]
