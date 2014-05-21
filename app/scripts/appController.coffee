'use strict'

glApp

.controller 'AppCtrl', ($scope, $rootScope, $state, $timeout) ->
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

    $rootScope.alarmStatus = 'disarmed'
    $scope.toolbar = if $rootScope.alarmStatus is 'disabled' then off else on

    $scope.swipeDown = ->
        console.warn 'swip down from header detected'
        $rootScope.$broadcast 'swipe:header', 'down'
        return
    $scope.swipeUp = ->
        console.warn 'swip up from notification detected'
        $rootScope.$broadcast 'swipe:notification', 'up'
        return

    $rootScope.pageFx = (ctrl, fx='slide') ->
        console.log 'goto controller:', ctrl, fx
        if oneFxCtrl
            cls = if fx.substr(0, 4) is 'one-' then fx else "one-#{fx}"
            fx  = if ctrl is oneFxCtrl then cls else fx
        else
            fx
        console.log 'use fx:', fx
        fx

    $rootScope.$on '$stateChangeSuccess', (e, current, toParams, previous, fromParams) ->
        current   = angular.fromJson current
        previous  = angular.fromJson previous
        prevRoute = if history.length > 0 then history[history.length - 1] else '-'

        if current and 'templateUrl' of current and previous and 'templateUrl' of previous
            curr_url = current.templateUrl
            prev_url = previous.templateUrl
            console.log 'current: '+ curr_url
            console.log 'previous: '+ prev_url
            console.log 'history: '+ prevRoute

            current_id  = getIndex curr_url
            previous_id = getIndex prev_url
            singleFx    = isSingleFx curr_url, prev_url

            if singleFx
                $scope.singleFx = 'singleFx'
                console.info 'this page change use single fx'
                curr_ctrl = current.controller
                prev_ctrl = previous.controller
                oneFxCtrl = if singleFx is 1 then curr_ctrl else prev_ctrl # Only slide this ctrl
                console.info 'Only slide this ctrl', oneFxCtrl
            else
                $scope.singleFx = ''
                oneFxCtrl       = ''

            if current_id < previous_id
                console.warn 'Current index is smaller! Page uses reverse fx'
                $rootScope.backFxClass = 'back'
#                $timeout ->
#                    $scope.backFxClass = ''
#                    return
#                , 800
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
        href: '#/wave'
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

.controller 'MainCtrl', ($scope, $rootScope, $location, $state) ->
    $scope.pageFxClass = $rootScope.pageFx 'MainCtrl'
    $scope.title       = 'Alarm Dashboard'
    $scope.leftIco     = 'icon-MainMenu'
    $scope.rightIco    = 'icon-Location'
    $scope.icon        = 'icon-IZ'
    $scope.goState     = (state) ->
        $state.go state
        return
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
        state: 'alarm.zones'
    ,
        leftIco: 'icon-Health'
        name: 'System Health'
        status: ['5 OK', '2 Fails']
        state: 'alarm.system'
    ,
        leftIco: 'icon-AlarmClock'
        name: 'Alarm'
        status: 'OK'
        state: 'alarm.emergency'
    ,
        leftIco: 'icon-Clock'
        name: 'Event Logs'
        status: '9 new'
        state: 'alarm.logs'
    ]

    $scope.updateZones = ->
        total = $scope.zones
        $scope.items[0].description = "#{total} zones detected"
        return
    return
        
.controller 'AlarmCtrl', ($scope, $rootScope, $window, $timeout, $state) ->
    $scope.pageFxClass = $rootScope.pageFx 'AlarmCtrl'
    $scope.title       = 'Home Alarm'
    $scope.leftIco     = 'icon-Back'
    $scope.icon        = 'icon-AlarmClock'
    $scope.tabs        = [
        icon: 'icon-Locked'
        name: 'Security'
        state: 'alarm.zones'
        active: false
    ,
        icon: 'icon-Health'
        name: 'Health'
        state: 'alarm.system'
        active: false
    ,
        icon: 'icon-AlarmClock'
        name: 'Alarm'
        state: 'alarm.emergency'
        active: false
    ,
        icon: 'icon-Clock'
        name: 'Events'
        state: 'alarm.logs'
        active: false
    ]
    $scope.swipe = (x) ->
        curState = $state.current.name
        index    = ''

        angular.forEach $scope.tabs, (tab, i) ->
            if tab.state is curState
                index = if x is 1 then i+1 else i-1
            return

        if index > -1 and index < $scope.tabs.length
            $state.go $scope.tabs[index].state, {}, location:'replace'
        return
    $scope.goState = (state) ->
        $state.go state, {}, location:'replace'
        return
    $scope.onLeftIcon  = ->
        console.info 'back button on click'
        $window.history.back()
        return

    window.lastState = null if 'lastState' of window is false
    $scope.$on '$stateChangeSuccess', (e, toState, toParams, fromState) ->
        lastIndex = null
        width     = (screen.width + 30) / $scope.tabs.length
        offset    = (width - 10) / 2

        if window.lastState and fromState.name is 'dashboard'
            angular.forEach $scope.tabs, (v, i) ->
                if v.state.indexOf(window.lastState) >= 0 and lastIndex is null
                    lastIndex   = i
                    $scope.left = (i * width + offset)
                    $timeout ->
                        v.active = yes
                        return
                    , 200
                return

        angular.forEach $scope.tabs, (v, i) ->
            if v.state.indexOf(toState.name) >= 0
                if fromState.name is 'dashboard'
                    $timeout ->
                        $scope.left = (i * width + offset)
                        return
                    , 400
                    $timeout ->
                        $scope.tabs[lastIndex].active = no unless lastIndex is null
                        v.active = yes
                        return
                    , 800
                else
                    $scope.left = (i * width + offset)
                    v.active    = yes
                $scope.icon = v.icon
            else
                v.active    = no
            return

        window.lastState = toState.name #unless fromState.url is '/wave'
        return
    return
.controller 'Alarm.ZonesCtrl', ($scope) ->
    $scope.pageFxClass = 'slide'
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
.controller 'Alarm.SystemCtrl', ($scope) ->
    $scope.pageFxClass = 'slide'
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
.controller 'Alarm.EmergencyCtrl', ($scope) ->
    $scope.items = [
        leftIco: 'icon-Siren'
        name: 'Panic'
        status: 'N/A'
    ,
        leftIco: 'icon-Message'
        name: 'Silent'
        status: 'N/A'
    ]
    return
.controller 'Alarm.LogsCtrl', ($scope) ->
    $scope.items = [
        leftIco: 'icon-Refresh'
        name: 'Event'
        description: 'Camera 1 (1 image)'
        status: '6:06AM'
    ,
        leftIco: 'icon-Mail'
        name: 'Kitchen Door'
        description: 'communication error'
        status: '7:38AM'
    ,
        leftIco: 'icon-Trash'
        name: 'Kitchen Door'
        description: 'communication restored'
        status: '7:43:AM'
    ,
        leftIco: 'icon-Forward'
        name: 'Zone Door'
        description: 'detect opened'
        status: '10:22AM'
    ,
        leftIco: 'icon-Zone20'
        name: 'Room Window 1'
        description: 'detect opened'
        status: '10:23AM'
    ]


.filter 'isLink', ->
    (data) ->
        if 'href' of data is on and data.href then "<a href='#{data.href}'>#{data.name}</a>" else data.name