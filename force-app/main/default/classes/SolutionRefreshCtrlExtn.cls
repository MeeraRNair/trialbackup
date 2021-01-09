public with sharing class SolutionRefreshCtrlExtn {
    public String status {get; set;}
    public list<OSCWebServiceCallout.error> integrationResults {get; set;}
    public list<OSCWebServiceCallout.Messages_Z> MessageResults {get; set;}
    public Boolean validResult {get; set;}
    public Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
    public Map<Id,List<String>> oppIsSlnIdMap = new Map<Id,List<String>>();
    public list<string> solidlist = new list<string>();
    public string solutionid{get;set;}
    public list<opportunity> opplist{get;set;}
    public String id{get;set;}
    public String description{get;set;}
    public String type{get;set;}
    public string messages{get;set;}
    public Map<id,List<Opportunitylineitem>> opptylineitem = new Map<id,list<opportunitylineitem>>();
    public List<Opportunitylineitem> olilist = new list<Opportunitylineitem>();
    public Boolean displaysuccessmsg{get;set;}
    public List<RefreshResponse> responseList {get; set;}
    public class RefreshResponse{
        public String label{get;set;}
        public String value{get;set;}
        public RefreshResponse(String labelName, String responseValue){
            this.label = labelName;
            this.value =  responseValue;
        }   
    }
    
    public SolutionRefreshCtrlExtn(ApexPages.StandardController controller){
        solutionid = apexpages.currentpage().getparameters().get('id');
        
        list<Solution__c> solutionlist = [SELECT Opportunity__r.Name,Opportunity__r.end_user_account_name__c,Opportunity__r.Account.Name, Opportunity__r.deal_id__c, Opportunity__c, OSC_Solution_ID__c, OSC_Regional_ID__c,CreatedBy.Profile.Name FROM Solution__c WHERE Id = :solutionId];     
        
        
        try{        
            if (solutionlist != null){
                
               for(Solution__c sol: solutionlist){
                   oppIsSlnIdMap.put(sol.Opportunity__c,new List<String>{sol.OSC_Regional_ID__c});
               }
            }   
            
            if(oppIsSlnIdMap.size() > 0){
                
                opplist = [select id, stagename, name,end_user_account_name__c, account.name, deal_id__c, deal_registration_status__c, deal_type__c, deal_expiration_date__c,Opportunity_Customer_Number__r.Name, Affinity_ID__c,Unassigned_End_User__c,Unweighted_Rev_USD__c,partnerAccount.Account_id__c,PartnerAccount.name,PartnerAccount.Partner_Track__r.Partner_Track_AffinityId__c,PartnerAccount.Partner_Track__r.name from opportunity where id IN : oppIsSlnIdMap.keyset()]; //Anamika- send Opportunity Customer Number & End User Affinity ID info to OSC
                olilist = [select PricebookEntry.product2.name, PricebookEntry.productcode, product_type__c from opportunitylineitem where opportunity.id IN : opplist];
                system.debug('Products list:' + olilist);
            }
            oppMap.put(opplist[0].id,opplist[0]);
            opptylineitem.put(opplist[0].id,olilist);
            OSCWebServiceCallout.isRefreshBtnClicked = true;
                integrationResults   = OSCWebServiceCallout.processRequest(oppMap,oppIsSlnIdMap,'Association',opptylineitem,false);
                system.debug('################ integrationResults' + integrationResults);
            responseList = new List<RefreshResponse>();    
            for(OSCWebServiceCallout.Error e: integrationResults){
                
                if(e.Messages.size() > 0){
                    responseList.add(new RefreshResponse ('MessageDescription',e.Messages[0].Description));
                    responseList.add(new RefreshResponse ('MessageId',e.Messages[0].Id));
                    
                    
                }
                    responseList.add(new RefreshResponse ('ResponseStatus',(e.IsSuccess == 'true'?'Successful':'Failed')));    
            
                }
                system.debug('____________________________________________________________________ responseList: '+responseList);      
        }catch (Exception exp) {
           PageUtils.addError(exp.getMessage());
           validResult = false;        
        }
        
        validResult = (responseList !=null && responseList.size()>0 );
    } 
}