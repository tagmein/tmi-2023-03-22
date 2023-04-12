set toolbar [
 at [ get element ], call
]

at [ get toolbar ] classList add, call [
 set name toolbar
 set rules '
  & {
   background-color: #595959;
   box-shadow: 0 0 20px #00000045;
   border-bottom: 1px solid #676767;
   color: #dfdfdf;
   display: flex;
   flex-direction: row;
   flex-shrink: 0;
   font-weight: bold;
   height: 60px;
   line-height: 44px;
   overflow-x: auto;
   overflow-y: hidden;
   width: 100%;
   z-index: 1;
  }

  & > div {
   border-right: 1px solid #676767;
  }

  & > a {
   font-size: 18px;
   height: 30px;
   line-height: 1.8;
   padding: 15px;
  }
 '
 get style, point
]

set channelSelect [
 at [ get element ], call
]

at [ get channelSelect ] classList add, call [
 set name channelSelect
 set rules '
  & {
   max-width: 100%;
   min-width: 60px;
   position: relative;
  }
 '
 get style, point
]

set channelSelectLabel [
 at [ get element ], call
]

at [ get channelSelectLabel ] classList add, call [
 set name channelSelectLabel
 set rules '
  & {
   padding: 10px 15px;
  }
 '
 get style, point
]

set channelSelectHidden [
 at [ get element ], call select
]

at [ get channelSelectHidden ] classList add, call [
 set name channelSelectHidden
 set rules '
  & {
   cursor: pointer;
   height: 100%;
   left: 0;
   opacity: 0;
   position: absolute;
   top: 0;
   width: 100%;
  }
 '
 get style, point
]

set updateBodyShowEditor [
 function showEditor [
  get showEditor
  true [
   at [ get body ] classList add, call show-editor
  ]
  false [
   at [ get body ] classList remove, call show-editor
  ]
 ]
]

set initialShowEditor [
 at [ get localStorage ] getItem, call showEditor, is 'true'
]

at [ get updateBodyShowEditor ], call [ get initialShowEditor ]

set editorToggle [
 # todo: set basePath correctly for modules loaded in browser
 load ./lib/components/toggle.cr, point, call 'Show editor' [
  function editorEnabled [
   at [ get localStorage ] setItem, call showEditor [
    at [ get editorEnabled ] toString, call
   ]
   at [ get updateBodyShowEditor ], call [ get editorEnabled ]
  ]
 ] [ get initialShowEditor ]
]

set spacer [
 at [ get element, call ]
]

at [ get spacer ] classList add, call [
 set name spacer
 set rules '
  & {
   flex-grow: 1;
  }
 '
 get style, point
]

set accountLink [
 load ./lib/components/account-link.cr, point
]

at [ get build ]
do [ call [ get toolbar ]       [ get channelSelect ] ]
do [ call [ get toolbar ]       [ get editorToggle ] ]
do [ call [ get toolbar ]       [ get spacer ] ]
do [ call [ get toolbar ]       [ get accountLink container ] ]
do [ call [ get channelSelect ] [ get channelSelectLabel ] ]
do [ call [ get channelSelect ] [ get channelSelectHidden ] ]
do [ call [ get document body ] [ get toolbar ] ]

at [ get channelSelectHidden ] addEventListener, call change [
 function [
  at [ get switchChannel ], call [
   get channelSelectHidden value
  ] [
   get channelSelectHidden selectedOptions 0 getAttribute
   call data-has-current, is yes
  ]
 ]
]

object [
 refreshAccountLink [ get accountLink refresh ]
 setChannels [
  function channels selectedChannel [
   set [ get channelSelectHidden ] innerHTML ''
   get channels, group [ at owner ], entries [
    function groupName channelsInGroup [
     set groupElement [
      at [ get element ], call optgroup
     ]
     get groupElement setAttribute, call label [
      get groupName
     ]
     get build
     call [ get channelSelectHidden ] [ get groupElement ]
     get channelsInGroup, each [
      function channel [
       set option [ get element, call option ]
       set [ get option ] value [ get channel key ]
       get selectedChannel, is [ get option value ], true [
        get option setAttribute, call selected selected
        set [ get channelSelectLabel ] textContent [ get channel name ]
       ]
       get channel hasCurrent, true [
        set [ get option ] textContent [
         template '%0 ✓' [ get channel name ]
        ]
        get option setAttribute, call data-has-current yes
       ], false [
        set [ get option ] textContent [
         get channel name
        ]
        get option setAttribute, call data-has-current no
       ]
       get build
       call [ get groupElement ] [ get option ]
      ]
     ]
    ]
   ]
  ]
 ]
]
