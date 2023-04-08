function message [
 # log incoming message [ get message data ]
 at [ get message source ] postMessage, call [
  object [
   messageId [ get message data messageId ]
   response [
    at [ get tmiOperator ], call [
     get message data operation
    ] [
     get message data data
    ]
   ]
  ]
 ]
]
