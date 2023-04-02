at [ get document ] body classList add, call [
 set name body
 set rules '
  & {
   background-color: #454545;
   display: flex;
   flex-direction: column;
   height: 100%;
   margin: 0;
  }

  html {
    height: 100vh;
  }
  
  body, input, select, textarea, button {
   color: #b0b0b0;
   font-family: Seravek, "Gill Sans Nova", Ubuntu, Calibri, "DejaVu Sans", source-sans-pro, sans-serif;
   font-size: 24px;
   line-height: 1.8;
  }

  a {
   color: inherit;
   text-decoration: none;
  }

  *:focus {
   box-shadow: inset 0 0 0 4px #797979;
   outline: none;
  }

  *::selection {
   background-color: #202020;
   color: #ffffff;
  }
 '
 get style, point
]

at [ get document ] body removeAttribute, call style
