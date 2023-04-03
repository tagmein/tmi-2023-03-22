set messageId [ object [ current 0 ] ]
set messageResolversById [ object ]
set messageRejectersById [ object ]

function tmiClientSource tmiClientTarget [
 at [ get tmiClientSource ] addEventListener, call message [
  function message [
   log got response [ get message data ]
   at [ get messageResolversById ] [ get message data messageId ], call [
    get message data response
   ]
   log resolvers [ get messageResolversById ]
   unset [ get messageResolversById ] [ get message data messageId ]
  ]
 ]
 function operation data [
  promise [
   function resolve reject [
    set [ get messageId ] current [ add 1 [ get messageId current ]]
    set [ get messageResolversById ] [ get messageId current ] [ get resolve ]
    set [ get messageRejectersById ] [ get messageId current ] [ get reject ]
    at [ get tmiClientTarget ] postMessage, call [
     object [
      data      [ get data ]
      operation [ get operation ]
      messageId [ get messageId current ]
     ]
    ]
   ]
  ]
 ]
]
