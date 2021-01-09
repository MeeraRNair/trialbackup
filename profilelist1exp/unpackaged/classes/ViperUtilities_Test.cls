//2.0      sharad  5-jun,2018  CR15899  Viper: Contract Status is blank on the POP page - INC5974188
@isTest
private class ViperUtilities_Test {
   // Methods for testing
   static testMethod void verifyfetchContractStatusFromAPVToPOPV(){
        
        Vendor__c parentVendor=new Vendor__c();
        parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; 
        parentVendor.Partner_Status__c ='Active';
        parentVendor.recordTypeId = Schema.SObjectType.vendor__c.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        insert parentVendor;
         
        List<Vendor__c> vendorList=new List<Vendor__c>(); 
        for(Integer i = 0; i<3; i++){
            vendorList.add(
                new Vendor__c(
                        Parent_Vendor__c=parentVendor.Id,
                        Name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+i, // Fenny added on 21-Feb-2013
                        Partner_Status__c='Active',
                        Partner_Type__c='Value',
                        Product_Category__c='Networking',
                        Contract_Types_eligible_for__c='Volume Based,Ala Carte',
                        recordTypeId=Schema.SObjectType.vendor__c.getRecordTypeInfosByName().get('Sub Vendor').getRecordTypeId()
                )
            );
        }
        insert vendorList; 
        
        
        Profile profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1];
        List<User> users = new List<User>();
        for(Integer i = 0; i<3; i++){           
            users.add(
                new User(
                    Username='testuser'+i+ System.currentTimeMillis()+'@dell.com',
                    Alias = 'test'+i, 
                    Email='testuser'+i+'@dell.com', 
                    FirstName='John', 
                    LastName='Doe'+i, 
                    ProfileId =profiles.Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='John.doe'+i,
                    isActive = true
                )
            );
        }
        insert users;
        
        Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
        marketingPlan.name='MP-001';
        marketingPlan.Vendor__c=vendorList[0].Id;
        marketingPlan.Fiscal_Quarter__c='FY12Q3';
        marketingPlan.Region__c='Americas';
        marketingPlan.Sub_Region__c='North America';
        marketingPlan.Contract_Type__c='Volume Based';
        marketingPlan.RecordTypeId=Schema.SObjectType.Marketing_Plan__c.getRecordTypeInfosByName().get('Volume Based Marketing Plan').getRecordTypeId();
        insert marketingPlan;
        
        Test.startTest();
        
        MDF_Program__c mdfProgram=new MDF_Program__c();
        mdfProgram.Name='testMDF Program';
        mdfProgram.POP_Owner__c=users[1].id;
        mdfProgram.Program_Owner__c=users[2].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q3';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        mdfProgram.Business_Segment__c='Commercial';
        mdfProgram.Region__c='Americas';
        mdfProgram.Sub_Region__c='North America';
        mdfProgram.Country__c='US';
        mdfProgram.POP_Approver__c = users[0].id;
        insert mdfProgram;
        
        List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
        for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgram.Id,
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=marketingPlan.Id,
                   recordTypeId=Schema.SObjectType.Associated_Programs_Vendors__c.getRecordTypeInfosByName().get('Vendor Association').getRecordTypeId(),
                   Rate_Card_Price__c=896542,
                   Budgeted_Price__c=56932,
                   Invoice_Amount__c=98980
               )
           );
       }
       
       insert apvList;      
        
        Proof_of_Performance_POP__c pop = new Proof_of_Performance_POP__c();
        pop.Name = 'Test POP 123';
        pop.MDF_Program__c = mdfProgram.Id;
        insert pop;
        
        POP_Line_Item__c popOli = new POP_Line_Item__c();
        popOli.Vendor__c = vendorList[0].Id;
        popOli.Proof_of_Performance_POP__c = pop.Id;
        insert popOli;
        
        Associated_Programs_Vendors__c  apvUpd = new Associated_Programs_Vendors__c();
        apvUpd.Id =apvList[0].Id;
        apvUpd.Status__c = 'Accepted';
        update apvUpd;
        Test.stopTest();      
   }
}