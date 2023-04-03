set createNode [
 function searchPath nodeName [
  promise [
   function resolve reject [
    set newDirPath [
     at [ get path ] join,
     call [ get searchPath ] [ get nodeName ]
    ]
    set mkdirCallback [
     function err [
      get err, true [
       at [ get resolve ], call false
      ]
      false [
       at [ get resolve ], call true
      ]
     ]
    ]
    at [ get fileSystem ] mkdir
    call [ get newDirPath ] [ get mkdirCallback ]
   ]
  ]
 ]
]

set channelGroup [
 set output [ list ]
 at [ get requestParams path ] split, call /
 at [ current ] 0
 is tagmein, true [
  set [ get output ] 0 system
 ]
 false [
  set [ get output ] 0 data
 ]
 at [ get output ] 0
]

set searchPath [
 at [ get path ] join
 call [ get publicBase ] [ get channelGroup ] [ get requestParams path ]
]

set responseString [
 at [ get JSON ] stringify, call [
  object [
   success [
    at [ get createNode ]
    call [ get searchPath ] [ get requestBody name ]
   ]
  ]
 ]
]

set [ get response ] statusCode 200
at [ get response ]
do [ at setHeader, call Content-Type application/json ]
do [ at end, call [ get responseString ] ]
