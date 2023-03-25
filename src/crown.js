const fs = require('fs')
const path = require('path')

const parse = require('./parse')

const SCOPE = {
 PARENT: Symbol('SCOPE:PARENT')
}

function uncrown(value) {
 return typeof value === 'object' && ('current' in value)
  ? value.current()
  : value
}

module.exports = function crown(context = globalThis, names = new Map) {
 let currentValue = context
 let lastComment
 const me = {
  '//'(comment) {
   lastComment = comment
   return me
  },
  at(...path) {
   for (const segment of path) {
    if (typeof segment === 'string') {
     if (currentValue && (segment in currentValue)) {
      const nextValue = currentValue[segment]
      if (typeof nextValue === 'function') {
       currentValue = currentValue[segment]
        .bind(currentValue)
      }
      else {
       currentValue = currentValue[segment]
      }
     }
     else {
      currentValue = undefined
      break
     }
    }
    else {
     currentValue = uncrown(segment)
    }
   }
   return me
  },
  call(...argumentCrowns) {
   if (typeof currentValue !== 'function') {
    throw new Error(`Expecting value to be a function, but got: ${typeof currentValue}`)
   }
   currentValue = currentValue(
    ...argumentCrowns.map(uncrown)
   )
   return me
  },
  clone() {
   const newNames = new Map
   newNames.set(SCOPE.PARENT, names)
   return crown(currentValue, newNames)
  },
  comment() {
   return lastComment
  },
  current() {
   return currentValue
  },
  default(crownValue) {
   const value = uncrown(crownValue)
   if (currentValue === null || currentValue === undefined || isNaN(currentValue)) {
    currentValue = value
   }
   return me
  },
  'function'(...argumentNames) {
   const functionImplementation = argumentNames.pop()
   currentValue = function (...runtimeArguments) {
    const scopeCrown = me.clone()
    for (const index in argumentNames) {
     scopeCrown.set(
      argumentNames[index],
      runtimeArguments[index]
     )
    }
    scopeCrown.walk(functionImplementation)
    return scopeCrown
   }
   return me
  },
  get(name) {
   let searchScope = names
   while (searchScope.has(SCOPE.PARENT)) {
    if (searchScope.has(name)) {
     break
    }
    searchScope = searchScope.get(SCOPE.PARENT)
   }
   if (!searchScope.has(name)) {
    throw new Error(`name ${JSON.stringify(name)} is not set`)
   }
   currentValue = searchScope.get(name)
  },
  log(...values) {
   console.log(...values.map(uncrown))
  },
  run([source]) {
   return me.walk(parse(source))
  },
  runFile(source) {
   return me.run([
    fs.readFileSync(
     path.join(__dirname, source),
     'utf-8'
    )
   ])
  },
  runJsonFile(source) {
   return me.walk(
    crown()
     .at('require')
     .call(
      crown().value(source)
     )
   )
  },
  set(...path) {
   const value = path.pop()
   const name = path.pop()
   if (path.length) {
    const context = uncrown(me.at(...path))
    if (context === 'null') {
     throw new Error(`cannot set property "${name}" of null`)
    }
    if (typeof context !== 'object') {
     throw new Error(`cannot set property "${name}" of ${typeof context}`)
    }
    context[name] = uncrown(value)
   }
   else {
    names.set(name, uncrown(value))
   }
   return me
  },
  toString() {
   const currentValueString = Array.isArray(currentValue)
    ? `Array (${currentValue.length})`
    : String(currentValue)
   const currentValueDescription = currentValueString.length > 0
    ? currentValueString
    : currentValue?.constructor?.name
   return `crown with ${typeof currentValue}: ${currentValueDescription}`
  },
  value(newValue) {
   currentValue = newValue
   return me
  },
  walk(instructionsCrown) {
   const instructions = uncrown(instructionsCrown)
   if (!Array.isArray(instructions)) {
    throw new Error(`walk expects an Array, got: ${typeof instructions}`)
   }
   if (instructions.length === 0) {
    throw new Error('walk expects at least one instruction, 0 provided')
   }
   const wrappedInstructions = Array.isArray(instructions[0]) ? instructions : [instructions]
   for (const statementIndex in wrappedInstructions) {
    const statement = wrappedInstructions[statementIndex]
    if (!Array.isArray(statement)) {
     throw new Error(`walk[${statementIndex}] expects an Array, got: ${typeof statement}`)
    }
    const [command, ...arguments] = statement
    if (!(command in me)) {
     throw new Error(`walk[${statementIndex}]: "${command}" is not a valid operation`)
    }
    const automaticWalk = {
     function: false,
     with: false
    }[command] ?? true
    me[command](
     ...arguments.map(
      x => automaticWalk && Array.isArray(x)
       ? me.clone().walk(crown(x))
       : x
     )
    )
   }
   return me
  },
  with(...commands) {
   const statements = commands.pop()
   for (const statement of statements) {
    const [prefix, ...rest] = statement[0]
    const compound = [commands.concat(prefix)].concat(rest)
    me.walk(compound)
   }
   return me
  }
 }
 return me
}
