'use strict'

glApp

.directive 'connectivity', ->
    transclude: yes
    controller: ($rootScope) ->
        this.internet = 'dis'
        this.cloud    = 'dis'
        this.hardware = 'dis'

        this.set = (name, status) ->
            this[name] = status
            $rootScope.$broadcast "#{name}:changed", status
            return
        return
    template: '
<div ng-transclude class="short row"></div>'
# END connectivity


.directive 'internetStatus', ($timeout, internetStatus) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        scope.iStatus = 'on'
        connectivityCtrl.internet = scope.iStatus

        $timeout ->
            scope.iStatus = 'off'
            connectivityCtrl.set 'internet', 'off'
            return
        , 3000
        $timeout ->
            internetStatus.check (status) ->
                scope.iStatus = if status then 'on' else 'off'
                connectivityCtrl.set 'internet', scope.iStatus
                return
            return
        , 6000
        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} internet text-center {{iStatus}}"></div>'
# END internetStatus

.directive 'cloudStatus', ($log) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        $log.debug 'Cloud find internet status', connectivityCtrl.internet

        scope.$on 'internet:changed', (obj, status) ->
            $log.debug 'Cloud found Internet status has changed:', status
            unless status is 'on'
                $log.warn 'Cloud status is now disabled'
                scope.cStatus = 'dis'
                connectivityCtrl.set 'cloud', 'dis'
            else
                scope.cStatus = 'on'
                connectivityCtrl.set 'cloud', 'on'
            return

        # can only check cloud status if there is internet connection
        return scope.cStatus = 'dis' unless connectivityCtrl.internet is 'on'
        scope.cStatus = 'off'
        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} cloud text-center {{cStatus}}"></div>'
# END cloudStatus

.directive 'hardwareStatus', ($log) ->
    restrict: 'E'
    replace: true
    require: '^connectivity'
    link: (scope, elem, attrs, connectivityCtrl) ->
        $log.debug 'Hardware find cloud status', connectivityCtrl.cloud

        scope.$on 'cloud:changed', (obj, status) ->
            $log.debug 'Hardware found Cloud status has changed:', status
            unless status is 'on'
                $log.warn 'Hardware status is now disabled'
                scope.hStatus = 'dis'
                connectivityCtrl.set 'hardware', 'dis'
            else
                scope.hStatus = 'off'
                connectivityCtrl.set 'hardware', 'off'
            return

        # can only check hardware status if there is cloud service available
        return scope.hStatus = 'dis' unless connectivityCtrl.cloud is 'on'
        scope.hStatus = 'off'
        return
    scope:
        column: '@'
    template: '
<div class="col-xs-{{column}} hardware text-center {{hStatus}}"></div>'
# END hardwareStatus
