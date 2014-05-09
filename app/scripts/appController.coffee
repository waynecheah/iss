'use strict'

glApp

.controller 'AppCtrl', ($scope, gettext) ->
    $scope.awesomeThings = gettext 'Awesome Things'
    return

.controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
        'HTML5 Boilerplate'
        'AngularJS'
    ]
    return