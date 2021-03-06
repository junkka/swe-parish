$(document).ready(function() {
  var parishid = $('.parishid').attr('value');
  var county = $('.parishcounty').attr('value');

  $.ajax({
    url: '../data/back' + county + '.geo.json',
    type: 'GET',
    async: true,
    dataType: "json",
    success: function (b) {
      $.ajax({
        url: '../data/map' + county + '.geo.json',
        type: 'GET',
        async: true,
        dataType: "json",
        success: function (d) {
            render_highmap(d, b, map_data(d, parishid));
        }
      });
    }
  });

});
 
var map_data = function(d, parish){
  var data = d.features;
  var ret = [];
  var val;
  for (var i=0,  tot=data.length; i < tot; i++) {
    if (data[i].properties.forkod == parish) {
      val = '#A28238';
    } else {
      val = '#F6EBD3';
    }
    ret.push({
      code: data[i].properties.forkod,
      socken: data[i].properties.socken,
      pid: data[i].properties.pid,
      color: val
    });
  }
  return ret;
};

var render_highmap = function(d, b, data) {
  map = new Highcharts.Map({
    chart: {
      renderTo: 'map',
      borderWidth : 1,
      borderColor: '#D7D7D7'
    },      
    title: {
      text: '<button role="button" class="btn btn-defualt" ><a href="../map.html">Till översiktskarta</a></button>',
      useHTML: true
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
      mapData: b,
      color: '#D8D8E7',
      name: 'background'
    },{
      data: data,
      mapData: d,
      name: 'Parish',
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
    }]
  });
  
  Highcharts.wrap(Highcharts.Point.prototype, 'select', function (proceed) {
    
    proceed.apply(this, Array.prototype.slice.call(arguments, 1));
    var points = map.getSelectedPoints();
    if (points.length) {
      window.location.href = points[0].pid + ".html";
    }
  });

      
      
};