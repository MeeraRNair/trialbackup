/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      18-June-2010   Azwanti         Created for CR2246 & 2243, R11.7
2.0      05-June-2013   Anamika         updated Test 3 to update CM and then update campaign to inactive
3.0      08-Jan-2018    Kokila          FY20-DCE-0202 - Lead 2.0 - Campaign Status enhancements - "Aborted" status renamed to "Cancelled" 
--------------------------------------------------------------------------------------
 */

@isTest
private class BatchUpdateCampaignMemberTest {
    static Campaign testCampaign;
    static Account testAcc;
    static List<CampaignMember> listTestCM = new List<CampaignMember>();
    static List<Contact> listTestContact = new List<Contact>();

 /* ----------------------------------- TEST METHODS FOR CAMPAIGN MEMBER --------------------------------------------------- */
    //TestCondition 1: Campaign status = 'Cancelled'
    public static testMethod void buCMStatusTest1(){
        system.debug('------- Start CM TestCondition 1 : Campaign Status = Cancelled ---------');
        testDataCreation();
        
        //v3.0 - Start
        /*testCampaign.Status = 'Aborted';  
        testCampaign.Proceed_with_cancellation__c = 'Yes';*/
        
        testCampaign.Status = 'Cancelled';  //v3.0 - End
        update testCampaign;
        
        BatchUpdateCampaignMember bucm = new BatchUpdateCampaignMember();
        /*
        bucm.queryCampaignMember = 'Select c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, '+
                                   'c.CM_Status__c From CampaignMember c '+
                                   'Where c.Campaign.Name = \'AZ CM Test Campaign CR2243\' AND ' +
                                   '(c.Campaign.Status = \'Aborted\' OR '+
                                   '(c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\') OR '+
                                   '(c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\'))';
        */
        
        //v3.0 - Start
        /*bucm.queryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, c.Campaign.Proceed_with_cancellation__c, '+
                                    'c.CM_Status__c FROM CampaignMember c '+
                                    'WHERE ((c.Campaign.Status = \'Aborted\' AND c.Campaign.Proceed_with_cancellation__c = \'Yes\' AND c.CM_Status__c != \'Cancelled\') '+
                                    'OR (c.Campaign.Proceed_with_cancellation__c != \'Yes\' AND ((c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                    'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\')))) '+
                                    'AND c.Campaign.Name =\'AZ CM Test Campaign CR2243\'' ;*/
        bucm.strQueryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, '+
                                    'c.CM_Status__c FROM CampaignMember c '+
                                    'WHERE ((c.Campaign.Status = \'Cancelled\' AND c.CM_Status__c != \'Cancelled\') '+
                                    'AND ((c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                    'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\'))) '+
                                    'AND c.Campaign.Name =\'AZ CM Test Campaign CR2243\'' ;
       //v3.0 - End
        System.debug('queryCampaignMember :'+bucm.strQueryCampaignMember);
                                   
        Test.startTest();                                                    
        database.executeBatch(bucm);
        Test.stopTest();
        
        List<CampaignMember> listCM = [Select c.CampaignId, c.CM_Status__c From CampaignMember c where c.CampaignID = :testCampaign.Id] ;
        System.assertEquals('Cancelled', listCM[0].CM_Status__c);
        system.debug('###DEBUG### 1. CM Status0 = ' + listCM[0].CM_Status__c);
        System.debug('----------------------- END: CM TestCondition 1 -----------------------'); 
    }   
    
    //TestCondition 2: Campaign status != 'Cancelled', CampaignActive = true
    public static testMethod void buCMStatusTest2() {
        System.debug('------- Start CM TestCondition 2 : Campaign Status != Cancelled | Campaign Active = TRUE ---------');
        testDataCreation();
        
        testCampaign.Status = 'Planned';    
        update testCampaign;            

        listTestCM[0].Status = 'Inactive';
        listTestCM[1].Status = 'Requires Follow-Up';
        update listTestCM;      
        
        BatchUpdateCampaignMember bucm = new BatchUpdateCampaignMember();
        /*
        bucm.queryCampaignMember = 'Select c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, '+
                                   'c.CM_Status__c From CampaignMember c '+
                                   'Where c.Campaign.Name = \'AZ CM Test Campaign CR2243\' AND ' +
                                   '(c.Campaign.Status = \'Aborted\' OR '+
                                   '(c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\') OR '+
                                   '(c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\'))';
        */
        //v3.0 - Start
        /*bucm.queryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, c.Campaign.Proceed_with_cancellation__c, '+
                                    'c.CM_Status__c FROM CampaignMember c '+
                                    'WHERE ((c.Campaign.Status = \'Aborted\' AND c.Campaign.Proceed_with_cancellation__c = \'Yes\' AND c.CM_Status__c != \'Cancelled\') '+
                                    'OR (c.Campaign.Proceed_with_cancellation__c != \'Yes\' AND ((c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                    'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\')))) '+
                                    'AND c.Campaign.Name =\'AZ CM Test Campaign CR2243\'' ;*/
        bucm.strQueryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId,  '+
                                    'c.CM_Status__c FROM CampaignMember c '+
                                    'WHERE ((c.Campaign.Status = \'Cancelled\' AND c.CM_Status__c != \'Cancelled\') '+
                                    'AND ((c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                    'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\'))) '+
                                    'AND c.Campaign.Name =\'AZ CM Test Campaign CR2243\'' ;                                             
        //v3.0 - End
        Test.startTest();                                                    
        database.executeBatch(bucm);
        Test.stopTest();
        
        List<CampaignMember> listCM2 = [Select c.CampaignId, c.CM_Status__c From CampaignMember c where c.CampaignID = :testCampaign.Id] ;
        System.assertEquals('Requires Follow-Up', listCM2[0].CM_Status__c);
        System.assertEquals('Requires Follow-Up', listCM2[1].CM_Status__c);
        system.debug('###DEBUG### 1. CM Status0 = ' + listCM2[0].CM_Status__c + ', CM Status1 = ' + listCM2[1].CM_Status__c);
        System.debug('----------------------- END: CM TestCondition 2 -----------------------'); 
                
    }
    //TestCondition 3: Campaign status != 'Cancelled', CampaignActive = false
    public static testMethod void buCMStatusTest3() {
        System.debug('------- Start CM TestCondition 3 : Campaign Status != Cancelled | Campaign Active = false ---------');
        testDataCreation();
                
        listTestCM[0].Status = 'Requires Follow-Up';
        listTestCM[1].Status = 'Inactive';
        update listTestCM;
        testCampaign.Status = 'Planned';
        testCampaign.IsActive = false;
        update testCampaign;              

        BatchUpdateCampaignMember bucm = new BatchUpdateCampaignMember();
        /*
        bucm.queryCampaignMember = 'Select c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, '+
                                   'c.CM_Status__c From CampaignMember c '+
                                   'Where c.Campaign.Name = \'AZ CM Test Campaign CR2243\' AND ' +
                                   '(c.Campaign.Status = \'Aborted\' OR '+
                                   '(c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\') OR '+
                                   '(c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\'))';
        */
        //v3.0 - Start
        /*bucm.queryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, c.Campaign.Proceed_with_cancellation__c, '+
                                    'c.CM_Status__c FROM CampaignMember c '+
                                    'WHERE ((c.Campaign.Status = \'Aborted\' AND c.Campaign.Proceed_with_cancellation__c = \'Yes\' AND c.CM_Status__c != \'Cancelled\') '+
                                    'OR (c.Campaign.Proceed_with_cancellation__c != \'Yes\' AND ((c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                    'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\')))) '+
                                    'AND c.Campaign.Name =\'AZ CM Test Campaign CR2243\'' ;*/
        bucm.strQueryCampaignMember = 'SELECT c.Campaign.IsActive, c.Campaign.Status, c.CampaignId, c.Campaign.Proceed_with_cancellation__c, '+
                                    'c.CM_Status__c FROM CampaignMember c '+
                                    'WHERE ((c.Campaign.Status = \'Cancelled\' AND c.CM_Status__c != \'Cancelled\') '+
                                    'OR (c.Campaign.IsActive = true AND c.CM_Status__c = \'Inactive\') '+
                                    'OR (c.Campaign.IsActive = false AND c.CM_Status__c = \'Requires Follow-Up\')) '+
                                    'AND c.Campaign.Name =\'AZ CM Test Campaign CR2243\'' ;
        //v3.0 - End
                                                     
        Test.startTest();                                                    
        database.executeBatch(bucm);
        Test.stopTest();
        
        List<CampaignMember> listCM3 = [Select c.CampaignId, c.CM_Status__c From CampaignMember c where c.CampaignID = :testCampaign.Id] ;
        System.assertEquals('Inactive', listCM3[0].CM_Status__c);
        System.assertEquals('Inactive', listCM3[1].CM_Status__c);
        system.debug('###DEBUG### 1. CM Status0 = ' + listCM3[0].CM_Status__c + ', CM Status1 = ' + listCM3[1].CM_Status__c);
        System.debug('----------------------- END: CM TestCondition 3 -----------------------'); 
    }

//==================================================== testDataCreation ===============================================================
    static void testDataCreation() {
        
        testAcc = new Account(name = 'testAccount'+System.currentTimeMillis()); 
        insert testAcc;     

        listTestContact.clear();
        for (integer intI = 0; intI < 2; intI++) {
            
            Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact'+intI);
            listTestContact.add(testContact);
        }                                            
        insert listTestContact;
        system.debug('###DEBUG### listTestContact Id 1 = ' + listTestContact[0].Id + ' , listTestContact Id 2 = ' + listTestContact[1].Id);
        testCampaign = new Campaign (Type='Dell Day', EndDate= date.newInstance(2025, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2015, 1, 1), 
                                                    Name='AZ CM Test Campaign CR2243', Follow_Up_Role__c = 'Inside Sales Rep');           
        insert testCampaign;
        
        for (integer intI = 0; intI < 2; intI++) {
            CampaignMember testCM = new CampaignMember(CampaignId = testCampaign.Id, Campaign_Vehicle__c = 'Dell Day',
                                                        ContactId = listTestContact[intI].Id, CM_Status__c = 'Requires Follow-Up');
            listTestCM.add(testCM);
        }                   
        insert listTestCM;                
                   
                    
    }
}