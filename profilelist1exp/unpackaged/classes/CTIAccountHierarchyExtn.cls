/***********************************************************
* Name          : CTIAccountHierarchyExtn
* Description   : Extension for CTI_Account_Hierarchy VF page
* Created By    : Krishnakumar Manoharan. User Story    
*/

public class CTIAccountHierarchyExtn {
    private CTI_Call_Log__c ctiLog;
    public List<AccountWrap> ctiAccList {get;set;}
    private ApexPages.StandardController stdCntroller;
    
    public CTIAccountHierarchyExtn(ApexPages.StandardController stdController){
      try{
        ctiLog = (CTI_Call_Log__c) stdController.getRecord();
        this.stdCntroller =   stdController;
        system.debug('Account id---'+ctiLog.Account__c);
        ID accountId = ctiLog.Account__c;
        if(accountId !=null){
            populateAccounts(accountId);  
        }
      }catch(Exception ex){
          system.debug('Exception occured--'+ex.getMessage()+'--'+ex.getLineNumber()+'--'+ex.getStackTraceString());
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ex.getMessage()));
      }  
    }
    
    public void populateAccounts(Id accountId){
        try{
            ctiAccList = new List<AccountWrap>();
            Boolean isParentAdded = false;
            List<Account> accList = null;      
            String query = 'Select id,Name,Account_ID__c,ParentId,parent.name,parent.Account_ID__c,Parent.parentid,Parent.parent.name,parent.Account_Type_Integration__c,parent.Segment_Desc__c,parent.BillingCity,parent.BillingCountry,parent.Owner.name,parent.Calculated_Status__c,parent.DMU__c ,Account_Type_Integration__c,Segment_Desc__c,BillingCity,BillingCountry,Owner.Name,OwnerId,Calculated_Status__c,DMU__c,(Select id,Name,Account_ID__c,ParentId,parent.name,Account_Type_Integration__c,Segment_Desc__c,BillingCity,BillingCountry,Owner.Name,OwnerId,Calculated_Status__c,DMU__c From ChildAccounts) From Account where id =\''+ctiLog.Account__c+'\'';     
            
            if(ctiLog.Account__r.parentid !=null){
                query = query+' or parentId = \''+ctiLog.Account__r.parentid+'\'';
            }  
             
            accList = Database.query(query);

            for(Account acc:accList){
              if(acc.ParentId !=null && !isParentAdded){
                    AccountWrap parentAcc = new AccountWrap();
                    parentAcc.id=acc.ParentId;
                    parentAcc.Name=acc.parent.name;
                    parentAcc.Account_ID=acc.parent.Account_ID__c;
                    if(acc.Parent.parentid!=null){
                        parentAcc.parentName=acc.parent.parent.name;                    
                    }                
                    parentAcc.Account_Type_Integration=acc.parent.Account_Type_Integration__c;
                    parentAcc.Segment_Desc=acc.parent.Segment_Desc__c;
                    parentAcc.BillingCity=acc.parent.BillingCity;
                    parentAcc.BillingCountry=acc.parent.BillingCountry;
                    parentAcc.OwnerName=acc.parent.Owner.name;
                    parentAcc.Calculated_Status=acc.parent.Calculated_Status__c;
                    parentAcc.DMU=acc.parent.DMU__c;
                    ctiAccList.add(parentAcc);
                    isParentAdded = true;  
                }
              AccountWrap selectedAcc = new AccountWrap();
                selectedAcc.id=acc.id;
                selectedAcc.Name=acc.name;
                selectedAcc.Account_ID=acc.Account_ID__c;
                if(acc.ParentId !=null){
                    selectedAcc.parentid = acc.parentid;
                    selectedAcc.parentName=acc.parent.name;
                }
                selectedAcc.Account_Type_Integration=acc.Account_Type_Integration__c;
                selectedAcc.Segment_Desc=acc.Segment_Desc__c;
                selectedAcc.BillingCity=acc.BillingCity;
                selectedAcc.BillingCountry=acc.BillingCountry;
                selectedAcc.OwnerName=acc.Owner.name;
                selectedAcc.Calculated_Status=acc.Calculated_Status__c;
                selectedAcc.DMU=acc.DMU__c;
                ctiAccList.add(selectedAcc);
              if(acc.childAccounts!=null && !acc.childAccounts.isEmpty()){
                    populateChildAccount(acc.childAccounts);
                }
          }
      }catch(Exception ex){
          system.debug('Exception occured--'+ex.getMessage()+'--'+ex.getLineNumber()+'--'+ex.getStackTraceString());
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + ex.getMessage()));
      }
    }
    
    public class AccountWrap{
        public ID Id {get;set;}
        public String Name {get;set;}
        public String Account_ID {get;set;}
        public ID parentId {get;set;}
        public String parentName {get;set;}
        public String Account_Type_Integration {get;set;}
        public String Segment_Desc {get;set;}
        public String BillingCity {get;set;}
        public String BillingCountry {get;set;}
        public String OwnerName {get;set;}
        public String Calculated_Status {get;set;}
        public Boolean DMU {get;set;}
    }
    
    public void populateChildAccount(List<Account> accLists){
        for(Account acc:accLists){
            AccountWrap selectedAcc = new AccountWrap();
            selectedAcc.id=acc.id;
            selectedAcc.Name=acc.name;
            selectedAcc.Account_ID=acc.Account_ID__c;
            if(acc.ParentId !=null){
                selectedAcc.parentid = acc.parentid;
                selectedAcc.parentName=acc.parent.name;
            }
            selectedAcc.Account_Type_Integration=acc.Account_Type_Integration__c;
            selectedAcc.Segment_Desc=acc.Segment_Desc__c;
            selectedAcc.BillingCity=acc.BillingCity;
            selectedAcc.BillingCountry=acc.BillingCountry;
            selectedAcc.OwnerName=acc.Owner.name;
            selectedAcc.Calculated_Status=acc.Calculated_Status__c;
            selectedAcc.DMU=acc.DMU__c;
            ctiAccList.add(selectedAcc); 
        }        
    }
    
    public PageReference save(){
        try{
        Boolean isError = false;           
        string accountId = Apexpages.currentPage().getParameters().get('accountId');
        ctiLog.Account__c = accountId;
        system.debug('Account id---'+accountId);
        if(accountId != null && accountId != ''){
            //stdCntroller.save();
            if(ctiLog.Trip_Report__c!=null && accountId != ctiLog.Trip_Report__r.Account__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'To proceed please remove the Trip Report linked to the CTI Call log and update the Account'));
                isError = true;
            }
            
            if(ctiLog.Opportunity__c!=null && accountId != ctiLog.Opportunity__r.accountid){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'To proceed please remove the Opportunity linked to the CTI Call log and update the Account'));
                isError = true;
            }
            if(ctiLog.Contact__c!=null && accountId != ctiLog.Contact__r.Accountid){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'To proceed please remove the Contact linked to the CTI Call log and update the Account'));
                isError = true;
            }
            if(isError){
                return null;
            }
            
            Database.SaveResult result = Database.update(ctiLog,false);
                if (!result.isSuccess()) {                    
                  for(Database.Error err : result.getErrors()) {
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
                  }
                  return null;  
                }else{
                    PageReference pageRef = new PageReference( '/'+ctiLog.id);
                    pageRef.setRedirect(false);
                    return pageRef;   
                }
            }   
        }catch(DmlException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }    
        return null;
   }
}