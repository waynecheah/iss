'use strict'

glApp

.directive 'pageBody', ->
        restrict: 'E'
        replace: yes
        transclude: yes
        controller: ($scope) ->
            return
        scope:
            name: '@'
            leftIco: '@'
            status: '@'
            gotoUrl: '@'
            description: '@'
        template: '<div class="body">' +
                    '<ul class="lgRow">' +
                      '<li data-page="{{gotoUrl}}" class="ln row">' +
                        '<div class="col-xs-2 col-md-2"><div class="{{leftIco}}"></div></div>' +
                        '<div class="col-xs-6 col-md-8">' +
                          '<div translate class="name">{{name}}</div>' +
                          '<div translate class="description">{{description}}</div>' +
                        '</div>' +
                        '<div translate class="col-xs-4 col-md-2 status">{{status}}</div>' +
                      '</li>' +
                    '</ul>' +
                  '</div>'
# END panelHead

.directive 'pageBodyLi', ->
        restrict: 'E'
        scope:
            icon: '@'
        template: ''
