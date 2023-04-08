set Buffer [ at Buffer ]
set decode [ at decodeURIComponent ]
set encode [ at encodeURIComponent ]
set JSON [ at JSON ]
set require [ at require ]
set setTimeout [ at setTimeout ]

set path [ at require, call path ]
set fileSystem [ at require, call fs ]

set querystring [
 at require, call querystring
]

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

# define base private path
set privateBase [
 set root [ at __dirname ]
 at [ get path ] join
 call [ get root ] .. private
]

# define base public path
set publicBase [
 set root [ at __dirname ]
 at [ get path ] join
 call [ get root ] .. public
]

# load private data utility
set privateData [
 load ./private-data.cr, point
]

# define routes
set routes [
 object [
  'GET /'                     [ load ./routes/index.cr ]
  'GET /api/hello'            [ load ./routes/hello.cr ]
  'GET /api/account'          [ load ./routes/account-get.cr ]
  'POST /api/account/sign-in' [ load ./routes/account-sign-in.cr ]
  'GET /api/content'          [ load ./routes/content.cr ]
  'POST /api/content/new'     [ load ./routes/create-node.cr ]
  'POST /api/content'         [ load ./routes/write-node-value.cr ]
 ]
]

# load default request handler
set defaultRequestHandler [
 load ./routes/default.cr
]

# load JSON body parser
set parseRequestBody [
 load ./parse-request-body.cr, point
]

# create request handler
set agent [
 function request response [
  set requestUrl [ 
   at [ get request ] url
  ]
  set requestMethod [
   at [ get request ] method
  ]
  set splitUrl [
   at [ get requestUrl ] split
   call ?
  ]
  set requestPath [ get splitUrl 0 ]
  set requestParams [
   get querystring parse,
   call [ get splitUrl 1 ]
  ]

  log [ get requestMethod ] [ get requestUrl ]

  set requestBody [
   get parseRequestBody, call [ get request ]
  ]

  log [ get requestBody ]

  set requestKey [
   template '%0 %1' [ get requestMethod ] [ get requestPath ]
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
