set byId [
 function id currentSessionKey [
  get privateData, call [ 
   template session:%0 [ get id ]
  ]
  set value [ at read, call ]
  get value, true [
   set [ get value ] current [
    get value key, is [ get currentSessionKey ]
   ]
  ]
  get value
 ]
]

set deleteById [
 function id [
  get privateData, call [ 
   template session:%0 [ get id ]
  ]
  at delete, call
 ]
]

object [
 byId [ get byId ]
 create [
  function email userAgent [
   set sessionListData [
    get privateData, call [ 
     template account.session-list:%0 [ get email ]
    ]
   ]
   set newSessionKey [ get randomKey, call ]
   set sessionData [
    get privateData, call [ 
     template session:%0 [ get newSessionKey ]
    ]
   ]
   set sessionObject [
    object [
     agent [ get userAgent ]
     created [ get Date now, call ]
     key [ get newSessionKey ]
     email [ get email ]
    ]
   ]
   get sessionData write, call [ get sessionObject ]
   set existingSessionList [
    get sessionListData read, call
   ]
   get existingSessionList, true [
    get sessionListData write, call [
     get existingSessionList concat, call [
      list [
       [ get newSessionKey ]
      ]
     ]
    ]
   ], false [
    get sessionListData write, call [
     list [
      [ get newSessionKey ]
     ]
    ]
   ]
   get sessionObject
  ]
 ]
 delete [
  function email sessionKeyToDelete [
   set sessionListData [
    get privateData, call [ 
     template account.session-list:%0 [ get email ]
    ]
   ]
   set currentList [
    get sessionListData read, call
   ]
   set responseObject [ object ]
   get currentList includes
   call [ get sessionKeyToDelete ], true [
    get deleteById, call [ get sessionKeyToDelete ]
    get sessionListData write, call [
     get currentList, filter [
      function item [
       get item, is [ get sessionKeyToDelete ], not
      ]
     ]
    ]
    set [ get responseObject ] current true
   ], false [
    set [ get responseObject ] current false
   ]
   get responseObject current
  ]
 ]
 list [
  function email currentSessionKey [
   set responseList [ object ]
   set sessionListData [
    get privateData, call [ 
     template account.session-list:%0 [ get email ]
    ]
   ]
   set currentList [
    get sessionListData read, call
   ]
   get currentList, true [
    set [ get responseList ] current [
     get currentList, map [
      function id [
        get byId, call [ get id ] [ get currentSessionKey ]
      ]
     ]
    ]
   ], false [
    set [ get responseList ] current [
     list []
    ]
   ]
   get responseList current
  ]
 ]
 fromApiKey [
  function apiKey [
   get privateData, call [ 
    template session:%0 [ get apiKey ]
   ]
   at read, call
  ]
 ]
]
