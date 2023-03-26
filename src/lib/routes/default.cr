set contentTypes [
 object [
  [css  text/css]
  [gif  image/gif]
  [html text/html]
  [jpeg image/jpeg]
  [jpg  image/jpeg]
  [js   application/javascript]
  [json application/json]
  [png  image/png]
  [svg  image/svg+xml]
  [txt  text/plain]
 ]
]

set fs [ get require, call fs ]
set path [ get require, call path ]

at [ get fs ] readFile, call [
 at [ get path ] join
 call [ get publicBase ] [ get requestUrl ]
] utf-8 [
 set extension [
  at [ get path ] extname, call [ get requestUrl ]
  at substring, call 1
 ]
 function error data [
  get error
  true [
   set [ get response ] statusCode 404
   at [ get response ] end, call 'Not found'
  ]
  false [
   set [ get response ] statusCode 200
   with at [ get response ] [
    [ setHeader, call Content-Type [
     at [ get contentTypes ] [ get extension ]
    ] ]
    [ end, call [ get data ] ]
   ]
  ]
 ]
]