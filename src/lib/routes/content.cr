set [ get response ] statusCode 200
do [
 at [ get response ]
 do [ at setHeader, call Content-Type [ get plainText ] ]
 do [ at end, call [
  template %0"%1" 'hello from content.cr, path is ' [
   get requestParams path
  ]
 ] ]
]
