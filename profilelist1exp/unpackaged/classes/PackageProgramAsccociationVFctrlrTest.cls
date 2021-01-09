@isTest
private class PackageProgramAsccociationVFctrlrTest{

    static  MDF_Program__c mdfProgram=new MDF_Program__c(); 
    static Vendor__c parentVendor=new Vendor__c();
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static Package__c packageObj=new Package__c(); 
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
    static List<MDF_Program__c> mdfList=new List<MDF_Program__c>();
    static List<ViperContractManagement.MPWrapper> testObj=new List<ViperContractManagement.MPWrapper>(); 
    static Profile profiles;
    static List<User> users = new List<User>();   
    
    public static void insertData(){       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();       
       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association MP' limit 1];
       
       profiles=[select id,name from Profile where name like 'MDF Program Owners%' limit 1];     
        
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }

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
                    Profile_Region__c= 'Americas'                    
               )
            );
       }
       insert users;     
         
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;       
       insert parentVendor;
       
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
       
       marketingPlan.name='MP-001';
       marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.RecordTypeId=marketingPlanRT.Id;
       insert marketingPlan; 
        
       packageObj.Marketing_Plan__c=marketingPlan.Id;
       packageObj.Status__c='Pending';
       packageObj.name='TestPkg';       
       insert packageObj;
        

        mdfProgram.Name='testMDF Program';
        mdfProgram.Program_Status__c='Pending';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q1';
        mdfProgram.Rate_Card_Price__c=12356;
        mdfProgram.Region__c='Americas';     
        mdfProgram.Program_Owner__c=users[0].id;
        mdfProgram.POP_Owner__c=users[1].id;           
        insert mdfProgram;
         
        
        for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgram.Id,       
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=marketingPlan.Id,
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                   //Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
                   //Modified Bahar, Ariff (20121811) - Budgeted Price must equal to (LE + CSMR + PUB + SMB). To Conform with VR_Distributed_Budgeted_Price_Match validation rule 
                   Budgeted_Price__c=25+25+25+25,
                   Invoice_Amount__c=98980,
                   LE__c=25,
                   PUB__c=25,
                   SMB__c=25,
                   CSMR__c=25
                   
               )
           );
       }
       /*
       for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   Package__c=packageObj.Id,
                   MDF_Program__c=mdfProgram.Id,   
                   Marketing_Plan__c=marketingPlan.Id,                 
                   Vendor__c=vendorList[i].Id,                   
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                   Budgeted_Price__c=mdfProgram.Rate_Card_Price__c,
                   Invoice_Amount__c=98980
                  
               )
           );
       }
       */
       insert apvList;
                  
    }
    
    public static testMethod void testUpdatefields(){
        List<PackageProgramAsccociationVFctrlr.MPWrapper> mpWrapperList=new List<PackageProgramAsccociationVFctrlr.MPWrapper>(); 
        PackageProgramAsccociationVFctrlr.MPWrapper wrapperElt;
        insertData(); 
        Set<Id> packageIdSet=new Set<Id>();
        Map<Id,Package__c> packageMap=new Map<Id,Package__c>(); 
        Test.startTest();
        for(Associated_Programs_Vendors__c apv:apvList){  
            wrapperElt=new PackageProgramAsccociationVFctrlr.MPWrapper(apv);
            wrapperElt.Selected=true;             
            mpWrapperList.add(wrapperElt);
        }      
       PageReference pageRef =new PageReference('/apex/PackageProgramAsccociation?id='+packageObj.Id);
       // PageReference pageRef2 = Page.PackageProgramAsccociation;
        Test.setCurrentPage(pageRef); 
        PackageProgramAsccociationVFctrlr controller = new PackageProgramAsccociationVFctrlr(new ApexPages.StandardController(packageObj));
        controller.getIsApvavailable();
        List<PackageProgramAsccociationVFctrlr.MPWrapper> wrapperLst=controller.getListofAvailableApvs();
        controller.setListofAvailableApvs(mpWrapperList);
        PageReference pageRefUpdate=controller.updatefields();  
        packageObj.Status__c='Accepted';
        update packageObj;     
        
        packageIdSet.add(packageObj.Id);
        packageMap.put(packageObj.Id,packageObj);
        updateAPVStatus.updatestatusfield(packageIdSet,packageMap);  
        Test.stopTest();
    }
    
        public static testMethod void testdeleteAPVFromPackage(){
        List<DeletePackageProgramAsccociationVFctrlr.APVWrapper> APVWrapperList=new List<DeletePackageProgramAsccociationVFctrlr.APVWrapper>(); 
        DeletePackageProgramAsccociationVFctrlr.APVWrapper wrapperElt;
        insertData(); 
        Test.startTest();
        Set<Id> packageIdSet=new Set<Id>();
        Map<Id,Package__c> packageMap=new Map<Id,Package__c>(); 
        
        packageIdSet.add(packageObj.Id);
        packageMap.put(packageObj.Id,packageObj);
        
        for(Associated_Programs_Vendors__c apv:apvList){  
            wrapperElt=new DeletePackageProgramAsccociationVFctrlr.APVWrapper(apv);
            wrapperElt.Selected=true;             
            APVWrapperList.add(wrapperElt);
        }      
       PageReference pageRef =new PageReference('/apex/DeletePackageProgramAsccociation?id='+packageObj.Id);
        Test.setCurrentPage(pageRef); 
        DeletePackageProgramAsccociationVFctrlr controller = new DeletePackageProgramAsccociationVFctrlr(new ApexPages.StandardController(packageObj));
        controller.getListofAvailableApvs();
        List<DeletePackageProgramAsccociationVFctrlr.APVWrapper> wrapperLst=controller.getListofAvailableApvs();
        controller.setListofAvailableApvs(APVWrapperList);
        PageReference pageRefUpdate=controller.deleteAPVFromPackage(); 
        Test.stopTest();        
    }
        
}