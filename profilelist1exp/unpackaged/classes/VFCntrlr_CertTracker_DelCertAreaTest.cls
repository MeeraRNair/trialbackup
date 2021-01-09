@isTest
private class VFCntrlr_CertTracker_DelCertAreaTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Country__c> listCountryTdf=TestDataFactory.createNCountry(1);
        listCountryTdf[0].Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        listCountryTdf[0].Code__c = 'IN';
        insert listCountryTdf;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Account_Country_Code__c='IN';
        listAccTdf[0].Status__c = 'Active';
        insert listAccTdf;
        list<Certification_Tracker__c> listCertTracTdf=TestDataFactory.createNcertTracker(1);
        listCertTracTdf[0].Account_Name__c=listAccTdf[0].id;
        listCertTracTdf[0].CurrencyIsoCode = 'INR';
        listCertTracTdf[0].Certification_Completed__c = 'Server ; Security ; Networking';
        listCertTracTdf[0].Dell_Certification_Areas__c = 'Server ; TestMP';
        insert listCertTracTdf;
        List<Master_Program_Setup__c> listMasterProSetTdf=TestDataFactory.createNMasterProSetup(1);
        listMasterProSetTdf[0].Master_Program_Name__c = 'TestMP';
        insert listMasterProSetTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    public static testmethod void testDelCertArea(){
        /*  Country__c country3 = new Country__c();    
country3.Region__c = 'APJ';
country3.Code__c = 'IN';  
country3.name = 'India';  
country3.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
insert(country3);

//Create partner Account
Account acc = new Account(
Name = 'Test Account',
RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
Account_Country_Code__c='IN',
Status__c = 'Active');       
insert acc;

//tracker
Certification_Tracker__c tracker = new Certification_Tracker__c(
Account_Name__c = acc.Id,
CurrencyIsoCode = 'INR',                                        
Certification_Completed__c = 'Server ; Security ; Networking',
Dell_Certification_Areas__c = 'Server ; TestMP');            
insert tracker;

Master_Program_Setup__c mp = new Master_Program_Setup__c(Master_Program_Name__c = 'TestMP', Apply_Requirement_To__c ='Global',
Active__c=true, Certification_Name__c='Security ; Networking');

insert mp;*/
        Master_Program_Setup__c mp=[select id,Master_Program_Name__c,Apply_Requirement_To__c,Active__c,Certification_Name__c from Master_Program_Setup__c where Master_Program_Name__c = 'TestMP' Limit 1];
        Country__c country3=[select id,Region__c,Code__c,Inc_Vendor_Name__c from Country__c where Region__c = 'APJ' Limit 1];
        Account acc=[select id,Status__c,Account_Country_Code__c from Account where Account_Country_Code__c='IN' Limit 1];
        Certification_Tracker__c tracker=[select id,Certification_Completed__c,Dell_Certification_Areas__c,CurrencyIsoCode,Account_Name__c from Certification_Tracker__c where CurrencyIsoCode = 'INR' Limit 1];
        PageReference pageRef = Page.CertTracker_DelCertArea;
        Test.setCurrentPageReference(pageRef);
        system.assertNotEquals(country3.id, null);
        VFCntrlr_CertTracker_DelCertArea trackerDelCertArea = new VFCntrlr_CertTracker_DelCertArea();
        trackerDelCertArea.go();
        trackerDelCertArea.getItems();
        trackerDelCertArea.Region = 'APJ';
        trackerDelCertArea.mpText = '';
        trackerDelCertArea.go();
        trackerDelCertArea.getAvailableList();
        trackerDelCertArea.selAvailableList.add('Server');
        trackerDelCertArea.selAvailableList.add('Storage');
        trackerDelCertArea.availableToSelected();
        trackerDelCertArea.getSelectedList();
        trackerDelCertArea.go();
        trackerDelCertArea.getAccounts();
        trackerDelCertArea.delValues();
        trackerDelCertArea.tableRows.get(0).isSelected = true;
        trackerDelCertArea.delValues();
        trackerDelCertArea.back();
        trackerDelCertArea.mpText = 'TestMP';
        trackerDelCertArea.go();
        trackerDelCertArea.tableRows.get(0).isSelected = true;
        trackerDelCertArea.delValues();
        trackerDelCertArea.selSelectList.add('Server');    
        trackerDelCertArea.unSelectToAvailable();
        trackerDelCertArea.getshowBlkCond();
        trackerDelCertArea.cancel();
        trackerDelCertArea.next();
        trackerDelCertArea.previous();
        trackerDelCertArea.getHasPreviousAndNext();
        trackerDelCertArea.Region = 'US';
        trackerDelCertArea.go();
        trackerDelCertArea.Region = 'Canada';
        trackerDelCertArea.go();
    }
}