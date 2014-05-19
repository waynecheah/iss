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

.directive 'notification', ($rootScope) ->
    restrict: 'E'
    replace: yes
    transclude: yes
    controller: ($scope) ->
        $rootScope.$on 'swipe:header', (e, direction) ->
            $scope.notification = if direction is 'down' then yes else no
            return
        return
    template: '
<div ng-transclude class="row" ng-show="notification"></div>'
# END connectivity


.directive 'internetStatus', ($rootScope, $timeout, internetStatus) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        $rootScope.$on 'internet:changed', (e, status) ->
            scope.iStatus = connectivityCtrl.internet = status
            unless $rootScope.$$phase
                scope.$apply ->
                    scope.iStatus = status
                    return
            return

        internetStatus.check()
        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} wrapper internet text-center {{iStatus}}">
  <div class="internet visual {{iStatus}}">
    <div class="text" translate>LINE</div>
    <div class="status">
      <div class="ico"><span class="icon-Earth"></span></div>
    </div>
  </div>
</div>'
# END internetStatus

.directive 'cloudStatus', ($rootScope, $log, socket, internetStatus) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        updateStatus = (status) ->
            connectivityCtrl.cloud = status
            scope.$apply ->
                scope.cStatus = status
                return
            return
        # END updateStatus

        $rootScope.$on 'socket:changed', (e, status, eventName) ->
            if status is 'off'
                # if internet is off, cloud status will be turned to disabled
                cloudStatus = if connectivityCtrl.internet is 'off' then 'dis' else 'off'
                updateStatus cloudStatus
                # Check internet connection and see if it caused cloud disconnected
                internetStatus.check() if eventName is 'connect_failed' or eventName is 'disconnect'
            else if status is 'on'
                updateStatus 'on'
            return
        $rootScope.$on 'internet:changed', (obj, status) ->
            $log.debug 'Cloud found Internet status has changed:', status
            if status is 'on'
                # when internet resume, socket may need to establish connection to cloud
                socket.connect()
            else
                cloudStatus = socket.status()
                return if cloudStatus is 'on'
                # internet and cloud also not available, make cloud disabled
                $log.warn 'Cloud status is now disabled'
                updateStatus 'dis'
            return

        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} wrapper cloud text-center {{cStatus}}">
  <div class="cloud visual {{cStatus}}">
    <div class="text" translate>CLOUD</div>
    <div class="status">
      <div class="ico"><span class="icon-CloudSync"></span></div>
    </div>
  </div>
</div>'
# END cloudStatus

.directive 'hardwareStatus', ($rootScope, $log, socket) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        updateStatus = (status) ->
            connectivityCtrl.hardware = status
            scope.$apply ->
                scope.hStatus = status
                return
            return
        # END updateStatus

        socket.on 'hardware:changed', (status, data) ->
            if status is 'on'
                $log.debug "Device serial [#{data.serial}] is report connected to server"
                updateStatus 'on'
            else
                $log.warn "Device serial [#{data.serial}] is report disconnected from server"
                hardwareStatus = if socket.status() is 'on' then 'off' else 'dis'
                updateStatus hardwareStatus
            return
        $rootScope.$on 'socket:changed', (e, status) ->
            $log.debug 'Hardware found Cloud status has changed:', status
            if status is 'on'
                updateStatus 'off'
            else
                $log.warn 'Hardware status is now disabled'
                updateStatus 'dis'
            return

        $log.debug 'Hardware find cloud status', connectivityCtrl.cloud
        return scope.hStatus = 'dis' unless connectivityCtrl.cloud is 'on'
        scope.hStatus = connectivityCtrl.hardware = 'off'
        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} wrapper hardware text-center {{hStatus}}">
  <div class="hardware visual {{cStatus}}">
    <div class="text" translate>PANEL</div>
    <div class="status">
      <div class="ico"><span class="icon-ServerSync"></span></div>
    </div>
  </div>
</div>'
# END hardwareStatus
