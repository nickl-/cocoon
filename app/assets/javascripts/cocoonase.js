//= require cocoon
//= require masonry-docs.min
(function($, window, document) {

    var scroll_y_now = window.scrollY;
    document.addEventListener("page:fetch", function () {
        scroll_y_now = window.scrollY;
    });
    document.addEventListener("page:load", function () {
        window.scrollTo(window.scrollX, scroll_y_now);
    });
//    document.addEventListener("page:fetch", startSpinner);
//    document.addEventListener("page:receive", stopSpinner);

    function sort_select2(results, container, query) {
        if (query.term)
            // use the built in javascript sort function
            return results.sort(function(a, b) {
                if (a.text.length > b.text.length)
                    return 1;
                else if (a.text.length < b.text.length)
                    return -1;
                else
                    return 0;
            });
       else
             return results.sort(function(a, b) {
                 if (a.children)
                    sort_select2(a.children, container, query);
                if (b.children)
                    sort_select2(b.children, container, query);
                return a.text > b.text ? 1 : a.text < b.text ? -1 : 0;
            });
       return results;
    }

    $.fn.select2.defaults.sortResults    = sort_select2;
    $.fn.select2.defaults.placeholder    = 'Choose from the list.';
    $.expander.defaults.slicePoint       = 45;
    $.expander.defaults.collapseTimer    = 20000;
    $.expander.defaults.preserveWords    = false;
    $.expander.defaults.expandText       = '(more)';
    $.expander.defaults.userCollapseText = '(less)';

    $(function () {
        $('form').submit(function () {
            $('input[readonly="readonly"]', this).attr('disabled', 'disabled');
        });

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


})(window.jQuery, window, window.document);
