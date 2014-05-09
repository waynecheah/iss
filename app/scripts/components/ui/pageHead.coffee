'use strict'

glApp

.directive 'pageHead', ->
    restrict: 'E'
    replace: yes
    transclude: yes
    controller: ($scope) ->
        return
    scope:
        leftIco: '@'
        title: '@'
        rightIco: '@'
    template: '<div class="header">' +
                '<div class="row">' +
                  '<div class="col-xs-2 col-md-1">' +
                    '<span class="{{leftIco}}"></span>' +
                  '</div>' +
                  '<div class="col-xs-8 col-md-10 pageTitle text-center">' +
                  '<div ng-transclude></div>{{title}}</div>' +
                  '<div class="col-xs-2 col-md-1">' +
                    '<span class="{{rightIco}}"></span>' +
                  '</div>' +
                '</div>' +
              '</div>'
# END panelHead

.directive 'iconTitle', ->
    restrict: 'E'
    scope:
        icon: '@'
    template: '<div class="iconWrapper">' +
                '<div class="icon {{icon}}"></div>' +
              '</div>' +
              '<div class="line"></div>'
