@isTest
private class VFCntrlr_AddWishListPageTest {
    
    public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'%MDF Program Owners%' limit 1];
    public static User u1 = new User();
    public static List <MDF_Program__c> mdfpgmlist = new List <MDF_Program__c>{};
    public static MDF_Program__c wishlistpgm = new MDF_Program__c();
    public static Volume_Based_Forecast__c alcfc = new Volume_Based_Forecast__c();
    public static Map <String,RecordType> vendorRTmap = new Map <String,RecordType>();
    public static Map <String,RecordType> fcRTmap = new Map <String,RecordType>();
    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static MDF_Program_Wish_List__c wishlist = new MDF_Program_Wish_List__c();
    public static List<VFCntrlr_AddWishListPage.ProgramWrapper> wrapperlist= new List<VFCntrlr_AddWishListPage.ProgramWrapper> ();  
    public static void createdata(){
        
        for(RecordType rtElt:[Select Name,Id From RecordType where sObjectType='Vendor__c']){   
                     vendorRTmap.put(rtElt.Name,rtElt);            
        }
        
        for(RecordType rtElt:[Select Name,Id From RecordType where sObjectType='Volume_Based_Forecast__c']){   
                     fcRTmap.put(rtElt.Name,rtElt);            
        }
        
        u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRTmap.get('Vendor').Id;
        
        insert parentVendor;
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
       //subVendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= vendorRTmap.get('Sub Vendor').Id;
        
        insert subvendor;
        
         for(Integer i=0;i<12;i++){
            MDF_Program__c pgm = new MDF_Program__c();
            pgm.Name = 'Name'+i;
            mdfpgmlist.add(pgm); 
            pgm.Program_Owner__c=u1.Id;
            pgm.POP_Owner__c=u1.Id; 
            pgm.Region__c='Americas';
            pgm.Sub_Region__c='North America';
            pgm.Country__c='US';
            pgm.Business_Segment__c='LE';
            pgm.Fiscal_Quarter__c='FY12Q1';                  
        }
        insert mdfpgmlist;
       
        alcfc.Sub_Vendor__c = subvendor.Id;
        alcfc.Fiscal_Quarter__c = 'FY12Q4';
        alcfc.Region__c = 'APJ';
        alcfc.AlaCarte_MDF_Forecast_CSMR__c=1;
        alcfc.AlaCarte_MDF_Forecast_LE__c=2;
        alcfc.AlaCarte_MDF_Forecast_PUB__c=3;
        alcfc.AlaCarte_MDF_Forecast_SMB__c=4;
        alcfc.Name = 'First';
        alcfc.RecordTypeId=fcRTmap.get('Ala Carte').Id;
        insert alcfc;
        
        wishlistpgm.Name = 'Name';
        wishlistpgm.Program_Owner__c=u1.Id;
        wishlistpgm.POP_Owner__c=u1.Id; 
        wishlistpgm.Region__c='Americas';
        wishlistpgm.Sub_Region__c='North America';
        wishlistpgm.Country__c='US';
        wishlistpgm.Business_Segment__c='LE';
        wishlistpgm.Fiscal_Quarter__c='FY12Q2';
        insert wishlistpgm;
        
        wishlist.MDF_Forecast__c=alcfc.Id;
        wishlist.MDF_Program__c=wishlistpgm.Id;
        insert wishlist;   
              
        
    }

    static testMethod void myUnitTest() {
       createdata();
       VFCntrlr_AddWishListPage.ProgramWrapper wrapperELt;
       PageReference testpage = new PageReference('/apex/AddWishListPage?FC='+alcfc.Id);
       Test.setCurrentPage(testpage);
       VFCntrlr_AddWishListPage cntrlr = new VFCntrlr_AddWishListPage(new ApexPages.StandardController(mdfpgmlist[1]));
       cntrlr.myPGM.Region__c='Americas';
       cntrlr.myPGM.Sub_Region__c='North America';
       cntrlr.myPGM.Country__c='US';
       cntrlr.myPGM.Business_Segment__c='LE';
       cntrlr.myPGM.Fiscal_Quarter__c='FY12Q1';
       cntrlr.availableprograms=mdfpgmlist;
       cntrlr.findPrograms();
       for(MDF_Program__c pgm:mdfpgmlist){
            wrapperELt = new VFCntrlr_AddWishListPage.ProgramWrapper(pgm);
            wrapperELt.apvMpElt=pgm;
            wrapperELt.selected=true;
            wrapperlist.add(wrapperELt);
       }
       cntrlr.availableprogramsList=wrapperlist;
       cntrlr.saveWishList();
       
    }
}