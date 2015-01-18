var parishApp = angular.module('parishApp', [
  'ngRoute'
]);

parishApp.factory('Store', function() {
  return { 
      currentPage: 0,
      county: '',
      forkod: '',
      fulltext: '' };
});

parishApp.config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/list.html',
        controller: 'MainCtrl'
      })
      .when('/parish/:pid', {
        templateUrl: 'views/parish.html',
        controller: 'ParishCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  });

parishApp.filter('offset', function() {
  return function(input, start) {
    start = parseInt(start, 10);
    return input.slice(start);
  };
});

var countiesStore = [
    { county: "1",  cname: "Stockholms"},
    { county: "3",  cname: "Uppsala"},
    { county: "4",  cname: "Södermanlands"},
    { county: "5",  cname: "Östergötlands"},
    { county: "6",  cname: "Jönköpings"},
    { county: "7",  cname: "Kronobergs"},
    { county: "8",  cname: "Kalmar"},
    { county: "9",  cname: "Gotlands"},
    { county: "10", cname: "Blekinge"},
    { county: "11", cname: "Kristianstads"},
    { county: "12", cname: "Skåne"},
    { county: "13", cname: "Hallands"},
    { county: "14", cname: "Västra Götalands"},
    { county: "15", cname: "Älvsborgs"},
    { county: "16", cname: "Skaraborgs"},
    { county: "17", cname: "Värmlands"},
    { county: "18", cname: "Örebro"},
    { county: "19", cname: "Västmanlands"},
    { county: "20", cname: "Dalarnas"},
    { county: "21", cname: "Gävleborgs"},
    { county: "22", cname: "Västernorrlands"},
    { county: "23", cname: "Jämtlands"},
    { county: "24", cname: "Västerbottens"},
    { county: "25", cname: "Norrbottens"}
  ];


parishApp.controller('ParishCtrl', function ($scope, $http, $routeParams){
  var index = $routeParams.pid;
  var map;
  $http({method: 'GET', url: 'data/' + index + '.json'}).success(function(e) {
    $scope.parish = e[0];
    $http({method: 'GET', url: 'data/map'+e[0].county+'.geo.json'}).success(function(d){
      render_highmap(d, map_data(d, e[0].forkod));
    });
    
  });


  $scope.countName = function(code){
    console.log('code:', code);
    if (!code){
      return '';
    }
    var results = countiesStore.filter(function (entry) { return entry.county === code; });
    return  results[0].cname;
  }

  var render_highmap = function(d, data) {;
    map = new Highcharts.Map({
      chart: {
        renderTo: 'map',
        borderWidth : 1,
        borderColor: '#D7D7D7'
      },      
      title: {
          text: ''
      },

      mapNavigation: {
          enabled: true,
          buttonOptions: {
              verticalAlign: 'bottom'
          }
      },
    
      legend: {
        enabled: false
      },

      colorAxis: {
        min: 0,
        minColor: '#EEEEFF',
        maxColor: '#000022',
        stops: [
          [0, '#EFEFFF'],
          [1, '#000022']
        ]
      },

      series : [{
          data: data,
          mapData: d,
          name: 'Parish',
          joinBy: ['forkod', 'code'],
          tooltip: {
              headerFormat: '',
              pointFormat: '{point.socken} {point.forkod}'
          }
      }]
    });
  }
})


parishApp.controller('MainCtrl', function($scope, $http, $timeout, Store) {
  $scope.pageSize = 20;
  $scope.currentPage = Store.currentPage;

  $scope.dataLoading = true;
  $scope.search = {
    forkod: Store.forkod
  };
  $scope.selected_county = Store.county;
  $scope.fulltext = Store.fulltext;
  $scope.counties = countiesStore;
  
  $scope.countName = function(code){
    if (!code){
      return 'Okänd';
    }
    var results = $scope.counties.filter(function (entry) { return entry.county === code; });
    return  results[0].cname;
  }

  $http({method: 'GET', url: 'data/parishes.json'}).
    success(function(d) {
      console.log(d);
      $scope.parishes = d;
      $scope.dataLoading = false;
    }).
    error(function(data, status, headers, config) {
      console.log(data);
    });
  $scope.clear = function() {
    $scope.search = "";
    $scope.fulltext = "";
    $scope.selected_county = "";
    $scope.currentPage = 0;
    Store.fulltext = '';
    Store.county = '';
    Store.forkod = '';
    Store.currentPage = 0;
  }

  $scope.filterText = '';
  $scope.$watch('selected_county', function (newval, oldval) {
    Store.county = newval;
    if (newval !== oldval) {
      Store.currentPage = 0;
      $scope.currentPage = 0;
    }
  });
  $scope.$watch('search.forkod', function (newval, oldval) {
    Store.forkod = newval;
    if (newval !== oldval) {
      Store.currentPage = 0;
      $scope.currentPage = 0;
    }
  });
  // Instantiate these variables outside the watch
  var tempFilterText = '',
      filterTextTimeout;
  $scope.$watch('fulltext', function (newval, oldval) {
      if (filterTextTimeout) $timeout.cancel(filterTextTimeout);
      
    // if (newval !== oldval){
      tempFilterText = newval;
      filterTextTimeout = $timeout(function() {
          $scope.filterText = tempFilterText;
          Store.fulltext = tempFilterText;
          if (newval !== oldval) {
            Store.currentPage = 0;
            $scope.currentPage = 0;  
          }
      }, 500); // delay 250 ms
      // }
  })
  $scope.newPage = function(page, eval) {
    if (eval){
      $scope.currentPage = page;
      Store.currentPage  = page;
    }
  }
});


var map_data = function(d, parish){
  var data = d.features;
  var ret = [];
  var val;
  for (var i=0,  tot=data.length; i < tot; i++) {
    if (data[i].properties.forkod == parish) {
      val = 1;
    } else {
      val = 0;
    }
    ret.push({
      code: data[i].properties.forkod,
      socken: data[i].properties.socken,
      value: val
    })
  }
  return ret;
}