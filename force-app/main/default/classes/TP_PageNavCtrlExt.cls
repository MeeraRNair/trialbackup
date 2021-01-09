/*
 * Author   : Sri Harsha Chadalavada
 * Purpose  : Common Extension class to save Territory plan record and navigate to other pages.
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR15152    	FY18-0102   21-Nov-2017     Harsha          Created
 */


public class TP_PageNavCtrlExt {

    Territory_Plan__c tp_Obj;
    public integer currentPageNum {get; set;}
    public integer totalPages {get; set;}
    
    private string currentPageName;
    private integer pageNum;
    
    private static final integer firstPageNum = 1;
    private static final integer lastPageNum = TP_PageNavUtils.vfPageNames.size();
    
    private Id userId;
    
    public TP_PageNavCtrlExt(ApexPages.StandardController controller) {
        
        getpageDetails();
        
        string sUrlId = apexPages.currentPage().getParameters().get('id');
        boolean bQuickSave = ((sUrlId!=NULL) ? TRUE : FALSE);
        userId = userinfo.getuserID();
        
        if(!bQuickSave && (currentPageNum == firstPageNum)){
            tp_Obj = new Territory_Plan__c();
            user us = [select id, name, manager.name,badge_number__c, managerid from user where id =: userId];
            tp_Obj.Name = us.name+' Territory Plan'; 
            tp_Obj.Manager_Approver__c = us.managerid;
        }
        else {
            tp_Obj = (Territory_Plan__c)Controller.getRecord();
        }
    }
  

    private void getpageDetails(){
        string url = ApexPages.currentPage().geturl();
        currentPageName = url.substringBetween('/apex/', '?');  
        TP_PageNavUtils obj = new TP_PageNavUtils();
        if(currentPageName == null && url.contains(TP_PageNavUtils.vfPageNames[0])){
            pageNum = 0;
            currentPageName = TP_PageNavUtils.vfPageNames[0];
        }
        else{
            pageNum = TP_PageNavUtils.vfPageSeq.get(currentPageName);
        }
        
        currentPageNum = pageNum+1;
        totalPages = TP_PageNavUtils.vfPageSeq.size();
    }
    
    public pageReference goToNextPage(){
        pageReference pg;
        if(currentPageNum == lastPageNum){
            currentPageName = TP_PageNavUtils.vfPageNames[0];
             TP_PageNavUtils.save(tp_Obj, currentPageName, TRUE);
             pg = new ApexPages.StandardController(tp_Obj).view();
             pg.setRedirect(true);      
         }
        else{
            saveRecord();
            string nextpp = TP_PageNavUtils.vfPageNames[pageNum+1];
            pg = TP_PageNavUtils.gotoPage(nextpp, tp_Obj.id);
        }
        return  pg;        
    }
    
    public pageReference goToPrevPage(){
        saveRecord();
        string prevpp = TP_PageNavUtils.vfPageNames[pageNum-1];
        pageReference pg = TP_PageNavUtils.gotoPage(prevpp, tp_Obj.id);
        return pg;        
    }
    
     public pageReference saveRecord(){
         pageReference pg;
         integer tpExistingCount = [SELECT count() from Territory_Plan__c where createdbyid=:userId];
         if((currentPageNum == firstPageNum)&&(tpExistingCount<1)){
             TP_PageNavUtils.save(tp_obj, currentPageName, FALSE);
             pg = TP_PageNavUtils.gotoPage(currentPageName, tp_Obj.id);
         }
         else {
             TP_PageNavUtils.save(tp_Obj, currentPageName, TRUE);
         }
         return  pg; 
     }
    
    public pageReference doCancel(){
        Schema.DescribeSObjectResult r = Territory_plan__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        String BaseURL = ApexPages.currentPage().getHeaders().get('Host');
        string url = 'https://'+BaseURL+'/'+keyPrefix+'/o';
        return  new pageReference(url);      
    }

}