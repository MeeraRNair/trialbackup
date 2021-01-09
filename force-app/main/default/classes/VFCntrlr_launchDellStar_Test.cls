/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         16136       FY19-DCE-0802   12-July-2018    Venkat Sharan   Created test class for VFCntrlr_launchDellStar as part of the story 5240538
*/ 
@isTest
public class VFCntrlr_launchDellStar_Test {
    @testSetup static void setup() {
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].Accountid=listAccTdf[0].id;
        insert listOppTdf;
    }   
    
    
    
    /*  ---   TEST METHODS   ---   */ 
    
    //Test Method 1: Set an opportunity id as page parameter that has a partner account
    public static testMethod void testVFCntrlrlaunchDellStarConstructorwithParam() {
        
        System.debug('#MN:START of testVFCntrlrlaunchDellStarConstructorwithParam()');
        
        PageReference pageRef = Page.launchDellStar;
        Test.setCurrentPage(pageRef);
        
        //Get Test Data 
        List<User> listTestPartnerUser=new List<User>();
        listTestPartnerUser=[SELECT UserType,Id,Contact.Accountid FROM User  WHERE UserType='PowerPartner' AND ContactId!=null AND IsActive=TRUE AND UserRoleId != null LIMIT 1 ];
        
        if(listTestPartnerUser.size()>0){
            TriggerExecutionController.setSkipAllTriggers(true);
            
            //Creates account
            //Account objAccount = new Account(name='Test Account 001');
            //insert objAccount;
            list<Account> listAcc=[Select id from Account Limit 1];
            // Creates the opportunity with owner = a partner user
            /* String strRecordType = '012300000004zf2';    // Standard Opportunity
//Date dCloseDate = Date.newInstance(2011,03,26); // Fenny commented [18-July-2014]: To fulfill new VR OpptyBookDateValidation
Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: To fulfill new VR OpptyBookDateValidation

Opportunity objOpportunity = new Opportunity(Name='Opportunity 1', AccountId=objAccount.Id, 
CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', 
RecordTypeId=strRecordType,ownerId=listTestPartnerUser[0].id);
*/
            list<Opportunity> listOpp=[select id from Opportunity Limit 1];
            SystemBehaviorBypasser.setSkipValidationRules(new List<String>{'Opportunity'});
            TriggerExecutionController.setSkipAllTriggers(true);
            // insert objOpportunity;
            //ResetSystemBehaviorBypasser.resetSkipValidationRules(new List<String>{'Opportunity'});
            // Adds parameters to page URL        
            ApexPages.currentPage().getParameters().put('oid', listOpp[0].id);
            
            System.runAs(listTestPartnerUser[0]){
                
                Test.startTest();
                
                // Instantiates a new controller with all parameters in the page
                VFCntrlr_launchDellStar objController = new VFCntrlr_launchDellStar();
                
                Test.stopTest();
                
                //Asserts whether the current user is same as the RunAs user.
                System.assertEquals(objController.getUserDetails().id,listTestPartnerUser[0].id);
                
                //Asserts whether the Partner account of the Opportunity is same as that of the owner of the Opp. 
                System.assertEquals(objController.getPartnerAccount().id,listTestPartnerUser[0].Contact.Accountid);
                
                //Asserts the getCurrentOpp returns the correct opportunity
                //System.assertEquals(objController.getCurrentOpp().id,listOpp[0].id);
            }//end of runAs block
            
        }
        System.debug('#MN:END of testVFCntrlrlaunchDellStarConstructorwithParam()');
    }    
    
    //Test Method 2:Create constructor without setting opportunity parameter
    public static testMethod void testVFCntrlrlaunchDellStarConstructorwithoutParam() {        
        
        System.debug('#MN:START of testVFCntrlrlaunchDellStarConstructorwithoutParam()');
        
        PageReference pageRef = Page.launchDellStar;
        Test.setCurrentPage(pageRef);
        
        //Get Test Data 
        List<User> listTestPartnerUser=new List<User>();
        listTestPartnerUser=[SELECT UserType,Id,Contact.Accountid FROM User  WHERE UserType='PowerPartner' AND ContactId!=null AND IsActive=TRUE AND UserRoleID != null LIMIT 1];
        
        if(listTestPartnerUser.size()>0){
            
            System.runAs(listTestPartnerUser[0]){
                Test.startTest();
                // Instantiates a new controller without any parameters to the page
                VFCntrlr_launchDellStar objController = new VFCntrlr_launchDellStar();
                Test.stopTest();
                
                //Asserts whether the current user is same as the RunAs user.
                System.assertEquals(objController.getUserDetails().id,listTestPartnerUser[0].id);
                
                //Asserts whether the partner account is same as partner user account
                System.assertEquals(objController.getPartnerAccount().id,listTestPartnerUser[0].Contact.Accountid);
                
                //Asserts that the getmethod returns a new opportunity.
                System.assertEquals(objController.getCurrentOpp(),new Opportunity());
            }//end of RunAs block
            
        }
        System.debug('#MN:END of testVFCntrlrlaunchDellStarConstructorwithoutParam()');
    } 
}