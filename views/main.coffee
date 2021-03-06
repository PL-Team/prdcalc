main = ()->
  if menu_compilar.className is ""
    source = OUTPUT.value
    try
      result = JSON.stringify(parse(source), null, 2)
    catch _error
      result = _error
      result = "+++++++ ERROR: " + result + "+++++"
    OUTPUT.value = result

window.onload = ()->
  menu_compilar.onclick = main

Object.constructor::error = (message, t) ->
  t = t or this
  t.name = "SyntaxError"
  t.message = message
  throw treturn

RegExp::bexec = (str) ->
  i = @lastIndex
  m = @exec(str)
  return m  if m and m.index is i
  null

String::tokens = ->
  from = undefined # The index of the start of the token.
  i = 0 # The index of the current character.
  n = undefined # The number value.
  m = undefined # Matching
  result = [] # An array to hold the results.
  tokens =
    ADDSUB : /[+-]/g
    COMPARISONOPERATOR: /[<>=!]=|[<>]/g
    ID: /[a-zA-Z_]\w*/g
    MULTIPLELINECOMMENT: /\/[*](.|\n)*?[*]\//g
    MULTDIV : /[*\/]/g
    NUM: /\b\d+(\.\d*)?([eE][+-]?\d+)?\b/g
    ONECHAROPERATORS: /([-+*\/=()&|;:,{}[\]])/g
    ONELINECOMMENT: /\/\/.*/g
    STRING: /('(\\.|[^'])*'|"(\\.|[^"])*")/g
    WHITES: /\s+/g

  RESERVED_WORD = 
    p:    "P"
    "if": "IF"
    then: "THEN"
    "begin": "BEGIN"
    "end": "END"
    "while": "WHILE"
    "do": "DO"
    "call": "CALL"
    "odd": "ODD"
    "const": "CONST"
    "var": "VAR"
    "procedure": "PROCEDURE"
  
  # Make a token object.
  make = (type, value) ->
    type: type
    value: value
    from: from
    to: i

  getTok = ->
    str = m[0]
    i += str.length # Warning! side effect on i
    str

  
  # Begin tokenization. If the source string is empty, return nothing.
  return  unless this
  
  # Loop through this text
  while i < @length
    for key, value of tokens
      value.lastIndex = i

    from = i
    
    # Ignore whitespace and comments
    if m = tokens.WHITES.bexec(this) or 
           (m = tokens.ONELINECOMMENT.bexec(this)) or 
           (m = tokens.MULTIPLELINECOMMENT.bexec(this))
      getTok()
    
    # name.
    else if m = tokens.ID.bexec(this)
      rw = RESERVED_WORD[m[0]]
      if rw
        result.push make(rw, getTok())
      else
        result.push make("ID", getTok())
    
    # number.
    else if m = tokens.NUM.bexec(this)
      n = +getTok()
      if isFinite(n)
        result.push make("NUM", n)
      else
        make("NUM", m[0]).error "Bad number"
    
    # string
    else if m = tokens.STRING.bexec(this)
      result.push make("STRING", 
                        getTok().replace(/^["']|["']$/g, ""))
    # add
    else if m = tokens.ADDSUB.bexec(this)
      result.push make("ADDSUB", getTok())
    
    # mult
    else if m = tokens.MULTDIV.bexec(this)
      result.push make("MULTDIV", getTok())
    # comparison operator
    else if m = tokens.COMPARISONOPERATOR.bexec(this)
      result.push make("COMPARISON", getTok())
    # single-character operator
    else if m = tokens.ONECHAROPERATORS.bexec(this)
      result.push make(m[0], getTok())
    else
      throw "Syntax error near '#{@substr(i)}'"
  result

parse = (input) ->
  tokens = input.tokens()
  lookahead = tokens.shift()
  match = (t) ->
    if lookahead.type is t
      lookahead = tokens.shift()
      lookahead = null  if typeof lookahead is "undefined"
    else # Error. Throw exception
      throw "Syntax Error. Expected #{t} found '" + 
            lookahead.value + "' near '" + 
            input.substr(lookahead.from) + "'"
    return

  statements = ->
    result = [statement()]
    while lookahead and lookahead.type is ";"
      match ";"
      result.push statement()
    (if result.length is 1 then result[0] else result)

  blocks = ->
    result = [block()]
    while lookahead and lookahead.type is ";"
      match ";"
      result.push block()
    (if result.length is 1 then result[0] else result)

  block =->
    if lookahead and lookahead.type is "CONST"
        match "CONST"
        result = [constant()]
        while lookahead and lookahead.type is ","
            match ","
            result.push constant()
            
    else if lookahead and lookahead.type is "VAR"
        match "VAR"
        result = [variable()]
        while lookahead and lookahead.type is ","
            match ","
            result.push variable()
    else if lookahead and lookahead.type is "PROCEDURE"
        match "PROCEDURE"
        left =
          type: "ID"
          value: lookahead.value
        match "ID"
        right = blocks()
        result =
          type: "PROCEDURE"
          left: left
          right: right
        result
    else if lookahead and lookahead.type is "BEGIN"
        match "BEGIN"
        value = statements()
        match "END"
        result =
          type: "BEGIN"
          value: value
    else
       result = statements()
    (if result.length is 1 then result[0] else result)
    
  variable= ->
    result =
      type: "VAR"
      value: lookahead.value
    match "ID"
    result
	
  constant= ->
    left =
      type: "ID"
      value: lookahead.value
    match "ID"
    match "="
    right =
      type: "NUM"
      value: lookahead.value
    match "NUM"
    result =
      type: "CONST"
      left: left
      right: right
    result
	
  statement = ->
    result = null
    if lookahead and lookahead.type is "ID"
      left =
        type: "ID"
        value: lookahead.value
      match "ID"
      match "="
      right = expression()
      result =
        type: "="
        left: left
        right: right
    else if lookahead and lookahead.type is "P"
      match "P"
      right = expression()
      result =
        type: "P"
        value: right
    else if lookahead and lookahead.type is "CALL"
      match "CALL"
      right =
        type: "function"
        value: lookahead.value
      match "ID"
      result =
        type: "CALL"
        value: right
    else if lookahead and lookahead.type is "IF"
      match "IF"
      left = condition()
      match "THEN"
      right = statements()
      result =
        type: "IF"
        left: left
        right: right
    else if lookahead and lookahead.type is "WHILE"
      match "WHILE"
      left = condition()
      match "DO"
      match "BEGIN"
      right = statement()
      match "END"
      result =
        type: "WHILE"
        left: left
        right: right
    else # Error!
      throw "Syntax Error. Expected identifier but found " + 
        (if lookahead then lookahead.value else "end of input") + 
        " near '#{input.substr(lookahead.from)}'"
    result

  condition = ->
    result = null
    if lookahead and lookahead.type is "ODD"
      match "ODD"
      right = expression()
      result =
        type: "ODD"
        value: right
    else
      left = expression()
      type = lookahead.value
      match "COMPARISON"
      right = expression()
      result =
        type: type
        left: left
        right: right
    result
    
  expression = ->
    result = term()
    while lookahead and lookahead.type is "ADDSUB"
      type = lookahead.value
      match "ADDSUB"
      right = term()
      result =
        type: type
        left: result
        right: right
    result

  term = ->
    result = factor()
    while lookahead and lookahead.type is "MULTDIV"
      type = lookahead.value
      match "MULTDIV"
      right = factor()
      result =
        type: type
        left: result
        right: right
    result

  factor = ->
    result = null
    if lookahead.type is "NUM"
      result =
        type: "NUM"
        value: lookahead.value

      match "NUM"
    else if lookahead.type is "ID"
      result =
        type: "ID"
        value: lookahead.value

      match "ID"
    else if lookahead.type is "("
      match "("
      result = expression()
      match ")"
    else # Throw exception
      throw "Syntax Error. Expected number or identifier or '(' but found " + 
        (if lookahead then lookahead.value else "end of input") + 
        " near '" + input.substr(lookahead.from) + "'"
    result

  tree = blocks(input)
  if lookahead?
    throw "Syntax Error parsing statements. " + 
      "Expected 'end of input' and found '" + 
      input.substr(lookahead.from) + "'"  
  tree
