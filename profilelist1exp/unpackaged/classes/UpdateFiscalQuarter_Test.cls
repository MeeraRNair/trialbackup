@isTest
private class UpdateFiscalQuarter_Test
{
    static testMethod void Test_TestAPV()
    { 
          Map<String,RecordType> vendorRT=new Map<String,RecordType>();
       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association' limit 1];
       
       Profile profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1];
       
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
       //parentVendor.name='TestVendor';
       Vendor__c parentVendor= new Vendor__c();
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A';
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;
       
       insert parentVendor;
       List<Vendor__c> vendorList=new List<Vendor__c>(); 
       for(Integer i = 0; i<3; i++){
           vendorList.add(
               new Vendor__c(
                   Parent_Vendor__c=parentVendor.Id,
                   //Name='TestSubVendor'+i, // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
                   Name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+i, // Fenny added on 21-Feb-2013
                   Partner_Status__c='Active',
                   Partner_Type__c='Value',
                   Product_Category__c='Networking',
                   Contract_Types_eligible_for__c='Volume Based,Ala Carte',
                   recordTypeId=vendorRT.get('Sub Vendor').Id
               )
           );
       }
       
       insert vendorList; 
       
       Invoice__c invoiceObj=new Invoice__c(); 
       invoiceObj.name='Inv-001';
       invoiceObj.Vendor__c=vendorList[0].Id;
       invoiceObj.Fiscal_Quarter__c='FY12Q1';
       invoiceObj.Region__c='Americas';
       invoiceObj.Contract_Type__c='Volume Based, Ala Carte, Headcount'; 
       
       insert invoiceObj;     
       
       Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
       marketingPlan.name='MP-001';
       marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.Contract_Type__c='Volume Based';
       marketingPlan.RecordTypeId=marketingPlanRT.Id;
       marketingPlan.invoice__c=invoiceObj.Id;
       insert marketingPlan; 
       
       Package__c packageObj=new Package__c(); 
       packageObj.Marketing_Plan__c=marketingPlan.Id;
       packageObj.Status__c='Pending';
       packageObj.name='TestPkg';
       
       insert packageObj;
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
                    Badge_Number__c='John.doe'+i
               )
            );
        }
        insert users;
        MDF_Program__c mdfProgram=new MDF_Program__c(); 
        mdfProgram.Name='testMDF Program';
        mdfProgram.Program_Owner__c=users[2].id;
        mdfProgram.POP_Owner__c=users[2].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q3';
        mdfProgram.OwnerId=users[2].id;
        mdfProgram.Rate_Card_Price__c=12356;
        
        insert mdfProgram;
        
        MDF_Program__c mdfProgram2=new MDF_Program__c();
        mdfProgram2.Name='testMDF Program';
        mdfProgram2.Program_Owner__c=users[2].id;
        mdfProgram2.POP_Owner__c=users[1].id;
        mdfProgram2.Program_Status__c='Pending';
        mdfProgram2.Pricing_Type__c='Variable';
        mdfProgram2.Fiscal_Quarter__c='FY12Q3';
        mdfProgram2.OwnerId=users[2].id;
        mdfProgram2.Rate_Card_Price__c=12356;
        mdfProgram2.Business_Segment__c='LE';
        mdfProgram2.OwnerId=UserInfo.getUserId();
        insert mdfProgram2;
        
        List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
        for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgram.Id,
                   Package__c=packageObj.Id,
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=marketingPlan.Id,
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=896542,
                   Budgeted_Price__c=56932,
                   Invoice_Amount__c=98980
                   
               )
           );
       }
       
       insert apvList;
        
    }
    
    
}