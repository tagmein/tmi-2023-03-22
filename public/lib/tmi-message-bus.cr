function message [
 # log incoming message [ get message data ]
 set address [
  get message target location hash substring
  call 1
 ]
 get tmiPermissionGate, call [ get address ] [
  get message data operation
 ]
 true [
  get message source postMessage, call [
   object [
    messageId [ get message data messageId ]
    response [
     get tmiOperator, call [
      get message data operation
     ] [
      get message data data
     ]
    ]
   ]
  ]
 ]
 false [
  log DENIED [ get address ] [ get message data operation ]
 ]
]
