'use strict'

glApp

.directive 'connectivity', ->
    transclude: yes
    controller: ->
        this.internet = 'dis'
        this.cloud    = 'dis'
        this.hardware = 'dis'
        return
    template: '
<div ng-transclude class="short row"></div>'
# END connectivity


.directive 'internetStatus', ($rootScope, $timeout, internetStatus) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        $rootScope.$on 'internet:changed', (e, status) ->
            scope.iStatus = connectivityCtrl.internet = status
            return

        internetStatus.check()
        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} internet text-center {{iStatus}}"></div>'
# END internetStatus

.directive 'cloudStatus', ($rootScope, $log, socket, internetStatus) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        $rootScope.$on 'socket:changed', (e, status, eventName) ->
            if status is 'off'
                # if internet is off, cloud status will be turned to disabled
                cloudStatus = if connectivityCtrl.internet is 'off' then 'dis' else 'off'
                connectivityCtrl.cloud = cloudStatus
                scope.$apply ->
                    scope.cStatus = cloudStatus
                # Check internet connection and see if it caused cloud disconnected
                internetStatus.check() if eventName is 'connect_failed' or eventName is 'disconnect'
            else if status is 'on'
                console.warn 'what is the status now?', status
                connectivityCtrl.cloud = 'on'
                scope.$apply ->
                    scope.cStatus = 'on'
            return
        scope.$on 'internet:changed', (obj, status) ->
            $log.debug 'Cloud found Internet status has changed:', status
            if status is 'on'
                # when internet resume, socket may need to establish connection to cloud
                socket.connect()
            else
                cloudStatus = socket.status()
                return if cloudStatus is 'on'
                # internet and cloud also not available, make cloud disabled
                $log.warn 'Cloud status is now disabled'
                connectivityCtrl.cloud = 'dis'
                scope.$apply ->
                    scope.cStatus = 'dis'
            return

        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} cloud text-center {{cStatus}}"></div>'
# END cloudStatus

.directive 'hardwareStatus', ($rootScope, $log, socket) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        socket.on 'hardware:changed', (status, data) ->
            if status is 'on'
                $log.debug "Device serial [#{data.serial}] is report connected to server"
                connectivityCtrl.hardware = 'on'
                scope.$apply ->
                    scope.hStatus = 'on'
            else
                $log.warn "Device serial [#{data.serial}] is report disconnected from server"
                hardwareStatus = if socket.status() is 'on' then 'off' else 'dis'
                connectivityCtrl.hardware = hardwareStatus
                scope.$apply ->
                    scope.hStatus = hardwareStatus
            return
        $rootScope.$on 'socket:changed', (e, status) ->
            $log.debug 'Hardware found Cloud status has changed:', status
            if status is 'on'
                connectivityCtrl.hardware = 'off'
                scope.$apply ->
                    scope.hStatus = 'off'
            else
                $log.warn 'Hardware status is now disabled'
                connectivityCtrl.hardware = 'dis'
                scope.$apply ->
                    scope.hStatus = 'dis'
            return

        $log.debug 'Hardware find cloud status', connectivityCtrl.cloud
        return scope.hStatus = 'dis' unless connectivityCtrl.cloud is 'on'
        scope.hStatus = connectivityCtrl.hardware = 'off'
        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} hardware text-center {{hStatus}}"></div>'
# END hardwareStatus
