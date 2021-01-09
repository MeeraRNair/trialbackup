/***********************************************************
* Name          : VFCntrlr_GoalDealListing 
* Description   : Controller class for GoalDealListing VF Page
* ---------------------------------------------------------
* Revision  Release Name    Date            Description
* 1.0               MenMee  08.03.2010      Creation          
* 2.0       12.3    MenMee  31.03.2011      Defect 69648 Change 'Goal' to all capital
* 2.1       12.3    MenMee  05.04.2011      Defect 69687 Customize error message
* 2.2       16.10   Krishna 20.08.2015      CR11839 - Hide Total Approved Deal Margin % from GOAL page layout for ALL Sales Profiles category in Dell Main
************************************************************/

public class VFCntrlr_GoalDealListing {
        
        //Variable
        private static final integer PAGE_SIZE = 25;
        private static final string SERVICE_GET = 'SERVICE_GET';
        private static final String SERVICE_UPDATE = 'SERVICE_UPDATE';
        private Integer currentPage;
        private Integer currentLastPage;
        private List<Opportunity> oppRecordList = new List<Opportunity>();
        private string oppId;
        //private Map<string, string> mapFaultCodeToFaultString = new Map<String, String> {
        //                                                                                                                      'fault:VEN-0000' => 'There is no GOAL deal associates to this Opportunity'
        //                                                                                                              };
                        
        //Property
        public String errorMessage {get; private set;}  
        public boolean showWinLossButton {get; private set;}            
        public GoalIntegrationUtils.GoalDeal[] goalDealList {get; private set;}
        public boolean hasPrevious {get; private set;}
        public boolean hasNext {get; private set;}
        public String apiSessionId {get;set;} 
        public String apiServerURL {get;set;} 
        public String vendavoURL {get; set;}
        public String browserName {get; set;}
        public String dealId {get; set;}
        
        public Boolean showTADMPerc{get;set;} //CR11839 - Hide Total Approved Deal Margin % from GOAL page layout for ALL Sales Profiles category in Dell Main
        
        public boolean hasPreviousAndNext {
                get {
                        return (hasPrevious && hasNext);
                }
        }
                
        public String backToOpportunity {
                get {
                        System.debug('## backToOpportunity: '+oppId);
                        return '/'+oppId;
                }
        }
        
    public Opportunity oppRecord;
        public Map<Integer, GoalIntegrationUtils.GoalDeal[]> batchToGoalDealMap = new Map<Integer, GoalIntegrationUtils.GoalDeal[]>(); 
                 
        //Constructor
    public VFCntrlr_GoalDealListing(ApexPages.StandardController controller) {
                
                showWinLossButton = false;
                hasNext = false;
                hasPrevious = false;
                currentPage = 1;
                                                                                        
                try {           
                    oppRecord = (Opportunity) controller.getRecord();
                    oppRecordList = [SELECT Id, Deal_Id__c, StageName 
                                                     FROM Opportunity
                                                             WHERE Id =:oppRecord.Id LIMIT 1];
                                                                                                    
                    System.debug ('## oppRecordList = '+ oppRecordList);  
                    if (oppRecordList.isEmpty()){
                            errorMessage = 'Could not find a valid Opportunity record';
                            return;
                    }    
                    
                    //CR11839 - Hide Total Approved Deal Margin % from GOAL page layout for ALL Sales Profiles category in Dell Main - start
                         String strCurrentUserProfile = StaticFactory.getCurrentUserDetails().Profile.name;
                         String profileNameWithoutVersion = null;
                         if(strCurrentUserProfile != null){
                             profileNameWithoutVersion = strCurrentUserProfile.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}','');  
                         }
                         system.debug('%%%% Profile Name Without Version--'+profileNameWithoutVersion);          
                         Set<String> profileList = new Set<String>();                                           
                         profileList.addAll(System.Label.STV_Sales_Profiles.split(';'));  
                         if(profileList.size() > 0){               
                             if (profileNameWithoutVersion!=null && profileList.contains(profileNameWithoutVersion)){
                                 showTADMPerc = false;
                             }else{
                                 showTADMPerc = true;
                             }
                         }
                    
                    //CR11839 - Hide Total Approved Deal Margin % from GOAL page layout for ALL Sales Profiles category in Dell Main - End
                       

                    OppId = oppRecordList[0].Id;
                    goalDealList = new GoalIntegrationUtils.GoalDeal[0];
                                                    
                    goalDealList = getGoalDealByBatch();
                                                                                            
                    if (GoalIntegrationUtils.isErrorResponse) {                                                             
                        if (GoalIntegrationUtils.faultCode != null) {
                            //Check for custom fault string
                            errorMessage = GoalIntegrationUtils.handleFaultString(GoalIntegrationUtils.faultCode, SERVICE_GET);                                     
                        }
                        else {
                            //Rev 2.1
                            errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';                                                       
                        }                               
                        return;                         
                    }                                                 
                }
                catch (Exception e) {
                    system.debug('## [Code: VFCntrlr_GoalDealListing:VFCntrlr_GoalDealListing] Caught APEX exception: '+e.getMessage());
                    errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';            
                }
        }
 
        //Method to update all goal deals to win/loss
        public PageReference updateAllWinLoss() {
            List<String> SFDCDealIdList = new List<String>();
            SFDCDealIdList.add(oppRecordList[0].Deal_Id__c);
            GoalIntegrationUtils.GoalDeal[] dealByBatch = new GoalIntegrationUtils.GoalDeal[0];
            
            try {              
                    GoalIntegrationUtils.updateWinLoss(SFDCDealIdList); 
                    
                    //Rev 2.1
                    if (GoalIntegrationUtils.isErrorResponse) {                                                             
                        if (GoalIntegrationUtils.faultCode != null) {
                            //Check for custom fault string
                            errorMessage = GoalIntegrationUtils.handleFaultString(GoalIntegrationUtils.faultCode, SERVICE_UPDATE);                                     
                        }
                        else {                          
                            errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';                                                       
                        }    
                        showWinLossButton = true;               
                    }                    
                    else {                                                     
                        //Clear all records from cache.
                        batchToGoalDealMap.clear();
                        goalDealList = getGoalDealByBatch();                            
                        setPreviousAndNext();
                        showWinLossButton = GoalIntegrationUtils.showWinLossButton();
                    }                                                                                   
                     
            }
            catch (Exception e) {
                system.debug('## [Code: VFCntrlr_GoalDealListing:updateAllWinLoss] Caught APEX exception: '+e.getMessage());
                errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';            
            }       
            
            return null;
        }
        
        public PageReference Previous() {
                currentPage = currentPage - 1;  
                        
                goalDealList = getGoalDealByBatch();
                System.debug('previous: '+goalDealList.size());
                return null;    
        }
        
        public PageReference Next() {
                currentPage = currentPage + 1;
                
                goalDealList = getGoalDealByBatch();
                return null;
        }
        
        public void setPreviousAndNext() {              
                hasNext = (currentPage < currentLastPage)? true:false;

                hasPrevious = (currentPage > 1)? true:false;
        }
        
        public GoalIntegrationUtils.GoalDeal[] getGoalDealByBatch() {
                GoalIntegrationUtils.GoalDeal[] dealByBatch = new GoalIntegrationUtils.GoalDeal[0];
                GoalIntegrationUtils.GoalDeal[] dealforNextBatch = new GoalIntegrationUtils.GoalDeal[0];
                                                                
                try {
                        if(batchToGoalDealMap.get(currentPage) == null) {
                                System.debug('## getGoalDealByBatch: get from Vendavo: '+ currentPage);
                                dealByBatch = GoalIntegrationUtils.getGoalDealBySFDCDealId(oppRecordList[0], currentPage, PAGE_SIZE);                           
                                batchToGoalDealMap.put(currentPage, dealByBatch);
                        }                       
                        else {                          
                                dealByBatch = batchToGoalDealMap.get(currentPage);
                                System.debug('## getGoalDealByBatch: get from cache: '+ currentPage);                   
                        }                       
                                                        
                        //check for Next Page
                        if (dealByBatch.size() == PAGE_SIZE) {  
                                Integer nextPage = currentPage + 1;
                                dealforNextBatch = GoalIntegrationUtils.getGoalDealBySFDCDealId(oppRecordList[0], nextPage, PAGE_SIZE);
                                if (GoalIntegrationUtils.faultCode == null) {
                                        System.debug('## getGoalDealByBatch: hasNext');
                                        batchToGoalDealMap.put(currentPage+1, dealforNextBatch);
                                        currentLastPage = currentPage+1;
                                }
                                else {                                  
                                        System.debug('## getGoalDealByBatch: No more Next Page:Error' + currentPage);
                                        GoalIntegrationUtils.isErrorResponse = false; // turn off this as this is to show no more next page and not really a error response                                     
                                        hasNext = false;
                                }
                        }                               
                        else {
                                System.debug('## getGoalDealByBatch: No more Next Page:' + currentPage);
                                hasNext = false;
                        }               
                } 
                catch (Exception e) {
            system.debug('## [Code: VFCntrlr_GoalDealListing:getGoalDealByBatch] Caught APEX exception: '+e.getMessage());
            errorMessage = 'The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.';            
        }
        
        showWinLossButton = GoalIntegrationUtils.showWinLossButton();
                setPreviousAndNext(); 
                return dealByBatch;
        }

        public PageReference doBack() {
                return new PageReference('/'+oppId);
        }    
}