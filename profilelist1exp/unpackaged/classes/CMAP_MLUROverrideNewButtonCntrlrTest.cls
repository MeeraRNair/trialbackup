@isTest(seeAllData=true)
private class CMAP_MLUROverrideNewButtonCntrlrTest{
    
    static testMethod void CMAP_MLUROverrideNewButtonCntrlrPartner(){
        Mass_Upload_Lead_Request__c mlur;
        User PartnerUser;
        CMAP_MLUROverrideNewButtonCntrlr cmap;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(thisUser){  
            Profile PartnerProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%NA PRM Portal User (MOSS) - Non SSO' LIMIT 1];
            Account accountObj = new Account(name='Test');
            insert accountObj;
            Contact cont = new Contact(FirstName='TestContact1',
                                       LastName='TestContactlast1',
                                       accountId=accountObj.Id,
                                       Email='test@ust-global.com',
                                       fax='01987645',
                                       MobilePhone='0000019',
                                       Status__c = 'Marketing Suspect',
                                       Decision_Making_Role__c = 'Evaluator',
                                       Job_Function__c = 'IT',
                                       Job_Function_Role__c = 'Director IT',
                                       Phone='0000000');             
            insert cont;    
            
            //User 
            PartnerUser = new User(FirstName='Test Partner_mlur', 
                                        LastName='Test', 
                                        Title='Partner_mlur', 
                                        UserName='Partner_mlurUser@test.com',
                                        Email='Partner_mlurUser@dell.com', Alias='pamlur', 
                                        CommunityNickName='tepatem', ProfileId = PartnerProfile.Id,
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='Asia/Kuala_Lumpur',
                                        Badge_Number__c='tepatem',
                                        ContactId = cont.Id,
                                        isActive = true);
            
            insert PartnerUser;
        
            PartnerUser.isPortalEnabled = true;
            
            update PartnerUser;
        
          //Mass_Upload_Lead_Request__c 
          mlur = new Mass_Upload_Lead_Request__c();
            //CMAP_MLUROverrideNewButtonCntrlr 
            cmap = new CMAP_MLUROverrideNewButtonCntrlr(new ApexPages.StandardController(mlur));
        }
        
        System.runAs(PartnerUser){
            
            cmap.redirect();
        }
        
        
                
    }

}