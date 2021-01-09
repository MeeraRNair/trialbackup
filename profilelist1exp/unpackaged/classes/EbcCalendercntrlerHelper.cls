/***********************************************************

* Name          : EbcCalendercntrlerHelper 

* Description: Helper Class  for calendar booking for Executive Briefing Center

* ---------------------------------------------------------

* Revision  Name    Date        Description

* 1.0       Ambily  30-Mar-2011:   CR #5748 
* 2.0       Ambily  30-Jun-2011:   CR #6358 ,CR #6364 ,CR # 6365 , CR #6366 ,CR #6367

 

************************************************************/


public class EbcCalendercntrlerHelper {

    //Returns the datetime value of the arguments
    public Datetime getDateTimeFormat(Integer day_i,Integer month_i,Integer year_i) {
        string year = ''+year_i;
        string month = ''+month_i;
        string day = ''+day_i;
        string hour = '00';
        string minute = '00';
        string second = '00';
        string stringDate = year.trim() + '-' + month.trim()+ '-' + day.trim() + ' ' + hour + ':' +minute + ':' + second;
        return(datetime.valueOf(stringDate));
    }
    
    //Returns the Month Name corresponding to a month Number
    public String getMonthName(Integer monthNum){ 
        String monthName;
        if(monthNum==1)
            monthName='Jan';
        else if(monthNum==2)
            monthName='Feb';
        else if(monthNum==3)
            monthName='Mar';
        else if(monthNum==4)
            monthName='Apr';
        else if(monthNum==5)
            monthName='May';
        else if(monthNum==6)
            monthName='Jun';
        else if(monthNum==7)
            monthName='Jul';
        else if(monthNum==8)
            monthName='Aug';
        else if(monthNum==9)
            monthName='Sep';
        else if(monthNum==10)
            monthName='Oct';
        else if(monthNum==11)
            monthName='Nov';
        else if(monthNum==12)
            monthName='Dec';
        else 
            system.debug('ERROR');
        return monthName;
    }
    
    //Returns the Month Number corresponding to a month Name
    public String getmonthNumber(String monthName) {
        String monthNumber;
        if(monthName=='Jan')
            monthNumber='01';
        else if(monthName=='Feb')
            monthNumber='02';
        else if(monthName=='Mar')
            monthNumber='03';
        else if(monthName=='Apr')
            monthNumber='04';
        else if(monthName=='May')
            monthNumber='05';
        else if(monthName=='Jun')
            monthNumber='06';
        else if(monthName=='Jul')
            monthNumber='07';
        else if(monthName=='Aug')
            monthNumber='08';
        else if(monthName=='Sep')
            monthNumber='09';
        else if(monthName=='Oct')
            monthNumber='10';
        else if(monthName=='Nov')
            monthNumber='11';
        else if(monthName=='Dec')
            monthNumber='12';
        else 
        system.debug('ERROR');
        return monthNumber;
    }
}