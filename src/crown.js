const [fs, parse, path] = [
 'fs', './parse', 'path'
].map(globalThis.require)

const SCOPE = {
 PARENT: Symbol('SCOPE:PARENT')
}

function uncrown(value) {
 return typeof value === 'object' && value !== null && ('current' in value)
  ? value.current()
  : value
}

module.exports = function crown(context = globalThis, names = new Map, basePath = __dirname) {
 let currentValue = context
 let lastComment
 const me = {
  '#'(comment) {
   lastComment = comment
   return me
  },
  at(...path) {
   let isFirstSegment = true
   for (const segment of path) {
    if (typeof segment === 'string') {
     const test = typeof currentValue === 'object'
      ? currentValue
      : Object.getPrototypeOf(currentValue)
     if (currentValue !== undefined && currentValue !== null && (segment in test)) {
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
     const candidate = uncrown(segment)
     if (isFirstSegment) {
      currentValue = candidate
     }
     else {
      if (currentValue && (candidate in currentValue)) {
       const nextValue = currentValue[candidate]
       if (typeof nextValue === 'function') {
        currentValue = currentValue[candidate]
         .bind(currentValue)
       }
       else {
        currentValue = currentValue[candidate]
       }
      }
      else {
       currentValue = undefined
       break
      }
     }
    }
    isFirstSegment = false
   }
   return me
  },
  call(...argumentCrowns) {
   if (typeof currentValue !== 'function') {
    throw new Error(`Expecting value to be a function, but got: ${typeof currentValue}`)
   }
   currentValue = currentValue(
    ...argumentCrowns.map(
     x => x === me ? x : uncrown(x)
    )
   )
   return me
  },
  clone() {
   const newNames = new Map
   newNames.set(SCOPE.PARENT, names)
   return crown(currentValue, newNames, basePath)
  },
  comment() {
   return lastComment
  },
  current() {
   return currentValue
  },
  default(crownValue) {
   const value = uncrown(crownValue)
   if (currentValue === null || currentValue === undefined || (
    typeof currentValue === 'number'
    && isNaN(currentValue)
   )) {
    currentValue = value
   }
   return me
  },
  false(instructionCrown) {
   if (!currentValue) {
    me.clone()
     .walk(uncrown(instructionCrown))
   }
  },
  function(...argumentNames) {
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
  load(filePath) {
   const code = parse(fs.readFileSync(
    path.join(basePath, filePath),
    'utf-8'
   ))
   const fileModule = eval(`(
    function () {
     return function ${filePath.replace(/[^a-zA-Z]+/g, '_')
    } (scope) {
     scope.walk(${JSON.stringify(code)})
    }})()`)
   currentValue = fileModule
   return me
  },
  log(...values) {
   console.log(...values.map(uncrown))
  },
  object(definition) {
   currentValue = {}
   for (const [[[k, v]]] of definition) {
    const scope = me.clone()
    currentValue[k] = Array.isArray(v)
     ? scope.walk(v).current()
     : v
   }
   return me
  },
  point() {
   if (typeof currentValue !== 'function') {
    throw new Error(`current value must be function, got ${typeof currentValue}`)
   }
   currentValue(me.clone())
  },
  run([source]) {
   return me.walk(parse(source))
  },
  runFile(source) {
   const filePath = path.join(__dirname, source)
   basePath = path.dirname(filePath)
   return me.run([
    fs.readFileSync(
     filePath,
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
  template(template, ...parameterCrowns) {
   const parameters = parameterCrowns.map(uncrown)
   currentValue = template.replace(
    /%(\d+)/g,
    function (_, index) {
     return parameters[parseInt(index, 10)]
    }
   )
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
  true(instructionCrown) {
   if (currentValue) {
    me.clone()
     .walk(uncrown(instructionCrown))
   }
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
    return me
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
     false: false,
     function: false,
     object: false,
     true: false,
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
