{*
 * WiND - Wireless Nodes Database
 * Basic HTML Template
 *
 * Copyright (C) 2005 Nikolaos Nikalexis <winner@cube.gr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 dated June, 1991.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 *}
{literal}
var map;
var nodes = Array();
var links = Array();
var markers = Array();
var polylines = Array();

// Markers Optimization
GMap.prototype.addOverlays=function(a){ 
	var b=this; 
	for (i=0;i<a.length;i++) { 
		try {
			this.overlays.push(a[i]); 
			a[i].initialize(this); 
			a[i].redraw(true);
		} catch(ex) { 
			alert('Drawing error: ' + i + ', ' + ex.toString()); 
		} 
	} 
	this.reOrderOverlays(); 
};
{/literal}

var icon_green = Array(new GIcon(), new GIcon());
icon_green[0].image = "{$img_dir}gmap/mm_20_green.png";
icon_green[0].shadow = "{$img_dir}gmap/mm_20_shadow.png";
icon_green[0].iconSize = new GSize(12, 20);
icon_green[0].shadowSize = new GSize(22, 20);
icon_green[0].iconAnchor = new GPoint(6, 20);
icon_green[0].infoWindowAnchor = new GPoint(5, 1);

icon_green[1].image = "{$img_dir}gmap/mm_50_green.png";
icon_green[1].shadow = "{$img_dir}gmap/mm_50_shadow.png";
icon_green[1].iconSize = new GSize(20, 34);
icon_green[1].shadowSize = new GSize(37, 34);
icon_green[1].iconAnchor = new GPoint(9, 32);
icon_green[1].infoWindowAnchor = new GPoint(10, 1);

var icon_orange = Array(new GIcon(), new GIcon());
icon_orange[0].image = "{$img_dir}gmap/mm_20_orange.png";
icon_orange[0].shadow = "{$img_dir}gmap/mm_20_shadow.png";
icon_orange[0].iconSize = new GSize(12, 20);
icon_orange[0].shadowSize = new GSize(22, 20);
icon_orange[0].iconAnchor = new GPoint(6, 20);
icon_orange[0].infoWindowAnchor = new GPoint(5, 1);

icon_orange[1].image = "{$img_dir}gmap/mm_50_orange.png";
icon_orange[1].shadow = "{$img_dir}gmap/mm_50_shadow.png";
icon_orange[1].iconSize = new GSize(20, 34);
icon_orange[1].shadowSize = new GSize(37, 34);
icon_orange[1].iconAnchor = new GPoint(9, 32);
icon_orange[1].infoWindowAnchor = new GPoint(10, 1);

var icon_blue = Array(new GIcon(), new GIcon());
icon_blue[0].image = "{$img_dir}gmap/mm_20_blue.png";
icon_blue[0].shadow = "{$img_dir}gmap/mm_20_shadow.png";
icon_blue[0].iconSize = new GSize(12, 20);
icon_blue[0].shadowSize = new GSize(22, 20);
icon_blue[0].iconAnchor = new GPoint(6, 20);
icon_blue[0].infoWindowAnchor = new GPoint(5, 1);

icon_blue[1].image = "{$img_dir}gmap/mm_50_blue.png";
icon_blue[1].shadow = "{$img_dir}gmap/mm_50_shadow.png";
icon_blue[1].iconSize = new GSize(20, 34);
icon_blue[1].shadowSize = new GSize(37, 34);
icon_blue[1].iconAnchor = new GPoint(9, 32);
icon_blue[1].infoWindowAnchor = new GPoint(10, 1);

var icon_red = Array(new GIcon(), new GIcon());
icon_red[0].image = "{$img_dir}gmap/mm_20_red.png";
icon_red[0].shadow = "{$img_dir}gmap/mm_20_shadow.png";
icon_red[0].iconSize = new GSize(12, 20);
icon_red[0].shadowSize = new GSize(22, 20);
icon_red[0].iconAnchor = new GPoint(6, 20);
icon_red[0].infoWindowAnchor = new GPoint(5, 1);

icon_red[1].image = "{$img_dir}gmap/mm_50_red.png";
icon_red[1].shadow = "{$img_dir}gmap/mm_50_shadow.png";
icon_red[1].iconSize = new GSize(20, 34);
icon_red[1].shadowSize = new GSize(37, 34);
icon_red[1].iconAnchor = new GPoint(9, 32);
icon_red[1].infoWindowAnchor = new GPoint(10, 1);

{literal}
function gmap_onload() {
	if (GBrowserIsCompatible()) {
		map = new GMap(document.getElementById("map"));
		var center = new GPoint({/literal}{$center_longitude}{literal}, 
								{/literal}{$center_latitude}{literal});
		var s_long = 	({/literal}{$max_longitude|default:0}{literal}) -
						({/literal}{$min_longitude|default:0}{literal});
		var s_lat =		({/literal}{$max_latitude|default:0}{literal}) -
						({/literal}{$min_latitude|default:0}{literal});
		var span = new GSize(s_long, s_lat);
		var zoom = map.spec.getLowestZoomLevel(center, span, map.viewSize); 
		if ('{/literal}{$zoom}{literal}' != '') {
			zoom = {/literal}{$zoom|default:0}{literal};
		}
		map.centerAndZoom(center, zoom);
		map.addControl(new GLargeMapControl());
		map.setMapType(G_SATELLITE_TYPE);
		GEvent.addListener(map, "moveend", gmap_reload);
		GEvent.addListener(map, "zoom",
				function (oldZoomLevel, newZoomLevel) {
					if ((oldZoomLevel > 3 && newZoomLevel <= 3) ||
						(oldZoomLevel <= 3 && newZoomLevel > 3))
							map.clearOverlays();
							markers = Array();
							polylines = Array();
							gmap_reload();
				});
		gmap_refresh();
	}
}

function gmap_reload() {
	var markers_t = Array();
	var polylines_t = Array();
	var bounds = map.getBoundsLatLng();
	var ch_p2p = document.getElementsByName("p2p")[0];
	var ch_aps = document.getElementsByName("aps")[0];
	var ch_clients = document.getElementsByName("clients")[0];
	var ch_unlinked = document.getElementsByName("unlinked")[0];
	for (var i = 0; i < nodes.length; i++) {
		if (markers[i] != undefined) continue;

		var node_id = nodes[i].getAttribute("id");
		var node_name = nodes[i].getAttribute("name");
		var node_area = nodes[i].getAttribute("area");
		var node_p2p = nodes[i].getAttribute("p2p") * 1;
		var node_aps = nodes[i].getAttribute("aps") * 1;
		var node_client_on_ap = nodes[i].getAttribute("client_on_ap") * 1;
		var node_clients = nodes[i].getAttribute("clients") * 1;
		var node_lat = nodes[i].getAttribute("lat");
		var node_lon = nodes[i].getAttribute("lon");
		var node_url = nodes[i].getAttribute("url");

		var show_p2p = node_p2p > 0 &&
						ch_p2p.checked == true;
		var show_aps = node_aps > 0 &&
						ch_aps.checked == true;
		var show_clients = node_client_on_ap > 0 &&
							ch_clients.checked == true;
		var show_unl = node_p2p == 0 && 
						node_client_on_ap == 0 &&
						ch_unlinked.checked == true;
		var show_nodes = show_p2p || show_aps || show_clients || show_unl;
		var inbounds = node_lat >= bounds.minY &&
						node_lat <= bounds.maxY &&
						node_lon >= bounds.minX &&
						node_lon <= bounds.maxX;
		if (show_nodes && inbounds) {
	    	var point = new GPoint(node_lon, 
	    							node_lat);
			var icon; var icon_s;
			if (map.getZoomLevel() <= 3) {
				var icon_scale = 1;
		    } else {
				var icon_scale = 0;
		    }
			if (node_aps > 0) {
				icon = icon_green[icon_scale];
				icon_s = icon_green[0];
			} else if (node_p2p > 0) {
				icon = icon_orange[icon_scale];
				icon_s = icon_orange[0];
			} else if (node_client_on_ap > 0) {
				icon = icon_blue[0];
				icon_s = icon_blue[0];
			} else {
				icon = icon_red[0];
				icon_s = icon_red[0];
			}
			var html = "<div style=\"text-align:left; font-size:12px;font-weight:bold;\"><img src=\"" + icon_s.image + "\" alt=\"\" />" + node_name + " (#" + node_id + ")</div><br />" +
						"<div style=\"text-align:left; font-size:10px;\">" +
						node_area + "<br />" +
						"{/literal}{$lang.links}{literal}: " + (parseInt(node_p2p) + parseInt(node_client_on_ap)) + " (+" + node_aps + " {/literal}{$lang.aps}{literal})" + "<br />" +
						"{/literal}{$lang.clients}{literal}: " + node_clients + "<br /><br />" +
						"<a href=\"" + node_url + "\">{/literal}{$lang.node_page}{literal}</a></div>";
			var marker = createMarker(point, html, icon);
			markers_t.push(marker);
			markers[i] = true;
		}
	}
	for (var i = 0; i < links.length; i++) {
		if (polylines[i] != undefined) continue;
		var show_l_p2p = links[i].getAttribute("type") == "p2p" &&
							ch_p2p.checked == true;
		var show_l_clients = links[i].getAttribute("type") == "client" &&
								ch_clients.checked == true;
		var show_links = show_l_p2p || show_l_clients;
		var l_inbound_1 = links[i].getAttribute("lat1") >= bounds.minY &&
							links[i].getAttribute("lat1") <= bounds.maxY &&
							links[i].getAttribute("lon1") >= bounds.minX &&
							links[i].getAttribute("lon1") <= bounds.maxX;
		var l_inbound_2 = links[i].getAttribute("lat2") >= bounds.minY &&
							links[i].getAttribute("lat2") <= bounds.maxY &&
							links[i].getAttribute("lon2") >= bounds.minX &&
							links[i].getAttribute("lon2") <= bounds.maxX;
		var l_inbounds = l_inbound_1 || l_inbound_2
		if (show_links && l_inbounds) {
			if (links[i].getAttribute("status") == 'active') {
				var color = "#00ff00";
			} else {
				var color = "#ff0000";
			}
			var point1 = new GPoint(links[i].getAttribute("lon1"),
									links[i].getAttribute("lat1"));
			var point2 = new GPoint(links[i].getAttribute("lon2"),
									links[i].getAttribute("lat2"));
			var polyline = new GPolyline([point1, point2], color,
							(links[i].getAttribute("type")=="p2p"?3:1));
			polylines_t.push(polyline);
			polylines[i] = true;
		}
    }
	map.addOverlays(markers_t);
	map.addOverlays(polylines_t);
}

function gmap_refresh() {
	var ch_p2p = document.getElementsByName("p2p")[0];
	var ch_aps = document.getElementsByName("aps")[0];
	var ch_clients = document.getElementsByName("clients")[0];
	var ch_unlinked = document.getElementsByName("unlinked")[0];
	var request = GXmlHttp.create();
	var xml_url = "{/literal}{$link_xml_page}{literal}" + 
					(ch_p2p.checked == true?"&show_p2p=1":"") +
					(ch_aps.checked == true?"&show_aps=1":"") +
					(ch_clients.checked == true?"&show_clients=1":"") +
					(ch_unlinked.checked == true?"&show_unlinked=1":"");
	request.open("GET", xml_url, true);
	request.onreadystatechange = 
			function() {
				if (request.readyState == 4) {
					var xmlDoc = request.responseXML;
					nodes = xmlDoc.documentElement.getElementsByTagName("node");
					links = xmlDoc.documentElement.getElementsByTagName("link");
					map.clearOverlays();
					markers = Array();
					polylines = Array();
					gmap_reload();
				}
			}
	request.send(null);
}

function createMarker(point, html, icon) {
	var marker = new GMarker(point, icon);
	GEvent.addListener(marker, "click",
		function() {
			marker.openInfoWindowHtml(html);
		});

	return marker;
}
{/literal}
