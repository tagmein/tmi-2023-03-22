set [ get response ] statusCode 200
do [
 get response
 do [ at setHeader, call Content-Type [ get plainText ] ]
 do [ at end, call 'hello world' ]
]
