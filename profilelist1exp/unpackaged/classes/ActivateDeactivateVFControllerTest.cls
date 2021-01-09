@isTest
private Class ActivateDeactivateVFControllerTest{
    static Vendor__c parentVendor=new Vendor__c();
    static List<Vendor__c> vendorList=new List<Vendor__c>();
    static Vendor__c subVendor=new Vendor__c(); 
    static Vendor__c parentVendorIA=new Vendor__c(); 
    
    public static void createData(){
       
       Map<String,RecordType> vendorRT=new Map<String,RecordType>();       
       for(RecordType rtElt:[Select Name, Id From RecordType where sObjectType='vendor__c']){
           vendorRT.put(rtElt.Name,rtElt);    
       }
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
       parentVendor.Partner_Status__c='Active';
       parentVendor.recordTypeId=vendorRT.get('Vendor').Id;
       
       insert parentVendor;
       
       for(Integer i = 0; i<3; i++){
           vendorList.add(
               new Vendor__c(
                   Parent_Vendor__c=parentVendor.Id,
			       //Name='TestSubVendor Record'+i, // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
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
       
       subVendor.Parent_Vendor__c=parentVendor.Id;
       //subVendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
       subVendor.Partner_Status__c='Inactive';
       subVendor.Partner_Type__c='Value';
       subVendor.Product_Category__c='Networking';
       subVendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
       subVendor.recordTypeId=vendorRT.get('Sub Vendor').Id;
       
       insert subVendor;
       
       //parentVendorIA.name='TestVendor Rec'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendorIA.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'C'; // Fenny added on 21-Feb-2013
       parentVendorIA.Partner_Status__c='Inactive';
       parentVendorIA.recordTypeId=vendorRT.get('Vendor').Id;
       
       insert parentVendorIA;
       
       
   }
   
   public static testMethod void testDeactivateVendor(){
       createData();
       
       PageReference  pr=new PageReference('/apex/DeactivateVendorPage?id='+parentVendor.id);
       Test.setCurrentPage(pr);
       ActivateDeactivateVFController controller = new  ActivateDeactivateVFController(new ApexPages.StandardController(parentVendor));
       PageReference  pageRef=controller.DeactivateVendor();
       boolean bol=controller.getdisplayerr();
       string pVendor=controller.getparentvendor();
                     
       PageReference  pr2=new PageReference('/apex/DeactivateVendorPage?id='+vendorList[1].id);
       Test.setCurrentPage(pr2);
       ActivateDeactivateVFController controller2 = new  ActivateDeactivateVFController(new ApexPages.StandardController(vendorList[1]));
       PageReference  pageRef2=controller2.DeactivateVendor();
   }
   
   public static testMethod void testActivateVendor(){
       createData();
       PageReference pr=new PageReference('/apex/ActivateVendorPage?id='+subVendor.id);
       Test.setCurrentPage(pr);
       ActivateDeactivateVFController controller = new  ActivateDeactivateVFController(new ApexPages.StandardController(subVendor));
       PageReference  pageRef=controller.ActivateVendor();
       
       PageReference pr2=new PageReference('/apex/ActivateVendorPage?id='+parentVendorIA.id);
       Test.setCurrentPage(pr2);
       ActivateDeactivateVFController controller2 = new  ActivateDeactivateVFController(new ApexPages.StandardController(parentVendorIA));
       PageReference  pageRef2=controller2.ActivateVendor();
       
   }
   
   
}