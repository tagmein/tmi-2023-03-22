set [ get response ] statusCode 200
with at [ get response ] [
 [ setHeader, call Content-Type [ get plainText ] ]
 [ end, call 'hello world' ]
]
