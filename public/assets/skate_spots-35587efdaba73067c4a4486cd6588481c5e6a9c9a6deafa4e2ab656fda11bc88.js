function all_coords(){var e=document.getElementById("all_latlng").innerHTML;coords_size=e.length;return e.slice(1,coords_size-1).split(",")}function allinitMap(){for(var e=all_coords(),n=$.map(e,function(e){return[e]}),o=[],t=3;n.length>0;)o.push(n.splice(0,t));var a=[];for(g=0;g<o.length;g++)a.push(o[g]);var l,g,p=new google.maps.Map(document.getElementById("index_map"),{zoom:6,center:new google.maps.LatLng(e[1],e[2]),mapTypeId:google.maps.MapTypeId.ROADMAP}),r=new google.maps.InfoWindow;for(g=0;g<a.length;g++)l=new google.maps.Marker({position:new google.maps.LatLng(a[g][1],a[g][2]),map:p}),google.maps.event.addListener(l,"click",function(e,n){return function(){r.setContent(a[n][0]),r.open(p,e)}}(l,g))}