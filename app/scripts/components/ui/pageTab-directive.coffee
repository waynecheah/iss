'use strict'

glApp

.directive 'pageTab', ->
    transclude: yes
    template: '
<div class="row tabWrap">
  <div class="arrow" style="left:{{left}}px" pos="Y"></div>
  <div class="tabs">
    <a ng-click="goState(tab.state)" ng-repeat="tab in tabs"
     ng-class="{selected:tab.active}" class="col-xs-3 text-center tab">
      <div class="icon {{tab.icon}}"></div>
      <span>{{tab.name}}</span>
    </a>
  </div>
</div>'
# END pageHead

