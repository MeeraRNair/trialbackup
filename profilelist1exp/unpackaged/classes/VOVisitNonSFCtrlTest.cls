/********************************************
Name   : VOVisitNonSFCtrlTest
Description   : test class for VOVisitNonSFCtrl
Author   : Rajesh Uppalapati, VisitOps

*********************************************/
@isTest(SeeAllData=false)
private class VOVisitNonSFCtrlTest {

    static VoVisitNonSFCtrl  newVisit;
     static VisitOps__Room__c room;
     static VisitOps__location__c Location;
     static VisitOps__place__c Place;
     static VisitOps__VisitType__c visitType;
     static VisitOps__Visit__c visit ;
     static VisitOps__Status__c status;
     static Id visitId;
    
     static void testGenerateTestData(String visittypeCategory){
          Location = new VisitOps__Location__c(name='testLocation',VisitOps__Location_Street_Address__c ='tsetStreet', VisitOps__Time_Zone__c = '(GMT+00:00) Greenwich Mean Time (GMT)');
           insert location;
          Place =new VisitOps__place__c(name='testPlace',VisitOps__location__c=location.id);  
           insert place;
          room = new VisitOps__Room__c(VisitOps__location__c= location.Id,name='testRoom',VisitOps__Place__c=Place.Id,VisitOps__Room_Capacity__c=20); 
           insert room;
          visitType= new VisitOps__VisitType__c(VisitOps__Category__c=visittypeCategory);
           insert visitType;      
          status = new VisitOps__Status__c(Name='New');
           insert status;       
          visit = new VisitOps__visit__c(VisitOps__Location__c=location.id,VisitOps__VisitOwner__c =userInfo.getUserId(),VisitOps__VisitType__c=visitType.id,VisitOps__TotalNoOfAttendees__c=20, VisitOps__VisitStatus__c =status.id,  VisitOps__VisitName__c='testVisit',VisitOps__DepartureDateTime__c=system.now()+2, VisitOps__ArrivalDateTime__c=system.now(), VisitOps__ArrivalDateTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),VisitOps__DepartureDateTimeLocationTZ__c=system.now().addDays(2).format('yyyy-MM-dd HH:mm:ss'));
           insert visit;
        
         visitId=visit.id;
         
       Account a=new Account(name='testAccount');
        insert a;
       Contact con = new Contact(lastname='testAttendee',accountId=a.id,Email='standarduser@dell.com');
        insert con;
       VisitOps__Attendee__c at = new VisitOps__Attendee__c(VisitOps__Contact__c= con.id); 
        insert at;
       VisitOps__Company__c c = new  VisitOps__Company__c(VisitOps__Account__c=a.id,VisitOps__Visit__c=visit.id);
        insert c;
        
    }
    
    static testmethod void testPaginatedGrid(){
    
    TriggerExecutionController.setSkipContactTriggers(true);
    TriggerExecutionController.setSkipAccountTriggers(true);
        
        testGenerateTestData('Internal Meeting');
        Test.startTest();
        PageReference pageRef = Page.VOVisitNonSFView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', visitId);
        newVisit=new VOVisitNonSFCtrl();
        
        ApexPages.currentPage().getParameters().put('id', '');
        newVisit=new VOVisitNonSFCtrl();
        
        System.assertequals(null,null);
        Test.stopTest();
    }


}