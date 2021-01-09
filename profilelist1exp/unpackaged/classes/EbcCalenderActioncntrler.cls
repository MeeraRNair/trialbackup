/***********************************************************

* Name          : EbcCalenderActioncntrler 

* Description: Helper Class  for calendar booking for Executive Briefing Center

* ---------------------------------------------------------

* Revision  Name    Date        Description

* 1.0       Ambily  30-Mar-2011:   CR #5748 

* 2.0       Ambily  30-Jun-2011:   

CR #6358 - Need the ability to book ‘Event type: Webcast’ for admin/analyst. Need to be treated as Customer Engagements to be booked only by the Admins.
Should not be available for AEs to book.
CR #6364 - Ability to use the same room twice in one day. Many sites offer half day engagements and their site only have 1 room. 
CR #6366 - Internal events should be able to book a single room. Currently it books the whole site. 
CR #6367 - Currently a maximum of 3 Tours can be displayed/Site in the Calendar. Need to make it dynamic.
 

************************************************************/

public class EbcCalenderActioncntrler {
    public List<Availability> alist1=new List<Availability>();
    public List<Availability> alist2=new List<Availability>();
    public List<Availability> alist3=new List<Availability>();
    public Integer colspanalist1{ get; set; }
    public Integer colspanalist2{ get; set; }
    public Integer colspanalist3{ get; set; }
    public String firstmonth{get;set;}
    public Integer firstYear{get;set;}
    public String secondmonth{get;set;}
    public Integer secondYear{get;set;}
    public String thirdmonth{get;set;}
    public Integer thirdYear{get;set;}
    public String singleAvailText{get;set;}
    public String doublAvailText{get;set;}
    public String waitngLstTxt{get;set;}
    public String waitinglist{get;set;}
    public String waitinglistrowcolor{get;set;}
    public String waitinglistcellcolor{get;set;}
    public String waitinglistrowtext{get;set;}
    public String singleRoomAvailabilitycolor{get;set;}
    public String singleRoomAvailabilitycolorAM{get;set;}
    public String doubleRoomAvailabilitycolorAM{get;set;}
    
    //public String singleRoomAvailabilitycolor{get;set;}
    public String doubleRoomAvailabilitycolor{get;set;}
    
    public Boolean consecutiveroomavailability{get;set;}
    public Boolean wholeDayBooking{get;set;}
    public String singleRoomAvailabilitycolorPM{get;set;}
    public String doubleRoomAvailabilitycolorPM{get;set;}
    public EbcCalendercntrlerHelper ebcCalendercntrlerHelperObj{get;set;}
    public Customer_Engagement__c customerEngagement;
    public String siteId;
    public String noOfDays;
    Map<Id, Integer> roomDetailsMap=new Map<Id, Integer>();
    Map<Id, List<Bookingdetails>> calendarManagmentMap = new Map<Id, List<Bookingdetails>>();
    Map<Id, List<Bookingdetails>> roomAvailabilityDetailsMap= new Map<Id, List<Bookingdetails>>(); 
     Availability availability;
    String primaryCalendarRTId;
    String secondaryCalendarRTId;
    String ebcRTId;
    public Integer tourListSize{get;set;}
    Map<String, Id> recordTypeIdMap;
    List<Date> calendarManagementHolidayList;
    
    //Constructor
    public EbcCalenderActioncntrler(Customer_Engagement__c customerEngagement ,String siteId ,String noOfDays ){
        System.debug('action noOfDays : ' + noOfDays);
        this.customerEngagement =customerEngagement ;
        this.siteId =siteId ;
        this.noOfDays =noOfDays ;
        this.consecutiveroomavailability=true;
        this.wholeDayBooking=false;
        
        
        //Query Record Type 
        List<RecordType> recordtypelist=[select id,name,SobjectType  from RecordType where (SobjectType='Calendar_Management__c' or SobjectType='Customer_Engagement__c') and (name='Primary Calendar RT' or name='Secondary Calendar RT' or name='Executive Briefing Center' )];
        recordTypeIdMap= new Map<String, Id>();
        for(RecordType r:recordtypelist){
            recordTypeIdMap.put(r.name,r.Id);
        }
        
    }

    //CR 6364: Wrapper Class for Storing Booking/Availability
    class Bookingdetails{
       Date bookingdate;
       String timeslot;
    }

    //Method to display the details corresponding to each Event Type and event selected
    public List<Availability> getAvailabilityDetails(Date startingDate,Date endingDate,DateTime startingDateTime){
        String selectedSiteId=siteId;
        Integer monthcount=0;
        Integer startdate_date_i=startingDateTime.day();
        ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        String startdate_month_s=ebcCalendercntrlerHelperObj.getMonthName(startingDateTime.month());
        Integer startMont_const=startingDateTime.month();
        Integer startdate_year_i=startingDateTime.year();
        tourListSize=0;
        alist1.clear();
        alist2.clear();
        List<Event_Location__c> toursList = new List<Event_Location__c>();
        availability=new Availability();  
        Integer s;
        Integer singleRoomsAvailableforAM=0;
        Integer doubleRoomsAvailableforAM=0;
        Integer singleRoomsAvailableforPM=0;
        Integer doubleRoomsAvailableforPM=0;
        
        Integer singleRoomsAvailable=0;
        Integer doubleRoomsAvailable=0;
        
        Integer dateRange=startingDate.daysBetween(endingDate);
        List<Id> idlist=new List<Id>();
        Integer occupancy;
        List<Id> roomIdList=new List<Id>();
        Integer numberDaysinEndmonth =date.daysInMonth(endingDate.year(), endingDate.month());
        Integer enddate_date_i;
        String enddate_month_s;
        Integer enddate_year_i;
        Integer roomavailability=0;
        String roomavailability_s;
        String singleRoomsAvailable_s;
        String doubleRoomsAvailable_s;
        String singleRoomsAvailable_sAM;
        String doubleRoomsAvailable_sAM;
        String tourAvailability='';
        String singleRoomsAvailable_sPM;
        String doubleRoomsAvailable_sPM;
        List<Calendar_Management__c> calendarManagementList;
        List<Calendar_Management__c> calendarManagementWaitingList;
        List<bookingdetails> dateBooked;
        Integer itcbooking=0;
        Integer maxitcbookingperday=2;
        waitinglistcellcolor='#98FF98';
                            
        try{
            calendarManagementHolidayList=new List<Date>(); 
            List<Calendar_Management__c> calendarManagementHolidays=[select Date__c,Id,Status__c from Calendar_Management__c where (Status__c='Holiday' or  (Status__c='Internal' and Room__r.Id=null)) and Date__c >= :startingDate and Date__c <= :endingDate and Site__r.Id=:selectedSiteId];
            //CR #6366
            
            for(Calendar_Management__c holiday : calendarManagementHolidays){
                calendarManagementHolidayList.add(holiday.Date__c);
            }// Query  Holidays and Weekends
            
            Date day1=startingDate;
            do{ 
                String weekname=(datetime.valueOf(day1.year() + '-' + day1.month()+ '-' + day1.day() + ' ' + '00' + ':' +'00' + ':' + '00')).format('EEE');
                if(weekname=='Sat' || weekname=='Sun')
                    calendarManagementHolidayList.add(day1);
                day1+=1;
            }while(day1<=endingDate);// Obtain the List of Holidays and Weekends
            
            if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false)) || customerEngagement.Event_Type__c=='Field Briefing'){
                singleAvailText='# Single Room(s)';
                doublAvailText='# Double Room(s)';
                waitngLstTxt='Waiting List';
                waitinglistrowcolor='#3366FF';
                waitinglistrowtext='Wait List - Not Confirmed until the Event status is Scheduled';   
                List<Event_Location__c> roomsList=[SELECT Id,Name,Room_Occupancy__c,Room_Type__c FROM Event_Location__c where Select_Site__c =:selectedSiteId and recordType.name='rooms' and Active__c=true]; //Query the Event Location to get the Rooms correcponding to the selected Site
                System.debug('#### roomsList : ' + roomsList);
                for(Event_Location__c room : roomsList){
                    if(room.Room_Type__c=='Single'){
                        roomDetailsMap.put(room.Id,1);
                    }
                    else if(room.Room_Type__c=='Double'){
                        roomDetailsMap.put(room.Id,2);
                    }// Create roomDetailsMap with  Room Id and Type of Room
                    roomIdList.add(room.Id);
                }
                
                //calendarManagementList=[select Date__c,Room__r.Id,Half_Day__c,recordType.name,Start_Date__c,Id from Calendar_Management__c where Room__r.Id in :roomIdList and Date__c >= :startingDate and Date__c <= :endingDate and (((Status__c='Pending' or Status__c='Scheduled') and (Event_Record_type__c='Briefing' or Event_Record_type__c='vEBC')) or  Status__c='Internal')];//Query Calendar_Management__c to get the list of Bookings for Rooms in roomIdList//CR #6366
                 calendarManagementList=[select Date__c,Room__r.Id,Half_Day__c,recordType.name,Start_Date__c,Id from Calendar_Management__c where Room__r.Id in :roomIdList and Date__c >= :startingDate and Date__c <= :endingDate and (((Status__c='Pending' or Status__c='Scheduled') and ((Event_Record_type__c='Briefing' and Webcast__c=false) or Event_Record_type__c='Field Briefing')) or  Status__c='Internal')];//Query Calendar_Management__c to get the list of Bookings for Rooms in roomIdList//CR #6366
              
                System.debug('#### calendarManagementList : ' + calendarManagementList);
                Bookingdetails roombookdetails;
                for(Calendar_Management__c calendarManagement: calendarManagementList){
                    if(calendarManagmentMap.get(calendarManagement.Room__r.Id)==null){
                        dateBooked=new List<bookingdetails>();
                        roombookdetails=new Bookingdetails();
                        roombookdetails.bookingdate=calendarManagement.Date__c;
                        roombookdetails.timeslot=calendarManagement.Half_Day__c;
                        dateBooked.add(roombookdetails);
                        calendarManagmentMap.put(calendarManagement.Room__r.Id,dateBooked);
                    }
                    roombookdetails=new Bookingdetails();
                    roombookdetails.bookingdate=calendarManagement.Date__c;
                    roombookdetails.timeslot=calendarManagement.Half_Day__c;
                    calendarManagmentMap.get(calendarManagement.Room__r.Id).add(roombookdetails);
                    //Create calendarManagmentMap with Room Id and List of roombookdetails(Date and slot booked)
                }
                
            }
            else if(customerEngagement.Event_Type__c=='Meeting'){
                calendarManagementList=[select Date__c,Half_Day__c,Event_Record_type__c,Id,Site__r.Id from Calendar_Management__c where Site__r.Id=:selectedSiteId and Event_Record_type__c='Meeting' and Date__c >= :startingDate and Date__c <= :endingDate and (Status__c='Pending' or Status__c='Scheduled')];
                for(Calendar_Management__c calendarManagement: calendarManagementList){
                    if(calendarManagement.Half_Day__c==null)
                        calendarManagement.Half_Day__c='Whole Day';
                    Bookingdetails roombookdetails;
                    if(calendarManagmentMap.get(calendarManagement.Site__r.Id)==null){
                        dateBooked=new List<bookingdetails>();
                        roombookdetails=new Bookingdetails();
                        roombookdetails.bookingdate=calendarManagement.Date__c;
                        roombookdetails.timeslot='Whole Day';
                        dateBooked.add(roombookdetails);
                        calendarManagmentMap.put(calendarManagement.Site__r.Id,dateBooked);
                    
                   }
                    roombookdetails=new Bookingdetails();
                    roombookdetails.bookingdate=calendarManagement.Date__c;
                    roombookdetails.timeslot='Whole Day';
                    calendarManagmentMap.get(calendarManagement.Site__r.Id).add(roombookdetails);
               }//Create calendarManagmentMap with Site Id and List of roombookdetails(Date and slot booked)
                
            }else if(customerEngagement.Event_Type__c=='Tour'){//CR #6367
                List<Availability.TourWrapper> TourWrapperRecordsObj=new List<Availability.TourWrapper>();
                Availability.TourWrapper tourwrapperobj;
                toursList=[SELECT Id,Name FROM Event_Location__c where Select_Site__c =:selectedSiteId and recordType.name='Tours' and Active__c=true];
                if(toursList!=null){
                    tourListSize=toursList.size();
                    for(Event_Location__c tour: toursList){
                        tourwrapperobj=new Availability.TourWrapper();
                        tourwrapperobj.tourValue=tour.Name;
                        tourwrapperobj.tourColour='#FFFFFF';
                        tourwrapperobj.tourName=tour.Id;
                        availability.TourWrapperRecords.add(tourwrapperobj);                       
                    }
                    availability.calendarDate=null;
                    availability.calendarDateFormat=null;
                    availability.dayOfTheweek=null;
                    availability.singleRoomAvailabilityAM='#FFFFFF';
                    alist1.add(availability); //Sets the Ist monthList with Tour Name
                    alist2.add(availability); //Sets the IInd monthList with Tour Name
                    alist3.add(availability); //Sets the IIIrd monthList with Tour Name
                }else{
                    tourListSize=0;
                    return null; // If no tours available, display Tours Unavailable message
                }
 
            }
            EbcCalendercntrlerHelper EbcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
            Datetime startingDateTimelocal =ebcCalendercntrlerHelperObj.getDateTimeFormat(1,startingDateTime.month(),startdate_year_i);
            
            //  Iterate from 1stdate of ist month to actual starting date for which the calendar is displayed
            for(Integer i=1; i<startdate_date_i;i++){
                Availability.TourWrapper tourwrapperobj=new Availability.TourWrapper();
                availability=new Availability();
                if(customerEngagement.Event_Type__c=='Tour'){ //CR #6367
                    for(Event_Location__c tour: toursList){
                        tourwrapperobj.tourValue=' ';
                        tourwrapperobj.tourColour='#FFFFFF';
                        tourwrapperobj.tourName=' ';
                        availability.TourWrapperRecords.add(tourwrapperobj);
                    }
                }
                availability.calendarDate=i;
                availability.calendarMonth=ebcCalendercntrlerHelperObj.getMonthName(startingDateTime.month());
                availability.calendaryear=startdate_year_i;
                availability.dayOfTheweek=(startingDateTimelocal.format('EEE'));
                availability.singleRoomAvailabilityAM=null;
                availability.singleroomsAM=null;
                alist1.add(availability);
                startingDateTimelocal+=1;
            }
            
            //  Iterate from actual starting date  through the date rangefor which the calendar is displayed
            
            for(Integer i=0; i<=dateRange;i++){
                System.debug('#### date Rage i ## :' + i);
                String waitingListCellvalue='';
                itcbooking=0;
                Bookingdetails roombookdetails;
                
                if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false))|| customerEngagement.Event_Type__c=='Field Briefing'){   
                    singleRoomsAvailableforAM=0;
                    singleRoomsAvailableforPM=0;
                    doubleRoomsAvailableforAM=0;
                    doubleRoomsAvailableforPM=0;
                    
                    singleRoomAvailabilitycolorAM = '#999999';
                    doubleRoomAvailabilitycolorAM = '#999999';
                    singleRoomAvailabilitycolorPM = '#999999';
                    doubleRoomAvailabilitycolorPM = '#999999';
                    
                    
                    singleRoomsAvailable=0;
                    doubleRoomsAvailable=0;
                    singleRoomAvailabilitycolor = '#999999';
                    doubleRoomAvailabilitycolor = '#999999';
                    
                    System.debug('#### roomDetailsMap ## :' + roomDetailsMap);
                    
                    for(String roomDetailsMapKey:roomDetailsMap.keyset()){
                        Boolean roomBookedAM=false;
                        Boolean roomBookedPM=false;
                        if(calendarManagmentMap.get(roomDetailsMapKey)!=null){
                            for(Bookingdetails datebked:calendarManagmentMap.get(roomDetailsMapKey)){
                                if(datebked.bookingdate==startingDate&& (datebked.timeslot=='AM: 12 AM – 11:59 AM' || datebked.timeslot=='Whole Day')){
                                    roomBookedAM=true;
                                }//checks if room is booked for AM
                                if(datebked.bookingdate==startingDate&& ( datebked.timeslot=='PM: 12 PM – 11:59 PM' || datebked.timeslot=='Whole Day')){
                                    roomBookedPM=true;//checks if room is booked for PM
                                }
                            }
                        }
                        System.debug('#### roomBookedAM## :' + roomBookedAM);
                        System.debug('#### roomBookedPM## :' + roomBookedPM);
                        //If a single room is not booked for the morning slot, count of rooms for AM is increased by 1
                        if((roomBookedAM==false)&&(roomDetailsMap.get(roomDetailsMapKey))==1){
                            singleRoomsAvailableforAM+=1;
                        }
                         System.debug('#### singleRoomsAvailableforAM## :' + singleRoomsAvailableforAM);
                        
                        //If a single room is not booked for the evening slot, count of rooms for PM is increased by 1
                        if((roomBookedPM==false)&&(roomDetailsMap.get(roomDetailsMapKey))==1){
                            singleRoomsAvailableforPM+=1;
                        }
                        System.debug('#### singleRoomsAvailableforPM## :' + singleRoomsAvailableforPM);
                        //If a double room is not booked for the morning slot, count of rooms for AM is increased by 1
                        if((roomBookedAM==false)&&(roomDetailsMap.get(roomDetailsMapKey))==2){
                            doubleRoomsAvailableforAM+=1;
                        }
                        System.debug('#### doubleRoomsAvailableforAM## :' + doubleRoomsAvailableforAM);
                        //If a double room is not booked for the evening slot, count of rooms for PM is increased by 1
                        if((roomBookedPM==false)&&(roomDetailsMap.get(roomDetailsMapKey))==2){
                            doubleRoomsAvailableforPM+=1;
                        }
                         System.debug('#### doubleRoomsAvailableforPM## :' + doubleRoomsAvailableforPM);
                        if((noOfDays!='PM')&&(noOfDays!='AM')){
                        
                            if(singleRoomsAvailableforAM==singleRoomsAvailableforPM)
                                singleRoomsAvailable=singleRoomsAvailableforAM;
                            else{
                                if(singleRoomsAvailableforAM<singleRoomsAvailableforPM)
                                    singleRoomsAvailable=singleRoomsAvailableforAM;
                                else if(singleRoomsAvailableforAM>singleRoomsAvailableforPM)
                                    singleRoomsAvailable=singleRoomsAvailableforPM;
                            }
                            
                            if(doubleRoomsAvailableforAM==doubleRoomsAvailableforPM)
                                doubleRoomsAvailable=doubleRoomsAvailableforAM;
                            else{
                                if(doubleRoomsAvailableforAM<doubleRoomsAvailableforPM)
                                    doubleRoomsAvailable=doubleRoomsAvailableforAM;
                                else if(doubleRoomsAvailableforAM>doubleRoomsAvailableforPM)
                                    doubleRoomsAvailable=doubleRoomsAvailableforPM;
                            }
                            system.debug('EEEEEEEEEEEEEEEEEEEE***'+startingDate);
                            system.debug('singleRoomsAvailable**'+singleRoomsAvailable);
                        system.debug('doubleRoomsAvailable_s***'+singleRoomsAvailable);
                        system.debug('singleRoomAvailabilitycolor***'+singleRoomAvailabilitycolor);
                        system.debug('doubleRoomAvailabilitycolor***'+doubleRoomAvailabilitycolor);
                        
                        }
                            
                        //Create roomAvailabilityDetailsMap with details of available rooms                 
                        if(roomBookedAM==false && roomBookedPM==true ){
                            if(roomAvailabilityDetailsMap.get(roomDetailsMapKey)==null){
                                dateBooked=new List<Bookingdetails>();
                                roombookdetails=new Bookingdetails();
                                roombookdetails.bookingdate=startingDate;
                                roombookdetails.timeslot='AM: 12 AM – 11:59 AM';
                                dateBooked.add(roombookdetails);
                                roomAvailabilityDetailsMap.put(roomDetailsMapKey,dateBooked);
                            }else{
                                roombookdetails=new Bookingdetails();
                                roombookdetails.bookingdate=startingDate;
                                roombookdetails.timeslot='AM: 12 AM – 11:59 AM';
                                roomAvailabilityDetailsMap.get(roomDetailsMapKey).add(roombookdetails);
                            }

                        }else if(roomBookedPM==false && roomBookedAM==true){
                            if(roomAvailabilityDetailsMap.get(roomDetailsMapKey)==null){
                                dateBooked=new List<Bookingdetails>();
                                roombookdetails=new Bookingdetails();
                                roombookdetails.bookingdate=startingDate;
                                roombookdetails.timeslot='PM: 12 PM – 11:59 PM';
                                dateBooked.add(roombookdetails);
                                roomAvailabilityDetailsMap.put(roomDetailsMapKey,dateBooked);
                            }else{
                                roombookdetails=new Bookingdetails();
                                roombookdetails.bookingdate=startingDate;
                                roombookdetails.timeslot='PM: 12 PM – 11:59 PM';
                                roomAvailabilityDetailsMap.get(roomDetailsMapKey).add(roombookdetails);
                            }
                        }else if(roomBookedPM==false && roomBookedAM==false){
                            if(roomAvailabilityDetailsMap.get(roomDetailsMapKey)==null){
                                dateBooked=new List<Bookingdetails>();
                                roombookdetails=new Bookingdetails();
                                roombookdetails.bookingdate=startingDate;
                                roombookdetails.timeslot='Whole Day';
                                dateBooked.add(roombookdetails);
                                roomAvailabilityDetailsMap.put(roomDetailsMapKey,dateBooked);
                            }else{
                                roombookdetails=new Bookingdetails();
                                roombookdetails.bookingdate=startingDate;
                                roombookdetails.timeslot='Whole Day';
                                roomAvailabilityDetailsMap.get(roomDetailsMapKey).add(roombookdetails);
                            }
                        }
                    }
                
                    //If no rooms are available for a slot, the background color is shown as blocked.
                    if(singleRoomsAvailableforAM!=0)
                        singleRoomAvailabilitycolorAM = '#FFFFFF';
                    
                    if(doubleRoomsAvailableforAM!=0)
                        doubleRoomAvailabilitycolorAM = '#FFFFFF';
                    
                    if(singleRoomsAvailableforPM!=0)
                        singleRoomAvailabilitycolorPM = '#FFFFFF';
                    
                    if(doubleRoomsAvailableforPM!=0)
                        doubleRoomAvailabilitycolorPM = '#FFFFFF';
                        
                    if(singleRoomsAvailableforAM!=0 && singleRoomsAvailableforPM!=0)
                        singleRoomAvailabilitycolor = '#FFFFFF';
                    
                    if(doubleRoomsAvailableforAM!=0 && doubleRoomsAvailableforPM!=0)
                        doubleRoomAvailabilitycolor = '#FFFFFF';
                    
                    System.debug('#### doubleRoomsAvailableforAM ##'  +doubleRoomsAvailableforAM);  
                    System.debug('#### singleRoomsAvailableforAM ##'  +singleRoomsAvailableforAM);
                    System.debug('#### doubleRoomsAvailableforPM ##'  +doubleRoomsAvailableforPM);
                    System.debug('#### singleRoomsAvailableforPM ##'  +singleRoomsAvailableforPM);
                    
                    //If no rooms are available for any slot for a particular day, waiting list is shown as available
                    if(doubleRoomsAvailableforAM==0 && singleRoomsAvailableforAM==0  && doubleRoomsAvailableforPM==0 && singleRoomsAvailableforPM==0 )
                        waitingListCellvalue='W';
                    
                    //The background color is shown as blocked for holidays
                    for(Date cm:calendarManagementHolidayList){
                        if(cm==startingDate){
                            doubleRoomsAvailableforAM=0;
                            singleRoomsAvailableforAM=0;
                            doubleRoomsAvailableforPM=0;
                            singleRoomsAvailableforPM=0;
                            singleRoomsAvailable=0;
                            doubleRoomsAvailable=0;
                            waitingListCellvalue='';
                            
                            singleRoomAvailabilitycolor = '#999999';
                            doubleRoomAvailabilitycolor = '#999999';
                            singleRoomAvailabilitycolorAM = '#999999';
                            doubleRoomAvailabilitycolorAM = '#999999';
                            singleRoomAvailabilitycolorPM = '#999999';
                            doubleRoomAvailabilitycolorPM = '#999999';
                        }
                    }
                   
                   
                   system.debug('************noOfDays***'+noOfDays);
                   
                   //Setting the string variabke with the available number
                    if(noOfDays=='AM'){
                        if(singleRoomsAvailableforAM==0){
                            singleRoomsAvailable_sAM='';
                        }else{
                            singleRoomsAvailable_sAM=''+singleRoomsAvailableforAM;
                        }
                        if(doubleRoomsAvailableforAM==0){
                            doubleRoomsAvailable_sAM='';
                        }else{
                            doubleRoomsAvailable_sAM=''+doubleRoomsAvailableforAM;
                        }
                        system.debug('IIIIIIIIIIIIII***'+i);
                        system.debug('IIIIIIIIIIIIII***'+startingDate);
                        system.debug('singleRoomsAvailable_sAM***'+singleRoomsAvailable_sAM);
                        system.debug('doubleRoomsAvailable_sAM***'+doubleRoomsAvailable_sAM);
                        system.debug('singleRoomAvailabilitycolorAM***'+singleRoomAvailabilitycolor);
                        system.debug('doubleRoomAvailabilitycolorAM***'+doubleRoomAvailabilitycolor);
                    }else if(noOfDays=='PM'){
                        
                        if(singleRoomsAvailableforPM==0){
                            singleRoomsAvailable_sPM='';
                        }else{
                            singleRoomsAvailable_sPM=''+singleRoomsAvailableforPM;
                        }
                        if(doubleRoomsAvailableforPM==0){
                            doubleRoomsAvailable_sPM='';
                        }else{
                            doubleRoomsAvailable_sPM=''+doubleRoomsAvailableforPM;
                        }
                        system.debug('singleRoomsAvailable_sPM***'+singleRoomsAvailable_sPM);
                        system.debug('doubleRoomsAvailable_sPM***'+doubleRoomsAvailable_sPM);
                        system.debug('singleRoomAvailabilitycolorPM***'+singleRoomAvailabilitycolor);
                        system.debug('doubleRoomAvailabilitycolorPM***'+doubleRoomAvailabilitycolor);
                    }else if((noOfDays!='PM')&&(noOfDays!='AM')){
                        if(singleRoomsAvailable==0){
                            singleRoomsAvailable_s='';
                        }else{
                            singleRoomsAvailable_s=''+singleRoomsAvailable;
                        }
                        if(doubleRoomsAvailableforPM==0){
                            doubleRoomsAvailable_s='';
                        }else{
                            doubleRoomsAvailable_s=''+doubleRoomsAvailable;
                        }
                        system.debug('IIIIIIIIIIIIII***'+i);
                        system.debug('IIIIIIIIIIIIII***'+startingDate);
                        
                        system.debug('singleRoomsAvailable_s***'+singleRoomsAvailable_s);
                        system.debug('doubleRoomsAvailable_s***'+doubleRoomsAvailable_s);
                        system.debug('singleRoomAvailabilitycolor***'+singleRoomAvailabilitycolor);
                        system.debug('doubleRoomAvailabilitycolor***'+doubleRoomAvailabilitycolor);
                    }
                    
                    
                } else if(customerEngagement.Event_Type__c=='Meeting' || ((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==true))|| customerEngagement.Event_Type__c=='Tour'){ //CR #6358
                    String webcastAvailability='.';
                    
                    //For IT Conf calls. 2 calls are allowed per day. Below code checks this.
                    if(customerEngagement.Event_Type__c=='Meeting'){
                       itcbooking=0;
                        roomavailability=maxitcbookingperday-itcbooking;                    
                        for(String calendarManagmentMapKey:calendarManagmentMap.keyset()){
                            if(calendarManagmentMap.get(calendarManagmentMapKey)!=null){
                                for(Bookingdetails datebked:calendarManagmentMap.get(calendarManagmentMapKey)){
                                    if(datebked.bookingdate==startingDate){
                                        itcbooking+=1;
                                    }
                                }
                            }
                        }
                                        
                            
                        if(maxitcbookingperday>itcbooking)
                            roomavailability=maxitcbookingperday-itcbooking;
                        else
                            roomavailability=0;
                    }
                    
                    if(roomavailability<=0)
                       roomavailability=0;
                    
                    //The background color is shown as blocked for holidays                 
                    for(Date cm:calendarManagementHolidayList){
                        if(cm==startingDate){
                             roomavailability=0;
                            webcastAvailability='';
                            singleRoomAvailabilitycolor = '#999999';
                        }
                    }
                   
                    //For tour and webcast,any number of booking can be made
                    if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==true)) ||   customerEngagement.Event_Type__c=='Tour'){//CR #6358
                        if(webcastAvailability=='')
                            singleRoomsAvailable_s='';
                        else
                            singleRoomsAvailable_s=webcastAvailability;
                    }
                    else{                   
                        if(roomavailability==0 || webcastAvailability==''){
                            singleRoomsAvailable_s='';
                            
                        }else{
                            singleRoomsAvailable_s=''+roomavailability;
                            
                        }
                    }
                    if(singleRoomsAvailable_s=='')
                        singleRoomAvailabilitycolor = '#999999';
                    else
                        singleRoomAvailabilitycolor = '#FFFFFF';
                        
                }
                
                
                if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false))|| customerEngagement.Event_Type__c=='Field Briefing'){        
                    if(noOfDays=='AM'){
                        
                        singleRoomsAvailable_s=singleRoomsAvailable_sAM;
                        doubleRoomsAvailable_s=doubleRoomsAvailable_sAM;
                        singleRoomAvailabilitycolor=singleRoomAvailabilitycolorAM;
                        doubleRoomAvailabilitycolor=doubleRoomAvailabilitycolorAM;
                        
                    }else if(noOfDays=='PM'){
                    
                        singleRoomsAvailable_s=singleRoomsAvailable_sPM;
                        doubleRoomsAvailable_s=doubleRoomsAvailable_sPM;
                        singleRoomAvailabilitycolor=singleRoomAvailabilitycolorPM;
                        doubleRoomAvailabilitycolor=doubleRoomAvailabilitycolorPM;
                    }
                        
system.debug('SSSSSSSSSSSSSSSSSSSSS***'+startingDate);
                        system.debug('singleRoomsAvailable_s***'+singleRoomsAvailable_s);
                        system.debug('doubleRoomsAvailable_s***'+doubleRoomsAvailable_s);
                        system.debug('singleRoomAvailabilitycolor***'+singleRoomAvailabilitycolor);
                        system.debug('doubleRoomAvailabilitycolor***'+doubleRoomAvailabilitycolor);
                }
                
               
                
                //checks how many months to be displayed in the calendar page
                if(((startMont_const+1)==startingDateTime.month()) || (startMont_const==12 && startingDateTime.month()==1))
                    monthcount=1;
                else  if(((startMont_const+2)==startingDateTime.month()) || (startMont_const==12 && startingDateTime.month()==2))
                    monthcount=2;
                else
                    monthcount = 0;
                
                    
                availability=new Availability();
                availability.calendarDate=startdate_date_i;
                availability.calendarDateFormat=startingDate;
                availability.dayOfTheweek=(startingDateTime.format('EEE'));

                if(customerEngagement.Event_Type__c!='Tour'){     
                    availability.singleRoomAvailabilityAM=singleRoomAvailabilitycolor;
                    availability.singleroomsAM=singleRoomsAvailable_s;
                }
                        
                if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false)) || customerEngagement.Event_Type__c=='Field Briefing'){

system.debug('SSSSSSSSSSSSSSSSSSSSS***'+startingDate);
                        system.debug('singleRoomsAvailable_s***'+singleRoomsAvailable_s);
                        system.debug('doubleRoomsAvailable_s***'+doubleRoomsAvailable_s);
                        system.debug('singleRoomAvailabilitycolor***'+singleRoomAvailabilitycolor);
                        system.debug('doubleRoomAvailabilitycolor***'+doubleRoomAvailabilitycolor);             
                    availability.doubleroomsPM=doubleRoomsAvailable_s;
                    availability.doubleRoomAvailabilityPM=doubleRoomAvailabilitycolor;
                    //availability.singleRoomAvailabilityPM=singleRoomAvailabilitycolorPM;
                    //availability.doubleRoomAvailabilityAM=doubleRoomAvailabilitycolorAM;
                  //  availability.doubleRoomAvailabilityPM=doubleRoomAvailabilitycolorPM;
                    //availability.singleroomsPM=singleRoomsAvailable_sPM;
                    //availability.doubleroomsAM=doubleRoomsAvailable_sAM;
                    //availability.doubleroomsPM=doubleRoomsAvailable_sPM;
                    availability.waitingList=waitingListCellvalue;
                    
                    system.debug('DDDDDDDDDDDD***'+startingDate);
                    
                    system.debug('availability***'+availability);
                    
                }else if(customerEngagement.Event_Type__c=='Tour'){ //CR #6367
                    List<Availability.TourWrapper> TourWrapperRecordsObj=new List<Availability.TourWrapper>();
                    Availability.TourWrapper tourwrapperobj;
                    tourListSize=toursList.size();
                    for(Event_Location__c tour: toursList){
                        tourwrapperobj=new Availability.TourWrapper();
                        tourwrapperobj.tourValue=singleRoomsAvailable_s;
                        tourwrapperobj.tourColour=singleRoomAvailabilitycolor;
                        tourwrapperobj.tourName=tour.Id;
                        availability.TourWrapperRecords.add(tourwrapperobj);                       
                    }
                }
                  

            if(monthcount==0){
                firstmonth=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                firstYear=startingDateTime.year();
                enddate_date_i=startdate_date_i;
                enddate_month_s=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                //startdate_month_s=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                //startdate_year_i=startingDateTime.year();
                alist1.add(availability);
            }//adds to First months list

            else  if(monthcount==1){
                secondmonth=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                secondYear=startingDateTime.year();
                enddate_date_i=startdate_date_i;
                enddate_month_s=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                //startdate_month_s=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                //startdate_year_i=startingDateTime.year();
                alist2.add(availability);
             //adds to Second months list  
            }else if(monthcount==2){
                thirdmonth=ebcCalendercntrlerHelperObj.getMonthName(startingDateTime.month());
                thirdYear=startingDateTime.year();
                enddate_date_i=startdate_date_i;
                enddate_month_s=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                //startdate_month_s=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()));
                //startdate_year_i=startingDateTime.year();
                alist3.add(availability);
                //adds to Third months list
            }

                startingDateTime+=1;
                startingDate=date.newInstance(startingDateTime.year(), startingDateTime.month(), startingDateTime.day());
                startdate_date_i=startingDateTime.day();
                startdate_month_s=ebcCalendercntrlerHelperObj.getMonthName((startingDateTime.month()-1));
                startdate_year_i=startingDateTime.year();
            }
            startingDateTimelocal=startingDateTime;
            for(Integer i=(enddate_date_i+1); i<=numberDaysinEndmonth;i++){
                availability=new Availability();
                if(customerEngagement.Event_Type__c=='Tour'){ //CR #6367
                    Availability.TourWrapper tourwrapperobj=new Availability.TourWrapper();
                    for(Event_Location__c tour: toursList){
                        tourwrapperobj.tourValue=' ';
                        tourwrapperobj.tourColour='#FFFFFF';
                        tourwrapperobj.tourName=' ';
                        availability.TourWrapperRecords.add(tourwrapperobj);
                    }
                }
                
                availability.calendarDate=i;
                availability.calendarMonth=enddate_month_s;
                availability.calendaryear=enddate_year_i;
                availability.dayOfTheweek=(startingDateTimelocal.format('EEE'));
        
                if(monthcount==1)
                    alist2.add(availability);
                
                if(monthcount==2)
                    alist3.add(availability);
                
                 startingDateTimelocal+=1;
            }// Adds (Total days in a month - Actual enddate) to the last month.(blank values)
            
            getAvailabilityDetailsNextMonth();
            getAvailabilityDetailsThirdMonth();
            colspanalist1=alist1.size()+1;
            colspanalist2=alist2.size()+1;
            colspanalist3=alist3.size()+1;
            return alist1;                      
        }catch(Exception e) {
            return null; 
        } 
    }
    
    public List<Availability> getAvailabilityDetailsNextMonth(){
        return alist2;
    }
    
    public List<Availability> getAvailabilityDetailsThirdMonth(){
        return alist3;
    }
    
    public PageReference navigationActionFunction(String roomrequirement,String cm_bookingdate,Date startingDate,Date endingDate,DateTime startingDateTime){
        List<Event_Location__c> singleRoomsList=new List<Event_Location__c>();
        List<Event_Location__c> doubleRoomsList=new List<Event_Location__c>();
        String selectedSiteId=siteId;
        Date cm_booking_D;
        String d=cm_bookingdate.substring(8,10);
        ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
        String m=ebcCalendercntrlerHelperObj.getmonthNumber(cm_bookingdate.substring(4,7));
        String y=cm_bookingdate.substring(24,28);
        string stringDate = y + '-' + m+ '-' + d + ' ' + '00' + ':' +'00' + ':' + '00';
        cm_booking_D = date.valueOf(stringDate);
        Integer noOfDaystoBook;
        List<Calendar_Management__c> secondarycalendarManagementList=new List<Calendar_Management__c>();
        Calendar_Management__c calendarManagement= new Calendar_Management__c();
        List<Calendar_Management__c> cmlist;
        Integer cm_roomcapacity;
        List<Event_Location__c> tourSelectd;
        Integer itcbooking=0;
        Integer maxitcbookingperday=2;
        Integer holidaycount=0;
        List<Calendar_Management__c> calendarManagementListitc;
        consecutiveroomavailability=true;
        
        
        try{
            String requiredSlot;
            String otherSlotForTheDay;
            Integer requiredCapacity;
            String tourName;
            Boolean requirementConfirmed=false;
            
            if(noOfDays!='AM' && noOfDays!='PM' )
                noOfDaystoBook=Integer.valueOf(noOfDays);
        
            //Decodes the type of requirement
            if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false))||(customerEngagement.Event_Type__c=='Field Briefing')){
                //wholeDayBooking=false;
                
                if(roomrequirement.contains('single'))
                    requiredCapacity=1;
                else if(roomrequirement.contains('double'))
                    requiredCapacity=2;
                    
                if(noOfDays=='AM'){ 
                    requiredSlot='AM: 12 AM – 11:59 AM';
                    noOfDaystoBook=1;
                }else if(noOfDays=='PM')    {
                    requiredSlot='PM: 12 PM – 11:59 PM';
                    noOfDaystoBook=1;
                }else if(noOfDays!='AM' && noOfDays!='PM')
                    requiredSlot='Whole Day';
                    
              /*  if(roomrequirement.contains('AM')){
                    requiredSlot='AM: 12 AM – 11:59 AM';
                    otherSlotForTheDay='PM: 12 PM – 11:59 PM';
                }else if(roomrequirement.contains('PM')){
                    requiredSlot='PM: 12 PM – 11:59 PM';
                    otherSlotForTheDay='AM: 12 AM – 11:59 AM';
                }

                if(roomrequirement.contains('Whole'))
                    requiredSlot='Whole Day';
                    
                if(roomrequirement.contains('Confirmed'))       
                    requirementConfirmed=true;*/
            }            
           
            Calendar_Management__c calendarManagement1;

            List<Date> dateBookeditc;
            Calendar_Management__c primarycm;
            
            
            if((noOfDaystoBook>=1)&&(noOfDaystoBook<=10)){
                
                Date cm_booking_Dlocal=cm_booking_D;
                Calendar_Management__c calendarManagement2;
                calendarManagement1= new Calendar_Management__c();//Primary CM Obj
                  
                for(Integer i=1;i<=noOfDaystoBook;i++){
                    calendarManagement2= new Calendar_Management__c();//Seconday CM obj
                    
                    for(Date cm:calendarManagementHolidayList){
                        if(cm==cm_booking_Dlocal){
                            cm_booking_Dlocal+=1;
                        }
                    }
                    
                    if(((customerEngagement.Event_Type__c=='Briefing')&&(customerEngagement.Webcast__c==false))||(customerEngagement.Event_Type__c=='Field Briefing')){
                    
                        for(Id roomid : roomAvailabilityDetailsMap.keyset()){
                            Bookingdetails previousAvailabilityDetails;
                                
                            for(Bookingdetails availabledate : roomAvailabilityDetailsMap.get(roomid)){
                                /*if(requiredSlot!='Whole Day'){
                                
                                    if(previousAvailabilityDetails!=null){
                                        if((availabledate.bookingdate==cm_booking_Dlocal && (availabledate.timeslot==requiredSlot ||  availabledate.timeslot=='Whole Day'))||((previousAvailabilityDetails.bookingdate==cm_booking_Dlocal && previousAvailabilityDetails.timeslot==requiredSlot ||  previousAvailabilityDetails.timeslot=='Whole Day')) ){ 
                                            if((availabledate.bookingdate==cm_booking_Dlocal && (availabledate.timeslot==otherSlotForTheDay ||  availabledate.timeslot=='Whole Day'))||(previousAvailabilityDetails.bookingdate==cm_booking_Dlocal && (previousAvailabilityDetails.timeslot==otherSlotForTheDay  ||  previousAvailabilityDetails.timeslot=='Whole Day'))) {
                                                if( roomDetailsMap.get(roomid)==requiredCapacity){
                                                
                                                    wholeDayBooking=true;
                                                    return null;
                                                }else 
                                                    requirementConfirmed=true;
                                            }
                                        }
                                    }
                                    
                                    if(availabledate.bookingdate==cm_booking_Dlocal)            
                                        previousAvailabilityDetails=availabledate;
                                }*/
                                
                             //  if(requirementConfirmed==true){
                                    if(availabledate.bookingdate==cm_booking_Dlocal && (availabledate.timeslot==requiredSlot || availabledate.timeslot=='Whole Day')){
                                        if(roomDetailsMap.get(roomid)==requiredCapacity){
                                            if(i==1){
                                                calendarManagement1.Room__c= roomid; //checks if room are available. If yes, assigns the room id to CM Obj
                                                calendarManagement1.Half_Day__c=requiredSlot;
                                            }
                                            else{
                                                calendarManagement2.Room__c= roomid; //checks if room are available. If yes, assigns the room id to CM Obj
                                                calendarManagement2.Half_Day__c=requiredSlot;
                                            }
                                            break;
                                            
                                        }
                                    }
                              //  }
                            }
                        }
            
                        if(i!=1 && calendarManagement2.Room__c==null){
                        
                            consecutiveroomavailability=false;//If no, displays Selection Error
                            return null;
                        }
                    }
                    else if(customerEngagement.Event_Type__c=='Meeting'){
                        Integer roomavailability=0;
                        maxitcbookingperday=2;
                        itcbooking=0;
                        consecutiveroomavailability=true;
                        
                        //checks if Sites are available. If yes, assigns the Sit id to CM Obj
                        for(Id roomid : roomAvailabilityDetailsMap.keyset()){
                            for(Bookingdetails availabledate : roomAvailabilityDetailsMap.get(roomid)){
                                if(availabledate.bookingdate==cm_booking_Dlocal){
                                    itcbooking+=1;
                                }
                            }
                        }
                        
                        if(maxitcbookingperday>itcbooking)
                            roomavailability=maxitcbookingperday-itcbooking;
                        
                        //If no, displays Selection Error
                        if(roomavailability<=0){
                           consecutiveroomavailability=false;
                           return null;
                        }
                    }
                    
                    else if(customerEngagement.Event_Type__c=='Tour'){
                        if(i==1){
                            calendarManagement1.Room__c= null;
                            calendarManagement1.Tour__c=roomrequirement;
                        }
                        else{
                            calendarManagement2.Room__c=null;
                            calendarManagement2.Tour__c=roomrequirement;
                        }
                    } 
                    
                    
                    if(i==1){               //Primary CM
                        calendarManagement1.Date__c =cm_booking_Dlocal;
                        calendarManagement1.Status__c ='Pending';
                        calendarManagement1.Event_Record_type__c=customerEngagement.Event_Type__c;
                        calendarManagement1.Site__c=siteId;
                        calendarManagement1.Start_Date__c=cm_booking_D;
                        calendarManagement1.End_Date__c=cm_booking_D;
                        calendarManagement1.Webcast__c=customerEngagement.Webcast__c;
                        calendarManagement1.recordTypeId=recordTypeIdMap.get('Primary Calendar RT');
                    }else{//Secondary CM
                        calendarManagement2.Status__c ='Pending';
                        calendarManagement2.Event_Record_type__c=customerEngagement.Event_Type__c;
                        calendarManagement2.Site__c=siteId;
                        calendarManagement2.Date__c =cm_booking_Dlocal;
                        calendarManagement2.recordTypeId=recordTypeIdMap.get('Secondary Calendar RT');
                        system.debug('** calendarManagement2 i*'+calendarManagement2);
                        calendarManagement2.Webcast__c=customerEngagement.Webcast__c;
                        secondarycalendarManagementList.add(calendarManagement2);
                    }
                        cm_booking_Dlocal+=1;
                }
                
                system.debug('***B$ INSERT*calendarManagement1*'+calendarManagement1);
                if(calendarManagement1!=null)
                    insert calendarManagement1;//Inserts Primary CM
                    
                
                for(Integer i=0;i<secondarycalendarManagementList.size();i++){
                    secondarycalendarManagementList.get(i).Calendar_Management_Record_ID__c=calendarManagement1.Id;
                } //Updates Primary Record Type field of Secondary CM with Primary CM
                
                system.debug('***B$ INSERT*secondarycalendarManagementList*'+secondarycalendarManagementList);
                
                if(secondarycalendarManagementList.size()>=0)
                    insert secondarycalendarManagementList;//Inserts Seconday CM
            
                primarycm=[SELECT Name,Id FROM Calendar_Management__c  where Id=:calendarManagement1.Id];
                primarycm.End_Date__c=cm_booking_Dlocal-1;
                update primarycm;//Update End date field of Primary CM 
            }

                String sid=primarycm.Id;
                String sname=primarycm.Name;
                String sevent=customerEngagement.Event_Type__c;
                Integer swebcast=0;
                if(customerEngagement.Webcast__c ==true){
                  swebcast=1;  
                }           
                PageReference pageRef;

                String urlString = '/a17/e?CF00NA00000063PPH='+sname+'&CF00NA00000063PPH_lkid='+sid+'&00NA00000063Ux3='+swebcast+'&00NA00000063PPb='+sevent+'&nooverride=1' ;//pass the CM name to new CE  Page
                pageRef = new PageReference(urlString);
                

            return pageRef;
        }
        
        catch(Exception e){
            return null;
        }
         return null;
    }
      
    //CR 5748: Book for  waiting List  
    public PageReference bookWaitingList(String cm_bookingdate) {
        Date cm_booking_D;
        if(noOfDays == 'AM' || noOfDays == 'PM'){
            noOfDays = '1';
        }
        Integer noOfDaystoBook=Integer.valueOf(noOfDays);
        try{
            if(cm_bookingdate!=null){
                String d=cm_bookingdate.substring(8,10);
                ebcCalendercntrlerHelperObj=new EbcCalendercntrlerHelper();
                String m=ebcCalendercntrlerHelperObj.getmonthNumber(cm_bookingdate.substring(4,7));
                String y=cm_bookingdate.substring(24,28);
                string stringDate = y + '-' + m+ '-' + d + ' ' + '00' + ':' +'00' + ':' + '00';
                cm_booking_D = date.valueOf(stringDate);
                List<Calendar_Management__c> secondarycalendarManagementList=new List<Calendar_Management__c>();
                Calendar_Management__c calendarManagement1= new Calendar_Management__c();
                Calendar_Management__c calendarManagement2;
                List<Calendar_Management__c> cmlist;
                Calendar_Management__c primarycm;
                Date cm_booking_Dlocal=cm_booking_D;
                if(noOfDaystoBook>=1){
                    
                    for(Integer i=1;i<=noOfDaystoBook;i++){
                        for(Date cm:calendarManagementHolidayList){
                            if(cm==cm_booking_Dlocal){
                                cm_booking_Dlocal+=1;
                            }
                        }
                        if(i==1){    //Primary CM   
                            calendarManagement1.Room__c= null;
                            calendarManagement1.Date__c =cm_booking_Dlocal;
                            calendarManagement1.Status__c ='Waitlisted';
                            calendarManagement1.Event_Record_type__c=customerEngagement.Event_Type__c;
                            calendarManagement1.Site__c=siteId;
                            calendarManagement1.Start_Date__c=cm_booking_D;
                            calendarManagement1.End_Date__c=cm_booking_D;
                            calendarManagement1.recordTypeId=recordTypeIdMap.get('Primary Calendar RT');
                        }else{//Seconday CM
                            calendarManagement1= new Calendar_Management__c();
                            calendarManagement2.Room__c=null;
                            calendarManagement2.Status__c ='Waitlisted';
                            calendarManagement2.Event_Record_type__c=customerEngagement.Event_Type__c;
                            calendarManagement2.Site__c=siteId;
                            calendarManagement2.Date__c =cm_booking_Dlocal;
                            calendarManagement2.recordTypeId=recordTypeIdMap.get('Secondary Calendar RT');
                            secondarycalendarManagementList.add(calendarManagement2);
                        }
                      cm_booking_Dlocal+=1;
                    }
                }
                      
                if(calendarManagement1!=null)
                    insert calendarManagement1;//inserts Primary CM
                    
                for(Integer i=0;i<secondarycalendarManagementList.size();i++){
                    secondarycalendarManagementList.get(i).Calendar_Management_Record_ID__c=calendarManagement1.Id;
                }//Updates Primary Record Type field of Secondary CM with Primary CM
                
                if(secondarycalendarManagementList.size()>=0)
                    insert secondarycalendarManagementList;//Inserts Secondary CM
            
                primarycm=[SELECT Name,Id FROM Calendar_Management__c  where Id=:calendarManagement1.Id];
                primarycm.End_Date__c=cm_booking_Dlocal-1;
                update primarycm;   //Update End date field of Primary CM             

                String sid=primarycm.Id;
                String sname=primarycm.Name;
                String sevent=customerEngagement.Event_Type__c;
                
                PageReference pageRef;

                String urlString = '/a17/e?CF00NA00000063PPH='+sname+'&CF00NA00000063PPH_lkid='+sid+'&nooverride=1' ;//pass the CM name to new CE  Page
                //String urlString = '/a1K/e?CF00NT0000001HtGF='+sname+'&CF00NT0000001HtGF_lkid='+sid+'&nooverride=1' ;
                //String urlString = '/a1W/e?CF00NT0000001LL5h='+sname+'&CF00NT0000001LL5h_lkid='+sid++'&00NA00000063PPY='+eventstatus'+'&nooverride=1' ;
                pageRef = new PageReference(urlString);
                
                return pageRef;
            }
            return null;
        }catch(Exception e){
            return null;
        }
    }
    
}