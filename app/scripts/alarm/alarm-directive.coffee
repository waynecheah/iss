'use strict'

glApp

.directive 'alarmToolbar', ($rootScope) ->
    restrict: 'E'
    controller: ($scope, $element, $timeout, gettext) ->
        updateStatusText = ->
            if $rootScope.alarmStatus is 'armed'
                $scope.statusIcon  = 'icon-Locked'
                $scope.armStatus   = gettext 'Armed Away.'
                $scope.description = gettext 'Press to Disarm'
                $scope.buttonTxt   = gettext 'Disarm'
            else if $rootScope.alarmStatus is 'disarmed'
                $scope.statusIcon  = 'icon-UnLock'
                $scope.armStatus   = gettext 'Disarmed.'
                $scope.description = gettext 'Press to Arm'
                $scope.buttonTxt   = gettext 'Arm'
            else if $rootScope.alarmStatus is 'emergency'
                $scope.statusIcon  = 'icon-Siren'
                $scope.armStatus   = gettext 'Emergency.'
                $scope.description = gettext 'Press to Disarm'
                $scope.buttonTxt   = gettext 'Disarm'
            return
        # END updateStatusText

        updateStatusText()
        $scope.cancelTxt  = gettext 'Cancel'
        $scope.numbers    = []
        $scope.onTap      = {}

        $scope.armDisarm = ->
            top = document.body.clientHeight - $element[0].firstChild.clientHeight
            $element.css 'top', "#{top}px"
            $timeout ->
                $scope.onPasscode = yes
                $element.css 'top', 0
                $timeout
            , 50

            if $rootScope.alarmStatus is 'disarmed'
                description = gettext 'Enter Passcode to Arm'
            else
                description = gettext 'Enter Passcode to Disarm'

            $rootScope.showKeypad = yes
            $scope.description    = description
            $scope.keypad         = on
            $scope.onKeypad       = yes
            return

        $scope.closeKeypad = ->
            top = document.body.clientHeight - $element[0].firstChild.clientHeight
            $timeout ->
                $element.css 'top', "#{top}px"
                return
            , 50
            $timeout ->
                $scope.onPasscode = no
                $element.css 'top', null
                return
            , 350

            updateStatusText()
            $rootScope.showKeypad = no
            $scope.keypad         = off
            $scope.onKeypad       = no
            $scope.numbers        = []
            $scope.cancelTxt      = gettext 'Cancel'
            $scope.showOk         = no
            return

        $scope.keyPress = (key) ->
            $scope.numbers.push key
            $scope.cancelTxt      = gettext 'Delete'
            $scope.showOk         = yes if $scope.numbers.length is 4
            $scope.onTap['k'+key] = on
            $timeout ->
                $scope.onTap['k'+key] = off
                return
            , 100
            return

        $scope.cancel = ->
            length = $scope.numbers.length
            $scope.cancelTxt = gettext 'Cancel' if length is 1
            $scope.showOk    = no if length is 4
            if length then $scope.numbers.pop() else $scope.closeKeypad()
            return

        $scope.submit = ->
            console.warn $scope.numbers.join ''
            return

        return
    template: '
<div class="row status">
  <div class="col-xs-2">
    <div ng-class="statusIcon" class="icon"></div>
  </div>
  <div class="col-xs-7">
    <div class="curArmStatus">{{armStatus}}</div>
    <div class="description">{{description}}</div>
  </div>
  <div class="col-xs-3 rightCol">
    <div class="armButton" ng-hide="keypad" ng-click="armDisarm()">{{buttonTxt}}</div>
    <div class="armIcon closeKeypad icon-False" ng-show="onKeypad" ng-click="closeKeypad()"></div>
    <div class="armIcon loading icon-Refresh" ng-show="onProgress"></div>
  </div>
</div>

<div class="passcode" ng-show="onPasscode">
  <div class="row digits">
    <div class="txt">Enter Passcode</div>
    <table>
      <tr>
        <td>
          <div ng-repeat="num in numbers track by $index"></div>
        </td>
      </tr>
    </table>
  </div>
  <div class="row keypad">
    <div class="col col-xs-4">
      <div class="passcodeButton" ng-class="{onTap:onTap.k1}" ng-click="keyPress(1)">1</div>
      <div class="passcodeButton" ng-class="{onTap:onTap.k4}" ng-click="keyPress(4)">4</div>
      <div class="passcodeButton" ng-class="{onTap:onTap.k7}" ng-click="keyPress(7)">7</div>
      <div class="cancel" ng-click="cancel()">{{cancelTxt}}</div>
    </div>
    <div class="col col-xs-4">
      <div class="passcodeButton" ng-class="{onTap:onTap.k2}" ng-click="keyPress(2)">2</div>
      <div class="passcodeButton" ng-class="{onTap:onTap.k5}" ng-click="keyPress(5)">5</div>
      <div class="passcodeButton" ng-class="{onTap:onTap.k8}" ng-click="keyPress(8)">8</div>
      <div class="passcodeButton" ng-class="{onTap:onTap.k0}" ng-click="keyPress(0)">0</div>
    </div>
    <div class="col col-xs-4">
      <div class="passcodeButton" ng-class="{onTap:onTap.k3}" ng-click="keyPress(3)">3</div>
      <div class="passcodeButton" ng-class="{onTap:onTap.k6}" ng-click="keyPress(6)">6</div>
      <div class="passcodeButton" ng-class="{onTap:onTap.k9}" ng-click="keyPress(9)">9</div>
      <div class="ok" ng-show="showOk" ng-click="submit()">Ok</div>
    </div>
  </div>
</div>'
# END alarmToolbar
