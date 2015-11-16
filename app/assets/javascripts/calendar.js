$(document).ready(function() {
  $calendar = $('#calendar');
  if ($calendar.length > 0) {
    $('#calendar').fullCalendar({
      lang: 'ru',
      height: 500,
      eventRender: function(event, element, view){
        if (event.ranges != undefined) {
          return (event.ranges.filter(function(range){
              return (event.start.isBefore(range.end) &&
                      event.end.isAfter(range.start));
          }).length) > 0;
        };
      },
      displayEventTime: false,
      eventSources: [
        {
          url: $(calendar).data('url')
        }
      ],
    });
  };
});
