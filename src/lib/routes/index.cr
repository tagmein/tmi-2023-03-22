set html 'text/html; charset=utf-8'

set fs [ get require, call fs ]
set path [ get require, call path ]

get fileSystem readFile, call [
 get path join
 call [ get publicBase ] index.html
] utf-8 [
 function error data [
  set [ get response ] statusCode 200
  do [
   get response
   do [ at setHeader, call Content-Type [ get html ] ]
   do [ at end, call [ get data ] ]
  ]
 ]
]
