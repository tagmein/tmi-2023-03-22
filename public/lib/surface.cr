set surface [ get element, call ]
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

set computedBaseStaticPath [ object ]
set filterNodesContainer [ object ]
set filterNodesInput [ object ]
set newNodeContainer [ object ]
set nodeList [ object ]
set valueEditor [ object ]

set documentArea [ get element, call ]
get documentArea classList add, call [
 set name documentArea
 set rules '
  & {
   display: flex;
   flex-direction: column;
   flex-grow: 1;
   min-width: 400px;
  }
 '
 get style, point
]

set documentInteractiveArea [ get element, call ]

set previewArea [ get element, call ]
get previewArea classList add, call [
 set name previewArea
 set rules '
  & {
   min-width: 400px;
   flex-grow: 1;
  }

  & > iframe {
   background-color: transparent;
   border: none;
   height: 100%;
   width: 100%;
  }
 '
 get style, point
]

set renderPreview [
 function value [
  set [ get previewArea ] innerHTML ''
  set previewFrame [
   get element, call iframe
  ]
  get value startsWith, call '
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
      get value substring, call 1
     ]
    ]
   ]
  ]
  false [
   get value startsWith, call <
   true [
    set [ get previewFrame ] srcdoc [ get value ]
   ]
   false [
    set [ get previewFrame ] srcdoc [
     template '<!doctype html>
<html>

<head>
 <meta charset="utf-8" />
 <meta name="viewport" content="width=device-width, initial-scale=1" />
 <script>
  globalThis.basePath = %0 + %1
 </script>
 <script type="text/javascript" src="/crown.js"></script>
</head>

<body>
 <noscript>JavaScript is required</noscript>
 <script type="text/javascript">
  async function main() {
   await loadCrownDependencies()
   await crown().run([%2])
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
       get computedBaseStaticPath current
      ]
     ] [
      get JSON stringify, call [ get value ]
     ]
    ]
   ]
  ]
  get build, call [ get previewArea ] [ get previewFrame ]
 ]
]

set loadedHash [ object ]

get isViewOnly, false [
 set [ get nodeList ] current [
  get element, call
 ]

 get nodeList current classList add, call [
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

   & .node {
    box-sizing: border-box;
    display: flex;
    flex-direction: row;
    font-size: 18px;
    line-height: 2;
    min-height: 47px;
    position: relative;
    width: 100%;
    word-wrap: break-word;
   }

   & .node[data-child="true"] {
    border-bottom: 1px solid #454545;
   }

   & .node[data-parent="true"] {
    background-color: #454545;
    border-bottom: 1px solid #676767;
   }

   & .node:hover {
    background-color: #565656;
   }

   & .node[data-current="true"],
   & .node[data-current="true"]:hover {
    background-color: #787878;
    color: #f0f0f0;
   }

   & .node a {
    display: block;
    flex-grow: 1;
    overflow: hidden;
    padding: 5px 15px;
    text-overflow: ellipsis;
   }

   & .node a[data-action="view"] {
    flex-grow: 0;
    flex-shrink: 0;
    opacity: 0;
    position: relative;
    width: 16px;
   }

   & .node:hover a[data-action="view"] {
    opacity: 0.5;
   }

   & .node a[data-action="view"]:hover,
   & .node a[data-action="view"]:focus {
    background-color: #898989;
    opacity: 1;
   }

   & .node a[data-action="view"]::after {
    border-radius: 2px;
    border: 1px solid #f0f0f0;
    content: "";
    display: block;
    height: 16px;
    left: 13px;
    position: absolute;
    top: 13px;
    width: 16px;
   }

   & .node a[data-action="view"]::before {
    background-color: #f0f0f0;
    border-radius: 2px;
    border: 1px solid #f0f0f0;
    content: "";
    display: block;
    height: 6px;
    right: 17px;
    position: absolute;
    top: 15px;
    width: 6px;
   }
  '
  get style, point
 ]

 set [ get valueEditor ] current [
  get element, call textarea
 ]

 get valueEditor current classList add, call [
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

 get build
 do [ call [ get surface ] [ get nodeList current ] ]
 do [ call [ get surface ] [ get valueEditor current ] ]

 set saveEditorChanges [
  function [
   set responseData [
    get tmiApi, call [
     template %0?path=%1 /content [
      get loadedHash current
     ]
    ] [
     object [
      value [ get valueEditor current value ]
     ]
    ]
   ]
  ]
 ]

 set renderPreviewDebounced [
  get debounce, call [
   function [
    get renderPreview, call [
     get valueEditor current value
    ]
   ]
  ] 250
 ]

 set saveEditorChangesDebounced [
  get debounce, call [ get saveEditorChanges ]
 ]

 list [ change, keyup ], each [
  function eventType [
   get valueEditor current addEventListener, call [ get eventType ] [
    function [
     get valueEditor current getAttribute
     call readonly, is readonly, false [
      get renderPreviewDebounced, call
      get saveEditorChangesDebounced, call
     ]
    ]
   ]
  ]
 ]

 set [ get newNodeContainer ] current [
  get element, call div
 ]

 get newNodeContainer current classList add, call [
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

 set [ get filterNodesContainer ] current [
  get element, call div
 ]

 get filterNodesContainer current classList add, call [
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

 set [ get filterNodesInput ] current [
  get element, call input
 ]

 get filterNodesInput current classList add, call [
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

 get filterNodesInput current addEventListener, call keyup [
  function event [
   get event key, is Escape, true [
     set [ get filterNodesInput current ] value ''
   ]
   get filterNodesInput current value, is '', true [
    set [ get filterNodesStyleTag ] textContent ''
   ], false [
    set [ get filterNodesStyleTag ] textContent [
     template '
 .node[data-child="true"] { display: none; }
 .node[data-child="true"][data-word*="%0"] { display: initial; }
     ' [
      get encode, call [ get filterNodesInput current value ]
     ]
    ]
   ]
  ]
 ]

 get build, call [ get filterNodesContainer current ] [ get filterNodesInput current ]

 set [ get newNodeContainer ] current [
  get element, call div
 ]

 get newNodeContainer current classList add, call [
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
    get setTimeout, call [
      function [
        get newNodeInput focus, call
      ]
    ] 250
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

 get build, call [ get newNodeContainer current ] [
  get newNodeInput
 ]

 get build, call [ get newNodeContainer current ] [
  get createButton
 ]
]

get build
do [ call [ get document body ] [ get surface ] ]
do [ call [ get surface ] [ get documentArea ] ]
do [ call [ get documentArea ] [ get previewArea ] ]
do [ call [ get documentArea ] [ get documentInteractiveArea ] ]

set appendLink [
 function node label href [
  set link [ get element, call a ]
  set [ get link ] textContent [ get label ]
  get link setAttribute, call href [ 
   template /%0 [ get href ]
  ]
  get build, call [ get node ] [ get link ]
  set viewLink [ get element, call a ]
  get viewLink setAttribute
  do [ call title 'View in new tab' ]
  do [ call data-action view ]
  do [
   call href [ template /view%0 [ get href ] ]
  ]
  do [ call target _blank ]
  get build, call [ get node ] [ get viewLink ]
 ]
]

object [
 setNodes [
  function nodes permissions currentChannel [
   set segments [ get getPathSegments, call ]
   set [ get nodeList current ] innerHTML ''
   set rootLink [
    get element, call
   ]
   get rootLink classList add, call node
   get rootLink setAttribute, call data-parent true
   get segments length, is 0, true [
    get rootLink setAttribute, call data-current true
    set [ get document ] title [
     template 'Home - %0' [ get currentChannel name ]
    ]
   ]
   get appendLink, call [ get rootLink ] Home [
    template '#%0' [
     get getChannelKey, call
    ]
    at replace, call [ regexp /$ ] ''
   ]
   get build, call [ get nodeList current ] [ get rootLink ]
   get segments, each [
    function segment index [
     set parentLink [ get element, call ]
     get parentLink classList add, call node
     get parentLink setAttribute, call data-parent true
     get index, is [ value -1, add [ get segments length ]], true [
       get parentLink setAttribute, call data-current true
       set [ get document ] title [
        template '%1 - %0' [ get currentChannel name ] [
         get decode, call [ get segment ]
        ]
       ]
     ]
     get appendLink, call [ get parentLink ] [
      get decode, call [ get segment ]
     ] [
      template '#%0/%1' [
       get getChannelKey, call
      ] [
       get segments slice, call 0 [ 
        add 1 [ get index ]
       ]
       at join, call /
      ]
      at replace, call [ regexp /$ ] ''
     ]
     get build, call [ get nodeList current ] [ get parentLink ]
    ]
   ]
   get build, call [ get nodeList current ] [ get filterNodesContainer current ]
   get nodes length, is 1, true [
    get filterNodesInput current setAttribute, call placeholder [
      template 'Filter one item'
    ]
   ], false [
    get filterNodesInput current setAttribute, call placeholder [
      template 'Filter %0 items' [ get nodes length ]
    ]
   ]
   get nodes, each [
    function node [
     set nodeLink [ get element, call ]
     get nodeLink classList add, call node
     get nodeLink setAttribute
     do [ call data-child true ]
     do [
      call data-word [
       get encode, call [ get node ]
      ]
     ]
     get appendLink, call [ get nodeLink ] [ get node ] [
      template %0/%1 [ get location hash ] [
       get encode, call [ get node ]
      ]
     ]
     get build, call [ get nodeList current ] [ get nodeLink ]
    ]
   ]
   get permissions edit, true [
    get build, call [ get nodeList current ] [ get newNodeContainer current ]
   ]
  ]
 ]
 setValue [
  function value permissions currentChannel [
   set [ get documentInteractiveArea ] innerHTML ''
   set [ get loadedHash ] current [
    get location hash,
    at substring, call 1
   ]
   get currentChannel key, is tagmein, true [
    set [ get computedBaseStaticPath ] current [
     template /system/%0 [ get loadedHash current ]
    ]
   ], false [
    set [ get computedBaseStaticPath ] current [
     template /data/%0 [ get loadedHash current ]
    ]
   ]
   log [ get computedBaseStaticPath ]
   get renderPreview, call [ get value ]
   get isViewOnly, false [
    set [ get valueEditor current ] value [ get value ]
    get permissions edit, true [
     get valueEditor current removeAttribute, call readonly
    ], false [
     get valueEditor current setAttribute, call readonly readonly
    ]
   ]
  ]
 ]
 insertDocumentElement [
  function documentElement [
   get build, call [ get documentInteractiveArea ] [ get documentElement ]
  ]
 ]
]
