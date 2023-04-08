log Keeping private data at [ get privateBase ]

function key [
 set encodedKey [
  get encode, call [ get key ]
 ]
 log [ get encodedKey ]
 object [
  read [
   function value [
    set stringValue [
     get JSON stringify, call [ get value ]
    ]
    promise [
     function resolve reject [
      set dataFile [
       at [ get path ] join,
       call [ get privateBase ] [ get encodedKey ]
      ]
      set complete [
       function err data [
        get err, true [
         at [ get resolve ], call undefined
        ], false [
         at [ get resolve ], call [
          get JSON parse, call data
         ]
        ]
       ]
      ]
      at [ get fileSystem ] readFile
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
       at [ get path ] join,
       call [ get privateBase ] [ get encodedKey ]
      ]
      set complete [
       function err [
        get err, true [
         at [ get resolve ], call false
        ], false [
         at [ get resolve ], call true
        ]
       ]
      ]
      at [ get fileSystem ] writeFile
      call [ get dataFile ] [ get stringValue ] utf8 [ get complete ]
     ]
    ]
   ]
  ]
 ]
]
