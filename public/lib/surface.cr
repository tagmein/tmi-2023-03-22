set surface [
 at [ get element ], call div
]

at [ get surface ] classList add, call [
 set name surface
 set rules '
  & {
   display: flex;
   flex-direction: row;
   flex-grow: 1;
   overflow: hidden;
  }
 '
 get style, point
]

set nodeList [
 at [ get element ], call
]

at [ get nodeList ] classList add, call [
 set name nodeList
 set rules '
  & {
   background-color: #343434;
   border-right: 1px solid #676767;
   display: flex;
   flex-direction: column;
   flex-shrink: 0;
   max-width: 100vw;
   overflow-x: hidden;
   overflow-y: auto;
   width: 320px;
  }

  & a {
   box-sizing: border-box;
   display block;
   font-size: 18px;
   line-height: 2;
   min-height: 47px;
   padding: 5px 15px;
   position: relative;
   word-wrap: break-word;
  }

  & a[data-child="true"] {
   border-bottom: 1px solid #454545;
  }

  & a[data-parent="true"] {
   background-color: #454545;
   padding-right: 40px;
   border-bottom: 1px solid #676767;
  }

  & a[data-current="true"] {
   font-weight: bold;
  }

  & a[data-parent="true"]::after {
   content: "\00AB";
   display: block;
   font-size: 28px;
   position: absolute;
   right: 15px;
   top: -5px;
   transform: rotate(90deg);
  }

  & a:hover {
   background-color: #565656;
  }
 '
 get style, point
]

set valueEditor [
 at [ get element ], call textarea
]

at [ get valueEditor ] classList add, call [
 set name valueEditor
 set rules '
  & {
   background: transparent;
   border: none;
   border-right: 1px solid #676767;
   color: #e9e9e9;
   display: none;
   flex-shrink: 0;
   font-family: "Nimbus Mono PS", "Courier New", "Cutive Mono", monospace;
   font-size: 16px;
   max-width: 100vw;
   padding: 10px 15px;
   resize: none;
   width: 400px;
  }

  body.show-editor & {
   display: block;
  }
 '
 get style, point
]

set previewFrame [
 at [ get element ], call iframe
]

at [ get previewFrame ] classList add, call [
 set name previewFrame
 set rules '
  & {
   background-color: transparent;
   border: none;
   min-width: 400px;
   flex-grow: 1;
  }
 '
 get style, point
]

set renderPreview [
 function [
  at [
   get valueEditor value
  ] startsWith, call '
'
  true [
   set [ get previewFrame ] srcdoc [
     template '<!doctype html>
<html>

<head>
 <meta charset="utf-8" />
 <meta name="viewport" content="width=device-width, initial-scale=1" />
 <style>
  #textContent {
   color: #f0f0f0;
   font-family: inherit;
   font-size: 18px;
   margin: 0;
   white-space: pre-wrap;
  }
 </style>
</head>

<body>
 <div id="textContent"></div>
 <noscript>JavaScript is required</noscript>
 <script type="text/javascript">
  document.getElementById("textContent").textContent = %0
 </script>
</body>

</html>' [
     at [ get JSON ] stringify, call [
      at [ get valueEditor value ] substring,
      call 1
     ]
    ]
   ]
  ]
  false [
   at [
    get valueEditor value
   ] startsWith, call <
   true [
    set [ get previewFrame ] srcdoc [
     get valueEditor value
    ]
   ]
   false [
    set [ get previewFrame ] srcdoc [
     template '<!doctype html>
<html>

<head>
 <meta charset="utf-8" />
 <meta name="viewport" content="width=device-width, initial-scale=1" />
 <script>
  globalThis.basePath = %0
 </script>
 <script type="text/javascript" src="/crown.js"></script>
</head>

<body>
 <noscript>JavaScript is required</noscript>
 <script type="text/javascript">
  async function main() {
   await loadCrownDependencies()
   await crown().run([%1])
  }
  main().catch(e => console.error(e))
 </script>
</body>

</html>' [
      at [ get JSON ] stringify, call [
       at [ get location ] origin
      ]
     ] [
      at [ get JSON ] stringify, call [
       get valueEditor value
      ]
     ]
    ]
   ]
  ]
 ]
]

set saveEditorChanges [
 function [
  set hash [
   get location hash,
   at substring, call 1
  ]
  set requestBody [
   at [ get JSON ] stringify, call [
    object [
     value [ get valueEditor value ]
    ]
   ]
  ]
  set response [
   at [ get fetch ], call [
    template %0?path=%1 /content [
     get hash
    ]
   ] [
    object [
     method POST
     headers [
      object [
       Content-Type application/json
      ]
     ]
     body [ get requestBody ]
    ]
   ]
  ]
  set responseData [
   at [ get response ] json, call
  ]
 ]
]

set renderPreviewDebounced [
 get debounce, call [ get renderPreview ] 250
]

set saveEditorChangesDebounced [
 get debounce, call [ get saveEditorChanges ]
]

each [ list [ change, keyup ] ] [
 function eventType [
  at [ get valueEditor ] addEventListener, call [ get eventType ] [
   function [
    get renderPreviewDebounced, call
    get saveEditorChangesDebounced, call
   ]
  ]
 ]
]

at [ get build ]
do [ call [ get document body ] [ get surface ] ]
do [ call [ get surface ] [ get nodeList ] ]
do [ call [ get surface ] [ get valueEditor ] ]
do [ call [ get surface ] [ get previewFrame ] ]

set newNodeContainer [
 at [ get element ], call div
]

at [ get newNodeContainer ] classList add, call [
 set name newNodeContainer
 set rules '
  & {
   background-color: #343434;
   display: flex;
   justify-content: center;
   padding: 10px;
  }
 '
 get style, point
]

set newNodeContainer [
 at [ get element ], call div
]

at [ get newNodeContainer ] classList add, call [
 set name newNodeContainer
 set rules '
  & {
   display: flex;
   justify-content: center;
   padding: 10px;
  }
 '
 get style, point
]

set newNodeInput [
 at [ get element ], call input
]

at [ get newNodeInput ] classList add, call [
 set name newNodeInput
 set rules '
  & {
   background-color: #5c5c5c;
   border: none;
   border-radius: 4px;
   color: #e9e9e9;
   font-size: 18px;
   padding: 5px 10px;
   outline: none;
   width: 100%;
  }

  &::placeholder {
   color: #9c9c9c;
  }
 '
 get style, point
]

at [ get newNodeInput ] setAttribute, call placeholder 'New item name'

set createButton [
 at [ get element ], call button
]

at [ get createButton ] classList add, call [
 set name createButton
 set rules '
  & {
   background-color: #343434;
   border: none;
   border-radius: 4px;
   color: #e9e9e9;
   cursor: pointer;
   font-size: 18px;
   margin-left: 10px;
   padding: 5px 10px;
  }

  &:hover {
   background-color: #565656;
  }
 '
 get style, point
]

set [ get createButton ] textContent Create

set createNewNode [
 function nodeName [
  set hash [
   get location hash,
   at substring, call 1
  ]
  set requestBody [
   at [ get JSON ] stringify, call [
    object [
     name [ get nodeName ]
    ]
   ]
  ]
  set response [
   at [ get fetch ], call [
    template %0?path=%1 /content/new [
     get hash
    ]
   ] [
    object [
     method POST
     headers [
      object [
       Content-Type application/json
      ]
     ]
     body [ get requestBody ]
    ]
   ]
  ]
  set responseData [
   at [ get response ] json, call
  ]
  get responseData success, true [
   set [ get newNodeInput ] value ''
  ]
  at [ get route ], call
 ]
]

at [ get createButton ] addEventListener, call click [
 function [
  get newNodeInput value length, is 0, true [
   at [ get alert ], call 'Name cannot be empty'
  ], false [
   at [ get createNewNode ], call [
    get newNodeInput value
   ]
  ]
 ]
]

at [ get build ], call [ get newNodeContainer ] [ get newNodeInput ]
at [ get build ], call [ get newNodeContainer ] [ get createButton ]

object [
 setNodes [
  function nodes [
   set [ get nodeList ] innerHTML ''
   set segments [ get getPathSegments, call ]
   each [ get segments ] [
    function segment index [
     set parentLink [
      at [ get element ], call a
     ]
     at [ get parentLink ] setAttribute, call data-parent true
     get index, is [ add -1 [ get segments length ]], true [
       at [ get parentLink ] setAttribute, call data-current true 
     ]
     set [ get parentLink ] href [
      template '/#%0/%1' [
       get getChannel, call
      ] [
       at [ get segments ] slice, call 0 [ get index ]
       at join, call /
      ]
      at replace, call [ regexp /$ ] ''
     ]
     set [ get parentLink ] textContent [
      at [ get decode ], call [ get segment ]
     ]
     at [ get build ], call [ get nodeList ] [ get parentLink ]
    ]
   ]
   each [ get nodes ] [
    function node [
     set nodeLink [
      at [ get element ], call a
     ]
     at [ get nodeLink ] setAttribute, call data-child true
     set [ get nodeLink ] href [
      template /%0/%1 [
       get location hash
      ] [
       at [ get encode ], call [ get node ]
      ]
     ]
     set [ get nodeLink ] textContent [ get node ]
     at [ get build ], call [ get nodeList ] [ get nodeLink ]
    ]
   ]
   at [ get build ], call [ get nodeList ] [ get newNodeContainer ]
  ]
 ]
 setValue [
  function value [
   set [ get valueEditor ] value [ get value ]
   at [ get renderPreview ], call
  ]
 ]
]
