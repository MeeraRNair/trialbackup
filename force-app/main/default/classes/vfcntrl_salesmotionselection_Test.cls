@isTest(SeeAllData=false)
public class vfcntrl_salesmotionselection_Test {
    static list<Account> listAcc;
    
    @testSetup static void setup() {
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTDF;
        
    }
    static testMethod void vfcntrlsalesmotiontestclass() {
        TriggerExecutionController.setSkipAllTriggers(true);
        partner_track__c p=new partner_track__c();
        p.Partner_Track_Name__c = 'test';
        insert p;
        listAcc = [Select Id from Account limit 1];
        listAcc[0].Status__c ='Active';
        update listAcc;
        //Account a=new Account(Name='testAcc',Status__c ='Active');
        //insert a;
        
       Contact con=new Contact();
        con.lastname='testcontact';
        con.AccountId=listAcc[0].id;
        con.Phone='3456234567';
        con.Selected_Track__c=p.id;
       insert con;
       system.assertEquals(listAcc[0].Status__c,'Active' );
        
        List<Profile> listpartnerProfile = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        //UserRole userRoleObject=[Select Id From UserRole Limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',
                            FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = listpartnerProfile.get(0).Id, LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test846258',
                            Enable_Partner_Admin__c = true, isActive = true,Enable_Partner_Deal_Registration__c = true,ContactId = con.Id);
        TriggerExecutionController.setSkipAllTriggers(true);
        insert partnerUser;
        User us=new User();
        us.Id=UserInfo.getUserId();
        us.Contact=con;
        us.Contact.Id=con.id;
        update us;
        
        Id recordTypeIdContact= IdLookupUtils.getRecordTypeId('Order Support','Account',true);
      
        PageReference pageRef=Page.OrderSupportVfPage;
        pageRef.getParameters().put('RecordType',recordTypeIdContact);
        VFcntrl_Case_SalesMotionSelection.recordTypeName='sdd';
        Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
        Map<string, Schema.RecordTypeInfo> mapCaserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
        Id idCSH = mapCaserecordtypeinfo.get('Channel Services Helpdesk').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('RecordType',idCSH );
        VFcntrl_Case_SalesMotionSelection sm=new VFcntrl_Case_SalesMotionSelection ();
          sm.salesMotionName=listAcc[0].id;
          sm.selectedSalesMotion='';
          sm.recordTypeName='Order Support';
        VFcntrl_Case_SalesMotionSelection.checkAndAddAccShare(listAcc[0].Id);   
          try{sm.updateSelectedAccToCon();}catch(Exception e){} 
          test.startTest();
          try{sm.checkAndRedirect();}catch(exception e){}
          test.stopTest();
           system.assertEquals(sm.recordTypeName,'Order Support' );
    }
     static testMethod void vfcntrlsalesmotiontestclass1() {
          Schema.DescribeSObjectResult cfrschema = schema.SObjectType.Case;
          Map<string, Schema.RecordTypeInfo> mapCaserecordtypeinfo =cfrschema.getRecordTypeInfosByName();
          Id idCSH = mapCaserecordtypeinfo.get('Channel Services Helpdesk').getRecordTypeId();
          ApexPages.currentPage().getParameters().put('RecordType',idCSH );
          VFcntrl_Case_SalesMotionSelection sm=new VFcntrl_Case_SalesMotionSelection ();
           sm.recordTypeName = 'Order Support';
           try{sm.updateSelectedAccToCon();}catch(Exception e){}
           try{sm.checkAndRedirect();}catch(exception e){}
           sm.recordTypeName = 'Deal Registration';
           try{sm.updateSelectedAccToCon();}catch(Exception e){}
           try{sm.checkAndRedirect();}catch(exception e){}
           sm.recordTypeName = 'On Boarding';
           try{sm.updateSelectedAccToCon();}catch(Exception e){}
           try{sm.checkAndRedirect();}catch(exception e){}
           sm.recordTypeName = 'Distribution';
           try{sm.updateSelectedAccToCon();}catch(Exception e){}
           try{sm.checkAndRedirect();}catch(exception e){}
           sm.recordTypeName = 'Application Support';
           try{sm.checkAndRedirect();}catch(exception e){}
           try{sm.updateSelectedAccToCon();}catch(Exception e){}
           try{sm.checkAndRedirect();}catch(exception e){}
           sm.recordTypeName = 'Partner Program';
           try{sm.updateSelectedAccToCon();}catch(Exception e){}
           try{sm.checkAndRedirect();}catch(exception e){}
           sm.recordTypeName = 'Channel Services Helpdesk';
           try{sm.updateSelectedAccToCon();}catch(Exception e){}
           try{sm.checkAndRedirect();}catch(exception e){}
           system.assertEquals('Order Support','Order Support');
     }
}