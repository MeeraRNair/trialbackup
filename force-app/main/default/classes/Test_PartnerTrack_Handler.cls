/*
 * Author   : Prasanthi M
 * Purpose  : Test class for PartnerTrack_Handler
 * Date     : 19-12-2018
 *  
 */
@isTest
Public class Test_PartnerTrack_Handler {
    Public static Partner_Track__c createPT(){
        //Track Rec Insertion
        Country__c country = new Country__c();
        country.Name = 'UNITED STATES';
        country.Code__c = 'US';
        insert country;
        Track__c t = new Track__c();
        t.Track_AffinityId__c = '432';
        t.Country_Code__c = 'US';
        t.Partner_Program_Track__c = 'Solution Provider';
        insert t;
        Partner_Request__c request = new Partner_Request__c();
         request.email__c = 'test@dell.com';
         request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Agree_Dell_Reseller__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
         insert request;
        system.debug('Track Id'+request); 
        //Partner Track Rec
        //List<Country__c> listCountry =  [select Id from Country__c where Name = 'UNITED STATES' limit 1];
        Partner_Program_Track__c secpt = new Partner_Program_Track__c();
        secpt.name = 'Solution Provider';
        secpt.Country__c = country.Id;
        secpt.Audit_Track_Y_N__c = true;
        secpt.Primary_Partner_Track__c = 'Solution Provider';
        insert secpt;
        Partner_Track__c pt = new Partner_Track__c();
        pt.Track_Affinity_Id__c = '432';
        pt.Partner_Registration_Number__c=[select name from Partner_Request__c where id=:request.id].name;
        pt.Master_Group_Affinity_Id__c = '123467';
        pt.Partner_track__c = 'Distributor';
        pt.Status__c = true;
        return pt;
        
    }
    Private static testMethod void testPRInserion(){
        Partner_Track__c pt = createPT();
        insert pt;
        system.assertEquals(pt.Track_Affinity_Id__c ,'432');
    }
    Private static testMethod void testPRUpdation(){
        Country__c country = new Country__c();
        country.Name = 'UNITED STATES';
        country.Code__c = 'USA';
        insert country;
        Track__c t = new Track__c();
        t.Track_AffinityId__c = '321';
         t.Country_Code__c = 'US';
        t.Partner_Program_Track__c = 'Solution Provider';
        t.Name = 'US - Solution Provider';
        insert t;
        Account a=new Account(Name='Test Acc',Account_ID__c ='123467');
        insert a;
        //List<Country__c> listCountry =  [select Id from Country__c where Name = 'UNITED STATES' limit 1];
        Partner_Program_Track__c secpt = new Partner_Program_Track__c();
         secpt.name = 'Solution Provider';
        secpt.Country__c = country.Id;
        secpt.Audit_Track_Y_N__c = true;
        secpt.Primary_Partner_Track__c = 'Solution Provider';
        insert secpt;
        system.debug('Track Id'+t.id); 
        Partner_Track__c pt = createPT();
        insert pt;
        pt.Track_Affinity_Id__c = '321';
        pt.Primary_Sales_Motion_Affinity_ID__c = '123467';
        pt.Master_Group_Affinity_Id__c = '123467';
        pt.Partner_track__c = 'OEM';
        update pt;
        Batch_TRTUpdateonPT obj = new Batch_TRTUpdateonPT();
     DataBase.executeBatch(obj); 
        system.assertEquals(pt.Track_Affinity_Id__c ,t.Track_AffinityId__c );
    }
    Private static testMethod void testPRafterUpdation(){
        Partner_Track__c pt = createPT();
        insert pt;
        Account a=new Account(Name='Test Acc',Partner_Track__c=pt.Id);
        insert a;
        pt.Purchase_Path__c= '321';
        pt.Partner_Program_Tier__c= '321';
        pt.Authorized_Countries__c= 'India';
        update pt;
        system.assertEquals(pt.Purchase_Path__c,'321' );
    }
}