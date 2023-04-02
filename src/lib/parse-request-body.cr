set MAX_REQUEST_BODY_SIZE 524288 # 512kb
set ENCODING_JSON application/json

function request [
 promise [
  function resolve reject [
   set error false
   set contentTypeHeader [
    at [ get request ] headers content-type
    default ''
   ]
   set contentType [
    at [
     at [ get contentTypeHeader ] split, call ;
    ] 0
   ]
   get contentType, is [ get ENCODING_JSON ], true [
    set bodyChunks [ list ]
    set bodySize 0
    at [ get request ] on, call data [
     function chunk [
      get error, false [
       at [ get bodyChunks ] push, call [ get chunk ]
       set bodySize [
        add [ get bodySize ] [ at [ get chunk ] length ]
       ]
       get bodySize, > [ get MAX_REQUEST_BODY_SIZE ], true [
        set error true
        at [ get reject ], call
        object [
         message template 'request body size cannot exceed %0 bytes' [
          get MAX_REQUEST_BODY_SIZE
         ]
        ]
       ]
      ]
     ]
    ]
    at [ get request ] on, call end [
     function [
      get error, false [
       at [ get resolve ], call [
        at [ get JSON ] parse, call [
         at [ get Buffer ] concat, call [ get bodyChunks ]
        ]
       ]
      ]
     ]
    ]
   ]
   false [
    at [ get resolve ], call [ object ]
   ]
  ]
 ]
]
