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

set accountData [
 get privateData, call [ 
  template account:%0 [ get requestBody email toLowerCase, call ]
 ]
]

set existingAccount [
 get accountData read, call
]

set responseMessage [ object ]

get setTimeout, call [
 function [
  get responseMessage message, true [
   get respondWithJson, call [ get responseMessage ]
  ]
 ]
] 1500

log existing account data [ get existingAccount ]

get existingAccount, true [
  get respondWithJson, call null
], false [
 get requestBody create, true [
  get respondWithJson, call null
 ], false [
  set [ get responseMessage ] message 'Account not found'
 ]
]
