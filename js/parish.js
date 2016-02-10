$(document).ready(function() {
  var parishid = $('.parishid').attr('value');
  var county = $('.parishcounty').attr('value');

  $.ajax({
    url: '../data/map' + county + '.geo.json',
    type: 'GET',
    async: true,
    dataType: "json",
    success: function (d) {
        render_highmap(d, map_data(d, parishid));
    }
  });

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
    });
  }
  return ret;
};

var render_highmap = function(d, data) {
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