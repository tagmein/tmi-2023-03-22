function operation data [
 log tmi-operator do: [ get operation ] with data [ get data ]
 set response [ object ]
 get operation
 do [
  is account:get, true [
   set [ get response ] current [
    get tmiApi, call /account
   ]
  ]
 ]
 do [
  is session:delete, true [
   set [ get response ] current [
    get tmiApi, call /sessions/delete [ get data ]
   ]
  ]
 ]
 do [
  is session:list, true [
   set [ get response ] current [
    get tmiApi, call /sessions
   ]
  ]
 ]
 do [
  is channel:create, true [
   set [ get response ] current [
    get tmiApi, call /channels/create [ get data ]
   ]
  ]
 ]
 do [
  is channel:forget, true [
   set [ get response ] current [
    get tmiApi, call /channels/forget [ get data ]
   ]
  ]
 ]
 do [
  is channel:list, true [
   set [ get response ] current [
    get tmiApi, call /channels
   ]
  ]
 ]
 do [
  is account:sign-in, true [
   set [ get response ] current [
    get tmiApi, call /account/sign-in [ get data ]
   ]
   get response current key, true [
    get route, call
   ]
  ]
 ]
 do [
  is account:sign-out, true [
   set key [
    get localStorage getItem
    call tmiApiKey
   ]
   get tmiApi, call /sessions/delete [
    object [
     key [ get key ]
    ]
   ]
   get localStorage removeItem, call tmiApiKey
   get route, call
  ]
 ]
 get response current
]
