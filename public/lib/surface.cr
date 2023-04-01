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
   display: flex;
   flex-direction: column;
   flex-shrink: 0;
   max-width: 100vw;
   overflow-x: hidden;
   overflow-y: auto;
   width: 200px;
  }

  & a {
   border-bottom: 1px solid #676767;
   display block;
   font-size: 18px;
   line-height: 2;
   padding: 5px 15px;
   word-wrap: break-word;
  }

  & a:hover {
   background-color: #676767;
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
   border-left: 1px solid #676767;
   border-right: 1px solid #676767;
   color: #e9e9e9;
   flex-shrink: 0;
   font-family: "Nimbus Mono PS", "Courier New", "Cutive Mono", monospace;
   font-size: 16px;
   max-width: 100vw;
   padding: 10px 15px;
   resize: none;
   width: 400px;
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
  set [ get previewFrame ] srcdoc [
   template '<!doctype html>
<html>

<head>
 <meta charset="utf-8" />
 <meta name="viewport" content="width=device-width, initial-scale=1" />
 <script type="text/javascript" src="/crown.js"></script>
</head>

<body>
 <noscript>JavaScript is required</noscript>
 <script type="text/javascript">
  async function main() {
   await loadCrownDependencies()
   await crown().run([%0])
  }
  main().catch(e => console.error(e))
 </script>
</body>

</html>' [
    at [ get JSON ] stringify, call [
     get valueEditor value
    ]
   ]
  ]
 ]
]

at [ get valueEditor ] addEventListener, call keyup [
 get renderPreview
]

at [ get build ]
do [ call [ get document body ] [ get surface ] ]
do [ call [ get surface ] [ get nodeList ] ]
do [ call [ get surface ] [ get valueEditor ] ]
do [ call [ get surface ] [ get previewFrame ] ]

object [
 setNodes [
  function nodes [
   set [ get nodeList ] innerHTML ''
   each [ get nodes ] [
    function node [
     set nodeLink [
      at [ get element ], call a
     ]
     set [ get nodeLink ] href [
      template %0/%1 [ get location hash ] [
       at [ get encode ], call [ get node ]
      ]
     ]
     set [ get nodeLink ] innerText [
      get node
     ]
     at [ get build ], call [ get nodeList ] [ get nodeLink ]
    ]
   ]
  ]
 ]
 setValue [
  function value [
   set [ get valueEditor ] value [ get value ]
   at [ get renderPreview ], call
  ]
 ]
]
