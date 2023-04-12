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

set currentSession [
 get session fromApiKey, call [
  get request headers x-tmi-api-key
 ]
]
get currentSession, true [
 set accountData [
  get privateData, call [ 
   template account:%0 [ get currentSession email ]
  ]
 ]
 get respondWithJson, call [
  get accountData read, call
 ]
], false [ get respondWithJson, call null ]
