/*
REVISION HISTORY
================
Version     Author        Date            Release#    	CR#     	Description
-------     ------        ----            --------    	---     	-----------
1.0                                                           		Initial draft
3.1		 Shue			 05-Oct-2018		FY19-1101	16597		Fix violation pmd tool post scan
*/

@isTest
private class SubVendorPopAssociation_Test{
    static Proof_of_Performance_POP__c popRec = new Proof_of_Performance_POP__c();	//3.1
    static POP_Line_Item__c popLIRec = new POP_Line_Item__c();	//3.1
    //static List<POP_Line_Item__c> POPLineRcd = new List<POP_Line_Item__c>(); 
    static Vendor__c parentVendor=new Vendor__c();    

    static Profile profiles;
    static MDF_Program__c mdfProgram=new MDF_Program__c();    
    static Associated_Programs_Vendors__c apvObj=new Associated_Programs_Vendors__c(); 
    static Marketing_Plan__c marketingPlan=new Marketing_Plan__c(); 
    static List<User> users = new List<User>();
    static List<Associated_Programs_Vendors__c> apvList= new List<Associated_Programs_Vendors__c>();
    static List<Vendor__c> vendorList=new List<Vendor__c>(); 
    static List<string> apvStrList = New List<string>();
            
    public static void createData(){
        Map<String,RecordType> vendorRT=new Map<String,RecordType>();
        RecordType mdfRecordRT = [Select Name, Id From RecordType where 
            sObjectType='MDF_Program__c' and name = 'Event' limit 1];
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }

       RecordType marketingPlanRT=[Select Name, Id From RecordType where 
       sObjectType='Marketing_Plan__c' and name='Volume Based Marketing Plan' limit 1];
       
       RecordType apvRT=[Select Name, Id From RecordType where 
       sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association' limit 1];
        
       profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1];
                            
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;
       
       insert parentVendor;

       for(Integer i = 0; i<6; i++){
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
       
        mdfProgram.Name='testMDF Program';
        mdfProgram.Program_Owner__c=users[0].id;
        mdfProgram.POP_Owner__c=users[1].id;
        mdfProgram.Program_Status__c='Approved';
        mdfProgram.Pricing_Type__c='Variable';
        mdfProgram.Fiscal_Quarter__c='FY12Q3';
        mdfProgram.OwnerId=users[0].id;
        mdfProgram.Rate_Card_Price__c=12356;
        
        insert mdfProgram;

       marketingPlan.name='MP-001';
       marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.Contract_Type__c='Volume Based';
       marketingPlan.RecordTypeId=marketingPlanRT.Id;
       insert marketingPlan;
               
        for(Integer i = 0; i<3; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Pending',
                   MDF_Program__c=mdfProgram.Id,
                   Vendor__c=vendorList[i].Id,
                   Marketing_Plan__c=marketingPlan.Id,
                   recordTypeId=apvRT.Id,
                   Rate_Card_Price__c=896542,
                   Budgeted_Price__c=56932,
                   Invoice_Amount__c=98980
               )
           );
       }
       
        for(Integer i = 3; i<6; i++){
           apvList.add(
               new Associated_Programs_Vendors__c(
                   Status__c='Declined',
                   MDF_Program__c=mdfProgram.Id,
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
       
       
       
        popRec.Name = 'TestPOP';
        popRec.MDF_Program__c = mdfProgram.Id;       
       
        insert popRec;

       
        for(Integer i = 0; i<3; i++){  
            popLIRec.Proof_of_Performance_POP__c = popRec.id;
            popLIRec.Vendor__c = vendorList[i].Id;
        }
        insert popLIRec;        

    }

    public static testMethod void testSubVendorPopAssociation(){
        List<SubVendorPopAssociation_VFctrlr.ASVWrapper> wrapperList=new List<SubVendorPopAssociation_VFctrlr.ASVWrapper>();   
        List<Associated_Programs_Vendors__c> asvList=new List<Associated_Programs_Vendors__c>();
        createData();   
        
        for(Associated_Programs_Vendors__c apv:apvList){
           apvStrList.add(apv.id);
        }

        PageReference pageRef = Page.SubvendorPopAssociationVFPage;
        Test.setCurrentPage(pageRef); 
        SubVendorPopAssociation_VFctrlr controller = new SubVendorPopAssociation_VFctrlr(new ApexPages.StandardController(popRec));
        
        controller.getListofAvailableVendors(); 
        controller.setListofAvailableVendors(wrapperList);
        controller.getIsSubVendorAvailable();
        controller.getIsAccessAvilable();
        PageReference pagerefnew= controller.addSubVendor();   
        SubVendorPopAssociation_VFctrlr.updatePOPLineItem(apvStrList);      
    }

}