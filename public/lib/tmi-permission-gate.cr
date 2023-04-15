set permissionStatusClass [
 set name permissionStatus
 set rules '
  & {
   background-color: #707070;
   border-top: 1px solid #a0a0a0;
   color: #ffffff;
   display: flex;
   flex-direction: row;
   flex-grow: 0;
   flex-shrink: 0;
   overflow: hidden;
  }

  & label {
   flex-grow: 1;
   font-size: 18px;
   line-height: 2;
   padding: 4px 8px;
  }

  & button {
   background-color: transparent;
   border-radius: 0;
   border: none;
   border-left: 1px solid #a0a0a0;
   color: #ffffff;
   cursor: pointer;
   font-size: 18px;
   padding: 4px 12px;
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
