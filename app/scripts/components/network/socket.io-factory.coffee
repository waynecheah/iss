'use strict'

angular.module 'glApp'

.factory 'socket', ($rootScope, $timeout, $log) ->
    socket  = null
    servers = [
        '127.0.0.1:8080'
        'innerzon.com:8080'
        'innerzon.com.my:8080'
        'cheah.homeip.net:8080'
    ]
    curServerId = 0
    serverInUse = ''
    serverList  = if angular.isString servers then [servers] else servers
    maxAttempt  = 4 # attempt 5 times retry take about 10 seconds, 6 times retry take about 15 seconds
    curStatus   = 'dis'
    $rootScope.$on 'socket:changed', (e, status) ->
        curStatus = status
        return

    connect = ->
        serverInUse = serverList[curServerId]
        #return socket.socket.reconnect() if socket # socket has initialized

        if serverList.length is 1
            maxAttempt = 1000
            connLimit  = 60000
        else
            connLimit = 3000

        $log.debug "Socket.io is connecting to server [#{serverInUse}]"
        socket = io.connect "http://#{serverInUse}",
            'reconnection limit': connLimit # maximum seconds delay of each reconnection
            'max reconnection attempts': maxAttempt
            'try multiple transports': false
        initSocketHandler()
        return
    # END connect

    initSocketHandler = ->
        retryCount = 1
        onReconnectFailed = ->
            $log.debug "Reconnect to server [#{serverInUse}] failed after #{retryCount} times"
            $rootScope.$broadcast 'socket:changed', 'off', 'reconnect_failed'
            retryCount = 1
            if serverList.length is 1 then socket.socket.connect() else changeServer()
            return
        # END onReconnectFailed

        socket.on 'error', ->
            $log.error "Error on Socket.io at server [#{serverInUse}]
                        and it could not be handled by the other event types"
            $rootScope.$broadcast 'socket:changed', 'off', 'error'
            changeServer()
            return
        socket.on 'connect', ->
            $log.debug "Socket.io has make connection to server [#{serverInUse}] successfully!"
            $rootScope.$broadcast 'socket:changed', 'on', 'connected'
            return
        socket.on 'connect_failed', ->
            $log.warn "Socket.io fail to make connection to server [#{serverInUse}]"
            $rootScope.$broadcast 'socket:changed', 'off', 'connect_failed'
            changeServer()
            return
        socket.on 'connecting', ->
            $log.debug 'Socket.io fires connecting event'
            return
        socket.on 'disconnect', ->
            $log.debug "Socket.io is disconnected from server [#{serverInUse}]"
            $rootScope.$broadcast 'socket:changed', 'off', 'disconnect'
            retryCount = 1
            return
        socket.on 'reconnect', ->
            $log.debug 'Socket.io has reconnected back to server successfully!'
            $rootScope.$broadcast 'socket:changed', 'on', 'reconnected'
            return
        socket.on 'reconnect_failed', ->
            onReconnectFailed()
            return
        socket.on 'reconnecting', ->
            retryCount++
            return unless serverList.length > 1 and retryCount > maxAttempt # return if only 1 server in list
            # perform failover, manual fix for socket event [reconnect_failed] not trigger
            $timeout onReconnectFailed, 4500
            return

        return
    # END initSocketHandler
    
    changeServer = ->
        nextIndex = curServerId + 1

        #return debug 'Internet is down, socket is not able to do reconnect', 'warn' if not window.onLine
        return $log.debug 'There is no extra server to switch connection' if serverList.length is 1

        curServerId = if nextIndex > serverList.length then 0 else nextIndex
        connect()
        return
     # END changeServer

    connect() unless socket


    connect: ->
        socket.socket.reconnect() unless curStatus is 'on'
        return
    # END connect
    
    status: ->
        curStatus
    # END status

    on: (eventName, callback) ->
        socket.on eventName, ->
            args = arguments
            $rootScope.$apply ->
                callback.apply socket, args
    # END on

    emit: (eventName, data, callback) ->
        unless curStatus is 'on'
            $log.warn "Can not perform socket.emit [#{eventName}]. Socket connection is #{curStatus}"
            return
        socket.emit eventName, data, ->
            args = arguments
            $rootScope.$apply ->
                callback.apply socket, args  if callback
    # END emit
