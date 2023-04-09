set respondWithJson [
 function data [
  set [ get response ] statusCode 200
  do [
   at [ get response ]
   do [ at setHeader, call Content-Type application/json ]
   do [
    at end, call [
     get JSON stringify, call [ get data ]
    ]
   ]
  ]
 ]
]

set currentSession [
 get session fromApiKey, call [
  get request headers x-tmi-api-key
 ]
]

get currentSession, true [
 set sessionList [
  get session list, call [ get currentSession email ] [
   get currentSession key
  ]
 ]
 get respondWithJson, call [ get sessionList ]
], false [ get respondWithJson, call null ]
