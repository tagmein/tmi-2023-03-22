set readDirectories [
 function searchPath [
  promise [
   function resolve reject [
    set directories [ list ]
    set readdirCallback [
     function err items [
      get err, true [
       at [ get resolve ], call [ get directories ]
      ]
      false [
       each [ get items ] [
        function item [
         promise [
          function resolve2 reject2 [
           set itemPath [
            at [ get path ] join,
            call [ get searchPath ] [ get item ]
           ]
           at [ get fileSystem ] stat
           call [ get itemPath ] [
            function err stats [
             get err, true [
              at [ get reject2 ], call [ get err ]
             ]
             false [
              at [ get stats ] isDirectory, call
              true [
               at [ get directories ] push, call [ get item ]
              ]
              at [ get resolve2 ], call
             ]
            ]
           ]
          ]
         ]
        ]
       ]
      ]
      at [ get resolve ], call [ get directories ]
     ]
    ]
    at [ get fileSystem ] readdir
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
     at [ get path ] join,
     call [ get searchPath ] main.value
    ]
    set readFileCallback [
     function err data [
      get err, true [
       at [ get resolve ], call ''
      ]
      false [
       at [ get resolve ], call [ get data ]
      ]
     ]
    ]
    at [ get fileSystem ] readFile
    call [ get mainFilePath ] utf8 [ get readFileCallback ]
   ]
  ]
 ]
]

set channelGroup [
 set output [ list ]
 at [ get requestParams path ] split, call /
 at [ current ] 0
 is tagmein, true [
  set [ get output ] 0 system
 ]
 false [
  set [ get output ] 0 data
 ]
 at [ get output ] 0
]

set searchPath [
 at [ get path ] join
 call [ get publicBase ] [ get channelGroup ] [ get requestParams path ]
]

set responseString [
 at [ get JSON ] stringify, call [
  object [
   value [
    at [ get readValue ], call [ get searchPath ]
   ]
   channels [
    list [
     [ object [ key tagmein, label 'Tag Me In' ] ]
     [ object [ key foobar, label 'Foo Bar' ] ]
    ]
   ]
   nodes [
    at [ get readDirectories ], call [ get searchPath ]
   ]
  ]
 ]
]

set [ get response ] statusCode 200
at [ get response ]
do [ at setHeader, call Content-Type application/json ]
do [ at end, call [ get responseString ] ]
