set MAX_REQUEST_BODY_SIZE 524288 # 512kb
set ENCODING_JSON application/json

function request [
 promise [
  function resolve reject [
   set error false
   set contentTypeHeader [
    get request headers content-type
    default ''
   ]
   set contentType [
    at [
     get contentTypeHeader split, call ;
    ] 0
   ]
   get contentType, is [ get ENCODING_JSON ], true [
    set bodyChunks [ list ]
    set bodySize 0
    get request on, call data [
     function chunk [
      get error, false [
       get bodyChunks push, call [ get chunk ]
       set bodySize [
        add [ get bodySize ] [ get chunk length ]
       ]
       get bodySize, > [ get MAX_REQUEST_BODY_SIZE ], true [
        set error true
        get reject, call
        object [
         message template 'request body size cannot exceed %0 bytes' [
          get MAX_REQUEST_BODY_SIZE
         ]
        ]
       ]
      ]
     ]
    ]
    get request on, call end [
     function [
      get error, false [
       get resolve, call [
        get JSON parse, call [
         get Buffer concat, call [ get bodyChunks ]
        ]
       ]
      ]
     ]
    ]
   ]
   false [
    get resolve, call [ object ]
   ]
  ]
 ]
]
