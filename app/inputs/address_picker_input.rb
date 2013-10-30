class AddressPickerInput < SimpleForm::Inputs::Base

  def input
    Rails.logger.info '-------------------------------------'
    Rails.logger.info input_html_options
    Rails.logger.info '-------------------------------------'
    input_field = @builder.hidden_field(attribute_name, input_html_options)
    input_id = input_field[/ id="(\w*)/, 1]
    out = <<-eod
#{input_field}
<div id="#{input_id}_map" class="map"></div>


<script type="text/javascript">
(function ($) {
    $(function () {

        var attribution = '&copy; <a target="_blank" href="http://openstreetmap.org">OSM</a>'
        var base = L.tileLayer('http://{s}.aerial.openstreetmap.org.za/ngi-aerial/{z}/{x}/{y}.jpg', {
            attribution: '&copy; <a title="Map source: Chief Directorate : National Geo-spatial Information" target="_blank" href="http://www.ngi.gov.za/">CD:NGI</a>',
            maxZoom: 28
        });
        var streetmap = L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png', {
            attribution: '<a title="Tiles Courtesy of MapQuest" href="http://www.mapquest.com/" target="_blank"><img src="http://developer.mapquest.com/content/osm/mq_logo.png"></a> | '+attribution,
            subdomains: '1234',
            maxZoom: 28
        });
        var cloudmadeUrl = 'http://{s}.tile.cloudmade.com/f116990e693a4407b40b8d27465fafd2/{styleId}/256/{z}/{x}/{y}.png';
        var streets = L.tileLayer(cloudmadeUrl, {styleId: 105314, attribution: attribution});
        var #{attribute_name}_map = L.map('#{input_id}_map', {
            center: new L.LatLng(-26.0977,27.876091),
            zoom: 18,
            layers: [base, streets]
        });
        L.control.layers({'Aerial View':base, 'Map View': streetmap}, {'Streets': streets}).addTo(#{attribute_name}_map);

        var v_marker = L.marker([-26.0977,27.876091]).addTo(#{attribute_name}_map);
        window.marker = v_marker;
        v_marker.bindPopup('<p class="logo"><b>✔</b>eriagent</p>').openPopup();
        var popup = L.popup();

        #{attribute_name}_map.on('click', function (e) {
            window.e = e;
            //  console.log(e);
            $.ajax({
                url: 'http://universe.veriagent.co.za/reverse.php',
                data: {
                    format: 'json',
                    zoom: 18,
                    addressdetails: 1,
                    lat: e.latlng.lat,
                    lon: e.latlng.lng
                },
                success: function (data) {
                    //        console.log(data);
                    $("#address-search").select2('data', data);
                }
            });
            //  distancePopup(e.latlng);
        });

        $("##{input_id}").on('change', function (e) {
            if (e.added.lat) {
                latlng = [e.added.lat, e.added.lon]
                window.latlng = latlng;
                #{attribute_name}_map.panTo(latlng);
                //   distancePopup(latlng);
            }
        }).select2({
            placeholder: "Address search",
            id: function (data) {
                return data.osm_id
            },
            minimumInputLength: 10,
            ajax: {
                url: 'http://universe.veriagent.co.za/search.php?',
                data: function (term, page) {
                    console.log('dt', term, page);
                    return {
                        q: term,
                        format: 'json',
                        countrycodes: 'za',
                        addressdetails: 1,
                        bounded: 1,
                        limit: 10
                    }
                },
                results: function (data, page) {
                    console.log('tx',data, page);
                    return {results: data};
                }
            },
            initSelection: function (element, callback) {
                var id=$(element).val();
                if (id!=="") {
                    $.ajax({
                        url: 'http://universe.veriagent.co.za/reverse.php',
                        data: {
                            format: 'json',
                            osm_type: 'N',
                            addressdetails: 1,
                            osm_id: id
                        },
                        success: function (data) { callback(data); }
                    });
                }
            },
            createSearchChoice: function (term) {
                term = term.replace(/,? *(South Africa|za|SAR|RSA|SA)/, '') + ', South Africa';
                return {id: term, display_name: term};
            },
            formatResult: function (data) {
                return '<table><tr><td>'+(data.icon ? '<img class="pull-left" src="'+data.icon+'">' : '') +
                        '</td><td>'+ data.display_name +'</td></tr></table>';
            },
            formatSelection: osmFormatSelection,
            escapeMarkup: function (m) { return m; }
        });

    });
    function osmFormatSelection(data) {
        return data.display_name;
    }

})(window.jQuery);

</script>
eod
    out.html_safe
  end

end
