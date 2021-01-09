@isTest
private class POPDetailLandingControllerTest {

    static testMethod void controllerTest() {
        Pagereference pgRef = Page.POPDetailLanding;
        List<User> users = new List<User>();
        List<Profile> profiles=[select id,name from Profile where name like 'MDF %' limit 5 ];
          for(Integer i = 0; i<5; i++){           
            users.add(
                new User(
                    Username='testuser'+i+ System.currentTimeMillis()+'@dell.com',
                    Alias = 'test'+i, 
                    Email='testuser'+i+'@dellteam.com', 
                    FirstName='John', 
                    LastName='Doe'+i, 
                    ProfileId= profiles[i].Id,
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='John.doe'+i
               )             
            );              
        }
        insert users;
        
        Test.setCurrentPage(pgRef); 
        
        MDF_Program__c program = new MDF_Program__c();
       
        System.runAs(users[0]){
            program.Vendor_Materials_Needed__c = 'Test';
            program.Rate_Card_Price__c = 120000;
            program.Program_Owner__c = users[0].id;
            program.POP_Owner__c=users[1].id;
            program.OwnerId=users[0].id;
            program.Program_Objective__c = 'Test';
            program.Program_Detail__c = 'Test';
            program.Pricing_Type__c = 'Non-Variable';
            program.Fiscal_Quarter__c = 'FY12Q1';
            program.Country__c = 'US';
            program.Business_Segment__c = 'PUB';
            program.Audience_Size__c = '25';
            program.Audience_Description__c = 'Test';
            insert program;
        }
        
        
        for(Integer i = 0; i<5; i++){
            System.runAs(users[i]){
                Apexpages.currentPage().getParameters().put('Id',program.Id);
                POPDetailLandingController ctrl = new POPDetailLandingController();
                Pagereference redirectpage=ctrl.Redirect();
            }
        }
    
        //String URL = ctrl.Redirect().getUrl();
        //Schema.DescribeSObjectResult r = Proof_of_Performance_POP__c.sObjectType.getDescribe();
        //String objId = r.keyPrefix;
        //system.assert(URL.contains('/'+objId));
    }
}