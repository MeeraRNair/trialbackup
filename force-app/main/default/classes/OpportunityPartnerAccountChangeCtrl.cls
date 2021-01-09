/***********************************************************
* Name          : OpportunityPartnerAccountChangeCtrl 
* Description   : Controller class for OpportunityPartnerAccountChange
* ---------------------------------------------------------
* Revision  Name            Date        Release Description
* 1.0                                   Creation
* 2.0       MenMee          28.12.2010  12.1    CR5472
* 2.1       MenMee          21.02.2011  12.1    Duplicate GBL PRM Operations Profile, so rename GBL PRM Operations Service - non SSO to GBL PRM Operations - non SSO
* 2.2       Jessie          08.08.2011  12.10   CR6513: When change Partner Contact change account, check all the opportunities under it, avoid deleting the System Engineer of Opportunity Engagament Request under the opportunities
* 3.0       Krishnamoorthi  25.09.2012  13.10   CR7310: Optimized the entire class to handle bulk DML and SOQL Query operations 
* 4.0       Anamika         19.05.2015  S-02    CR11490: SAR 11644 
************************************************************/

public class OpportunityPartnerAccountChangeCtrl{
       
    Public Boolean displayNoPartnerUserMessage=false;
    Public Boolean displayOptionScreen=false;
    Public Boolean displayNoOpportunityMessage=false;
    Public Boolean displayNoOptionSelected=false; 
    Public Boolean displayNoOpenOpportunity=false;
    Public Boolean displayNoClosedOpportunity=false;
    //Rev 3.0 variables
    Public Boolean recordExistsFurther{get; set;}
    Public Boolean opprecordExistsFurther{get; set;}
    Public Boolean isError{get; set;}
    Public Boolean isUpdateContact;
    List<OpportunityTeamMember> toBeDeletedOppTMList = new List<OpportunityTeamMember>();
    Map<Id, Set<Id>> oppSysEngListMap = new Map<Id, Set<Id>>();
    Boolean preparedSysEngineerMap = false;
    Set<Id> teamMembersNotDeleted = new Set<Id>();
    Public Integer UPDATE_BATCH_SIZE_LIMIT =500;
    Public Integer BATCH_NUMBER{get; set;} 
   
     
    Public String contactUID;
    Public Contact contactObject;
        
    Public String selected;
    Public String[] optionsArr = new String[]{};
    Public Set<String> selectedOptionsSet=new Set<String>();    
    
    List<Opportunity>  opportunityList=new List<Opportunity>();
    List<Opportunity>  openOpptyList=new List<Opportunity>();
    List<Opportunity>  closedOpptyList=new List<Opportunity>();
    
    Public double UPDATE_LIST_SIZE_LIMIT=100;
    Public Id TEMPORARY_OWNER_ID;
    Public String TEMPORARY_OWNER_NAME=system.label.SAR11644_Username;     // 4.0     
    Public String TEMPORARY_OWNER_PROFILE=system.label.SAR11644_Profile_name;       //Rev 2.1 //4.0
        
    public opportunityPartnerAccountChangeCtrl(ApexPages.StandardController controller){
        //User globalDataAdminUser
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
        
        User globalPRMOperationsUser=[Select u.Profile_Name__c, u.ProfileId, u.Name, u.IsActive,u.Id,
                                    u.System_Admin_or_Delegated_User_Admin__c  From User u 
                                    where u.Profile.name=:TEMPORARY_OWNER_PROFILE and u.IsActive=true
                                    and u.name=:TEMPORARY_OWNER_NAME limit 1 ];
                                
        TEMPORARY_OWNER_ID=globalPRMOperationsUser.Id;
        
                  
        
        contactObject=(Contact)controller.getRecord();
        contactObject=[select accountId,FirstName,LastName,phone,email,Account_Changed__c from 
                       contact where id=:contactObject.id limit 1];
        contactUID = contactObject.Id;
                              
        System.debug('###contactObject'+contactObject);    
        System.debug('###contactUID'+contactUID);                   
        
        List<User> userList =[select contactid,id from user where contactid=:contactObject.id limit 1];                             
        
        if(userList.isEmpty()){
            displayNoPartnerUserMessage=true;            
        }
        else{            
           /* opportunityList = [SELECT id ,accountid,OwnerId,stagename,PartnerAccountId,Deal_Created_Date_Time__c 
                               FROM opportunity 
                               WHERE OwnerId=:userList[0].id 
                               AND PartnerAccountId != :contactObject.AccountId]; */
                               
             for(Opportunity opptyObject:[SELECT id ,accountid,OwnerId,stagename,PartnerAccountId,Deal_Created_Date_Time__c 
                                           FROM opportunity 
                                           WHERE OwnerId=:userList[0].id 
                                           AND PartnerAccountId != :contactObject.AccountId]){
                     opportunityList.add(opptyObject); 
                     if(opptyObject.stagename!='Win - 100%' && opptyObject.stagename!='Lost, Cancelled - 0%'){
                         openOpptyList.add(opptyObject);
                     }
                     if(opptyObject.stagename=='Win - 100%' || opptyObject.stagename=='Lost, Cancelled - 0%'){
                         closedOpptyList.add(opptyObject);
                     }                     
             }
                              
            if(opportunityList.isEmpty()){                             
                displayNoOpportunityMessage=true;                
            }else{
                displayOptionScreen=true;               
            }
            if(closedOpptyList.isEmpty() && opportunityList.size()>0 && displayOptionScreen==true){
                displayNoClosedOpportunity=true;
            }
            if(openOpptyList.isEmpty() && opportunityList.size()>0 && displayOptionScreen==true){
                displayNoOpenOpportunity=true;
            } 
        } 
        System.debug('###opportunityList'+opportunityList);     
        System.debug('###displayOptionScreen'+displayOptionScreen);
        System.debug('###displayNoPartnerUserMessage'+displayNoPartnerUserMessage);
        System.debug('###displayNoOpportunityMessage'+displayNoOpportunityMessage);
        System.debug('###displayNoClosedOpportunity'+displayNoClosedOpportunity);
        System.debug('###displayNoOpenOpportunity'+displayNoOpenOpportunity);
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        
        BATCH_NUMBER = 0;
        recordExistsFurther = true;
        opprecordExistsFurther = true;
        isUpdateContact = false;
        isError = false;
    }//end of constructor
    
    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if(openOpptyList.size()>0){
            options.add(new SelectOption('open','Transfer all open opportunities to new account'));
        }
        if(closedOpptyList.size()>0){
            options.add(new SelectOption('closed','Transfer all closed opportunities to new account'));
        }
        return options;
    }
    public String[] getSelectedOptions() {
        return optionsArr; 
    }
    public void setSelectedOptions(String[] selectedArr){
        //this.optionsArr = selectedArr;
        if(selectedArr.size()>0){
            for(String stringElt:selectedArr){
                selectedOptionsSet.add(stringElt);
            }   
        }else{
            displayNoOptionSelected=true;
        }
        System.debug('###selectedOptionsSet'+selectedOptionsSet);
    }
        
    public Boolean getDisplayNoPartnerUserMessage() {
        return displayNoPartnerUserMessage;
    }
    public void setDisplayNoPartnerUserMessage(Boolean booleanValue){
        this.displayNoPartnerUserMessage = booleanValue;
    }
    
    public Boolean getDisplayOptionScreen() {
        return displayOptionScreen;
    }
    public void setDisplayOptionScreen(Boolean booleanValue){
        this.displayOptionScreen = booleanValue;
    }
    
    public Boolean getDisplayNoOpportunityMessage() {
        return displayNoOpportunityMessage;
    }
    public void setDisplayNoOpportunityMessage(Boolean booleanValue){
        this.displayNoOpportunityMessage = booleanValue;
    }
    
    public Boolean getDisplayNoOpenOpportunity() {
       /* if(openOpptyList.size()==0 && opportunityList.size()>0 && displayNoPartnerUserMessage==false){
            displayNoOpenOpportunity=true;
        }*/
        return displayNoOpenOpportunity;
    }
    public void setDisplayNoOpenOpportunity(Boolean booleanValue){
        this.displayNoOpenOpportunity = booleanValue;
    }
    
    public Boolean getDisplayNoClosedOpportunity() {
       /* if(closedOpptyList.size()==0 && opportunityList.size()>0 && displayNoPartnerUserMessage==false){
            displayNoClosedOpportunity=true;
        }*/
        return displayNoClosedOpportunity;
    }
    public void setDisplayNoClosedOpportunity(Boolean booleanValue){
        this.displayNoClosedOpportunity = booleanValue;
    }
    
    
    
    public pagereference updateContact(){
        
        if(opportunityList.isEmpty()){
            contactObject.Account_Changed__c=false;
            Update contactObject;   
        }
        return null;
    } 
    
    
    private void prepareSystemEngineerMap(){
        //this is just to see if there is at least one team member
        List<OpportunityTeamMember> oppTMList = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId =:opportunityList LIMIT 1];
              
        
        String PPT_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support', 'Support_Request__c', true); 
        String PPT_IM_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support - IM', 'Support_Request__c', true); 
        String PPT_SE_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support - SE', 'Support_Request__c', true); 
        
        Set<Id> recordTypeIdSet = new Set<Id>{PPT_RECORDTYPEID, PPT_IM_RECORDTYPEID, PPT_SE_RECORDTYPEID};
        
        System.debug('### recordTypeIdSet : ' + recordTypeIdSet);
        if(oppTMList!=null && oppTMList.size() >0){                               
            for(Support_Request__c oppEngRequest : [Select o.Opportunity__c, o.Assigned_System_Engineer_1__c, o.Assigned_System_Engineer_2__c from Support_Request__c o 
                                                                where o.Opportunity__c IN :opportunityList and o.RecordTypeId IN :recordTypeIdSet
                                                                and (o.Assigned_System_Engineer_1__c!=null OR o.Assigned_System_Engineer_2__c!=null)]){
                
                if(!oppSysEngListMap.containsKey(oppEngRequest.Opportunity__c)){
                    
                    System.debug('### new Opp key [' + oppEngRequest.Opportunity__c + '] created into the map.');
                    oppSysEngListMap.put(oppEngRequest.Opportunity__c, new Set<Id>());
                    
                }
                
                Set<Id> oppSysEngList = oppSysEngListMap.get(oppEngRequest.Opportunity__c);
                    
                if(oppEngRequest.Assigned_System_Engineer_1__c!=null){
                    System.debug('### new OTM [' + oppEngRequest.Assigned_System_Engineer_1__c + '] created to the key[' + oppEngRequest.Opportunity__c + ']');
                    oppSysEngList.add(oppEngRequest.Assigned_System_Engineer_1__c);
                }
                
                if(oppEngRequest.Assigned_System_Engineer_2__c!=null){
                    System.debug('### new OTM [' + oppEngRequest.Assigned_System_Engineer_2__c + '] created to the key[' + oppEngRequest.Opportunity__c + ']');
                    oppSysEngList.add(oppEngRequest.Assigned_System_Engineer_2__c);
                }
                    
            }
        }
        preparedSysEngineerMap = true;
    
    } //end of prepareSystemEngineerMap
    
    //Opportunity Team memeber deletion
    public pagereference removeOTMsExceptSysEngOfOpps(){
        
        isError = false;
        
        if(selectedOptionsSet.isEmpty()){            
            PageUtils.addFatal('Error: Please select one or both the actions below to move the opportunities to new account.');
            isError = true;
            return null; 
        }
        
        recordExistsFurther = true;
        if(!preparedSysEngineerMap){
            prepareSystemEngineerMap();
        }
        
        //Rev 2.0 - Delete All OpportunityTeamMember and OpportunityShare    
        //CR6513 - Delete All OpportunityTeamMember (excluding team members which are SE1 and SE2 of each opportunity)
        
        List<OpportunityTeamMember> oppTMList = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId =:opportunityList AND Id NOT IN :teamMembersNotDeleted LIMIT 1000];
        
        if(oppTMList!=null && oppTMList.size() >0){
                                
            for(integer i=oppTMList.size()-1; i>=0;i--){
                OpportunityTeamMember oppTM = oppTMList.get(i);
                System.debug('### oppTM : ' + oppTM);
                if(!oppSysEngListMap.containsKey(oppTM.OpportunityId) || (oppSysEngListMap.containsKey(oppTM.OpportunityId) && !oppSysEngListMap.get(oppTM.OpportunityId).contains(oppTM.UserId))){
                    System.debug('### exclude deletion for oppTM [' + oppTM + '], which exits in the map');
                    toBeDeletedOppTMList.add(oppTM);
                }else{
                    teamMembersNotDeleted.add(oppTM.id);
                
                }               
            }
            
            System.debug('### oppTM List to be deleted : ' + toBeDeletedOppTMList.size());
            
            if(toBeDeletedOppTMList.size() > 0){
                Database.delete(toBeDeletedOppTMList, false);
            }
            
        }else{
            System.debug('### No removal for empty oppTM List');
        } 

        if(oppTMList==null || (oppTMList!=null && oppTMList.size() < 1000)){
            recordExistsFurther = false;
        }
                          
        //Rev 2.0-end  
        return null;
        
    }
    
    
    public pagereference changePartnerAccount(){
                
        //clearing all used lists.
        oppSysEngListMap.clear();
        teamMembersNotDeleted.clear();
        
        Id originalOwnerId;
        
        Opportunity opportunityObject;
        List<Opportunity>  updateOpportunityList=new List<Opportunity>();
        List<Opportunity>  updateOldOwnerOpportunityList=new List<Opportunity>();
        List<Opportunity>  originalOwnerUpdateSuccessList=new List<Opportunity>();
        Map<Id,Opportunity> opportunity2BUpdatedMap=new Map<Id,Opportunity>();  
        
        if(opportunityList.size()>0){ 
            
            opprecordExistsFurther = true;
             
            //Index calculation based on total records
            BATCH_NUMBER++;
            integer startingIndex = (BATCH_NUMBER -1) * UPDATE_BATCH_SIZE_LIMIT;
            integer lastIndex = startingIndex + (UPDATE_BATCH_SIZE_LIMIT-1);

            if(lastIndex > opportunityList.size()) {
                lastIndex = opportunityList.size()-1;
            }

            for(integer j=startingIndex; j<=lastIndex; j++){
            
                //try{                
                    //sp= Database.setSavepoint();
                                    
                    //Rev 2.0 - Delete All OpportunityTeamMember and OpportunityShare                
                    //List<OpportunityTeamMember> oppTMList = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityList];
                    //System.debug('### Existing OTM: '+ oppTMList);
                    //Database.delete(oppTMLIst, false);
                                    
                    //List<OpportunityShare> oppShare = [SELECT Id FROM OpportunityShare WHERE OpportunityId IN : opportunityList];
                    //System.debug('### Existing OS: '+ oppShare);
                    //Database.delete(oppShare, false);
                    //Rev 2.0-end                
                    
                    //removeSysEngOfOppEngRequestFromOTM(); 
                                        
                    Opportunity opptyObject = opportunityList[j];
                    System.debug('###opptyObject');
                
                    originalOwnerId=opptyObject.OwnerId;
                    System.debug('###originalOwnerId'+originalOwnerId);  
                    if((selectedOptionsSet.contains('open')==true && opptyObject.stagename!='Win - 100%' && opptyObject.stagename!='Lost, Cancelled - 0%') ||
                       (selectedOptionsSet.contains('closed')==true && (opptyObject.stagename=='Win - 100%' || opptyObject.stagename=='Lost, Cancelled - 0%'))){                   
                        /*assigning a dummy owner to the opportunity. here it is 
                        global data load 5 . This is done because the partneraccountid
                        field value can be changed only if owner of opportunity
                        is changed.*/
                        
                        opptyObject.OwnerId =TEMPORARY_OWNER_ID;
                        updateOpportunityList.add(opptyObject);                        
                        opportunity2BUpdatedMap.put(opptyObject.Id,opptyObject);                       
                        //System.debug('###updateOpportunityList'+updateOpportunityList);                        
                    }
                    
                   // System.debug('###updateOpportunityList'+updateOpportunityList);
                    if(updateOpportunityList.size()==UPDATE_LIST_SIZE_LIMIT){ 
                        processTheOpportunityBatch(updateOpportunityList,opportunity2BUpdatedMap, originalOwnerId);
                    } //100 opp update block                      
                
                    
               // }catch(Exception e){
                    //Database.rollback(sp);   
                //}
                
            }// end of for j=startingIndex
        
            System.debug('###updateOpportunityList <UPDATE_LIST_SIZE_LIMIT'+updateOpportunityList);
            if(updateOpportunityList.size()>0 && updateOpportunityList.size()<UPDATE_LIST_SIZE_LIMIT){                  
                processTheOpportunityBatch(updateOpportunityList,opportunity2BUpdatedMap, originalOwnerId);
            }// end of last batch process    
            
            
            if(lastIndex == opportunityList.size()-1) { 
                opprecordExistsFurther = false;
            }
            
            //return PageUtils.redirect(contactLink);            
        
        } 
        return null;
    }
    
    //Opportunity update
    public void processTheOpportunityBatch(List<Opportunity>  updateOpportunityList,Map<Id,Opportunity> opportunity2BUpdatedMap, Id originalOwnerId){

        Opportunity opportunityObject;
        Database.SaveResult[] results;
        Database.SaveResult[] originalOwnerUpdateResults;
        List<Opportunity>  updateOldOwnerOpportunityList=new List<Opportunity>();
        List<Opportunity>  originalOwnerUpdateSuccessList=new List<Opportunity>();
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;   
        
        results = Database.Update(updateOpportunityList, false);
        for (integer i=0; i< updateOpportunityList.size(); i++) {
            if (results[i].IsSuccess()==true){
                opportunityObject=opportunity2BUpdatedMap.get(updateOpportunityList[i].Id);
                opportunityObject.OwnerId =originalOwnerId;        
                updateOldOwnerOpportunityList.add(opportunityObject);                          
            }                    
         } 
        
        if(updateOldOwnerOpportunityList.size()>0){
            originalOwnerUpdateResults= Database.Update(updateOldOwnerOpportunityList, false);
            for (integer i=0; i< updateOldOwnerOpportunityList.size(); i++) {
                if (originalOwnerUpdateResults[i].IsSuccess()==true){                                  
                    originalOwnerUpdateSuccessList.add(updateOldOwnerOpportunityList[i]);              
                }                    
            } 
        }
        
        
        //Rev 2.0 - Re-populate OpportunityTeamMember and OpportunityShare
        List<Opportunity> updatedPAOpportunityList = [SELECT Id, PartnerAccountId, AccountId, OwnerId, Direct_Team_Sync__c FROM Opportunity WHERE Id in :originalOwnerUpdateSuccessList];
        SalesTeamUtil.setDefaultSalesTeam(updatedPAOpportunityList, true); 
        //Rev 2.0-end   
        
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        
        if(isUpdateContact || originalOwnerUpdateSuccessList.size()>0){
                isUpdateContact = true;
        }
        else {
            isUpdateContact = false;
        }
        
        updateOpportunityList.clear();
        opportunity2BUpdatedMap.clear();    
        
    }// end of  processTheOpportunityBatch
    
    
    //Update Contact field Account_Changed__c
     public pagereference updateContactobj(){
         
        String contactLink='/'+contactUID;
        
        if(isUpdateContact == true){
            if(openOpptyList.size()>0 && closedOpptyList.size()>0 && 
                selectedOptionsSet.contains('open') && selectedOptionsSet.contains('closed')){
                    contactObject.Account_Changed__c=false;
                    Update contactObject;
            }
            if(openOpptyList.size()>0 && closedOpptyList.isEmpty() && 
                selectedOptionsSet.contains('open') ){
                    contactObject.Account_Changed__c=false;
                    Update contactObject;
            }
            if(closedOpptyList.size()>0 && openOpptyList.isEmpty() && 
                selectedOptionsSet.contains('closed') ){ 
                    contactObject.Account_Changed__c=false;
                    Update contactObject;
            } 
            
            return PageUtils.redirect(contactLink);   
        } 
                       
        return null;
     }// end of Contact update
}