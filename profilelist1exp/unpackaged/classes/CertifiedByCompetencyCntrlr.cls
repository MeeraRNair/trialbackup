/*-------------------------------------------------------------------------
Description: Class for check and redirect to edit page for object Certified By Competency on manually added/automate
CR #9035
Version:1.0 

History:
    
Rev    Date          Author          Remarks 
1.0    30/01/2014    Jaya Kumar      CR9035: Check and redirect to edit page if manually added.
                                             If added via automate process show 'no permission' error message  
--------------------------------------------------------------------------*/
public class CertifiedByCompetencyCntrlr {
    public Certified_by_Certification__c CBCBObj;
    public Account AccObj;   
    public Boolean manualStatus;
    public String pageURL;   
    public CertifiedByCompetencyCntrlr (ApexPages.StandardController controller) {  
        manualStatus = false;
        this.CBCBObj = (Certified_by_Certification__c)controller.getRecord();
               
        if(CBCBObj.Id!= null){            
            CBCBObj=[SELECT Manually_Added_Competency__c,Account__c FROM Certified_by_Certification__c WHERE id=:CBCBObj.Id];         
        }
                
        if(CBCBObj!=null){
            AccObj=[SELECT name FROM Account WHERE id=:CBCBObj.Account__c];
        }                
        pageURL = '/'+CBCBObj.Id+'/e?nooverride=1&saveURL='+CBCBObj.Id+'&retURL='+CBCBObj.Account__c+'&CF00NA00000063fFr_lkid='+CBCBObj.Account__c+'&CF00NA00000063fFr='+AccObj.name;  
    }
    
    
    public PageReference redirect(){  
        if(CBCBObj.Manually_Added_Competency__c == false){
            return null;  
        }
        
        return(PageUtils.redirect(pageURL));
    } 
}