log Keeping private data at [ get privateBase ]

function key [
 set encodedKey [
  get encode, call [ get key ]
 ]
 object [
  delete [
   function [
    promise [
     function resolve reject [
      set dataFile [
       get path join,
       call [ get privateBase ] data [ get encodedKey ]
      ]
      set complete [
       function err [
        get err, true [
         get resolve, call undefined
        ], false [
         get resolve, call true
        ]
       ]
      ]
      get fileSystem unlink
      call [ get dataFile ] [ get complete ]
     ]
    ]
   ]
  ]
  read [
   function [
    promise [
     function resolve reject [
      set dataFile [
       get path join,
       call [ get privateBase ] data [ get encodedKey ]
      ]
      set complete [
       function err stringValue [
        get err, true [
         get resolve, call undefined
        ], false [
         get resolve, call [
          get JSON parse, call [ get stringValue ]
         ]
        ]
       ]
      ]
      get fileSystem readFile
      call [ get dataFile ] utf8 [ get complete ]
     ]
    ]
   ]
  ]
  write [
   function value [
    set stringValue [
     get JSON stringify, call [ get value ]
    ]
    promise [
     function resolve reject [
      set dataFile [
       get path join,
       call [ get privateBase ] data [ get encodedKey ]
      ]
      set complete [
       function err [
        get err, true [
         get resolve, call false
        ], false [
         get resolve, call true
        ]
       ]
      ]
      get fileSystem writeFile
      call [ get dataFile ] [ get stringValue ] utf8 [ get complete ]
     ]
    ]
   ]
  ]
 ]
]
