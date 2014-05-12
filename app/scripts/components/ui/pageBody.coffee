'use strict'

glApp

.directive 'pageBody', ->
    transclude: yes
    controller: ($scope) ->
        return
    template: '
<div class="body">
  <ul>
    <li data-page="{{gotoUrl}}" ng-repeat="item in items" class="ln">
      <a href="{{item.href}}" class="row ln">
        <div class="col-xs-2 col-md-2"><div class="{{item.leftIco}}"></div></div>
        <div class="col-xs-6 col-md-8">
          <div translate class="name">{{item.name}}</div>
          <div translate class="description">{{item.description}}</div>
        </div>
        <div translate class="col-xs-4 col-md-2 text-right status">{{ item.status | joinArray }}</div>
      </a>
    </li>
  </ul>
</div>'

.filter 'joinArray', ->
    (data) ->
        if angular.isArray(data) then data.join('<br />') else data
