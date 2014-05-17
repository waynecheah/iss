'use strict'

angular.module 'glApp'

.factory 'internetStatus', ($rootScope, $http, $log) ->
    attempt   = 0
    urls      = ['https://api.github.com/users/waynecheah/orgs']
    curStatus = 'dis'

    fetch = ->
        url = urls[attempt]
        ttl = urls.length

        $http.get url
        .success ->
            $log.debug "Successfully connect to #{url}. Internet is available."
            $rootScope.$broadcast 'internet:changed', 'on'
            attempt   = 0
            curStatus = 'on'
        .error ->
            attempt++
            $log.warn "#{attempt} attempt. Fail connect to #{url}"
            if ttl > attempt
                curStatus = 'retry'
                fetch()
            else
                $log.warn "Fail connect to all urls. Internet is unavailable."
                $rootScope.$broadcast 'internet:changed', 'off'
                attempt   = 0
                curStatus = 'off'

        return
    # END fetch


    status: ->
        curStatus
    # END status

    check: ->
        $log.debug 'Start checking internet connection status..'
        fetch()
        return
    # END check
# END internetStatus
