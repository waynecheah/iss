'use strict'

glApp =

  angular.module 'glApp', [
    'ngAnimate'
    'ngResource'
    'ngSanitize'
    'ngRoute'
    'ngTouch'
    'gettext'
  ]

#  .run (gettextCatalog) ->
#      #gettextCatalog.currentLanguage = 'zh_CN'
#      gettextCatalog.debug           = true
#      return

#  .config ($httpProvider) ->
#      delete $httpProvider.defaults.headers.common['X-Requested-With']
#      $httpProvider.interceptors.push 'authInterceptor'
#      return

  .config ($routeProvider) ->
      $routeProvider
      .when '/',
          templateUrl: '3_dashboard'
          controller: 'MainCtrl'
      .when '/alarm/zones',
          templateUrl: '4.1_alarm-page'
          controller: 'AlarmCtrl'
      .when '/alarm/system',
          templateUrl: '2_menu-page.s'
          controller: 'MenuCtrl'
      .otherwise
          redirectTo: '/'
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
