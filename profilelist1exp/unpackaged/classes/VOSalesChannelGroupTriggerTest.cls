/*        
* Revision Ref Number  Release No  Date            Modified By     Description
* -------- ----------  ----------  -----------     ------------    -----------
* 1.0      6192529  DCE-FY20-0502  11-Apr-2019    Rajiv Ranjan        Test class for VOSalesChannelGroupTrigger    
*/
@isTest
public class VOSalesChannelGroupTriggerTest {
    
    @testSetup
    public static void setupTestData(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(true);
        test.startTest();
        Sales_Channel_Group__c salesChannel = new Sales_Channel_Group__c(Name='Sales Channel Test', Regional_Parent_Name__c = 'EMEA');
        insert salesChannel;
        
        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        listAccTdf[0].Sales_Channel__c = salesChannel.Id;
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].accountId=listAccTdf[0].id;
        listOppTdf[0].VisitOps__MainCompetitors__c='test';
        TriggerExecutionController.setSkipOpportunitySplitTriggers(true);
        insert listOppTdf;
        VisitOps__Location__c loc = new VisitOps__Location__c();
        loc.name='Banglore';
        loc.VisitOps__Time_Zone__c='(GMT+14:00) Line Islands Time (Pacific/Kiritimati)';
        insert loc; 
        
        VisitOps__VisitType__c  vType= new VisitOps__VisitType__c   ();
        vType.name='Community Visit Type';
        vType.VisitOps__Category__c ='Community';
        insert vType;
        
        VisitOps__Status__c status= new VisitOps__Status__c();
        status.name='Submitted';
        insert status;
        
        visitops__visit__c visit= new visitops__visit__c();
        visit.VisitOps__VisitName__c='test';
        visit.VisitOps__VisitType__c=vType.id;
        visit.VisitOps__TotalNoOfAttendees__c=1;
        visit.VisitOps__Location__c=loc.id;
        visit.VisitOps__DepartureDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTimeLocationTZ__c= '2017-09-11 02:02:42';
        visit.VisitOps__ArrivalDateTime__c=datetime.now()+1;
        visit.VisitOps__DepartureDateTime__c=datetime.now()+2;
        visit.VisitOps__VisitOwner__c=userinfo.getUserId();
        visit.VisitOps__VisitStatus__c  =status.id;
        insert visit;
        
        visitops__company__c company= new visitops__company__c();
        company.VisitOps__Company_Name__c='test';
        company.visitops__visit__c=visit.id;
        company.Child_Parent_Company_Number__c='C00';
        company.VisitOps__Account__c = listAccTdf[0].id; 
        insert company;
        
        VisitOps__VisitBundle__c bundle= new VisitOps__VisitBundle__c();
        bundle.VisitOps__Opportunity__c=listOppTdf[0].id;
        bundle.VisitOps__Visit__c=visit.id;
        insert bundle;
        test.stopTest();
    }
    
    @isTest
    public static void testAfterUpdateSegmentDesc(){
        Sales_Channel_Group__c salesChannelGroup =  [Select ID From Sales_Channel_Group__c Limit 1];
        salesChannelGroup.Segment_Desc__c = 'Test Desc';        
        update salesChannelGroup;  
        System.assertEquals('Test Desc', salesChannelGroup.Segment_Desc__c, 'Segment Desc should be Test Desc');
        salesChannelGroup.Region_Desc__c = 'Test Region Desc';
        update salesChannelGroup;
        salesChannelGroup.Segment_Business_Unit_Name__c = 'Test BS Name';        
        update salesChannelGroup;
        salesChannelGroup.Regional_Parent_Name__c = 'Parent Name Test';
        update salesChannelGroup;
    }
}