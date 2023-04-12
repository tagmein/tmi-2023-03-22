set Array [ at Array ]
set Buffer [ at Buffer ]
set Date [ at Date ]
set decode [ at decodeURIComponent ]
set encode [ at encodeURIComponent ]
set JSON [ at JSON ]
set Math [ at Math ]
set require [ at require ]
set setTimeout [ at setTimeout ]

set fileSystem [ at require, call fs ]
set path [ at require, call path ]
set querystring [ at require, call querystring ]

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
 get path join
 call [ get root ] .. private
]

# define base public path
set publicBase [
 set root [ at __dirname ]
 get path join
 call [ get root ] .. public
]

set channelTools [ load ./channel-tools.cr, point ]
set privateData [ load ./private-data.cr, point ]
set randomKey [ load ./random-key.cr, point ]
set session [ load ./session.cr, point ]

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
  'GET /api/sessions'         [ load ./routes/sessions-list.cr ]
  'POST /api/sessions/delete' [ load ./routes/session-delete.cr ]
  'GET /api/channels'         [ load ./routes/channels-list.cr ]
  'POST /api/channels/create' [ load ./routes/channel-create.cr ]
  'POST /api/channels/forget' [ load ./routes/channel-forget.cr ]
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
   get request url
  ]
  set requestMethod [
   get request method
  ]
  set splitUrl [
   get requestUrl split, call ?
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

  # log [ get requestBody ]

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
get server listen
call [ get port ] [ get host ] [
 function [
  log [
   template 'Starting server at http://%0:%1' [ get host ] [ get port ]
  ]
  log Serving routes [ get routes ]
  log 'Serving public content from' [ get publicBase ]
 ]
]
