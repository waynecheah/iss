'use strict'

angular.module 'glApp'

.factory 'internetStatus', ($http, $log) ->
    attempt  = 0
    urls     = ['https://api.github.com/users/waynecheah/orgs']
    callback = ->
        return
    fetch    = ->
        url = urls[attempt]
        ttl = urls.length

        $http.get url
        .success ->
            $log.debug "Successfully connect to #{url}. Internet is available."
            callback true
        .error ->
            attempt++
            $log.warn "#{attempt} attempt. Fail connect to #{url}"
            if ttl > attempt
                fetch()
            else
                $log.warn "Fail connect to all urls. Internet is unavailable."
                callback false
        return

    check: (cb) ->
        callback = cb
        $log.debug 'Start checking internet connection status..'
        fetch()
        return
# END internetStatus