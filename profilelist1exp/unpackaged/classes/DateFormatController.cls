public class DateFormatController {

    public Idea ideaParam { get; set; }
    public IdeaComment commentParam { get; set; }

    public String getDateDisplay() {
        
      
        Datetime datetimeValue;
        if (ideaParam != null) {
            datetimeValue = ideaParam.createdDate;
        }
        else if (commentParam != null) {
            datetimeValue = commentParam.createdDate;
        }
        else {
            return '';
        }

        String dateDisplay;
        DateTime now = DateTime.now();
        long nowMS = now.getTime();
        long createdDateMS = datetimeValue.getTime();
        long millisAgo = nowMS - createdDateMS;
        DateTime beginningOfDayNow = DateTime.newInstance(now.year(), now.month(), now.day());
        DateTime beginningOfDayCreatedDate = DateTime.newInstance(datetimeValue.year(), datetimeValue.month(), datetimeValue.day());
        long daysAgo = (beginningOfDayNow.getTime() - beginningOfDayCreatedDate.getTime()) / 86400000;
        

        
        
        if (daysAgo > 0) {
        // today, i.e. "7:20am"
          if (daysAgo < 2) {
            // "Yesterday"
            dateDisplay = 'Yesterday';
          } 
          else if (daysAgo < 4) {
            dateDisplay = String.valueOf(daysAgo) + ' days ago';
            // "2 days ago", "3 days ago"
          }
          else {
            // month and date of this year, i.e. "Jul 19, 2002"
            dateDisplay = datetimeValue.format('MMM d, yyyy');
          }
        } else if (millisAgo > 1800000) {
          dateDisplay = datetimeValue.format('h:mm a');                   
        } else if (millisAgo > 60000) {
          dateDisplay = String.valueOf(millisAgo / 60000) + ' minutes ago';
        }
        else {
          dateDisplay = String.valueOf(millisAgo / 1000) + ' seconds ago';
        }



        return dateDisplay;

        
    }

}