'use strict'

glApp =

  angular.module 'glApp', [
    'ngAnimate'
    'ngResource'
    'ngSanitize'
    'ui.router'#'ngRoute'
    'angular-gestures'
    'gettext'
  ]

  .run ($rootScope, $log, gettextCatalog) ->
      $rootScope.$log                = $log
      #gettextCatalog.currentLanguage = 'zh_CN'
      gettextCatalog.debug           = true
      FastClick.attach document.body # seem to be slower after add?
      return

  .config ($logProvider) ->
      $logProvider.debugEnabled yes
      return

  .config ($httpProvider) ->
      delete $httpProvider.defaults.headers.common['X-Requested-With']
      #$httpProvider.interceptors.push 'authInterceptor'
      return

  .config ($stateProvider, $urlRouterProvider) ->
      $urlRouterProvider.otherwise '/'
      $stateProvider
          .state 'mainmenu',
              url: '/'
              templateUrl: '2_menu-page.s'
              controller: 'MenuCtrl'

          .state 'dashboard',
              url: '/wave'
              templateUrl: '3_dashboard'
              controller: 'MainCtrl'

          .state 'alarm',
              url: '/alarm'
              templateUrl: '4_alarm-page'
              controller: 'AlarmCtrl'
          .state 'alarm.zones',
              url: '/zones'
              templateUrl: '4.1_zones-page'
              controller: 'Alarm.ZonesCtrl'
          .state 'alarm.system',
              url: '/system'
              templateUrl: '4.2_system-page'
              controller: 'Alarm.SystemCtrl'
          .state 'alarm.emergency',
              url: '/emergency'
              templateUrl: '4.3_emergency-page'
              controller: 'Alarm.EmergencyCtrl'
          .state 'alarm.logs',
              url: '/logs'
              templateUrl: '4.4_logs-page'
              controller: 'Alarm.LogsCtrl'
      return

  .constant 'facebookAPI',
      appId: '553789621375577'
      status: true
      cookie: off
      email: on
  .constant 'googleAPI',
      apiKey: 'AIzaSyD6z5RkfXSuBKGwm0djIHoRWm-OLsS7IYI'
      client_id: '341678844265-5ak3e1c5eiaglb2h9ortqbs9q57ro6gb.apps.googleusercontent.com'
      scope: 'https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/userinfo.email'
      immediate: yes

  .value 'debug', (msg, type='log') ->
      return if 'env' of window is false or window.env is 'pro'
      switch type
          when 'log' then console.log msg
          when 'info' then console.info msg
          when 'err' then console.error msg
          when 'warn' then console.warn msg
          when 'table' then console.table msg
      return
