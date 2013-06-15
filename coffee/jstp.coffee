class Dispatch
  constructor: (options)->
    for key of options
      this[key] = options[key]

    @protocol = ["JSTP", "0.4"]  unless @protocol
    @timestamp = +new Date().getTime() unless @timestamp
    @token = JSTP.defaultToken unless @token
    @referer = [] unless @referer
    @body = {} unless @body

  toString: ->
    JSON.stringify this

  isGET: ->
    return @method.toLowerCase() == "get"

@JSTP = 
  defaultToken: []
  connections: {}
  bound: []
  reboundBuffer: {}

  bind: (pack, callback, context)->
    pack.method = "BIND"
    @dispatch pack, callback, context

  on: (pack, callback, context)->
    pack.method = "BIND"
    @dispatch pack, callback, context

  get: (pack)->
    pack.method = "GET"
    @dispatch pack, null, null

  post: (pack)->
    pack.method = "POST"
    @dispatch pack, null, null

  patch: (pack)->
    pack.method = "PATCH"
    @dispatch pack, null, null

  delete: (pack)->
    pack.method = "DELETE"
    @dispatch pack, null, null

  release: (pack, callback, context)->
    pack.method = "RELEASE"
    @dispatch pack, callback, context

  off: (pack, callback, context)->
    pack.method = "RELEASE"
    @dispatch pack, callback, context

  dispatch: (pack, callback, context)->
    pack        = new Dispatch pack

    if pack.method.toLowerCase() == "bind"
      @_bind pack, callback, context

    if pack.host and pack.host.length > 0
      @_sendOrConnect pack, callback, context
    else
      @trigger pack

  _sendOrConnect: (pack, callback, context)->
    pack = new Dispatch pack unless (pack.toString)
    host = pack.host[0]
    pack.host.splice 0, 1
    packString = pack.toString()

    if @open host
      @send host, packString
    else
      console.log "Opening socket to #{host.join(':')}"
      @connect host, ->
        JSTP.send host, packString
        packString = null
        pack = null

  _bind: (pack, callback, context)->
    callbackObj = 
      endpoint: pack.endpoint
      callback: callback
      context: context
      host: pack.host[0]

    @bound.push callbackObj

  _rebind: (hostString, doIt)->
    if doIt
      current = []
      for hook in @reboundBuffer[hostString]
        current.push hook

      for hook in current
        pack = new Dispatch
          method: "BIND"
          endpoint: hook.endpoint
          host: [hook.host]

        @_sendOrConnect pack, hook.callback, hook.context

    else
      console.log "Will rebind #{@reboundBuffer[hostString].length} endpoints in 3 seconds"
      setTimeout ->
        JSTP._rebind hostString, true
      , 3000

  send: (host, string) ->
    socket = @_get host
    socket.send string
    console.log "%c Sent: " + string, "color: #0055FF"

  _get: (host) ->
    host = [host, 80] unless host instanceof Array
    hostString = host[0] + ":" + host[1]
    @connections[hostString]

  trigger: (pack)->
    method = pack.method.toLowerCase()
    for hooked in @bound
      switch method
        when 'bind', 'release'
          if @_compare hooked.endpoint, method, pack.endpoint.resource
            hooked.callback.call hooked.context, pack
        when 'get', 'post', 'put', 'delete', 'patch'
          if @_compare hooked.endpoint, method, pack.resource
            hooked.callback.call hooked.context, pack

  _compare: (endpoint, method, resource, strict)->
    method = method.toLowerCase()
    endpointMethod = endpoint.method.toLowerCase()
    if strict
      if method is endpointMethod and resource.length is endpoint.resource.length
        for el of endpoint.resource
          return false  unless endpoint.resource[el] is resource[el]
        return true
    else
      if (method is endpointMethod or endpointMethod is "*") and (resource.length is endpoint.resource.length)
        for el of endpoint.resource
          return false  if endpoint.resource[el] isnt "*" and endpoint.resource[el] isnt resource[el]
        return true
    false

  open: (host) ->
    host = [host, 80] unless host instanceof Array
    hostString = host[0] + ":" + host[1]
    @connections[hostString] and @connections[hostString].readyState == 1

  connect: (host, callback) ->
    host = [host, 80] unless host instanceof Array
    hostString = host[0] + ":" + host[1]

    if @connections[hostString] and not @connections[hostString].shuttedDown
      if @connections[hostString].callbacks.indexOf(callback) == -1
        console.log "Adding the callback since this is already connecting"
        @connections[hostString].callbacks.push callback
      else
        console.warn "The callback was already hooked for onopen"

    else
      @connections[hostString] = new WebSocket 'ws://' + hostString + '/'
      @connections[hostString].parent = this
      @connections[hostString].host = host
      @connections[hostString].hostString = hostString
      @reboundBuffer[hostString] = []
      @connections[hostString].callbacks = [callback]

      @connections[hostString].onopen = ->
        for toCall in @callbacks
          toCall()
        @callbacks = []

      @connections[hostString].onmessage = (event)->
        console.log "%c Received: " + event.data, "color: #FF5500"
        @parent.dispatch JSON.parse event.data

      @connections[hostString].onclose = ->
        for hooked in @parent.bound
          if hooked.host == @host
            @parent.reboundBuffer[@hostString].push hooked
        console.log "Rebinding to #{@host.join(':')}" if @parent.reboundBuffer[@hostString].length > 0
        @parent._rebind hostString 
        @shuttedDown = true