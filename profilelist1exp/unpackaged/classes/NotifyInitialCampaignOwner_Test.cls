/*
***********************************************************************
Name: NotifyInitialCampaignOwner_Test
Author: Anwar
History:
Version Date            Modified By     Description     
------------------------------------------------------------------------
*1.0     18-June-2015     Anwar          Created for CR 11602
************************************************************************
*/
@isTest(SeeAllData=false)
private class NotifyInitialCampaignOwner_Test{
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
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Campaign> listCampaignTdf=TestDataFactory.createNCampaign(2,'Campaign 2.0');
        insert listCampaignTdf;
        
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1,'Deal Registration');
        listOppTdf[0].CampaignId=listCampaignTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testmethod void myTest(){
        system.Test.startTest();
        Map<Id, Opportunity> mapNewOpp = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapoldOpp = new Map<Id, Opportunity>();
        /* Campaign testCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', 
EndDate= date.newInstance(2010, 1, 1), 
IsActive=true, 
Description='Test Campaign', 
StartDate=date.newInstance(2009, 12, 1), 
Name='Test Campaign', 
Follow_Up_Role__c = 'Inside Sales Rep');
insert testCampaign;
system.debug('testCampaign' + testCampaign);
Campaign testCampaign1 = new Campaign (Type='eSeminar/Webcast/Webinar', 
EndDate= date.newInstance(2010, 1, 1), 
IsActive=true, 
Description='Test Campaign', 
StartDate=date.newInstance(2009, 12, 1), 
Name='Test Campaign2', Follow_Up_Role__c = 'Inside Sales Rep');
insert testCampaign1;
system.debug('testCampaign1' + testCampaign1);

Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true);
Opportunity opp=new Opportunity (name='teset opp SR', 
Total_Expected_Dell_Revenue__c=5000,
CloseDate=System.Today(),
Engagement_Type__c='Public Tender',
Solution_Type__c='Campus',
Solution_Name__c='Wired Chassis Switches',
Justification_Statement__c='test Justification_Statement__c',
End_User_Account_Name__c='test End_User_Account_Name__c', 
End_User_Mailing_City__c='mailing city',
End_User_Mailing_State_Province_Region__c='mailing state',
End_User_Mailing_Country__c='INDIA',
Save_End_Customer_to_my_list__c='Yes',
End_User_First_Name__c='end fist name',
End_User_Last_Name__c='end last name',
End_User_Email__c='test@gmail.com',
Is_the_Customer_Part_of_a_Larger_Group__c='Yes',
StageName='Plan - 1%',
Primary_Product_Delivery_Address_Region__c ='LATAM',
Primary_Product_Delivery_Address_Country__c= 'INDIA',
CampaignId =testCampaign.Id);

insert opp;
*/
        list<Campaign> listCampaign=[select id from Campaign Limit 2];
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        mapNewOpp.put(listOpp[0].Id, listOpp[0]);
        //Opportunity OldOpp = new Opportunity(id = opp.id, CampaignId = testCampaign1.Id);
        listOpp[0].CampaignId=listCampaign[1].id;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp;
        System.assertEquals(listCampaign[1].id,listOpp[0].CampaignId);
        //OldOpp.CampaignId = testCampaign1.Id;
        mapoldOpp.put(listOpp[0].Id, listOpp[0]);
        NotifyInitialCampaignOwner.sendEmailTocampaignowner(mapNewOpp, mapoldOpp);
        system.Test.stopTest();
    }
}