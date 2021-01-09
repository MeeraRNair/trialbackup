/*
 * Author : Impana
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 191149    R16.10     14-Sep-2015     Impana          Added logic to display inconming deal details 
                                                                    Account 
 * 2.0      CR 191150    R16.10     15-Sep-2015     Devika          Added logic to check the conflicting LOBs on incoming deals                                                                 
 * 3.0      CR 174558    R16.10     15-Sep-2015     Devika          Added logic to update the conflicting LOB list from EU Account and
                                                                    pagination. 
 * 4.0      CR 12472     R16.12     14-Dec-2015     Jiji            Add Logic to compare partner account in deal and LOB record
 */
public class LOBconflictDisplayController{

  public Opportunity oppRecord {get;set;}   
  public Set<String> productLobCategory;
  public Set<String> finaloppLobConflictSet {get;set;}
  
    
    public LOBconflictDisplayController(Apexpages.Standardcontroller controller){
      productLobCategory = new Set<String>();
      finaloppLobConflictSet = new Set<String>();
      
      try{
          this.oppRecord = [Select Name,Account.Name,PartnerAccountId, PartnerAccount.Name,End_User_Account_Name__c,End_User_Mailing_City__c,End_User_Mailing_State_Province_Region__c,
                                   (Select Product2.LOB_Category__c From OpportunityLineItems)
                                   From Opportunity Where Id=: ApexPages.currentPage().getParameters().get('oppId')];
          
          
          for(OpportunityLineItem oppLineItem : oppRecord.OpportunityLineItems){
            if(oppLineItem.Product2.LOB_Category__c != null && oppLineItem.Product2.LOB_Category__c != 'Undefined'){
              productLobCategory.add(oppLineItem.Product2.LOB_Category__c);
            }          
            
          }
          for(LOB_Registration__c oppLOB : [SELECT LOB_Name__c FROM LOB_Registration__c Where LOB_Name__c IN: productLobCategory
                                                     AND Registered_End_User__c =: oppRecord.AccountId 
                                                     //Ver 4.0: Start
                                                     //AND (LOB_registration_status__c ='Partner(approved)' OR LOB_registration_status__c ='Dell(approved)')
                                                     AND ((LOB_registration_status__c ='Partner(approved)' AND Preferred_GTM_Partner_Account__c != :oppRecord.PartnerAccountId)
                                                        OR LOB_registration_status__c ='Dell(approved)')
                                                     //Ver 4.0: End
                                                     ORDER BY LOB_Name__c ASC]){
            finaloppLobConflictSet.add(oppLOB.LOB_Name__c);
          }
          
          if(finaloppLobConflictSet.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Conflicts Present'));
          }          
      }catch(Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:'+e.getMessage()));
      }                 
    }
    
    public ApexPages.StandardSetController setCon {
      get {
        if(setCon == null) {        
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                   [SELECT Id,LOB_Name__c,LOB_Award_Type__c,City__c,State_Province_Region__c,Subsidiary_Name__c,LOB_registration_status__c,
                           Preferred_GTM_Partner_Account__c,Registered_End_User__c,GTM_Linkage_Expiry_Date__c,Name, 
                           Preferred_GTM_Partner_Account__r.Name,Registered_End_User__r.Name
                           FROM LOB_Registration__c Where LOB_Name__c IN: finaloppLobConflictSet
                           AND Registered_End_User__c =: oppRecord.AccountId
                           //Ver 4.0: Start
                           //AND (LOB_registration_status__c ='Partner(approved)' OR LOB_registration_status__c ='Dell(approved)')
                           AND ((LOB_registration_status__c ='Partner(approved)'AND Preferred_GTM_Partner_Account__c != :oppRecord.PartnerAccountId)
                           OR LOB_registration_status__c ='Dell(approved)')
                           //Ver 4.0: End
                           ORDER BY LOB_Name__c ASC]));
                             
        }
        
        return setCon;
      }
      set;
    }
    
    
    public List<LOB_Registration__c> getConflictList(){       
        setCon.setPageSize(10);
        return (List<LOB_Registration__c>) setCon.getRecords(); 
    }
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
  
    public void first() {
        setCon.first();
    }
  
    public void last() {
        setCon.last();
    }
  
    public void previous() {
        setCon.previous();
    }
  
    public void next() {
        setCon.next();
    }
}