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

set responseMessage [ object ]

get setTimeout, call [
 function [
  get responseMessage message, true [
   get respondWithJson, call [ get responseMessage ]
  ]
 ]
] 1500

set invalidSignIn [
 function [
  set [ get responseMessage ] message 'Email and password did not match an existing account'
 ]
]

set email [ get requestBody email toLowerCase, call ]

get requestBody password length, >= 8, true [
 set accountData [
  get privateData, call [ 
   template account:%0 [ get email ]
  ]
 ]

 set existingAccount [
  get accountData read, call
 ]

 set agent [
  get request headers user-agent
 ]

 get existingAccount, true [
  get existingAccount password
  is [ get requestBody password ], true [
   get respondWithJson, call [
    get session create, call [ get email ] [ get agent ]
   ]
  ], false [ get invalidSignIn, call ]
 ], false [
  get requestBody create, true [
   get accountData write, call [
    object [
     created [ get Date now, call ]
     email [ get email ]
     password [ get requestBody password ]
    ]
   ]
   get respondWithJson, call [
    get session create, call [ get email ] [ get agent ]
   ]
  ], false [ get invalidSignIn, call ]
 ]
], false [
 set [ get responseMessage ] message 'Password must be at least 8 characters in length'
]
