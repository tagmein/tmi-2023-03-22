// plain text content type header
set plainText 'text/plain; charset=utf-8'

// get port from environment variable PORT
set environmentPort [
 at process env PORT
]

// set port to run on
set port [
 at parseInt, call [ get environmentPort ] 10
 default 3456
]

// notify when server is listening
set ready [
 function [
  log 'Starting server on port' [ get port ]
 ]
]

// create request handler
set agent [
 function request response [
  set [ get response ] statusCode 200
  with at [ get response ] [
   [ setHeader, call Content-Type [ get plainText ] ]
   [ end, call 'hello world' ]
  ]
 ]
]

// create http server
set server [
 at require, call http
 at createServer, call [ get agent ]
]

// start server
at [ get server ] listen
call [ get port ] 0.0.0.0 [ get ready ]
