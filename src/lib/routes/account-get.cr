set [ get response ] statusCode 200
do [
 at [ get response ]
 do [ at setHeader, call Content-Type application/json ]
 do [ at end, call 'null' ]
]
