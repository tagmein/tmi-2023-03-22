function url data [
 set apiKey [
  get localStorage getItem, call tmiApiKey
 ]
 set apiResponse [ object ]
 get data, true [
  set response [
   at [ get fetch ], call [
    template %0%1 /api [ get url ]
   ] [
    object [
     method POST
     headers [
      object [
       Content-Type application/json
       x-tmi-api-key [ get apiKey ]
      ]
     ]
     body [
      at [ get JSON ] stringify, call [ get data ]
     ]
    ]
   ]
  ]
  get response ok, true [
   set [ get apiResponse ] current [
    at [ get response ] json, call
   ]
  ], false [
   log API request failed [ get url ] [ get data ] [
    get response statusText
   ]
  ]
 ], false [
  set response [
   at [ get fetch ], call [
    template %0%1 /api [ get url ]
   ] [
    object [
     method GET
     headers [
      object [
       x-tmi-api-key [ get apiKey ]
      ]
     ]
    ]
   ]
  ]
  get response ok, true [
   set [ get apiResponse ] current [
    at [ get response ] json, call
   ]
  ], false [
   log API request failed [ get url ] [ get data ] [
    get response statusText
   ]
  ]
 ]

 get url, is /account/sign-in, true [
  get apiResponse current key, true [
   get localStorage setItem, call tmiApiKey [
    get apiResponse current key
   ]
  ]
 ]

 get apiResponse current
]
