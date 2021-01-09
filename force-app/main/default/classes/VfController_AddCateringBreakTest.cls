@isTest
private class VfController_AddCateringBreakTest{
 static list<Opportunity> listOpp;
 static list<Account> listAcc;
 static Customer_Engagement__c testCE = new Customer_Engagement__c();
    //Account newaccount;// = new Account();
    static Opportunity newOpportunity = new Opportunity();
    static  Attending_Accounts__c newAttendingAccounts = new Attending_Accounts__c();
    static Agenda_Content__c agCon = new Agenda_Content__c();
    static List<Agenda_Content__c> listsc = new List<Agenda_Content__c >();
    static List <CateringBreakWrapper> listcb =  new List<CateringBreakWrapper> ();
    static List <Event_Location__c> listel = new List<Event_Location__c> ();
    public static void createData(){
/*        RecordType OpportunityRt = [Select Name, Id 
                                   From RecordType
                                   where sObjectType='Opportunity' and name='Run Rate Opportunity' limit 1]; */
         RecordType ceRt = [Select Name, Id 
                                   From RecordType
                                   where sObjectType='Customer_Engagement__c' and name='Dell Solution Centers' limit 1];

       //Account newaccount =new Account(Name='Test Account');
       // insert newaccount;
		listAcc = TestDataFactory.createNAccount(1, 'Master Account');
        insert listAcc;
        system.assertEquals(listAcc, listAcc);
        testCE.Name = 'Mytest CE';
        testCE.Primary_Account__c = listAcc[0].Id;
        testCE.RecordTypeId =ceRt.id;
        insert testCE;
        list<Opportunity> listOpp = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOpp[0].AccountId = newAttendingAccounts.Id;
        insert listOpp;
		/*
        newOpportunity.RecordTypeId = acRecTypeId;
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.AccountId = newAttendingAccounts.Id;
        newOpportunity.StageName = 'testStage';
        newOpportunity.CloseDate = System.Today();
        insert newOpportunity; 
        */ 
        newAttendingAccounts.Customer_Engagement__c = testCE.Id;
        insert newAttendingAccounts;        
     
     
      
   List<RecordType> listrecTypCE = [Select r.Id, r.Name from RecordType r Where Id =: testCE.RecordTypeId  and IsActive=true]; 
    
    string strrecTypeName = listrecTypCE.get(0).Name == 'Dell Solution Centers' ? 'DSC' : 'EBC';
    system.debug('##### The record Type Name is  ' + strrecTypeName);
    List<RecordType> listrecTypBreak = [Select r.Id, r.Name, r.SobjectType from RecordType r Where SobjectType='Agenda_Content__c' and Name = 'Breaks' And IsActive=true];
    string strbreakRecType = listrecTypBreak.get(0).Id;
      
        agCon.Name='www';
        agCon.Break_Type__c = 'Catering';
        agCon.Active__c = true;
        agCon.RecordTypeId = strbreakRecType;
        agCon.Engagement_Type__c = strrecTypeName;
        insert agCon;
     
    }

public static testMethod void testMyController() {
        //Skip all triggers
        TriggerExecutionController.setSkipAllTriggers(true);
        createData ();
        //Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
        PageReference pageRef = new PageReference ('/apex/AddCateringBreak?id='+testCE.id);
        Test.setCurrentPage(pageRef);
        system.assertEquals(testCE.id, testCE.id);
        VfController_AddCateringBreak testObject = new VfController_AddCateringBreak();
        testObject.addCateringBreaks();
        List<CateringBreakWrapper> listcw=testObject.getAgendaContent() ;        
        listcw[0].isChecked=True;
        
        PageReference pr=testObject.addCateringBreaks();
        testObject.getAddCateringBreaks();
        
        PageReference pr1=testObject.backToCE() ;
               
}
}