@isTest
private class newPOPCreationProcessTest{
   // Methods for testing
   static testMethod void clickView(){
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
        
        Headcount__c HC = new Headcount__c();
        HC.Business_Segment__c = 'Consumer';
        HC.Country__c = 'India';
        HC.Detailed_Job_Description__c = 'Testing data';
        HC.Program_Name__c = 'TestPrgrm';
        HC.Rate_Card_Price__c = 100;
        HC.Employee_Cost_Center__c = '1234-5678-123456';
        HC.Region__c = 'APJ';
        HC.Sub_Region__c = 'APJ'; 
        HC.Manager_s_Name__c = users[0].Name; 
        HC.Employee_Name__c = 'Vikky'; 
        
        Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
        marketingPlan.name='MP-001';
        marketingPlan.Vendor__c=vendorList[0].Id;
        marketingPlan.Fiscal_Quarter__c='FY12Q3';
        marketingPlan.Region__c='Americas';
        marketingPlan.Sub_Region__c='North America';
        marketingPlan.Contract_Type__c='Volume Based';
        marketingPlan.RecordTypeId=Schema.SObjectType.Marketing_Plan__c.getRecordTypeInfosByName().get('Volume Based Marketing Plan').getRecordTypeId();
        insert marketingPlan;
        
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
        mdfProgram.HCID__c=HC.Id;
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
                   Invoice_Amount__c=98980,
                   POP_Status__c = 'Executed',
                   Headcount__c = mdfProgram.HCID__c,
                   Manager_Name__c = mdfProgram.HCID__r.Manager_s_Name__c,
                   Fiscal_Quarter_New__c = mdfProgram.Fiscal_Quarter__c
               )
           );
       }
       
       insert apvList;  
       
       newPOPCreationProcess newPOP = new newPOPCreationProcess();
       List<newPOPCreationProcess.WrapperContactWrapper> wrapList = new List<newPOPCreationProcess.WrapperContactWrapper>();
       for(Integer k=0;k<apvList.size();k++){      
               newPOPCreationProcess.WrapperContactWrapper objWrap = new newPOPCreationProcess.WrapperContactWrapper (apvList[k],false);
               wrapList.add(objWrap);               
       }
       newPOP.wrapperlist = wrapList;
       wrapList[1].bool = true;
       wrapList[2].bool = true;
       wrapList[1].con = apvList[0];
       wrapList[2].con = apvList[2];
       newPOP.display = true;
       newPOP.panelShow = true;
       newPOP.firstPanel = true;
       newPOP.secondPanel = true;
       newPOP.allorNone = true;
       newPOP.size = 10;
       newPOP.NumberOfPages = 10;              
       newPOP.initLoad();
       Map <id,Associated_Programs_Vendors__c> onjMap = new Map <id,Associated_Programs_Vendors__c>();
       onjMap.put(wrapList[1].con.Id,wrapList[1].con);
       onjMap.put(wrapList[2].con.Id,wrapList[2].con);
       newPOP.SelectedcontactMap = onjMap ;
       newPop.getSelectedContact();
       ApexPages.StandardSetController objSetCon = new ApexPages.StandardSetController(apvList);
       newPOP.setCon = objSetCon;
       newPOP.hasPrevious = true;
       newPOP.hasNext = true;
       newPOP.Setcon.getPageNumber();
       newPOP.setCon.getHasPrevious();
       newPOP.setCon.getHasNext();
       newPOP.noOfRecords = apvList.size();       
       newPOP.getContact();       
       Map<Id,List<Id>> objMap = new Map<Id,List<Id>>();
       List<Id> lid = new list<Id>();
       for(Associated_Programs_Vendors__c apv : apvList){
            lid.add(apv.vendor__c);
           objMap.put(apv.mdf_program__c,lid);
       }
       newPOP.mapMdfIds();
       newPOP.createPOPRecord();
       newPOP.View_Existing();       
   }
}