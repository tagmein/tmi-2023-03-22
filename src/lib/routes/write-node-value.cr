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

set writeValue [
 function searchPath value [
  promise [
   function resolve reject [
    set mainFilePath [
     get path join,
     call [ get searchPath ] main.value
    ]
    set writeFileCallback [
     function err [
      get err, true [
       get resolve, call false
      ]
      false [
       get resolve, call true
      ]
     ]
    ]
    # log saving to [ get mainFilePath ]
    get fileSystem writeFile
    call [ get mainFilePath ] [ get value ] utf8 [ get writeFileCallback ]
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
 get channelKey
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
       get writeValue
       call [ get searchPath ] [ get requestBody value ]
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
        get writeValue
        call [ get searchPath ] [ get requestBody value ]
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
