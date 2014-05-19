'use strict'

###
    Module Dependency [connectivity-directive]
###

glApp

.directive 'notification', ($rootScope, $timeout) ->
    restrict: 'E'
    replace: yes
    transclude: yes
    controller: ($scope, $element) ->
        $rootScope.$on 'swipe:header', (e, direction) ->
            bottom = document.body.clientHeight
            $element.css 'bottom', "#{bottom}px"
            $scope.notification = if direction is 'down' then yes else no

            $timeout ->
                $element.css 'bottom', '0'
            , 10
            return
        $rootScope.$on 'swipe:notification', (e, direction) ->
            bottom = document.body.clientHeight
            $element.css 'bottom', "#{bottom}px"
            $timeout ->
                $scope.notification = if direction is 'up' then no else yes
            , 400
            return
        return
    template: '
<div ng-transclude class="row" ng-show="notification"></div>'
# END connectivity