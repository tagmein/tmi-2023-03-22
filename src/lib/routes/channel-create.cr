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
 get requestBody name length, >= 2, true [
  get respondWithJson, call [
   get channelTools create, call [ get currentSession email ] [
    get requestBody name
   ]
  ]
 ], false [
  get respondWithJson, call [
   object [
    message 'Channel name must be at least 2 characters in length'
   ]
  ]
 ]
], false [ get respondWithJson, call null ]
