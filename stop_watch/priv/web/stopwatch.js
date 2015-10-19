function StopwatchCtrl($scope, $http) {

  var model_url         = "/cell/watch";  // must serve up json
  var min_poll_interval = 20;            // suggest 10-50, 0=high browser cpu
  var err_poll_interval = 5000;          // retry every 5 secs if http error

  put_headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}

  $scope.model = { };
  $scope.resolutions = [10, 100, 1000];

  $scope.$watch('model.resolution', function(newValue, oldValue, scope) {
    headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
    if (! angular.equals(oldValue, newValue)) {
      console.log("new resolution: ", newValue, oldValue);
      $http({method: 'PUT', url: model_url, headers: headers, data: {resolution: newValue}}).
        success(function(data, status, headers, config) {
          //angular.extend($scope.model, data)
          //$scope.last_version = headers('x-version')
        }).
        error(function(data, status, headers, config) {
          console.error("put failed!");
        });
    }
  }, true)

  $scope.$watch('seconds()', function(newValue, oldValue, scope) {
    $('#timedisplay')[0].ctl.setValue(newValue)
  })

  $scope.clear = function() {
    $http({method: 'PUT', url: model_url, headers: put_headers, data: {ticks: 0}})
  }

  $scope.start = function() {
    $http({method: 'PUT', url: model_url, headers: put_headers, data: {running: true}})
  }

  $scope.stop = function() {
    $http({method: 'PUT', url: model_url, headers: put_headers, data: {running: false}})
  }

  $scope.seconds = function() {
    return ($scope.model.ticks * $scope.model.resolution) / 1000;
  }

  $scope.POLLER();

}
