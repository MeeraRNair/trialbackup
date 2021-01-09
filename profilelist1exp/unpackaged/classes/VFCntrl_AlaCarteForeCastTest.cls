public with sharing class VFCntrl_AlaCarteForeCastTest {

    public static Vendor__c parentVendor = new Vendor__c ();
    public static Vendor__c subvendor = new Vendor__c();
    public static RecordType vendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Vendor'];
    public static RecordType subvendorRT = [Select Id,Name from RecordType where sObjectType ='Vendor__c'and isActive=true and Name ='Sub Vendor'];
    public static Marketing_Plan__c mp = new Marketing_Plan__c();
    public static RecordType mpRT = [Select Id,Name from RecordType where sObjectType ='Marketing_Plan__c'and isActive=true and Name ='Ala Carte Marketing Plan'];
    public static List <MDF_Program__c> mdfpgmlist = new List <MDF_Program__c>{};
    public static List <Associated_Programs_Vendors__c> mpapvList = new List <Associated_Programs_Vendors__c>();
    public static Profile p1 = [SELECT Id,Name FROM profile WHERE Name like'%MDF Program Owners%' limit 1];
    public static RecordType alcRT = [Select Id,Name from RecordType where sObjectType ='Volume_Based_Forecast__c'and isActive=true and Name ='Ala Carte'];
    public static Volume_Based_Forecast__c vbcexisting = new Volume_Based_Forecast__c();
    public static User u1 = new User();
    public static MDF_Program__c wishlistpgm = new MDF_Program__c();
    public static List <VFCntrlr_AddWishListPage.ProgramWrapper> wrapperlist = new List <VFCntrlr_AddWishListPage.ProgramWrapper>();
    public static void createdata(){
        u1 = new User(alias = 'newUser', email='user1@dellteam.com',emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id,Badge_Number__c='badge1',timezonesidkey='America/Los_Angeles', username='user1@dellteam.com');
        insert u1;
        
       //parentVendor.name='TestVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       parentVendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'A'; // Fenny added on 21-Feb-2013
        parentVendor.Partner_Status__c='Active';
        parentVendor.recordTypeId=vendorRT.Id;
        
        insert parentVendor;
        
        // creating a sub vendor
        subvendor.Parent_Vendor__c=parentVendor.Id;
       //subvendor.Name='TestSubVendor'; // Fenny commented on 21-Feb-2013 during 14.2 prod build week due to failure: DUPLICATE_VALUE, duplicate value found: Vendor_Unique_Field__c duplicates value
       subvendor.name = string.valueOf(Time.newInstance(0,DateTime.Now().minute(),DateTime.Now().second(),0))+'B'; // Fenny added on 21-Feb-2013
        subvendor.Partner_Status__c='Active';
        subvendor.Partner_Type__c='Value';
        subvendor.Product_Category__c='Networking';
        subvendor.Contract_Types_eligible_for__c='Volume Based,Ala Carte';
        subvendor.recordTypeId= subvendorRT.Id;
        
        insert subvendor;
        
        mp.name='MP-001';
        mp.Vendor__c=subvendor.Id;
        mp.Fiscal_Quarter__c='FY12Q4';
        mp.Region__c='EMEA';
        mp.Contract_Type__c='Ala Carte';
        mp.RecordTypeId=mpRT.Id;      
        insert mp; 
        
        for(Integer i=0;i<12;i++){
            MDF_Program__c pgm = new MDF_Program__c();
            pgm.Name = 'Name'+i;
            mdfpgmlist.add(pgm);
            pgm.Program_Owner__c=u1.Id;
            pgm.POP_Owner__c=u1.Id;
        }
        insert mdfpgmlist;
        
        for(Integer i=0;i<12;i++){
            Associated_Programs_Vendors__c apv = new Associated_Programs_Vendors__c();
            apv.Marketing_Plan__c = mp.Id;
            apv.MDF_Program__c = mdfpgmlist[i].Id;      
            apv.Status__c = 'Accepted';     
            apv.Accounting_Treatment__c = 'COGS Offset';
            apv.Vendor__c = subvendor.Id; 
            apv.LE__c=i;
            apv.CSMR__c=i;
            apv.SMB__c=i;
            apv.PUB__c=i;
            mpapvList.add(apv);         
        
        }
        insert mpapvList;
        
        
        vbcexisting.Sub_Vendor__c = subvendor.Id;
        vbcexisting.Fiscal_Quarter__c = 'FY12Q3';
        vbcexisting.Region__c = 'EMEA';
        vbcexisting.AlaCarte_MDF_Forecast_CSMR__c=10;
        vbcexisting.AlaCarte_MDF_Forecast_PUB__c=10;
        vbcexisting.AlaCarte_MDF_Forecast_LE__c=10;
        vbcexisting.AlaCarte_MDF_Forecast_SMB_Channel__c=10;
        vbcexisting.AlaCarte_MDF_Forecast_SMB_Channel__c=10;
        vbcexisting.AlaCarte_MDF_Forecast_All_Segments__c=10;
        vbcexisting.Name = 'First';
        vbcexisting.RecordTypeId=alcRT.Id;
        insert vbcexisting;
        
        wishlistpgm.Name='wishlist';
        wishlistpgm.Region__c='EMEA';
        wishlistpgm.Fiscal_Quarter__c='FY12Q4';
        wishlistpgm.Sub_Region__c='EMEA';
        wishlistpgm.Country__c='Sweden';
        wishlistpgm.Business_Segment__c='LE';
        wishlistpgm.Program_Owner__c=u1.Id;
        wishlistpgm.POP_Owner__c=u1.id;
        insert wishlistpgm;     
    }
    
    static testMethod void myUnitTest() {
        createdata();
        Volume_Based_Forecast__c vbc = new Volume_Based_Forecast__c();
        vbc.Sub_Vendor__c = subvendor.Id;
        vbc.Fiscal_Quarter__c = 'FY12Q4';
        vbc.Region__c = 'APJ';
        vbc.AlaCarte_MDF_Forecast_CSMR__c=10;
        vbc.AlaCarte_MDF_Forecast_PUB__c=10;
        vbc.AlaCarte_MDF_Forecast_LE__c=10;
        vbc.AlaCarte_MDF_Forecast_SMB_Channel__c=10;
        vbc.AlaCarte_MDF_Forecast_SMB_Channel__c=10;
        vbc.AlaCarte_MDF_Forecast_All_Segments__c=10;
        vbc.Name = 'First';
        vbc.RecordTypeId=alcRT.Id;
        PageReference  pr=new PageReference('apex/AlaCarteForecastNewPage');
        Test.setCurrentPage(pr);
        VFCntrl_AlaCarteForeCast cntrlr = new VFCntrl_AlaCarteForeCast(new ApexPages.StandardController(vbc));
        cntrlr.saveFC();
        vbc.Region__c = 'EMEA';
        cntrlr.saveFC();
        cntrlr.regionSelection();
        vbc.Region__c='Americas';
        cntrlr.saveFC();
        cntrlr.regionSelection();
        Volume_Based_Forecast__c alcfcquery =[Select Id,Name,Region__c,Fiscal_Quarter__c,Sub_Vendor__c,RecordTypeId from Volume_Based_Forecast__c where Sub_Vendor__c =:subvendor.Id and Fiscal_Quarter__c = 'FY12Q4'and Region__c = 'EMEA'and RecordTypeId=:alcRT.Id];
        PageReference  pr1=new PageReference('apex/AlaCarteForecastViewPage?id='+alcfcquery.Id);
        Test.setCurrentPage(pr1);
        cntrlr.newWishlist();
        MDF_Program_Wish_List__c mywishlist = new MDF_Program_Wish_List__c();
        mywishlist.MDF_Forecast__c=alcfcquery.Id;
        mywishlist.MDF_Program__c=mdfpgmlist[1].Id;
        insert mywishlist;
        cntrlr.wislistId=mywishlist.Id;
        cntrlr.deleteWishlist();
        PageReference  pr2=new PageReference('apex/AlaCarteForecastNewPage?id='+alcfcquery.Id);
        Test.setCurrentPage(pr2);
        VFCntrl_AlaCarteForeCast cntrlr1 = new VFCntrl_AlaCarteForeCast(new ApexPages.StandardController(alcfcquery));
        cntrlr1.regionvalueselected='APJ';       
        cntrlr1.regionSelection();
        cntrlr1.regionvalueselected='Americas';     
        cntrlr1.regionSelection();
        cntrlr1.regionvalueselected='EMEA';     
        cntrlr1.regionSelection();
        cntrlr1.myAFC.Fiscal_Quarter__c='FY12Q3';
        cntrlr1.saveFC();
        
        PageReference  pr3=new PageReference('apex/AddWishListPage?FC='+alcfcquery.Id);
        Test.setCurrentPage(pr3);
        VFCntrlr_AddWishListPage cntrlr2 = new VFCntrlr_AddWishListPage(new ApexPages.StandardController(wishlistpgm));
        cntrlr2.myPGM.Region__c='EMEA';
        cntrlr2.myPGM.Fiscal_Quarter__c='FY12Q4';
        cntrlr2.myPGM.Sub_Region__c='EMEA';
        cntrlr2.myPGM.Country__c='Sweden';
        cntrlr2.myPGM.Business_Segment__c='LE';
        cntrlr2.findPrograms();
        /*VFCntrlr_AddWishListPage.ProgramWrapper wrapperobj = new VFCntrlr_AddWishListPage.ProgramWrapper(wishlistpgm);
        cntrlr2.availableprogramsList.add(wrapperobj);
        wrapperobj.selected=true;
        wrapperobj.apvMpElt = wishlistpgm;
        cntrlr2.saveWishList();*/
        
        
    }

}