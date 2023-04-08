function operation data [
 log tmi-operator do: [ get operation ] with data [ get data ]
 set response [ object ]
 get operation
 do [
  is account.get, true [
   set [ get response ] current [
    get tmiApi, call /account
   ]
  ]
 ]
 do [
  is account:sign-in, true [
   set [ get response ] current [
    get tmiApi, call /account/sign-in [ get data ]
   ]
  ]
 ]
 get response current
]
