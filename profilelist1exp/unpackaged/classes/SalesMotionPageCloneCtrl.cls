/* 
Author: Micky Toms

History:
Version Date            Modified By     Description     
----------------------------------------------------------------------------------------------------
1.0     Nov-2012     Micky Toms   Created for R14.2 - VF controller for Sales Motion Page Clone page

*/
public class SalesMotionPageCloneCtrl {
    private apexpages.standardcontroller controller;
    public String currentId = ApexPages.currentPage().getParameters().get('id');
    public Sales_Motion_Page__c salesMotionsPages {get; set;}
    public List<Sales_Motion_Page_Section__c> salesMotionsPageSections {get; set;}
    List<SalesMotionPageSectionWrapper> SalesmotionPageSectionWrapperRecs=new List<SalesMotionPageSectionWrapper>();
    
    public SalesMotionPageCloneCtrl(ApexPages.StandardController controller){
        this.controller = controller;
        getSalesMotionPages();
        getSalesMotionSections();
    }
    
    private void getSalesMotionPages(){
        salesMotionsPages  = [SELECT  Name, Domain__c,IsActive__c,Sales_Motion_Name__c,Solution_Name__c,Solution_Type__c,RecordType.Name,RecordTypeId,Sort_Order__c,Stages_Enabled__c  FROM Sales_Motion_Page__c WHERE Id = :currentId limit 1]; 
        salesMotionsPages.IsActive__c=false;
        System.Debug('##salesMotionsPages'+salesMotionsPages);
    }
    /*public List<Sales_Motion_Page_Section__c> getSalesMotionSections(){
        return [SELECT Configure_Country__c, Country_List__c, Country__c, Id, Name, RecordTypeId, SalesEdge_Category__c, Sales_Motion_Page__c, Sales_Motion_Page__r.Name, SectionContentLong__c, Section_Content__c, Side_Bar__c, Sort_Order__c, Stage__c, Support_Request_Type__c, Type__c FROM Sales_Motion_Page_Section__c WHERE Sales_Motion_Page__c = :currentId ORDER BY Sales_Motion_Page__c ASC];
    }*/
    public void getSalesMotionSections(){
        salesMotionsPageSections  = [SELECT Configure_Country__c, Country_List__c,Region_List__c,Business_Unit_List__c,Language_List__c, Country__c, Id, Name, RecordTypeId,RecordType.Name, SalesEdge_Category__c, Sales_Motion_Page__c, Sales_Motion_Page__r.Name, SectionContentLong__c, Section_Content__c, Side_Bar__c, Sort_Order__c, Stage__c, Support_Request_Type__c, Type__c,IsActive__c FROM Sales_Motion_Page_Section__c WHERE Sales_Motion_Page__c = :currentId ORDER BY Sales_Motion_Page__c ASC]; 
        System.Debug('###salesMotionsPageSectionsQueryRes:' +salesMotionsPageSections);
        if(salesMotionsPageSections!=null){
            
            for(Sales_Motion_Page_Section__c lstsmps:salesMotionsPageSections ){
                System.Debug('##salesMotionsRegionList region'+lstsmps.Region_List__c);
                SalesmotionPageSectionWrapperRecs.add(new SalesMotionPageSectionWrapper(false,lstsmps.Name,lstsmps.SalesEdge_Category__c,lstsmps.Sort_Order__c,lstsmps.Type__c,lstsmps.RecordTypeId,lstsmps.Side_Bar__c,lstsmps.IsActive__c,lstsmps.Section_Content__c,lstsmps.Stage__c,lstsmps.Country_List__c,lstsmps.Region_List__c,lstsmps.Business_Unit_List__c,lstsmps.Language_List__c,lstsmps.Support_Request_Type__c));
            }
            System.Debug('##SalesmotionPageSectionWrapperRecs'+SalesmotionPageSectionWrapperRecs);
        }
        
        //return null;
    }
    public class SalesMotionPageSectionWrapper{
        public Boolean selected {get;set;}
        public string Name {get;set;}
        public string SalesEdgeCategory{get;set;}
        public Decimal SortOrder{get;set;}
        public string Type{get;set;}
        public Id RecordTypeId{get;set;}
        public Boolean Sidebar{get;set;}
        public Boolean IsActive{get;set;}
        public string SectionContent{get;set;}
        public string Stage{get;set;}
        public string Country{get;set;}
        public string Region{get;set;}
        public string BusinessUnit{get;set;}
        public string Language{get;set;}
        public string SupportReq{get;set;}
        public SalesMotionPageSectionWrapper(){
        } 
        public SalesMotionPageSectionWrapper(Boolean selvalue,String pgName,string seCategory,Decimal srtOrder,string typ,Id rectypeid,Boolean sdebar,Boolean isactve,string seccontent,string stg, string cntry,string reg,string busunit,string lang,string suppreq){
           selected=selvalue;
           Name=pgName;
           SalesEdgeCategory=seCategory;
           SortOrder=srtOrder;
           Type=typ;
           RecordTypeId=rectypeid;
           Sidebar=sdebar;
           IsActive=isactve;
           SectionContent=seccontent;
           Stage=stg;
           Country=cntry;
           Region=reg;
           BusinessUnit=busunit;
           Language=lang;
           SupportReq=suppreq;
        }
    }
    
    public PageReference Save(){
        System.Debug('SalesmotionPageSectionWrapperRecs'+SalesmotionPageSectionWrapperRecs);
        System.Debug('##salesMotionsPages'+salesMotionsPages);
        Sales_Motion_Page__c salesMotionsPagesToClone =new Sales_Motion_Page__c(); 
        List<Sales_Motion_Page__c> salesMotionsPagesToCloneSave=new List<Sales_Motion_Page__c>();
        List<Sales_Motion_Page_Section__c> lstsmpsToClone=new List<Sales_Motion_Page_Section__c>();
        string smpagecloneid;
        if(salesMotionsPages.Sales_Motion_Name__c==null || salesMotionsPages.Name==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that you select the SalesMotion Name and enter the Page Title!!'));
            return null;
        }
        


        salesMotionsPagesToClone.Name=salesMotionsPages.Name;
        salesMotionsPagesToClone.Sales_Motion_Name__c=salesMotionsPages.Sales_Motion_Name__c;
        salesMotionsPagesToClone.IsActive__c=salesMotionsPages.IsActive__c;
        salesMotionsPagesToClone.RecordTypeId=salesMotionsPages.RecordTypeId;
        salesMotionsPagesToClone.Sort_Order__c=salesMotionsPages.Sort_Order__c;
        salesMotionsPagesToClone.Stages_Enabled__c=salesMotionsPages.Stages_Enabled__c;
        salesMotionsPagesToCloneSave.add(salesMotionsPagesToClone);
        try{
            System.Debug('##salesMotionsPagesToCloneSave'+salesMotionsPagesToCloneSave);
            Insert salesMotionsPagesToCloneSave;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
        for(Sales_Motion_Page__c smPage:salesMotionsPagesToCloneSave){
            smpagecloneid=smPage.id;
        }
        System.Debug('##SalesmotionPageSectionWrapperRecs'+SalesmotionPageSectionWrapperRecs);
        for(SalesMotionPageSectionWrapper smpsWrapperRecs:SalesmotionPageSectionWrapperRecs){
            Sales_Motion_Page_Section__c smpsToClone=new Sales_Motion_Page_Section__c();
            if(smpsWrapperRecs.selected==true){
              smpsToClone.Sales_Motion_Page__c=smpagecloneid;
              smpsToClone.Name= smpsWrapperRecs.Name; 
              smpsToClone.RecordTypeId=smpsWrapperRecs.RecordTypeId;
              smpsToClone.Sort_Order__c= smpsWrapperRecs.SortOrder; 
              smpsToClone.Side_Bar__c=smpsWrapperRecs.Sidebar;
              smpsToClone.Type__c=smpsWrapperRecs.Type;
              smpsToClone.SalesEdge_Category__c=smpsWrapperRecs.SalesEdgeCategory;
              smpsToClone.IsActive__c=smpsWrapperRecs.IsActive;
              smpsToClone.Section_Content__c=smpsWrapperRecs.SectionContent;
              smpsToClone.Stage__c=smpsWrapperRecs.Stage;
              smpsToClone.Country_List__c=smpsWrapperRecs.Country;
              smpsToClone.Region_List__c=smpsWrapperRecs.Region;
              smpsToClone.Business_Unit_List__c=smpsWrapperRecs.BusinessUnit;
              smpsToClone.Language_List__c=smpsWrapperRecs.Language;
              smpsToClone.Support_Request_Type__c=smpsWrapperRecs.SupportReq;
              lstsmpsToClone.add(smpsToClone);
            }
            
        }
        try{
            System.Debug('##lstsmpsToClone'+lstsmpsToClone);
            Insert lstsmpsToClone;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
       ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'SalesMotion Page Cloned Successfully!'));
        PageReference previewPage = new PageReference('/'+smpagecloneid);
        previewPage.setRedirect(true);
        return previewPage;

    }
    
    public PageReference Cancel(){
        PageReference previewPage = new PageReference('/'+currentId );
        previewPage.setRedirect(true);
        return previewPage;
    }
    
    public List<SalesMotionPageSectionWrapper> getSalesmotionPageSectionWrapperRecs(){
        return SalesmotionPageSectionWrapperRecs;
    }
    public void setSalesmotionPageSectionWrapperRecs(list<SalesMotionPageSectionWrapper> SalesmotionPageSectionWrapperRecs){
        this.SalesmotionPageSectionWrapperRecs=SalesmotionPageSectionWrapperRecs;
    }
}