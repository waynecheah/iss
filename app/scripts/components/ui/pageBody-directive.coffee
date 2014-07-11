'use strict'

glApp

.directive 'pageBody', ->
    transclude: yes
    template: '
<div class="body">
  <ul>
    <li hm-tap="goState(item.state)" hm-tap-opts="{preventDefault:false}" ng-repeat="item in items">
      <div class="row ln">
        <div class="col-xs-2 col-md-2"><div class="{{item.leftIco}}"></div></div>
        <div class="col-xs-6 col-md-8">
          <div translate class="name">{{item.name}}</div>
          <div translate class="description">{{item.description}}</div>
        </div>
        <div translate class="col-xs-4 col-md-2 text-right status" ng-class="item.statusCls" hm-tap="statusAct($index)">
          {{ item.status | joinArray }}
        </div>
      </div>
    </li>
  </ul>
</div>'
# END pageBody

.filter 'joinArray', ->
    (data) ->
        if angular.isArray(data) then data.join('<br />') else data
# END joinArray
