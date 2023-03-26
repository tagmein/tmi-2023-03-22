# plain text content type header
set plainText 'text/plain; charset=utf-8'

# set host name
set host 0.0.0.0

# get port from environment variable PORT
set environmentPort [
 at process env PORT
]

# set port to run on
set port [
 at parseInt, call [ get environmentPort ] 10
 default 3456
]

# load path module
set path [ at require, call path ]

# define base public path
set publicBase [
 set root [ at __dirname ]
 at [ get path ] join
 call [ get root ] .. public
]

# define routes
set routes [
 object [
  [ 'GET /'      [ load ./routes/index.cr ] ]
  [ 'GET /hello' [ load ./routes/hello.cr ] ]
 ]
]

# load default request handler
set defaultRequestHandler [
 load ./routes/default.cr
]

# todo - how else to pass global to sub context
set require [ at require ]

# create request handler
set agent [
 function request response [
  set requestUrl [ 
   at [ get request ] url
  ]
  set requestMethod [
   at [ get request ] method
  ]
  log [ get requestMethod ] [ get requestUrl ]
  set requestKey [
   template '%0 %1' [ get requestMethod ] [ get requestUrl ]
  ]
  at [ get routes ] [ get requestKey ]
  default [ get defaultRequestHandler ]
  # point is a special command that calls the current value with the current scope
  point
 ]
]

# create http server
set server [
 at require, call http
 at createServer, call [ get agent ]
]

# start server
at [ get server ] listen
call [ get port ] [ get host ] [
 function [
  log [
   template 'Starting server at http://%0:%1' [ get host ] [ get port ]
  ]
  log Serving routes [ get routes ]
  log 'Serving public content from' [ get publicBase ]
 ]
]