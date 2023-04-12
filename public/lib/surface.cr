set surface [
 get element, call div
]

get surface classList add, call [
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
 get element, call
]

get nodeList classList add, call [
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

  & a[data-parent="true"]::after {
   content: "\2022";
   display: block;
   font-size: 28px;
   position: absolute;
   right: 15px;
   top: -5px;
   transform: rotate(-90deg);
  }

  & a:hover {
   background-color: #565656;
  }

  & a[data-current="true"],
  & a[data-current="true"]:hover {
   background-color: #787878;
   color: #f0f0f0;
  }
 '
 get style, point
]

set valueEditor [
 get element, call textarea
]

get valueEditor classList add, call [
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
   width: 500px;
  }

  body.show-editor & {
   display: block;
  }
 '
 get style, point
]

set previewFrame [
 get element, call iframe
]

get previewFrame classList add, call [
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
     get JSON stringify, call [
      get valueEditor value substring, call 1
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
      get JSON stringify, call [
       get location origin
      ]
     ] [
      get JSON stringify, call [
       get valueEditor value
      ]
     ]
    ]
   ]
  ]
 ]
]

set loadedHash [ object ]

set saveEditorChanges [
 function [
  set responseData [
   get tmiApi, call [
    template %0?path=%1 /content [
     get loadedHash current
    ]
   ] [
    object [
     value [ get valueEditor value ]
    ]
   ]
  ]
 ]
]

set renderPreviewDebounced [
 get debounce, call [ get renderPreview ] 250
]

set saveEditorChangesDebounced [
 get debounce, call [ get saveEditorChanges ]
]

list [ change, keyup ], each [
 function eventType [
  get valueEditor addEventListener, call [ get eventType ] [
   function [
    get valueEditor getAttribute
    call readonly, is readonly, false [
     get renderPreviewDebounced, call
     get saveEditorChangesDebounced, call
    ]
   ]
  ]
 ]
]

get build
do [ call [ get document body ] [ get surface ] ]
do [ call [ get surface ] [ get nodeList ] ]
do [ call [ get surface ] [ get valueEditor ] ]
do [ call [ get surface ] [ get previewFrame ] ]

set newNodeContainer [
 get element, call div
]

get newNodeContainer classList add, call [
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

set filterNodesContainer [
 get element, call div
]

get filterNodesContainer classList add, call [
 set name filterNodesContainer
 set rules '
  & {
   display: flex;
   justify-content: center;
   padding: 10px;
  }
 '
 get style, point
]

set filterNodesInput [
 get element, call input
]

get filterNodesInput classList add, call [
 set name filterNodesInput
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

set filterNodesStyleTag [
 get element, call style
]

get document head appendChild, call [
 get filterNodesStyleTag
]

get filterNodesInput addEventListener, call keyup [
 function event [
  get event key, is Escape, true [
    set [ get filterNodesInput ] value ''
  ]
  get filterNodesInput value, is '', true [
   set [ get filterNodesStyleTag ] textContent ''
  ], false [
   set [ get filterNodesStyleTag ] textContent [
    template '
a[data-child="true"] { display: none; }
a[data-child="true"][data-word*="%0"] { display: initial; }
    ' [
     get encode, call [ get filterNodesInput value ]
    ]
   ]
  ]
 ]
]

get build, call [ get filterNodesContainer ] [ get filterNodesInput ]

set newNodeContainer [
 get element, call div
]

get newNodeContainer classList add, call [
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
 get element, call input
]

get newNodeInput classList add, call [
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

get newNodeInput setAttribute, call placeholder 'New item name'

set createButton [
 get element, call button
]

get createButton classList add, call [
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
  set responseData [
   get tmiApi, call [
    template %0?path=%1 /content/new [
     get hash
    ]
   ] [
    object [
     name [ get nodeName ]
    ]
   ]
  ]
  get responseData success, true [
   set [ get newNodeInput ] value ''
  ], false [
   get alert, call 'Unable to create node, maybe it exists?'
  ]
  get route, call
 ]
]

get newNodeInput addEventListener, call keypress [
 function event [
  get event key, is Enter, true [
    get newNodeInput value length, is 0, true [
    get alert, call 'Name cannot be empty'
   ], false [
    get createNewNode, call [
      get newNodeInput value
    ]
   ]
  ]
 ]
]

get createButton addEventListener, call click [
 function [
  get newNodeInput value length, is 0, true [
   get alert, call 'Name cannot be empty'
  ], false [
   get createNewNode, call [
    get newNodeInput value
   ]
  ]
 ]
]

get build, call [ get newNodeContainer ] [ get newNodeInput ]
get build, call [ get newNodeContainer ] [ get createButton ]

object [
 setNodes [
  function nodes permissions [
   set segments [ get getPathSegments, call ]
   set [ get nodeList ] innerHTML ''
   set rootLink [
    get element, call a
   ]
   get rootLink setAttribute, call data-parent true
   get segments length, is 0, true [
    get rootLink setAttribute, call data-current true 
   ]
   set [ get rootLink ] href [
    template '/#%0' [
     get getChannel, call
    ]
    at replace, call [ regexp /$ ] ''
   ]
   set [ get rootLink ] textContent Home
   get build, call [ get nodeList ] [ get rootLink ]
   get segments, each [
    function segment index [
     set parentLink [
      get element, call a
     ]
     get parentLink setAttribute, call data-parent true
     get index, is [ add -1 [ get segments length ]], true [
       get parentLink setAttribute, call data-current true 
     ]
     set [ get parentLink ] href [
      template '/#%0/%1' [
       get getChannel, call
      ] [
       get segments slice, call 0 [ 
        add 1 [ get index ]
       ]
       at join, call /
      ]
      at replace, call [ regexp /$ ] ''
     ]
     set [ get parentLink ] textContent [
      get decode, call [ get segment ]
     ]
     get build, call [ get nodeList ] [ get parentLink ]
    ]
   ]
   get build, call [ get nodeList ] [ get filterNodesContainer ]
   get nodes length, is 1, true [
    get filterNodesInput setAttribute, call placeholder [
      template 'Filter one item'
    ]
   ], false [
    get filterNodesInput setAttribute, call placeholder [
      template 'Filter %0 items' [ get nodes length ]
    ]
   ]
   get nodes, each [
    function node [
     set nodeLink [
      get element, call a
     ]
     get nodeLink setAttribute
     do [ call data-child true ]
     do [
      call data-word [
       get encode, call [ get node ]
      ]
     ]
     set [ get nodeLink ] href [
      template /%0/%1 [
       get location hash
      ] [
       get encode, call [ get node ]
      ]
     ]
     set [ get nodeLink ] textContent [ get node ]
     get build, call [ get nodeList ] [ get nodeLink ]
    ]
   ]
   get permissions edit, true [
    get build, call [ get nodeList ] [ get newNodeContainer ]
   ]
  ]
 ]
 setValue [
  function value permissions [
   set [ get loadedHash ] current [
    get location hash,
    at substring, call 1
   ]
   set [ get valueEditor ] value [ get value ]
   get permissions edit, true [
    get valueEditor removeAttribute, call readonly
   ], false [
    get valueEditor setAttribute, call readonly readonly
   ]
   get renderPreview, call
  ]
 ]
]
