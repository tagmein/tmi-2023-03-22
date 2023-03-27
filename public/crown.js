const globalBasePath = typeof __dirname === 'string'
 ? __dirname
 : location.pathname.replace(/\/$/, '')

let fs, path, parse

if (typeof require !== 'function') {
 globalThis.loadCrownDependencies = async function () {
  const [_fs, _path] = await Promise.all(['fs', 'path'].map(globalThis.require))
  const [_parse] = await Promise.all([globalBasePath + '/parse.js'].map(globalThis.require))
  fs = _fs
  path = _path
  parse = _parse
 }
 globalThis.browserModules = {}
 const browserModuleDefinitions = {
  fs() {
   return {
    async readFile(filePath, encoding, callback) { // encoding is ignored in browser
     try {
      const fileResponse = await fetch(filePath)
      const fileContents = await fileResponse.text()
      callback(undefined, fileContents)
     }
     catch (error) {
      callback(error)
     }
    }
   }
  },
  path() {
   return {
    dirname(filePath) {
     const segments = filePath.split('/')
     segments.pop()
     return segments.join('/')
    },
    join(...segments) {
     return segments.join('/')
    }
   }
  }
 }

 globalThis.require = async function (requirePath) {
  if (requirePath in browserModuleDefinitions) {
   if (!(requirePath in globalThis.browserModules)) {
    globalThis.browserModules[requirePath] = browserModuleDefinitions[requirePath]()
   }
  }
  else if (!(requirePath in globalThis.browserModules)) {
   await new Promise(function (resolve, reject) {
    browserModules.fs.readFile(requirePath, 'utf-8', function (error, contents) {
     if (error) {
      reject(error)
     }
     else {
      const scriptElement = document.createElement('script')
      scriptElement.innerHTML = `const module = {}\n${contents}\nglobalThis.browserModules[${JSON.stringify(requirePath)
       }] = module.exports`
      document.head.appendChild(scriptElement)
      resolve()
     }
    })
   })
  }
  return globalThis.browserModules[requirePath]
 }
}

const SCOPE = {
 PARENT: Symbol('SCOPE:PARENT')
}

function uncrown(value) {
 return typeof value === 'object' && value !== null && ('current' in value)
  ? value.current()
  : value
}

function crown(context = globalThis, names = new Map, basePath = globalBasePath) {
 let currentValue = context
 let lastComment
 const me = {
  '#'(comment) {
   lastComment = comment
   return me
  },
  add(...argumentCrowns) {
   currentValue = argumentCrowns.reduce((sum, x) => sum + uncrown(x), 0)
  },
  at(...path) {
   let isFirstSegment = true
   for (const segment of path) {
    if (typeof segment === 'string') {
     if (currentValue === undefined || currentValue === null) {
      throw new Error(`cannot read '${segment}' of ${currentValue}`)
     }
     const test = typeof currentValue === 'object'
      ? currentValue
      : Object.getPrototypeOf(currentValue)
     if (segment in test) {
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
  async false(instructionCrown) {
   if (!currentValue) {
    await me.clone()
     .walk(uncrown(instructionCrown))
   }
  },
  function(...argumentNames) {
   const functionImplementation = argumentNames.pop()
   currentValue = async function (...runtimeArguments) {
    const scopeCrown = me.clone()
    for (const index in argumentNames) {
     scopeCrown.set(
      argumentNames[index],
      runtimeArguments[index]
     )
    }
    await scopeCrown.walk(functionImplementation)
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
    currentValue = undefined
    return
    // todo add required flag?
    // throw new Error(`name ${JSON.stringify(name)} is not set`)
   }
   currentValue = searchScope.get(name)
   return me
  },
  async load(filePath) {
   await new Promise(function (resolve, reject) {
    fs.readFile(
     path.join(basePath, filePath),
     'utf-8',
     function (error, content) {
      if (error) { reject(error) }
      else {
       const code = parse(content)
       const fileModule = eval(`(
        function () {
         return async function ${filePath.replace(/[^a-zA-Z]+/g, '_')
        } (scope) {
         await scope.walk(${JSON.stringify(code)})
         return scope
        }})()`)
       currentValue = fileModule
       resolve()
      }
     }
    )
   })
   return me
  },
  log(...values) {
   console.log(...values.map(uncrown))
  },
  async object(definition) {
   currentValue = {}
   for (const [[[k, v]]] of definition) {
    const scope = me.clone()
    currentValue[k] = Array.isArray(v)
     ? (await scope.walk(v)).current()
     : v
   }
   return me
  },
  async point() {
   if (typeof currentValue !== 'function') {
    throw new Error(`current value must be function, got ${typeof currentValue}`)
   }
   currentValue = await currentValue(me.clone())
   return me
  },
  async run([source]) {
   return me.walk(parse(source))
  },
  async runFile(source) {
   const filePath = basePath.length > 0
    ? path.join(basePath, source)
    : source
   basePath = path.dirname(filePath)
   return new Promise(function (resolve, reject) {
    fs.readFile(
     filePath,
     'utf-8',
     function (error, contents) {
      if (error) {
       reject(error)
       return
      }
      else {
       resolve(me.run([contents]))
      }
     }
    )
   })
  },
  async runJsonFile(source) {
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
  async true(instructionCrown) {
   if (currentValue) {
    await me.clone()
     .walk(uncrown(instructionCrown))
   }
  },
  value(newValue) {
   currentValue = newValue
   return me
  },
  async walk(instructionsCrown) {
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
    await me[command](
     ...(await Promise.all(arguments.map(
      x => automaticWalk && Array.isArray(x)
       ? me.clone().walk(crown(x))
       : x
     ))
     )
    )
   }
   return me
  },
  async with(...commands) {
   const statements = commands.pop()
   for (const statement of statements) {
    const [prefix, ...rest] = statement[0]
    const compound = [commands.concat(prefix)].concat(rest)
    await me.walk(compound)
   }
   return me
  }
 }
 return me
}

if (typeof module === 'object') {
 const [_fs, _path] = ['fs', 'path'].map(require)
 const [_parse] = [globalBasePath + '/parse.js'].map(require)
 fs = _fs
 path = _path
 parse = _parse
 module.exports = crown
}
