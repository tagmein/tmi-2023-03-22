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
    log saving to [ get mainFilePath ]
    get fileSystem writeFile
    call [ get mainFilePath ] [ get value ] utf8 [ get writeFileCallback ]
   ]
  ]
 ]
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
 at [ get output ] 0
]

set searchPath [
 get path join
 call [ get publicBase ] [ get channelGroup ] [ get requestParams path ]
]

set responseString [
 get JSON stringify, call [
  object [
   success [
    get writeValue
    call [ get searchPath ] [ get requestBody value ]
   ]
  ]
 ]
]

set [ get response ] statusCode 200
get response
do [ at setHeader, call Content-Type application/json ]
do [ at end, call [ get responseString ] ]
