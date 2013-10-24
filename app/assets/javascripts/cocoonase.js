//= require cocoon
//= require masonry-docs.min
(function($) {

    $(function () {
        $('form').submit(function () {
            $('input[readonly="readonly"]', this).attr('disabled', 'disabled');
        });

        $.expander.defaults.slicePoint    = 45;
        $.expander.defaults.preserveWords = false;
        $('dd.content').not('.no-expander').expander();
        $('.scaffold-table td').not('.no-expander').expander();

        initWidgets();
        console.log('cocoonase')


        $('.nested-group').bind('cocoon:before-insert', function(e, to_be_added) {
            to_be_added.fadeIn('slow');
        }).bind('cocoon:after-insert', function(e, just_added) {
                $('input[type!="hidden"]', just_added).first().focus();
                $('.sidebar-nav').scrollspy('refresh');
                initWidgets();
                $('input.switch', just_added).removeClass('switch').addClass('make-switch');
                $('.make-switch', just_added)['bootstrapSwitch']();
            });



    });

    function initWidgets() {
        $('.container.well .row').last().masonry({
            gutter: 0,
            itemSelector: '.col-md-6',
            stamp: ".stamp"
        });
        $('.container.well .row .stamp').css('position', 'relative');

        $('select').select2();

        $('.datetime-picker input[readonly!="readonly"]').datetimepicker({
            format: "yyyy-mm-dd hh:ii:ss",
            autoclose: true,
            todayBtn: true,
            weekStart: 1,
            todayHighlight: true,
            pickerPosition: "bottom-left"
        }).find('input:first').removeAttr('size');

        $('.date-picker input[readonly!="readonly"]').datetimepicker({
            format: "yyyy-mm-dd",
            autoclose: true,
            todayBtn: true,
            todayHighlight: true,
            startView: 2,
            minView: 2,
            maxView: 2,
            weekStart: 1,
            pickerPosition: "bottom-left"
        }).find('input:first').removeAttr('size');

        $('.time-picker input[readonly!="readonly"]').timepicker({
            minuteStep: 5,
            secondStep: 10,
            defaultTime: false,
            showSeconds: true,
            showMeridian: false,
            showInputs: false,
            disableFocus: true
        }).find('input:first').removeAttr('size');

        $('textarea:not([name*="address"])').each(function () {
            if ($(this).css('display') != 'none')
                $(this).addClass('editor').attr('rows', 5).wysihtml5();
        });
    }


})(jQuery);
