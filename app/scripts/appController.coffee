'use strict'

glApp

.controller 'AppCtrl', ($scope, $rootScope, $route, $timeout) ->
    history   = []
    oneFxCtrl = ''
    getIndex  = (route) ->
        return false if route.indexOf('_') < 1
        a = route.split '_'
        parseFloat a[0]
    # END getIndex

    isSingleFx = (current_route, previous_route) ->
        str1 = current_route.substr -2
        str2 = previous_route.substr -2
        return 1 if str1 is '.s'
        return 2 if str2 is '.s'
        false
    # END isSingleFx

    $rootScope.pageFx = (ctrl, fx='slide') ->
        console.log 'goto controller:', ctrl, fx
        if oneFxCtrl
            cls = if fx.substr(0, 4) is 'one-' then fx else "one-#{fx}"
            fx  = if ctrl is oneFxCtrl then cls else fx
        else
            fx
        console.log 'use fx:', fx
        fx

    $rootScope.$on '$routeChangeSuccess', (e, current, previous) ->
        current   = angular.fromJson current
        previous  = angular.fromJson previous
        prevRoute = if history.length > 0 then history[history.length - 1] else '-'

        if current and 'loadedTemplateUrl' of current and previous and 'loadedTemplateUrl' of previous
            curr_url = current.loadedTemplateUrl
            prev_url = previous.loadedTemplateUrl
            console.log 'current: '+ curr_url
            console.log 'previous: '+ prev_url
            console.log 'history: '+ prevRoute

            current_id  = getIndex curr_url
            previous_id = getIndex prev_url
            singleFx    = isSingleFx curr_url, prev_url

            if singleFx
                $scope.singleFx = 'singleFx'
                console.info 'this page change use single fx'
                curr_ctrl = current.$$route.controller
                prev_ctrl = previous.$$route.controller
                oneFxCtrl = if singleFx is 1 then curr_ctrl else prev_ctrl # Only slide this ctrl
                console.info 'Only slide this ctrl', oneFxCtrl
            else
                $scope.singleFx = ''
                oneFxCtrl       = ''

            if current_id < previous_id
                console.warn 'Current index is smaller! Page uses reverse fx'
                $scope.backFxClass = 'back'
                $timeout ->
                    $scope.backFxClass = ''
                    return
                , 500
            if prevRoute is curr_url
                history.pop()
                console.info 'history list: ', history
            else
                history.push prev_url
                console.info 'history list: ', history
        return

    return

.controller 'MenuCtrl', ($scope, $rootScope) ->
    $scope.pageFxClass = $rootScope.pageFx 'MenuCtrl', 'one-slide'
    $scope.items = [
        name: 'Wave'
        href: '#/alarm'
    ,
        name: 'Profile'
        href: ''
    ,
        name: 'Settings'
        href: ''
    ,
        name: 'Add Device'
        href: ''
    ,
        name: 'Logout'
        href: '#/signin'
    ]
    return

.controller 'MainCtrl', ($scope, $rootScope, $location) ->
    $scope.pageFxClass = $rootScope.pageFx 'MainCtrl'
    $scope.title       = 'Alarm Dashboard'
    $scope.leftIco     = 'icon-MainMenu'
    $scope.rightIco    = 'icon-Location'
    $scope.icon        = 'icon-IZ'
    $scope.onLeftIcon  = ->
        console.info 'Main menu on click'
        $location.path '/'
        return

    $scope.zones = 5
    $scope.items = [
        leftIco: 'icon-Locked'
        name: 'Security'
        description: "#{$scope.zones} zones detected"
        status: 'Disarmed'
        href: '#/alarm/zones'
    ,
        leftIco: 'icon-Health'
        name: 'System Health'
        status: ['5 OK', '2 Fails']
        href: '#/alarm/system'
    ,
        leftIco: 'icon-AlarmClock'
        name: 'Alarm'
        status: 'OK'
        href: '#/alarm/emergency'
    ,
        leftIco: 'icon-Clock'
        name: 'Event Logs'
        status: '9 new'
        href: '#/alarm/logs'
    ]
    
    $scope.updateZones = ->
        total = $scope.zones
        $scope.items[0].description = "#{total} zones detected"
        return
    return
        
.controller 'AlarmCtrl', ($scope, $rootScope, $window) ->
    $scope.pageFxClass = $rootScope.pageFx 'AlarmCtrl'
    $scope.title       = 'Home Alarm'
    $scope.leftIco     = 'icon-Back'
    $scope.icon        = 'icon-AlarmClock'
    $scope.onLeftIcon  = ->
        console.info 'back button on click'
        $window.history.back()
        return

    $scope.items = [
        leftIco: 'icon-Zone8'
        name: 'Zone 1'
        status: 'Ready'
    ,
        leftIco: 'icon-Zone8'
        name: 'Zone 2'
        status: 'Alarm'
    ,
        leftIco: 'icon-Zone8'
        name: 'Zone 3'
        status: 'ByPass'
    ,
        leftIco: 'icon-Zone8'
        name: 'Zone 4'
        status: 'Alarm'
    ,
        leftIco: 'icon-Zone8'
        name: 'Zone 5'
        status: 'ByPass'
    ]
    return

.controller 'SystemCtrl', ($scope, $rootScope, $window) ->
        $scope.pageFxClass = $rootScope.pageFx 'SystemCtrl'
        $scope.title       = 'Home Alarm'
        $scope.leftIco     = 'icon-Back'
        $scope.icon        = 'icon-AlarmClock'
        $scope.onLeftIcon  = ->
            console.info 'back button on click'
            $window.history.back()
            return

        $scope.items = [
            leftIco: 'icon-PowerAdapter'
            name: 'AC'
            status: 'Ok'
        ,
            leftIco: 'icon-MenuBox'
            name: 'Battery'
            status: 'Ok'
        ,
            leftIco: 'icon-Phone'
            name: 'PSTN'
            status: 'Ok'
        ,
            leftIco: 'icon-Siren'
            name: 'Bell'
            status: 'Ok'
        ,
            leftIco: 'icon-iMac'
            name: 'Peripheral'
            status: 'Ok'
        ]
        return


.filter 'isLink', ->
    (data) ->
        if 'href' of data is on and data.href then "<a href='#{data.href}'>#{data.name}</a>" else data.name