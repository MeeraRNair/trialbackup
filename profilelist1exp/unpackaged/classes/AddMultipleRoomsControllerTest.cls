@isTest 
private class AddMultipleRoomsControllerTest {
    static List<Calendar_Management__c> testCalendarManagements=new List<Calendar_Management__c>();
    
    static Event_Location__c testSite1=new Event_Location__c();
    static Event_Location__c testSite2=new Event_Location__c();
    static Event_Location__c testRoom1=new Event_Location__c();
    static Event_Location__c testRoom2=new Event_Location__c();
    static Event_Location__c testRoom3=new Event_Location__c();
    static Calendar_Management__c testCalendarManagement1;
    
    private static testmethod void createSiteRoomTour(){
        List<RecordType> recordtypelist=[select id,name,SobjectType  from RecordType  WHERE (SobjectType='Calendar_Management__c' or sObjectType='Event_Location__c' ) and (name='Sites' OR name='Rooms' or name='Primary Calendar RT' or name='Secondary Calendar RT' )];
        Map<String, Id> recordTypeIdMap= new Map<String, Id>();
        for(RecordType r:recordtypelist){
            recordTypeIdMap.put(r.name,r.Id);
        }
    
            List<Event_Location__c> testSiteRoomTour1=new List<Event_Location__c>();    
            /*create test site */
            
            testSite1=new Event_Location__c(Name='testSite11',Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;vEBC;IT Conference Call;Tour',recordTypeid=recordTypeIdMap.get('Sites'),Active__c=true);
            testSiteRoomTour1.add(testSite1);
            testSite2=new Event_Location__c(Name='testSite22',Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;vEBC;IT Conference Call;Tour',recordTypeid=recordTypeIdMap.get('Sites'),Active__c=true);
            testSiteRoomTour1.add(testSite2);
            
            insert testSiteRoomTour1;
            /*create test rooms*/
            
            List<Event_Location__c> testSiteRoomTour=new List<Event_Location__c>();    
            testRoom1=new Event_Location__c(Name='testRoom1',Room_Occupancy__c='15',Room_Type__c='Single',Select_Site__c=testSite1.Id,recordTypeid=recordTypeIdMap.get('Rooms'),Active__c=true);
            testSiteRoomTour.add(testRoom1);
            testRoom2=new Event_Location__c(Name='testRoom2',Room_Occupancy__c='20',Room_Type__c='Double',Select_Site__c=testSite1.Id,recordTypeid=recordTypeIdMap.get('Rooms'),Active__c=true);
            testSiteRoomTour.add(testRoom2);
            testRoom3=new Event_Location__c(Name='testRoom3',Room_Occupancy__c='20',Room_Type__c='Double',Select_Site__c=testSite2.Id,recordTypeid=recordTypeIdMap.get('Rooms'),Active__c=true);
            testSiteRoomTour.add(testRoom3);
        
            insert testSiteRoomTour;
    }
    
    private static testmethod void createSiteWithoutRoom(){
        List<RecordType> recordtypelist=[select id,name,SobjectType  from RecordType  WHERE (SobjectType='Calendar_Management__c' or sObjectType='Event_Location__c' ) and (name='Sites' OR name='Rooms' or name='Primary Calendar RT' or name='Secondary Calendar RT' )];
        Map<String, Id> recordTypeIdMap= new Map<String, Id>();
        for(RecordType r:recordtypelist){
            recordTypeIdMap.put(r.name,r.Id);
        }
            List<Event_Location__c> testSiteRoomTour1=new List<Event_Location__c>();    
            /*create test site */
            
            testSite1=new Event_Location__c(Name='testSite11',Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;vEBC;IT Conference Call;Tour',recordTypeid=recordTypeIdMap.get('Sites'),Active__c=true);
            testSiteRoomTour1.add(testSite1);
            testSite2=new Event_Location__c(Name='testSite22',Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;vEBC;IT Conference Call;Tour',recordTypeid=recordTypeIdMap.get('Sites'),Active__c=true);
            testSiteRoomTour1.add(testSite2);
            insert testSiteRoomTour1;
    }
    
    private static testmethod void  createTestCalendarManagements(){
        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite1.Id,Room__c=testRoom1.Id,Event_Record_type__c='IT Conference Call',Date__c=System.today()+30,Start_Date__c=System.today()+30,End_Date__c=System.today()+30,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        insert testCalendarManagements;
    }
    
    static testMethod void  myUnitTestAddMultipleRoomsControllerTest() {
    	List<String> lstOfAvailRooms = new List<String>();
    	lstOfAvailRooms.add(testRoom1.Id);
    	lstOfAvailRooms.add(testRoom2.Id);
    	lstOfAvailRooms.add(testRoom3.Id);
        createSiteRoomTour();
        createTestCalendarManagements();
        AddMultipleRoomsController addMultipleRoomsControllerObj = new AddMultipleRoomsController(new ApexPages.StandardController(testCalendarManagement1));
        Test.startTest();
        addMultipleRoomsControllerObj.getRoomDispaly();
        addMultipleRoomsControllerObj.getavailableRooms();
        addMultipleRoomsControllerObj.setavailableRooms(lstOfAvailRooms);
        addMultipleRoomsControllerObj.availableRooms.add(testRoom2.Id);
        addMultipleRoomsControllerObj.createRecords();
        testCalendarManagement1.Site__c=testSite2.Id;
        testCalendarManagement1.Room__c=testRoom3.Id;
        update testCalendarManagement1;
        Test.stopTest();
    }
    
    static testMethod void  testAddMultipleRoomsControllerWithoutRooms() {
        createSiteWithoutRoom();
        createTestCalendarManagements();
        AddMultipleRoomsController addMultipleRoomsControllerObj = new AddMultipleRoomsController(new ApexPages.StandardController(testCalendarManagement1));
        Test.startTest();
        addMultipleRoomsControllerObj.getRoomDispaly();
        addMultipleRoomsControllerObj.availableRooms.add(testRoom2.Id);
        addMultipleRoomsControllerObj.createRecords();
        testCalendarManagement1.Site__c=testSite2.Id;
        testCalendarManagement1.Room__c=testRoom3.Id;
        update testCalendarManagement1;
        Test.stopTest();
    }
    
    //Test Method for Recurrance Controller
    
    /*static testMethod void  myUnitTestRecurranceControllerTest() {
        createSiteRoomTour();
        createTestCalendarManagements();
        RecurranceController recurranceControllerObj = new RecurranceController(new ApexPages.StandardController(testCalendarManagement1));
        recurranceControllerObj.getType();
        recurranceControllerObj.getOccursonWeek();
        recurranceControllerObj.displayOptions();
        recurranceControllerObj.calMngmntObj.Recurring_Till__c=System.today()+90;
        Test.startTest();
        
        recurranceControllerObj.recuranceType='Daily';
        recurranceControllerObj.OccursonDay=2;
        recurranceControllerObj.createRecurringRecords();
        
        recurranceControllerObj.recuranceType='Weekly';
        recurranceControllerObj.occurson.add('2');
        recurranceControllerObj.occurson.add('3');
        recurranceControllerObj.createRecurringRecords();
        
        recurranceControllerObj.recuranceType='Monthly';
        recurranceControllerObj.OccursonDayofMonth=31;
        recurranceControllerObj.createRecurringRecords();
        
        Test.stopTest();
        
    }*/

}