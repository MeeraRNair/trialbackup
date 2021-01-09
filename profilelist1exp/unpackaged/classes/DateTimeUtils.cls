public class DateTimeUtils {
	public static Datetime convertToDateTime(Date dateValue){
    	
    	Datetime resultDatetime;
    	if(dateValue != null){
    		resultDatetime = datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day(),0,0,0);
    	}    	  
    	return resultDatetime;  	
    }
}