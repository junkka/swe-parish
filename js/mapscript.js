$(document).ready(function() {
  $.ajax({
    url: 'data/county.geo.json',
    type: 'GET',
    async: true,
    dataType: "json",
    success: function (b) {
     render_fullmap(b, fullmap_data(b));
    }
  });
});



var parish_data = function(d){
  var data = d.features;
  var ret = [];
  for (var i=0,  tot=data.length; i < tot; i++) {
    ret.push({
      code: data[i].properties.forkod,
      socken: data[i].properties.socken,
      pid: data[i].properties.pid
    });
  }
  return ret;
};

var fullmap_data = function(d){
  var data = d.features;
  var ret = [];
  for (var i=0,  tot=data.length; i < tot; i++) {
    ret.push({
      code: data[i].properties.lan,
      name: data[i].properties.name,
      drilldown: data[i].properties.lan
    });
  }
  return ret;
};


var render_fullmap = function(d, data) {
  $('#fullmap').highcharts('Map', {
    chart: {
      borderWidth : 1,
      borderColor: '#D7D7D7',
      events: {
        drilldown: function (e) {
          if (!e.seriesOptions) {
            var chart = this;
            console.log(e);
            chart.showLoading('Laddar ...');
            $.ajax({
              url: 'data/map' + e.point.lan + '.geo.json',
              type: 'GET',
              async: true,
              dataType: "json",
              success: function (a) {
                var mapdata = parish_data(a);
                
                chart.hideLoading();
                chart.addSeriesAsDrilldown(e.point, {
                  name: e.point.name,
                  data: mapdata,
                  mapData: a,
                  joinBy: ['forkod', 'code'],
                  allowPointSelect: true,
                  dataLabels: {
                    enabled: true,
                    format: '{point.socken}'
                  },
                  tooltip: {
                    headerFormat: '',
                    pointFormat: '{point.socken} {point.forkod}'
                  }
                });
                
                Highcharts.wrap(Highcharts.Point.prototype, 'select', function (proceed) {
                  
                  proceed.apply(this, Array.prototype.slice.call(arguments, 1));
                  var points = chart.getSelectedPoints();
                  if (points.length) {
                    window.location.href = 'parish/' + points[0].pid + ".html";
                  }
                });

               
               
              }
            });
          }
        }
      }
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
    
   
    series : [{
      data: data,
      mapData: d,
      color: '#E1E0DA',
      name: 'Län',
      joinBy: ['lan', 'code'],
      dataLabels: {
        enabled: true,
        format: '{point.name}'
      },
      tooltip: {
        headerFormat: '',
        pointFormat: '{point.name}'
      }
    }],
    
    drilldown: {
      series: []      
    }
  });
};