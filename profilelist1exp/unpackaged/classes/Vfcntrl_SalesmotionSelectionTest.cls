/*
*  Revision                      Name             Date              Description
*                               venugopalachary   15-10-2019        implimented TestDataFactory
*/
@isTest
public class Vfcntrl_SalesmotionSelectionTest {
    static list<Account> listAcc;
    @testSetup static void setup() {
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
    }
    public static testmethod void fetchSalesMotionAcc1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[select id from Account];
        for(Account acc : listAcc){
            acc.Partner_Type__c = 'COMMERCIAL';
            acc.Partner_Tier__c = 'Tier';
            acc.Partner_Relationship__c = 'Registered';
            acc.Account_Country__c = 'United States';
            acc.Sales_Motion_Deal_Registration__c=true;
        }
        listAcc[0].Status__c ='Active';
        listAcc[0].DMU__c=false;
        listAcc[0].partner_track__c=null;
        listAcc[0].Master_Group_Id__c=null;
        listAcc[1].Account_Type_Integration__c ='Account';
        update listAcc;
        User loggedInUser = [select Id,Contact.AccountId,Contact.Selected_Track__c from user where id = : UserInfo.getUserId()];
        System.assertEquals(listAcc[1].Partner_Type__c,'COMMERCIAL');
        try{Vfcntrl_SalesmotionSelection.checkAndAddAccShare(null);
           } 
        catch(exception ex){System.debug('exception e');}
        Vfcntrl_SalesmotionSelection k1=new Vfcntrl_SalesmotionSelection(null);
        try{k1.updateSelectedAccToCon();
           }catch(exception e){
           }
        try{  
            k1.checkAndRedirect(); 
        }catch(exception e){} 
        TriggerExecutionController.setSkipAllTriggers(false);
        System.assertNotEquals(listAcc[1].Partner_Type__c,'COMMERCE');
    }
    public static testmethod void fetchSalesMotionAcc(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Track__c pr=new Partner_Track__c( );
        insert pr;
        listAcc=[select id from Account];
        listAcc[1].Partner_Type__c = 'COMMERCIAL';
        listAcc[1].Partner_Tier__c = 'Tier';
        listAcc[1].Partner_Relationship__c = 'Registered';
        listAcc[1].Account_Country__c = 'United States';
        listAcc[1].Account_Type_Integration__c ='Account';
        listAcc[1].Account_id__c=listAcc[0].id;
        listAcc[1].Status__c ='A';
        listAcc[1].DMU__c=true;
        listAcc[1].partner_track__c = pr.id;
        listAcc[1].Master_Group_Id__c=listAcc[0].id;
        listAcc[1].Sales_Motion_Deal_Registration__c=true;
        update listAcc;
        System.assertNotEquals(null,listAcc[1]);
        Contact newCont = new Contact(FirstName = 'MyTestContact7653',
                                      LastName = 'MyTestContact76523',
                                      AccountId =listAcc[0].Id,
                                      Status__c  =  'Marketing Suspect',
                                      Email = 'MyTestContactEmail_3@dell.com',
                                      Fax = '12344567',Selected_Track__c= pr.id,
                                      Last_Operation_Performed__c = 'testing');
        insert newCont;
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];
        ApexPages.currentPage().getParameters().put('RecordType',TestDataFactory.getRecordTypeIdbyName('Deal Registration', 'Opportunity'));
        ApexPages.currentPage().getParameters().put('SalesmotionId',listAcc[0].id);
        User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                      Alias = 'MTU9', 
                                      Email='MyTestUser9@dell.com', 
                                      FirstName='MyTestUser9', 
                                      LastName='MyTestUser9',  
                                      ProfileId = p.Id, 
                                      LanguageLocaleKey='zh_CN', 
                                      LocaleSidKey='zh_CN', 
                                      EmailEncodingKey='UTF-8', 
                                      TimeZoneSidKey='America/Los_Angeles',
                                      Badge_Number__c='Test99826513', 
                                      isActive = TRUE,
                                      Enable_Partner_Admin__c = false,
                                      ContactId = newCont.Id);
        insert partnerUserGC;
        Vfcntrl_SalesmotionSelection k=new Vfcntrl_SalesmotionSelection(null);
        try{k.checkAndRedirect();
           }catch (exception ex){System.debug('===========ex====');}
        Test.startTest(); 
        System.runAs (partnerUserGC) {
            Vfcntrl_SalesmotionSelection k1=new Vfcntrl_SalesmotionSelection(null);
            try{k1.updateSelectedAccToCon();
               }catch(exception e){}
            try{k1.checkAndRedirect(); 
               }catch(exception e){}
            Test.stopTest();
            TriggerExecutionController.setSkipAllTriggers(false); 
        }
    }
}