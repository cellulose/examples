var app = angular.module('stopwatch', []);

app.config(function($routeProvider) {
    $routeProvider.
      when('/', {controller:'StartCtrl', templateUrl:'start.html'}).
      when('/main', {controller:'MainCtrl', templateUrl:'main.html'}).
      otherwise({redirectTo:'/'});
});

app.controller('MainCtrl', function($scope, Poller) {
  $scope.name = 'World';
  $scope.data = Poller.data;
});
app.controller('StartCtrl',function(){});
app.run(function(Poller) {});

app.factory('Poller', function($http, $timeout) {
  var data = { response: {}, calls: 0 };
  var poller = function() {
    $http.get('cell/watch').then(function(r) {
      data.response = r.data;
      data.calls++;
      $timeout(poller, 1000);
    });
  };
  poller();
  return { data: data };
});
