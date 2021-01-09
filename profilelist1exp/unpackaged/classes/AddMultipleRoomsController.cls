/***********************************************************

* Name          : AddMultipleRoomsController 

* Description   : CR 6362

* ---------------------------------------------------------

* Revision  Name    Date        Description

* 1.0       Ambily  26.06.2011   CR 6362- Create method to allow the record to block 1 room or multiple rooms

 

************************************************************/

 

//CR 6362
public class AddMultipleRoomsController {

    public Calendar_Management__c calMngmntObj{get; set;}
    Map<Id, Event_Location__c> roomDetailsMap;
    Map<Id, List<Bookingdetails>> calendarManagmentMap;
    public String[] availableRooms=new String[]{};
    public Boolean roomsUnavailable{get; set;}
    
    class Bookingdetails{
       Date bookingdate;
       String timeslot;
    }

    
    public String[] getavailableRooms() {
        return availableRooms;
    }
    public void setavailableRooms(String[] availableRooms) {
        this.availableRooms = availableRooms;
    }
    public AddMultipleRoomsController (ApexPages.StandardController controller) {
        calMngmntObj = (Calendar_Management__c)controller.getRecord(); 
        calMngmntObj = [SELECT Id,Site__c,Applies_to_Other_Rooms__c,Half_Day__c,Customer_Engagement_Event__c,recordTypeId,Status__c,Event_Record_type__c,Site__r.name,Room__c,Date__c FROM Calendar_Management__c  WHERE Id =: calMngmntObj.Id LIMIT 1]; 
        this.roomsUnavailable=false;
    }
    
    //To display the available rooms in the picklist 
    public List<SelectOption> getRoomDispaly() {
        roomDetailsMap= new Map<Id, Event_Location__c>();
        calendarManagmentMap = new Map<Id, List<Bookingdetails>>();        
        List<SelectOption> options = new List<SelectOption>(); 
        List<Calendar_Management__c> calendarManagementList;
        List<Bookingdetails> dateBooked;
        List<Id> roomIdList=new List<Id>();
        Boolean roomBooked=false;
        
        List<Event_Location__c> roomsList=[SELECT Id,Name,Room_Occupancy__c,Room_Type__c FROM Event_Location__c where Select_Site__c =:calMngmntObj.Site__c and recordType.name='rooms' and Active__c=true];
            for(Event_Location__c room : roomsList){
                roomDetailsMap.put(room.Id,room);
                roomIdList.add(room.Id);
            }
            
           /* calendarManagementList=[select Date__c,Room__r.Id,Id from Calendar_Management__c where Room__r.Id in :roomIdList and Date__c =:calMngmntObj.Date__c and (Status__c='Pending' or Status__c='Scheduled') and (Event_Record_type__c='Briefing' or Event_Record_type__c='vEBC')];
            for(Calendar_Management__c calendarManagement: calendarManagementList){
                if(calendarManagmentMap.get(calendarManagement.Room__r.Id)==null){
                    dateBooked=new List<Date>();
                    dateBooked.add(calendarManagement.Date__c);
                    calendarManagmentMap.put(calendarManagement.Room__r.Id,dateBooked);
                }
                calendarManagmentMap.get(calendarManagement.Room__r.Id).add(calendarManagement.Date__c);
            }*/
            calendarManagementList=[select Date__c,Room__r.Id,Half_Day__c,recordType.name,Start_Date__c,Id from Calendar_Management__c where Room__r.Id in :roomIdList and Date__c =:calMngmntObj.Date__c  and (((Status__c='Pending' or Status__c='Scheduled') and (Event_Record_type__c='Briefing' or Event_Record_type__c='vEBC')) or  Status__c='Internal')];//Query Calendar_Management__c to get the list of Bookings for Rooms in roomIdList//CR #6366
                
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
                
        /*for(Id roomDetailsMapKey:roomDetailsMap.keyset()){
            roomBooked=false;
            if(calendarManagmentMap.get(roomDetailsMapKey)!=null){
                for(Date datebked:calendarManagmentMap.get(roomDetailsMapKey)){
                    if(datebked==calMngmntObj.Date__c){
                        roomBooked=true;
                        break;
                    }
                }
            }*/
            for(String roomDetailsMapKey:roomDetailsMap.keyset()){
                roomBooked=false;
                //Boolean roomBookedPM=false;
                if(calendarManagmentMap.get(roomDetailsMapKey)!=null){
                    for(Bookingdetails datebked:calendarManagmentMap.get(roomDetailsMapKey)){
                        if(datebked.bookingdate==calMngmntObj.Date__c&& datebked.timeslot==calMngmntObj.Half_Day__c){
                            roomBooked=true;
                        }//checks if room is booked for AM
                        
                    }
                }
            if(roomBooked==false){
            options.add(new SelectOption(roomDetailsMapKey,''+(roomDetailsMap.get(roomDetailsMapKey).Name+' - '+ roomDetailsMap.get(roomDetailsMapKey).Room_Type__c)+' Room'));
            
            }
        }  
        if(options.size()==0){
            options.add(new SelectOption('','No Rooms are available for this site'));
            roomsUnavailable=true;
        }
        
        return options; 
    }
    
    //Create recordS to block 1 room or multiple rooms
    public PageReference createRecords() {
        PageReference pageRef ;
        Map<String, Id> recordTypeIdMap;
        List<Calendar_Management__c> secondarycalendarManagementList=new List<Calendar_Management__c>();   
        Calendar_Management__c calendarManagement; 
        
        List<RecordType> recordtypelist=[select id,name,SobjectType  from RecordType where (SobjectType='Calendar_Management__c') and (name='Primary Calendar RT' or name='Secondary Calendar RT')];
        recordTypeIdMap= new Map<String, Id>();
        for(RecordType r:recordtypelist){
            recordTypeIdMap.put(r.name,r.Id);
        }
        
        
        for(Integer i=0; i<availableRooms.size();i++){
            calendarManagement = new Calendar_Management__c();
            calendarManagement.Customer_Engagement_Event__c=calMngmntObj.Customer_Engagement_Event__c;
            calendarManagement.Room__c= availableRooms.get(i);
            calendarManagement.Date__c = calMngmntObj.Date__c;
            calendarManagement.Half_Day__c=calMngmntObj.Half_Day__c;
            calendarManagement.Status__c ='Pending';
            calendarManagement.Event_Record_type__c=calMngmntObj.Event_Record_type__c;
            calendarManagement.Site__c=calMngmntObj.Site__c;
            calendarManagement.recordTypeId=recordTypeIdMap.get('Secondary Calendar RT');
            calendarManagement.Calendar_Management_Record_ID__c=calMngmntObj.Id;
            calendarManagement.Applies_to_Other_Rooms__c=true;
            secondarycalendarManagementList.add(calendarManagement);
            system.debug('**secondarycalendarManagementList'+calendarManagement);
        }
        
        
        if(secondarycalendarManagementList.size()!=0){
            
            calMngmntObj.Applies_to_Other_Rooms__c=true;
            update calMngmntObj;
            
            insert secondarycalendarManagementList;
        }
            
            
        pageRef = new PageReference('/'+calMngmntObj.Id);
        return pageRef;
    
    }
    
    
}