function url data [
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

 get apiResponse current
]
