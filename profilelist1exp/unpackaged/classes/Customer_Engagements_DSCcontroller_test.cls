@isTest
public class Customer_Engagements_DSCcontroller_test{
static testmethod void myDSCtest()

{
string RTId ;
List<RecordType> RT=[select id from RecordType where SobjectType='Event_Location__c' and name='Sites' limit 1];
 for(RecordType r:RT)
    {
      RTId=r.Id;
    }

    Account acc = new Account();
    acc.Name = 'testAccount';
    insert acc;
    
    
    Event_Location__c elc = new Event_Location__c(
    Name ='test',
    Region__c ='APJ',
    Engagement_Type__c ='DSC',
    Email__c ='test@mail.com',
    Active__c = true,
    recordtypeid = RTId,
    Offer_Transportation__c ='yes',
    Offer_Catering__c ='yes');
    insert elc;
    
    Customer_Engagement__c custe = new Customer_Engagement__c(
    Name='test',
    Estimated_no_of_Customer_Attendees__c=114,
    Event_Type__c ='Breifing',
    Dell_Solution_Center_Site__c=elc.id,
    GSL_End_Date__c=System.Today(),
    GSL_Start_Date__c=System.Today(),
    Customer_Type__c='Onsite Customer',
    NDA__c='Yes',
    Trade_Compliant__c='Yes',
    Customer_Background__c='test',
    Objective_of_Visit__c='test',
    Top_3_Pain_Points__c='test',
    Potential_for_case_study__c='Yes',
    Reason_for_Above_Answer__c='test',
    Primary_Account__c = acc.id,
    Requestor_Name__c = UserInfo.getUserId()
    );
    insert custe;
    
    ApexPages.StandardController  stdCon = new ApexPages.StandardController(custe);
    Customer_Engagements_DSCcontroller dsct=new Customer_Engagements_DSCcontroller(stdCon);
    
    dsct.customerEng = custe;
    dsct.posId = elc.Id;
    dsct.editFlag = true;
    dsct.showHideErr = true;
    dsct.err = 'Please select both DSC Event Type and DSC Site';
    dsct.getsites();
    dsct.Displayerr();
    

   } 
   static testmethod void myDSCtestagain()

{
string RTId ;
List<RecordType> RT=[select id from RecordType where SobjectType='Event_Location__c' and name='Sites' limit 1];
 for(RecordType r:RT)
    {
      RTId=r.Id;
    }

    Account acc = new Account();
    acc.Name = 'testAccount';
    insert acc;
    
    
    Event_Location__c elc = new Event_Location__c(
    Name ='test',
    Region__c ='APJ',
    Engagement_Type__c ='DSC',
    Email__c ='test@mail.com',
    Active__c = true,
    recordtypeid = RTId,
    Offer_Transportation__c ='yes',
    Offer_Catering__c ='yes');
    insert elc;
    
    Customer_Engagement__c custe = new Customer_Engagement__c(
    Name='test',
    Estimated_no_of_Customer_Attendees__c=114,
    Event_Type__c = null,
    Dell_Solution_Center_Site__c=elc.id,
    GSL_End_Date__c=System.Today(),
    GSL_Start_Date__c=System.Today(),
    Customer_Type__c='Onsite Customer',
    NDA__c='Yes',
    Trade_Compliant__c='Yes',
    Customer_Background__c='test',
    Objective_of_Visit__c='test',
    Top_3_Pain_Points__c='test',
    Potential_for_case_study__c='Yes',
    Reason_for_Above_Answer__c='test',
    Primary_Account__c = acc.id,
    Requestor_Name__c = UserInfo.getUserId()
    );
    insert custe;
    
    ApexPages.StandardController  stdCon = new ApexPages.StandardController(custe);
    Customer_Engagements_DSCcontroller dsct=new Customer_Engagements_DSCcontroller(stdCon);
    
    dsct.customerEng = custe;
    dsct.customerEng.Event_Type__c = null;
    dsct.posId ='--None--';
    dsct.editFlag = false;
    dsct.showHideErr = true;
    dsct.err = 'Please select both DSC Event Type and DSC Site';
    dsct.getsites();
    dsct.Displayerr();
    

   } 
  
}