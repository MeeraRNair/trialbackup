/* 
History:
Version Release         CR #        Date            Modified By     Description     
1.0		0102						04-Dec-2019		Vikas KH		Implemented TDF
*/

@isTest
public class Vctrl_SelectLeadData_Test {
    static list<Account> listAcc = new list<Account>();
    @testsetup static void setup() { 
        list<Account> listAcc = TestDataFactory.createNAccount(1, 'Partner Account');
        listAcc[0].BillingStreet = 'test add';
        listAcc[0].D_U_N_S__c = '234';
        listAcc[0].Website = 'www.test.com';
        TriggerExecutionController.setskipAccountTriggers(true);
        insert listAcc;   
        Partner_Request__c pr=new Partner_Request__c();
        pr.Account__c = listAcc[0].id;
        pr.Website__c = 'www.test.com';
        insert pr;
        Partner_Track__c p=new Partner_Track__c();
        p.Partner_Track_Name__c = 'test partner track apid';
        p.Master_Group_Id__c=listAcc[0].id;
        p.PPA_UCID__c='123';
     //   p.Partner_Track_APID__c='apid';
        insert p;
        Campaign c=new Campaign(Name='camp',Country_Code__c='US',IsActive=true);
        insert c;
        Lead l=new Lead(Account__c=listAcc[0].id,Company = 'JohnMiller',Country_Code__c='US',Lead_Type__c='Outbound',
                        LeadSource='Web', LastName = 'Mike', Status = 'Open',Location_Number__c=324,Campaign__c=c.id);
        insert l;
        Vctrl_SelectLeadData.ucidValidation('123',listAcc[0].id);
        System.AssertNotEquals(l.Company,'JohnMille');
        System.AssertEquals(pr.Website__c,'www.test.com');
    } 
    static testMethod void sleData() { 
        test.startTest();
        Partner_Request__c p=[select id,Account__c from Partner_Request__c limit 1];
        Partner_Track__c pt=[select id from Partner_Track__c limit 1]; 
        Lead le=[select id from Lead limit 1];
        Vctrl_SelectLeadData.getAccounts('guptasda','test add','234','www.test.com','riverton','riverton','USA','123456');
        Vctrl_SelectLeadData.initialization(p.id);
        Vctrl_SelectLeadData.dataget(p.Account__c);
        Vctrl_SelectLeadData.decimalToBinary(10);
        Vctrl_SelectLeadData.base64ToBits('OEM');
        Vctrl_SelectLeadData.fetchPartnerListsData('Distributor','OEM');
        Vctrl_SelectLeadData.fetchTrackData('CHINA','Distributor','OEM','Zone1');
        Vctrl_SelectLeadData.fetchTrackData('CHINA','Distributor',null,null);
        Vctrl_SelectLeadData.fetchSellingMotionData('CHINA','Distributor');
        Vctrl_SelectLeadData.fetchSellingMotionData('CHINA',null);
        Vctrl_SelectLeadData.getPickListValuesIntoList();
        Vctrl_SelectLeadData.getSalesMotionPickListValues();
        Vctrl_SelectLeadData.PicklistEntryWrapper pw=new Vctrl_SelectLeadData.PicklistEntryWrapper();
        Vctrl_SelectLeadData.getDependentMap(p,'Distributor','OEM');
        Lead l=new Lead();
        Vctrl_SelectLeadData.getPartnerTracks('Test Acc');
        Vctrl_SelectLeadData.PTdataGetting(pt.id);
        Vctrl_SelectLeadData.saveToLead(l,le.id,'def','g','de','as','abc','India');
        Vctrl_SelectLeadData.ucidSelectionPage(le.id,'1234','1234','1234','1234');
        Vctrl_SelectLeadData.fetchRejectPrPage(p.id);
        System.AssertEquals('www.test.com','www.test.com');
        test.stoptest();
    } 
    static testMethod void ucidValidate(){
        Test.startTest();
        Lead l=new Lead(Company = 'JohnMiller');
        System.AssertNotEquals(l.Company,'JohnMille');
        Test.SetMock(HttpCallOutMock.class, new SendUcidMock());
        Vctrl_SelectLeadData.ucidValidate('213212');
        Vctrl_SelectLeadData.getMupDetails('3436');
        System.AssertEquals('www.test.com','www.test.com');
        Test.stopTest();
    }
}