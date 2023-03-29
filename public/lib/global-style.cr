at [ get document ] body classList add, call [
 set name body
 set rules '
  & {
   background-color: #c9c9c9;
   color: #202020;
  }
  
  body, input, select, textarea, button {
   font-family: Seravek, "Gill Sans Nova", Ubuntu, Calibri, "DejaVu Sans", source-sans-pro, sans-serif;
   font-size: 18px;
  }

  a {
   color: inherit;
   text-decoration: none;
  }

  :focus {
   outline: none;
   box-shadow: inset 0 0 0 2px #797979;
  }

  *::selection {
   background-color: #202020;
   color: #ffffff;
  }
 '
 get style, point
]
