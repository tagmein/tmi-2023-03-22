set permissionStatusClass [
 set name permissionStatus
 set rules '
  & {
   background-color: #707070;
   border-radius: 8px;
   border: 1px solid #a0a0a0;
   box-shadow: 0 0 16px #00000049;
   color: #ffffff;
   display: flex;
   flex-direction: row;
   flex-grow: 0;
   flex-shrink: 0;
   max-width: calc(100% - 100px);
   overflow: hidden;
   width: 80%;
  }

  & > div {
   flex-grow: 1;
   padding: 8px 16px;
  }

  & h3 {
   font-size: 28px;
   padding: 0;
   margin: 0;
  }

  & label {
   font-size: 18px;
   padding: 0;
  }

  & button {
   background-color: transparent;
   border: none;
   border-left: 1px solid #a0a0a0;
   border-radius: 0;
   color: #ffffff;
   cursor: pointer;
   font-size: 18px;
   font-weight: bold;
   padding: 4px 24px;
  }

  & button:hover {
   background-color: #808080;
  }
 '
 get style, point
]

function insertPermissionRequestElement [
 function address operation [
  log permission check [ get address ] [ get operation ]
  # set permissionGateResponse [
  #  get tmiApi, call /permission/gate [
  #   object [
  #    address [ get address ]
  #    operation [ get operation ]
  #   ]
  #  ]
  # ]
  promise [
   function resolve reject [
    set permissionStatusElement [
     get element, call
    ]
    get permissionStatusElement classList add, call [
     get permissionStatusClass
    ]
    set permissionStatusMessage [ get element, call ]
    set permissionStatusHeader [ get element, call h3 ]
    set [ get permissionStatusHeader ] textContent 'Permission request'
    set permissionStatusText [ get element, call label ]
    set [ get permissionStatusText ] textContent [
     template '%0 is requesting %1' [
      get address
     ] [
      get operation
     ]
    ]
    set approveButton [ get element, call button ]
    set denyButton [ get element, call button ]
    set [ get approveButton ] textContent Approve
    set [ get denyButton ] textContent Deny
    get build
    do [ call [ get permissionStatusElement ] [
     get permissionStatusMessage
    ] ]
    do [ call [ get permissionStatusMessage ] [
     get permissionStatusHeader
    ] ]
    do [ call [ get permissionStatusMessage ] [
     get permissionStatusText
    ] ]
    do [ call [ get permissionStatusElement ] [
     get approveButton
    ] ]
    do [ call [ get permissionStatusElement ] [
     get denyButton
    ] ]
    get approveButton addEventListener, call click [
     function [
      get permissionStatusElement parentElement removeChild
      call [ get permissionStatusElement ]
      get resolve, call true
     ]
    ]
    get denyButton addEventListener, call click [
     function [
      get permissionStatusElement parentElement removeChild
      call [ get permissionStatusElement ]
      get resolve, call false
     ]
    ]
    get insertPermissionRequestElement, call [
     get permissionStatusElement
    ]
    log gate response is [ get permissionGateResponse ]
   ]
  ]
 ]
]
