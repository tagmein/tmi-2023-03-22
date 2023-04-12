set contentTypes [
 object [
  cr   text/plain
  css  text/css
  gif  image/gif
  html text/html
  jpeg image/jpeg
  jpg  image/jpeg
  js   application/javascript
  json application/json
  png  image/png
  svg  image/svg+xml
  txt  text/plain
 ]
]

set fs [ get require, call fs ]
set path [ get require, call path ]

get fileSystem readFile, call [
 get path join
 call [ get publicBase ] [ get requestUrl ]
] utf-8 [
 set extension [
  get path extname, call [ get requestUrl ]
  at substring, call 1
 ]
 function error data [
  get error
  true [
   set [ get response ] statusCode 404
   get response end, call 'Not found'
  ]
  false [
   set [ get response ] statusCode 200
   set contentType [
    at [ get contentTypes ] [ get extension ]
    default [ get contentTypes txt ]
   ]

   do [
     get response
     do [ at setHeader, call Content-Type [ get contentType ] ]
     do [ get response end, call [ get data ] ]
   ]
  ]
 ]
]
