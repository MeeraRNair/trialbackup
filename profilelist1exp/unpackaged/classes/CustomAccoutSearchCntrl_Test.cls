@istest(seeAlldata = true)

public class CustomAccoutSearchCntrl_Test{

    @istest static void testmethod1()
    {
      Deal_Program__c dealPgm = new Deal_Program__c();
        dealPgm.Deal_Program_Name__c ='test12234';
        dealPgm.Deal_Program_Description__c ='test1';
        dealPgm.Stackable__c = 'Yes';
        dealPgm.Start_Date__c = Date.Today() - 1;
        dealPgm.End_Date__c = Date.Today() + 1;
        dealPgm.Benefit_Type__c = 'test2';
        dealPgm.Business_Unit__c = 'test3';
        dealPgm.Program_Region__c = 'EMA';
        dealPgm.Partner_Account_Regions__c = 'EMA';
        dealPgm.End_User_Account_Regions__c = 'EMA';        
        insert dealPgm;
        
         Account testAccount = new Account(Name = 'Test EU Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true);
            insert testAccount;
    
        Custom_End_User_Accounts__c CEUA = new Custom_End_User_Accounts__c();
        //CEUA.Affinity_Id_Search__c = '98089889';
        CEUA.Deal_Program__c = dealPgm.id;
        CEUA.Account__c = testAccount.id;
        insert CEUA;
        ApexPages.StandardController sc = new ApexPages.StandardController(dealPgm);
        
        Apexpages.Currentpage().getparameters().put('id',dealPgm.id);
        Apexpages.Currentpage().getparameters().put('AccType','EndUserAcc');
        CustomAccoutSearchCntrl ctrl = new CustomAccoutSearchCntrl(sc);
        ctrl.accName  = 'Name';
        ctrl.searchstring = '';
        ctrl.search();
        ctrl.accName  = 'Name';
        ctrl.searchstring = 'Test';
        ctrl.search();
        ctrl.accName  = 'Affinity';
        ctrl.searchstring = 'Test';
        ctrl.search();
        Apexpages.Currentpage().getparameters().put('AccType','Partner');
        CustomAccoutSearchCntrl ctrl1 = new CustomAccoutSearchCntrl(sc);
        ctrl1.accName  = 'Name';
        ctrl1.searchstring = 'Test';
        ctrl1.search();
        ctrl1.accName  = 'Affinity';
        ctrl1.searchstring = 'Test';
        ctrl1.search();
        Apexpages.Currentpage().getparameters().put('AccType','Disti/Reseller');
        CustomAccoutSearchCntrl ctrl2 = new CustomAccoutSearchCntrl(sc);
        ctrl2.accName  = 'Name';
        ctrl2.searchstring = 'Test';
        ctrl2.search();
        ctrl2.accName  = 'Affinity';
        ctrl2.searchstring = 'Test';
        ctrl2.search();
        List<Account> lstacc = new List<Account>();
        
        
        
    }




}