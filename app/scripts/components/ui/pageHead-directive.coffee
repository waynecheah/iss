'use strict'

glApp

.directive 'pageHead', ->
    transclude: yes
#    controller: ($scope, $window) ->
#        $scope.onLeftIcon = ->
#            $window.history.back()
#            return
#        return
#    scope:
#        leftIco: '@'
#        title: '@'
#        rightIco: '@'
    template: '
<div class="row">
  <div class="col-xs-2 col-md-1" ng-click="onLeftIcon()">
    <span class="{{leftIco}}"></span>
  </div>
  <div class="col-xs-8 col-md-10 pageTitle text-center">
    <div ng-transclude class="icon-title"></div>{{title}}
  </div>
  <div class="col-xs-2 col-md-1 text-right">
    <span class="{{rightIco}}"></span>
  </div>
</div>'
# END pageHead

.directive 'iconTitle', ->
    restrict: 'E'
#    scope:
#        icon: '@'
    template: '
<div class="iconWrapper">
  <div class="icon {{icon}}"></div>
</div>
<div class="line"></div>'
# END iconTitle
