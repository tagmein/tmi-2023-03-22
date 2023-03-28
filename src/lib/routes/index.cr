set html 'text/html; charset=utf-8'

set fs [ get require, call fs ]
set path [ get require, call path ]

at [ get fs ] readFile, call [
 at [ get path ] join
 call [ get publicBase ] index.html
] utf-8 [
 function error data [
  set [ get response ] statusCode 200
  do [
   at [ get response ]
   do [ at setHeader, call Content-Type [ get html ] ]
   do [ at end, call [ get data ] ]
  ]
 ]
]
