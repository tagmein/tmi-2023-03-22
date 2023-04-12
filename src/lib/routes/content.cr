set respondWithJson [
 function data [
  set [ get response ] statusCode 200
  do [
   get response
   do [ at setHeader, call Content-Type application/json ]
   do [
    at end, call [
     get JSON stringify, call [ get data ]
    ]
   ]
  ]
 ]
]

set tagMeInChannel [
 object [ owner System, key tagmein, name 'Tag Me In' ]
]

set readDirectories [
 function searchPath [
  promise [
   function resolve reject [
    set directories [ list ]
    set readdirCallback [
     function err items [
      get err, true [
       get resolve, call [ get directories ]
      ]
      false [
       get items, each [
        function item [
         promise [
          function resolve2 reject2 [
           set itemPath [
            get path join,
            call [ get searchPath ] [ get item ]
           ]
           get fileSystem stat
           call [ get itemPath ] [
            function err stats [
             get err, true [
              get reject2, call [ get err ]
             ]
             false [
              get stats isDirectory, call
              true [
               get directories push, call [ get item ]
              ]
              get resolve2, call
             ]
            ]
           ]
          ]
         ]
        ]
       ]
      ]
      get resolve, call [ get directories ]
     ]
    ]
    get fileSystem readdir
    call [ get searchPath ] [ get readdirCallback ]
   ]
  ]
 ]
]

set readValue [
 function searchPath [
  promise [
   function resolve reject [
    set mainFilePath [
     get path join,
     call [ get searchPath ] main.value
    ]
    set readFileCallback [
     function err data [
      get err, true [
       get resolve, call ''
      ]
      false [
       get resolve, call [ get data ]
      ]
     ]
    ]
    get fileSystem readFile
    call [ get mainFilePath ] utf8 [ get readFileCallback ]
   ]
  ]
 ]
]

set pathExists [
 function searchPath [
  promise [
   function resolve [
    get fileSystem exists
    call [ get searchPath ] [ get resolve ]
   ]
  ]
 ]
]

set channelKey [
 get requestParams path split, call /
 at [ current ] 0
]

set relativeNodePath [
 get requestParams path split, call /
 at slice, call 1
 at join, call /
]

set channelKey [
 get requestParams path split, call /
 at [ current ] 0
]

set channelGroup [
 set output [ list ]
 get channelKey
 is tagmein, true [
  set [ get output ] 0 system
 ]
 false [
  set [ get output ] 0 data
 ]
 get output 0
]

set searchPath [
 get path join
 call [ get publicBase ] [ get channelGroup ] [
  get requestParams path split, call /
  each [
   function segment [
    get encode, call [ get segment ]
   ]
  ]
  at join, call /
 ]
]

set currentSession [
 get session fromApiKey, call [
  get request headers x-tmi-api-key
 ]
]

set channelHasPath [
 function testChannelKey testPath [
  set testChannelGroup [
   set output [ list ]
   get testChannelKey
   is tagmein, true [
    set [ get output ] 0 system
   ]
   false [
    set [ get output ] 0 data
   ]
   get output 0
  ]
  get pathExists, call [
   get path join
   call [ get publicBase ] [ get testChannelGroup ] [
    get testChannelKey
   ] [
    get testPath
   ]
  ]
 ]
]

set channelsWithPath [
 function relativePath [
  set resultChannels [ object ]
  get currentSession, true [
   set [ get resultChannels ] current [
    list [
     [ get tagMeInChannel ]
    ]
    at concat, call [
     get channelTools list
     call [ get currentSession email ]
    ]
   ]
  ], false [
   set [ get resultChannels ] current [
    list [
     [ get tagMeInChannel ]
    ]
   ]
  ]
  get channelKey, is tagmein, false [
   get resultChannels current, filter [
    function testChannel [
     get testChannel key, is [ get channelKey ]
    ]
   ], at length, is 0, true [
    get resultChannels current push, call [
     get channelTools byKey
     call [ get channelKey ]
    ]
   ]
  ]
  get resultChannels current
  each [
   function testChannel [
    get channelHasPath
    call [ get testChannel key ] [ get relativePath ]
    true [
     set [ get testChannel ] hasCurrent true
    ]
    get testChannel
   ]
  ]
 ]
]

set permissions [ object ]
get currentSession, true [
 get channelGroup, is system, true [
  set [ get permissions ] edit [
   get currentSession email, is hello@nateferrero.com
  ]
 ], false [
  set [ get permissions ] edit [
   get channelTools byKey
   call [ get channelKey ]
   at owner, is [ get currentSession email ]
  ]
 ]
], false [
 set [ get permissions ] edit false
]

get respondWithJson, call [
 object [
  permissions [ get permissions ]
  value [
   get readValue, call [ get searchPath ]
  ]
  channels [
   get channelsWithPath, call [ get relativeNodePath ]
  ]
  nodes [
   get readDirectories, call [ get searchPath ]
   each [
    function dirName [
     get decode, call [ get dirName ]
    ]
   ]
  ]
 ]
]
