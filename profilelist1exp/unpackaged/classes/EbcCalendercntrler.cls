/***********************************************************

* Name          : EbcCalendercntrler 

* Description: Controller Class  for calendar booking for Executive Briefing Center

* ---------------------------------------------------------

* Revision  Name    Date        Description

* 1.0       Ambily  30-Mar-2011:   CR #5748 
* 2.0       Ambily  30-Jun-2011:   CR #6365 - Ability to customize lead times for Briefings per site. 3 weeks could be too much lead time for some sites
* 3.0       Samridh 31-Dec-2013:   CR #9039 - page navigation when DSC record Type is selected for new records
 

************************************************************/

public class EbcCalendercntrler {
    
    //Class Variables
    public static String CONFIRM_DETAILS_FOR_BOOKING {get{return 'CONFIRM_DETAILS_FOR_BOOKING';}} 
    public static String CONFIRM_DETAILS_FOR_WAITLIST {get{return 'CONFIRM_DETAILS_FOR_WAITLIST';}} 
    public static String WAITLIST_UNAVAILABLE   {get{return 'WAITLIST_UNAVAILABLE';}} 
    public static String DISPLAY_FIRST_MONTH {get{return 'DISPLAY_FIRST_MONTH';}} 
    public static String DISPLAY_SECOND_MONTH {get{return 'DISPLAY_SECOND_MONTH';}} 
    public static String DISPLAY_THIRD_MONTH {get{return 'DISPLAY_THIRD_MONTH';}} 
    public static String START_DATE_NOT_NULL {get{return 'START_DATE_NOT_NULL';}} 
    public static String START_DATE_GREATER_THAN_TODAY {get{return 'START_DATE_GREATER_THAN_TODAY';}} 
    public static String ROOMS_UNAVAILABLE_FOR_CONSECUTIVE_DAYS {get{return 'ROOMS_UNAVAILABLE_FOR_CONSECUTIVE_DAYS';}} 
    public static String START_DATE_VALID {get{return 'START_DATE_VALID';}} 
    public static String TOURS_UNAVAILABLE {get{return 'TOURS_UNAVAILABLE';}}
    public static String PM_AVAILABLE {get{return 'PM_AVAILABLE';}}  
    //public static String BOOK_WHOLE_DAY {get{return 'BOOK_WHOLE_DAY';}} 
    public Customer_Engagement__c customerEngagement {get; set;}
    public String siteName;
    public Date sDate {get; set;}
    public String timeSlotSelected { get; set; }
    public String siteId;
    public String noOfDays { get; set; }
    public String sitenotes{get;set;}
    public Boolean confirmDetails{get;set;}
    public Boolean waitingListAvailable{get;set;}
    public EbcCalenderActioncntrler ebcCalenderActioncntrlerObj{get;set;}
    public EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj{get;set;}
    public datetime startingDateTime = datetime.now().adddays(21);
    public Date startingDate=date.newInstance(startingDateTime.year(), startingDateTime.month(), startingDateTime.day());
    public datetime endingdateTime=startingDateTime.adddays(30);
    Date endingDate=date.newInstance(endingdateTime.year(), endingdateTime.month(), endingdateTime.day()); 
    String roomrequirement;
    String cm_bookingdate;
    String tourbooked;
    public boolean Error {get;set;}    
    public string status{get;set;}   
    public string statusFirstMonth{get;set;}   
    public string statusSecondMonth{get;set;}   
    public string statusThirdMonth{get;set;}   
    String ebcRTId;
    String dscRTId;
    public boolean refreshCal {get;set;}    
    Datetime startingDateTimenew = startingDateTime;
    Date startingDatenew = startingDate;
    public boolean adminUser{get;set;}
    public Integer leadTime{get;set;}    
    public boolean webcast{get;set;} 
    boolean offerHalfDay=false;
    public boolean pmFlag {get; set;}
    public boolean displayFlag {get; set;}
    public boolean pmFlag_dbl {get; set;}
    public boolean displayFlag_dbl {get; set;}
    public boolean bothMsgFlag {get; set;}
    public boolean bothPmFlag {get; set;}
    public boolean singleRoom {get; set;}
    public boolean doubleRoom {get; set;}
    Date todaysDate = System.today();
      
    public EbcCalendercntrler(ApexPages.StandardController controller) {
        this.customerEngagement = (Customer_Engagement__c)controller.getRecord(); 
        //this.noOfDays='1';
        this.refreshCal=false;
        List<RecordType> ebcRT=[select id,name,SobjectType  from RecordType where SobjectType='Customer_Engagement__c' and name='Executive Briefing Center' limit 1];
        for(RecordType r:ebcRT){
            ebcRTId=r.Id;
        }
         List<RecordType> dscRT=[select id,name,SobjectType  from RecordType where SobjectType='Customer_Engagement__c' and name='Dell Solution Centers' limit 1];
        for(RecordType a:dscRT){
            dscRTId=a.Id;
        }
        this.adminUser=false;

        this.leadTime=22;//CR #6366
        Map<Id,Profile>adminMap = new Map<Id, Profile>([select Name,Id from Profile where Name Like '%Customer Engagements Analyst%' 
                                                                                        or Name Like '%Customer Engagements Admin%' 
                                                                                        or Name Like '%System Administrator%'
                                                                                        or Name Like '%IT Captain Hook User%'
                                                                                        or Name Like '%IT Configuration User%'
                                                                                        or Name Like '%IT GBL Data Load%'
                                                                                        or Name Like '%IT GBL Read Only%'
                                                                                        or Name Like '%IT GBL Read Only - IdeaAdmin%'
                                                                                        or Name Like '%IT Integration API Only%'
                                                                                        or Name Like '%IT Manage Users - Sales Central%'
                                                                                        or Name Like '%IT TA User%']);
        adminUser = adminMap.containsKey(userinfo.getProfileID());        
    }
    
    /*Calendar gets displayed*/
    public PageReference populateSites() {
        try{
                Date startDateselected;
                startDateselected=customerEngagement.GSL_Start_Date__c;
                refreshCal=true;
                if(startDateselected==null){
                    Error =false;
                    status=START_DATE_NOT_NULL;
                    statusFirstMonth='';
                    statusSecondMonth='';
                    statusThirdMonth='';
                }else if (startDateselected< (date.today()+leadTime) && adminUser==false){//CR #6366
                    Error =false;
                    status=START_DATE_GREATER_THAN_TODAY;
                    statusFirstMonth='';
                    statusSecondMonth='';
                    statusThirdMonth='';
                }else{
                    status=START_DATE_VALID;
                    Date endDateselected=startDateselected+30;
                    startingDate=startDateselected;
                    endingDate=endDateselected;
                    EbcCalendercntrlerHelper EbcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
                    startingDateTime =ebcCalendercntrlerHelperObj.getDateTimeFormat(startingDate.day(),startingDate.month(),startingDate.year());
                    getAvailabilityDetails();
                    displaysitenotes(siteName);
                }
            return null;
        }catch(Exception e) {
            system.debug('Exception occured : '+e);
            return null; 
        }
    }
    
    /*Data in the calendar is populated*/
    public List<Availability> getAvailabilityDetails(){
        if(refreshCal==false){  
            startingDate = startingDatenew;
            startingDateTime = startingDateTimenew;
        }
        statusFirstMonth='';
        statusSecondMonth='';
        statusThirdMonth='';
        ebcCalenderActioncntrlerObj=new EbcCalenderActioncntrler(customerEngagement,siteId,noOfDays);
        List<Availability> availabilitylist=ebcCalenderActioncntrlerObj.getAvailabilityDetails(startingDate,endingDate,startingDateTime);
        if(customerEngagement.Event_Type__c!=null && siteId!=null){
            if((customerEngagement.Event_Type__c=='Tour')&&(ebcCalenderActioncntrlerObj.tourListSize<=0)){
                status = TOURS_UNAVAILABLE;
                Error = false;      
                statusFirstMonth='';
                statusSecondMonth='';
                statusThirdMonth='';
            }
            else{
                if(ebcCalenderActioncntrlerObj.alist1.size()>0)
                    statusFirstMonth='DISPLAY_FIRST_MONTH';
                if(ebcCalenderActioncntrlerObj.alist2.size()>0){
                    if((customerEngagement.Event_Type__c=='Tour')&& (ebcCalenderActioncntrlerObj.alist2.size()==1))
                        statusSecondMonth='';
                    else
                        statusSecondMonth='DISPLAY_SECOND_MONTH';
                }
                if(ebcCalenderActioncntrlerObj.alist3.size()>0){
                    if((customerEngagement.Event_Type__c=='Tour')&& (ebcCalenderActioncntrlerObj.alist3.size()==1))
                        statusThirdMonth='';
                    else
                        statusThirdMonth='DISPLAY_THIRD_MONTH';
                }
            }
        }
        return availabilitylist;
    }
    
    /* Sites are populated in the picklist accoring to the Event Type selected*/ 
    public List<SelectOption> getsites() {
        try{
            List<Event_Location__c> site=[SELECT Event__c,Id,Name FROM Event_Location__c where recordType.name='sites' and Active__c=true and Engagement_Type__c='EBC' ORDER BY Name ASC];
            List<SelectOption> options = new List<SelectOption>(); 
            if(customerEngagement.Event_Type__c!=null){
                if((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==true)){ //For CR 6358, CCR 0099
                    options.add(new SelectOption('Round Rock EBC','Round Rock EBC'));       
                }
                else{
                options.add(new SelectOption('','----------------- Select a Site -----------------'));
                for(Event_Location__c s:site){
                    if ((s.Event__c)!=null && (s.Event__c).contains(customerEngagement.Event_Type__c) )
                       options.add(new SelectOption(s.Name,s.Name));
                    }
                }
            }
            return options;
        }catch(Exception e) {
            system.debug('Exception occured : '+e);
            return null; 
        }
    }

    public List<SelectOption> getdays() {
        List<SelectOption> options = new List<SelectOption>();
        //if((pmFlag == true && offerHalfDay==true) || (pmFlag_dbl == true && offerHalfDay==true)){
        if(((pmFlag == true && offerHalfDay==true) || (pmFlag_dbl == true && offerHalfDay==true) || (bothPmFlag == true && offerHalfDay==true)) && (startingDate != todaysDate)){
            options.add(new SelectOption('PM','0.5 PM'));
            options.add(new SelectOption('AM','0.5 AM'));
        } 
        else if(((offerHalfDay==true && pmFlag == false) || (offerHalfDay==true && pmFlag_dbl == false) || (offerHalfDay==true && bothPmFlag == false)) && 
                ((startingDate == todaysDate) || (startingDate != todaysDate))){
            options.add(new SelectOption('AM','0.5 AM'));
            options.add(new SelectOption('PM','0.5 PM'));
        }
        options.add(new SelectOption('1','1'));
        options.add(new SelectOption('2','2'));
        options.add(new SelectOption('3','3'));
        options.add(new SelectOption('4','4'));
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('6','6'));
        options.add(new SelectOption('7','7'));
        options.add(new SelectOption('8','8'));
        options.add(new SelectOption('9','9'));
        options.add(new SelectOption('10','10'));
        return options;
    }

    public PageReference eventSelection() {
        if(webcast==true){
            customerEngagement.Event_Type__c='Briefing';
            customerEngagement.Webcast__c = true;
    }
        getsites();
        return null;
    }
    
    /*Data for the creation of Calendar management Record for confirmed booking is set*/
    public PageReference paramSetForNavigation(){
        String cm_roomsAvailable;
        cm_bookingdate=ApexPages.currentPage().getParameters().get('cdate');
        if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false))||(customerEngagement.Event_Type__c=='Field Briefing'))
            timeSlotSelected=ApexPages.currentPage().getParameters().get('roomreq');
        
        if(customerEngagement.Event_Type__c=='Tour')
            timeSlotSelected=ApexPages.currentPage().getParameters().get('tname');
                
        
            Error = false;      
            status = CONFIRM_DETAILS_FOR_BOOKING;  
            statusFirstMonth='';
            statusSecondMonth='';
            statusThirdMonth='';
        return null;
    }
    
    /*Data for the creation of Calendar management Record for waiting list is set*/
    public PageReference paramSetBookWaitingList() {
        cm_bookingdate=ApexPages.currentPage().getParameters().get('cdate');
        Error = false;      
        status = CONFIRM_DETAILS_FOR_WAITLIST;  
        statusFirstMonth='';
        statusSecondMonth='';
        statusThirdMonth='';                    
        return null;
    }
    
    
  /*  public PageReference bookWholeDayMethod(){
        timeSlotSelected=timeSlotSelected+'Whole Day';
        return navigationActionFunction();
    }
    */
    /*Actual Booking happens*/
    public PageReference navigationActionFunction(){
        ebcCalenderActioncntrlerObj=new EbcCalenderActioncntrler(customerEngagement,siteId,noOfDays);
        ebcCalenderActioncntrlerObj.getAvailabilityDetails(startingDate,endingDate,startingDateTime);
        PageReference pref;   
      /*  if(status == BOOK_WHOLE_DAY)
            timeSlotSelected=timeSlotSelected+'Confirmed';*/
        pref= ebcCalenderActioncntrlerObj.navigationActionFunction(timeSlotSelected,cm_bookingdate,startingDate,endingDate,startingDateTime);      
        /*if(ebcCalenderActioncntrlerObj.wholeDayBooking==true && status != BOOK_WHOLE_DAY){
            Error = false;      
            status = BOOK_WHOLE_DAY;                       
            statusFirstMonth='';
            statusSecondMonth='';
            statusThirdMonth='';
            return null;        
        }*/
        
        if(ebcCalenderActioncntrlerObj.consecutiveroomavailability==false){
            Error = false;      
            status = ROOMS_UNAVAILABLE_FOR_CONSECUTIVE_DAYS;                       
            statusFirstMonth='';
            statusSecondMonth='';
            statusThirdMonth='';
            return null;
        }
        return pref;
    }
    
   
   /*Booking for waiting list*/
    public PageReference bookWaitingList() {
        ebcCalenderActioncntrlerObj=new EbcCalenderActioncntrler(customerEngagement,siteId,noOfDays);
        ebcCalenderActioncntrlerObj.getAvailabilityDetails(startingDate,endingDate,startingDateTime);
        return ebcCalenderActioncntrlerObj.bookWaitingList(cm_bookingdate);
     }
     
    /*Redirects Page according to the Record selection*/
     public PageReference redirect() {
        PageReference pageRef ;
        pageRef = new PageReference('/a17/e?RecordType=012A0000000VhLo&ent=01IA00000016E4S&nooverride=1&retURL=/a17/o');
        PageReference pgref;
        pgref = new PageReference('/apex/Customer_Engagements_DSCpage');
        //pageRef = new PageReference('/a1K/e?RecordType=012T0000000D4cy&ent=01IT00000005Aw5&nooverride=1&retURL=/a1K/o');
        // pageRef = new PageReference('/a1W/e?RecordType=012T00000004hY4&ent=01IT0000000DTTz&nooverride=1&retURL=/a1W/o');
        String recSelcted=ApexPages.currentPage().getParameters().get('RecordType');
        displayFlag = false;
        displayFlag_dbl = false;
        bothMsgFlag = false;
        Error =false;
        status=START_DATE_VALID;
        statusFirstMonth='';
        statusSecondMonth='';
        statusThirdMonth='';
        if(recSelcted==ebcRTId.substring(0,15))
            return null;
        if(recSelcted==dscRTId.substring(0,15))
            return pgref;
        else
            return pageRef;
     }
     
     public void setsiteName(String siteName){ 
        this.siteName=siteName; 
        setsiteId(siteName);
     }
    
     public void setsiteId(String siteName){
        try{
            if(siteName!=null){
               Event_Location__c site=[SELECT Id,Name FROM Event_Location__c where Name =:siteName and recordType.name='sites' LIMIT 1];
               this.siteId=site.Id; 
            }
        }catch(Exception e) {
            system.debug('Exception occured : '+e);
        }
     }
     
     public String getsiteId(){ 
        return siteId;
     }
     
     public String getsiteName(){ 
        return siteName;
     }
     
     //CR #6366
     public PageReference displaypreferedDateRange(){ 
        this.siteName=siteName;
        Event_Location__c sitelist=[SELECT Id,Name,Half_Day__c,Lead_Time__c FROM Event_Location__c where Name =:siteName and recordType.name='sites' LIMIT 1];
        system.debug('sitelist'+sitelist);
        If(sitelist.Lead_Time__c!=null)
            leadTime=(sitelist.Lead_Time__c).intValue();        
        if(adminUser == true){//start the calendar display from today if admin has logged in
           startingDateTime = datetime.now(); 
        }
        else{ //else calendar display from 3 weeks
            startingDateTime = datetime.now().adddays(leadTime);
        }
        startingDate=date.newInstance(startingDateTime.year(), startingDateTime.month(), startingDateTime.day());
        endingdateTime=startingDateTime.adddays(30);
        endingDate=date.newInstance(endingdateTime.year(), endingdateTime.month(), endingdateTime.day()); 
        customerEngagement.GSL_Start_Date__c=startingDate;
        system.debug('sitelist.Half_Day__c'+sitelist.Half_Day__c+customerEngagement.Event_Type__c+customerEngagement.Webcast__c);
        if(sitelist.Half_Day__c==true && (((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false))||(customerEngagement.Event_Type__c=='Field Briefing'))){
            offerHalfDay=true;
            getdays();
            this.noOfDays='0.5 AM';
        }
        else{
            getdays();
            this.noOfDays='1';
        }
        Error =false;
        status=START_DATE_VALID;
        statusFirstMonth='';
        statusSecondMonth='';
        statusThirdMonth='';
        sDate = startingDate;
        displayMsgForHalfDay();
        return null;
     }
     
     public PageReference displayMsgForHalfDay(){
        Id s_roomId;
        Id d_roomId;
        this.siteName=siteName;
        pmFlag = false;
        displayFlag = false;
        pmFlag_dbl = false;
        displayFlag_dbl = false;
        bothPmFlag = false;
        bothMsgFlag = false;
        statusFirstMonth='';
        statusSecondMonth='';
        statusThirdMonth='';
        List<Id> roomIdList=new List<Id>();
        Map<Id, Integer> roomDetailsMap=new Map<Id, Integer>();
        List<Event_Location__c> roomsList=[SELECT Id,Name,Room_Occupancy__c,Room_Type__c 
                                            FROM Event_Location__c where Select_Site__c =:siteId 
                                            and recordType.name='rooms' and Active__c=true]; 
        List<Calendar_Management__c> calendarManagementListFors_room;
        List<Calendar_Management__c> calendarManagementListFord_room;
        Date startDateselected;
        startDateselected=customerEngagement.GSL_Start_Date__c;
        for(Event_Location__c room : roomsList){
            if(room.Room_Type__c=='Single'){
                s_roomId = room.Id;
                singleRoom = true;
            }
            if(room.Room_Type__c=='Double'){
                d_roomId = room.Id;
                doubleRoom = true;
            }
        }
        calendarManagementListFors_room=[select Date__c,Room__r.Id,Half_Day__c,Event_Record_type__c,recordType.name,Id, Status__c
                                        from Calendar_Management__c where Room__r.Id = :s_roomId and 
                                        Date__c = :sDate and
                                        ((Status__c='Pending' or Status__c='Scheduled') and (Event_Record_type__c='Briefing' or Event_Record_type__c='Field Briefing'))];
        
        calendarManagementListFord_room=[select Date__c,Room__r.Id,Half_Day__c,Event_Record_type__c,recordType.name,Id, Status__c
                                        from Calendar_Management__c where Room__r.Id = :d_roomId and 
                                        Date__c = :sDate and
                                        ((Status__c='Pending' or Status__c='Scheduled') and (Event_Record_type__c='Briefing' or Event_Record_type__c='Field Briefing'))];

        //For both rooms
        for(Calendar_Management__c singleCal : calendarManagementListFors_room){
            for(Calendar_Management__c doubleCal : calendarManagementListFord_room){
                if((singleCal.Half_Day__c == 'AM: 12 AM – 11:59 AM') && (doubleCal.Half_Day__c == 'AM: 12 AM – 11:59 AM')){
                    if((singleRoom == true && calendarManagementListFors_room.size() == 1) && (doubleRoom == true && calendarManagementListFord_room.size() == 1) ){
                        bothPmFlag = true;
                        bothMsgFlag = true;
                        return null;
                    }
                }
            }
        }
        
       //For Single Room 
       for(Calendar_Management__c singleCal : calendarManagementListFors_room){
            if(singleCal.Half_Day__c == 'AM: 12 AM – 11:59 AM'){
               if(singleRoom == true && calendarManagementListFors_room.size() == 1){ 
                    pmFlag = true;
                    displayFlag = true;
                    statusFirstMonth='';
                    statusSecondMonth='';
                    statusThirdMonth='';
                    return null;
                }
            }
            if(calendarManagementListFors_room.size() == 0){
                pmFlag = false;
                displayFlag = false;
                Error =false;
                status=START_DATE_VALID;
                statusFirstMonth='';
                statusSecondMonth='';
                statusThirdMonth='';
                return null;
            }
       }
       
                
       //For Double Room
       for(Calendar_Management__c doubleCal : calendarManagementListFord_room){
           if(doubleCal.Half_Day__c == 'AM: 12 AM – 11:59 AM'){
               if(doubleRoom == true && calendarManagementListFord_room.size() == 1){
                    pmFlag_dbl = true;
                    displayFlag_dbl = true;
                    statusFirstMonth='';
                    statusSecondMonth='';
                    statusThirdMonth='';
                    return null;
                }
            }
            if(calendarManagementListFord_room.size() == 0){
                pmFlag_dbl = false;
                displayFlag_dbl = false;
                Error =false;
                status=START_DATE_VALID;
                statusFirstMonth='';
                statusSecondMonth='';
                statusThirdMonth='';
                return null;
            }
       }
       return null;
     }
     
     public PageReference pmBooking(){
        this.noOfDays='0.5 PM';
        Error =false;
        status=START_DATE_VALID;
        statusFirstMonth='';
        statusSecondMonth='';
        statusThirdMonth='';
        displayFlag = false;
        displayFlag_dbl = false;
        bothMsgFlag = false;
        return null;
     }
     
     /*Sitenotes corresponding to each site is displayed*/
     public void displaysitenotes(String siteName){ 
        try{
            Event_Location__c sitelist=[SELECT Id,Name,Site_Notes__c FROM Event_Location__c where Name =:siteName and recordType.name='sites' LIMIT 1];
            this.sitenotes=sitelist.Site_Notes__c; 
        }catch(Exception e) {
            system.debug('Exception occured : '+e);
        }
     }
    
}