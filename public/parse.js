const END = {
 name: 'end'
}

const STRING = {
 name: 'string',
 "'"(control) {
  control.statement.push(control.queue)
  control.queue = ''
  return INITIAL
 }
}

const INITIAL = {
 end(control) {
  control.queueToStatement()
  control.statementToBlock()
  return END
 },
 name: 'script',
 ' '(control) {
  control.queueToStatement()
 },
 '\n'(control) {
  control.queueToStatement()
  control.statementToBlock()
 },
 ','(control) {
  control.queueToStatement()
  control.statementToBlock()
 },
 "'"(control) {
  control.queueToStatement()
  return STRING
 },
 '['(control) {
  control.queueToStatement()
  control.block = []
  control.stack.push(control.block)
  control.statement.push(control.block)
  control.statementStack.push(control.statement)
  control.statement = []
 },
 ']'(control) {
  if (control.stack.length <= 1) {
   throw new Error('Unexpected ] character')
  }
  control.queueToStatement()
  control.statementToBlock()
  control.stack.pop()
  control.block = control.stack
  [control.stack.length - 1]
  control.statement = control.statementStack.pop()
 }
}

module.exports = function parse(source) {
 const top = []
 const control = {
  beginAtIndex: 0,
  block: top,
  queue: '',
  stack: [top],
  statement: [],
  statementStack: [],
  queueToStatement() {
   if (control.queue.length) {
    switch (control.queue) {
     case 'null':
      control.statement.push(null)
      break
     case 'undefined':
      control.statement.push(undefined)
      break
     case 'true':
      control.statement.push(true)
      break
     case 'false':
      control.statement.push(false)
      break
     default:
      if (String(parseFloat(control.queue)) === control.queue) {
       control.statement.push(
        parseFloat(control.queue)
       )
      }
      else {
       control.statement.push(control.queue)
      }
    }
    control.queue = ''
   }
  },
  statementToBlock() {
   if (control.statement.length) {
    control.block.push(control.statement)
    control.statement = []
   }
  }
 }
 let state = INITIAL
 for (const charIndex in source) {
  const char = source[charIndex]
  if (char in state) {
   try {
    const newState = state[char](control)
    if (newState) {
     state = newState
    }
   }
   catch (e) {
    e.message = e.message + ` (at ${charIndex}, '${source.substring(charIndex, charIndex + 20)}')`
    throw e
   }
   control.beginAtIndex = charIndex
  }
  else {
   control.queue += char
  }
 }
 if (control.queue.length > 0) {
  if (!('end' in state)) {
   throw new Error(
    `Unterminated ${state.name} at ${control.beginAtIndex}-${source.length}`
   )
  }
  state = state.end(control)
 }
 return top
}
