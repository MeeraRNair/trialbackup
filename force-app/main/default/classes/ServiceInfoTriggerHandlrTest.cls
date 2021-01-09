/*
*  Revision                      Name             Date              Description
*                               venugopalachary   15-10-2019        implimented TestDataFactory
*/
@isTest()
public class ServiceInfoTriggerHandlrTest{
    @testSetup static void setup() {
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
    }
    private static testMethod void testInsertServiceIfoMethod(){
        list<Partner_Track__c> listpartnertrack=new list<Partner_Track__c>();
        list<account> listAcc=[select id from account];
        listAcc[0].Partner_Type__c = 'US Federal';
        listAcc[0].Partner_Tier__c = 'Tier 2';
        listAcc[0].Partner_Relationship__c = 'Registered';
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'UNITED STATES';
        update listAcc;
        Partner_Track__c partnertrack=new Partner_Track__c(Partner_Track__c='Cloud Service Provider',
                                                           Enabled_for_Services__c=false
                                                          );
        listpartnertrack.add(partnertrack);
        insert listpartnertrack;
        List<Service_Information__c> listSerInfo = new List<Service_Information__c>(); 
        Service_Information__c serInfo = new Service_Information__c(Partner_Track__c=listpartnertrack[0].Id,
                                                                    Velocity_Services__c = 'Yes',
                                                                    Velocity_Services_Managed__c ='yes',
                                                                    Velocity_Services_Implement__c ='yes'
                                                                   );
        listSerInfo.add(SerInfo);
        insert listSerInfo ;
        Test.startTest();
        try
        {
            listSerInfo[0].Services_Onsite_Support_Exception__c=true;
            update listSerInfo;
        }
        catch(Exception ee){
            
        }
        list<Partner_Track__c> listpt=new list<Partner_Track__c>();
        Partner_Track__c ptTest=[select id,Enabled_for_Services__c from Partner_Track__c where id =: partnertrack.id];
        system.assertEquals(ptTest.Enabled_for_Services__c,true);
        Service_Information__c serinfo2=[select id,Partner_Track__c,Velocity_Services__c,Velocity_Services_Implement__c,Velocity_Services_Managed__c from Service_Information__c where id =:SerInfo.id ];
        serinfo2.Velocity_Services__c='No';
        serinfo2.Velocity_Services_Implement__c='NO';
        serinfo2.Velocity_Services_Managed__c='No';
        update serinfo2;
        Partner_Track__c ptTest1=[select id,Enabled_for_Services__c from Partner_Track__c where id =: partnertrack.id];
        system.assertEquals(ptTest1.Enabled_for_Services__c,false);
        Partner_Track__c ptTest2=[select id,Enabled_for_Services__c from Partner_Track__c where id =: partnertrack.id];
        Partner_Track__c ptTest3=[select id,Enabled_for_Services__c from Partner_Track__c where id =: partnertrack.id];
        system.assertEquals(ptTest3.Enabled_for_Services__c,false);
        Test.stopTest();      
    }
}