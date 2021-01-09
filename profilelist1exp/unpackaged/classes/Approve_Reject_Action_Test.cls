/* 
History:
Version     Date           Modified By           Description    
1.0      13-Nov-2015     Yeswanth Ravilla     Test Class for Approve_Reject_Action  class
2.0      08-Jan-2019     Meenu                FY20-DCE-0202 16970 Field Trip clean up for Opportunity (Remove/Comment check_for_other_channel_program__c,
check_for_specialty_product__c,review_lob_awards__c fields)
*/
@isTest(seeAlldata = FALSE)
public class Approve_Reject_Action_Test {
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(1, 'Deal Registration-Submitted');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOppFromFactory;
    }   
    static testMethod void approveRejectDealTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
         List<String> lstObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);

        listAcc=[select id from account];
        listAcc[0].NPS_Qualified_Contacts__c = 1;
        listAcc[1].type='Partner';
        update listAcc;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].Id;
        listOpp[0].Deal_Registration_Status__c= 'Submitted';
        listOpp[0].Deal_Type__c ='Agent';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Request_Status__c = 'Submitted';
        listOpp[0].Engagement_Type__c='Public Tender';
        listOpp[0].Distributor_Name__c='Direct Fulfilment';
        
        update listOpp;        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(listOpp[0].Id);
        req1.setSkipEntryCriteria(true);
        req1.setProcessDefinitionNameOrId('Deal_Renewal_Approval');
        Approval.ProcessResult result = Approval.process(req1);
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.VF_ApproveRejectCustomButton;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        Approve_Reject_Action con = new Approve_Reject_Action (new ApexPages.StandardController(listOpp[0]));
        con.Approve_Reject_Action();
        con.isValidApprover();
    }
    static testMethod void approveRejectDealTest1(){
        TriggerExecutionController.setSkipAllTriggers(true);
List<String> lstObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);

        listAcc=[select id from account];
        listAcc[0].NPS_Qualified_Contacts__c = 1;
        listAcc[1].type='Partner';
        update listAcc;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].Id;
        listOpp[0].Deal_Registration_Status__c= 'Rejected';
        listOpp[0].Deal_Type__c ='Agent';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Request_Status__c = 'Submitted';
        listOpp[0].Bypass_Close_Date__c = True;
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.VF_ApproveRejectCustomButton;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        Approve_Reject_Action con = new Approve_Reject_Action (new ApexPages.StandardController(listOpp[0]));
        con.Approve_Reject_Action();
    }
    static testMethod void approveRejectDealTest3(){
        TriggerExecutionController.setSkipAllTriggers(true);
List<String> lstObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);

        listAcc=[select id from account];
        listAcc[0].NPS_Qualified_Contacts__c = 1;
        listAcc[1].type='Partner';
        update listAcc;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].Id;
        //listOpp[0].Deal_Registration_Reviewer__c=
        listOpp[0].Deal_Registration_Status__c= 'Submitted';
        listOpp[0].Deal_Type__c =null;
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Request_Status__c = 'Submitted';
        listOpp[0].Bypass_Close_Date__c = True;
        listOpp[0].Distributor_Name__c='';
        update listOpp;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(listOpp[0].Id);
        req1.setSkipEntryCriteria(true);
        req1.setProcessDefinitionNameOrId('Deal_Renewal_Approval');
        Approval.ProcessResult result = Approval.process(req1);
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.VF_ApproveRejectCustomButton;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        Approve_Reject_Action con = new Approve_Reject_Action (new ApexPages.StandardController(listAcc[1]));
        con.Approve_Reject_Action();
        con.isValidApprover();
    }
    static testMethod void approveRejectDealTest4(){
        TriggerExecutionController.setSkipAllTriggers(true);
        List<String> lstObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);
 Profile userProfile= [select id,name from profile where name like '%GBL PRM Operations%' order by name limit 1 ];
      //  UserRole role = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        User adminUser = [Select Id From User Where Profileid=:userProfile.id AND IsActive = True Limit 1];
        UserRole role1 = [select id, name from Userrole where name like '%Partner User%' limit 1];
        listAcc=[select id from account];
        listAcc[0].NPS_Qualified_Contacts__c = 1;
        listAcc[1].type='Partner';
        update listAcc;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].Id;
        //listOpp[0].Deal_Registration_Reviewer__c=
        listOpp[0].Deal_Registration_Status__c= 'Submitted';
        listOpp[0].Deal_Type__c ='Agent';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Request_Status__c = 'Submitted';
        listOpp[0].Bypass_Close_Date__c = True;
        listOpp[0].Distributor_Name__c='Distribution';
        listOpp[0].Enterprise_Sales_Approval_Requested__c =false;
        listOpp[0].Deal_Registration_Reviewer__c =adminUser.id;
        update listOpp;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(listOpp[0].Id);
        req1.setSkipEntryCriteria(true);
        req1.setProcessDefinitionNameOrId('Deal_Renewal_Approval');
        Approval.ProcessResult result = Approval.process(req1);
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.VF_ApproveRejectCustomButton;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        Approve_Reject_Action con = new Approve_Reject_Action (new ApexPages.StandardController(listAcc[1]));
        con.Approve_Reject_Action();
        con.isValidApprover();
    }
    static testMethod void approveRejectDealTest5(){
        TriggerExecutionController.setSkipAllTriggers(true);
        List<String> lstObjAPINames = new List<String>{'Opportunity'};
        SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);
 Profile userProfile= [select id,name from profile where name like '%GBL PRM Operations%' order by name limit 1 ];
      //  UserRole role = [select id, name from Userrole where name like '%WW_Exec%' limit 1];
        User adminUser = [Select Id From User Where Profileid=:userProfile.id AND IsActive = True Limit 1];
        UserRole role1 = [select id, name from Userrole where name like '%Partner User%' limit 1];
        listAcc=[select id from account];
        listAcc[0].NPS_Qualified_Contacts__c = 1;
        listAcc[1].type='Partner';
        update listAcc;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].Id;
        //listOpp[0].Deal_Registration_Reviewer__c=
        listOpp[0].Deal_Registration_Status__c= 'Submitted';
        listOpp[0].Deal_Type__c ='Agent';
        listOpp[0].Save_End_Customer_to_my_list__c = 'No';
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        listOpp[0].Request_Status__c = 'Submitted';
        listOpp[0].Bypass_Close_Date__c = True;
        listOpp[0].Distributor_Name__c='Direct Fulfilment';
        listOpp[0].Enterprise_Sales_Approval_Requested__c =false;
        listOpp[0].Deal_Registration_Reviewer__c =adminUser.id;
        update listOpp;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(listOpp[0].Id);
        req1.setSkipEntryCriteria(true);
        req1.setProcessDefinitionNameOrId('Deal_Renewal_Approval');
        Approval.ProcessResult result = Approval.process(req1);
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.VF_ApproveRejectCustomButton;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        Approve_Reject_Action con = new Approve_Reject_Action (new ApexPages.StandardController(listAcc[1]));
        con.Approve_Reject_Action();
        con.isValidApprover();
    }
}