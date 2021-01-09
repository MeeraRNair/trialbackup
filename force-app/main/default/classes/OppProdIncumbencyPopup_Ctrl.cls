/*
 * Author   : Pawan Kumar Nitin Vasigala
 * Purpose  : Apex Controller class to show a pop up to Channel Users on Incumbent Products being added to a
 *            Opportunity of Incumbent Account.
 *        
 * Revision CR Number   Release No  Date            Modified By                         Description
 * -------- ---------   ----------  -----------     ------------                        -----------
 * 1.0      CR14268     Sprint07    02-May-2017     Pawan Kumar Nitin Vasigala   Created Apex class and its test class
 * 2.0  Defect 3369470  Sprint08    15-May-2017     Pawan Kumar Nitin Vasigala   Revised and added boolean variable to control the deal type for Engage channel Opportunity
 * 3.0      CR15946     Sprint10    11-Jun-2018     Ravindra Babu Marripudi      Merged checkForEngageChannelPopUp() and checkForEngageChannelPopUp_new() for optimizing the Code 
 * 4.0     CR 16727     Sprint 20   25-oct-2017     Pavan Kumar                  Changed Incumbency pop up message 
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

global class OppProdIncumbencyPopup_Ctrl {
    
    public Boolean showPopUp{get;set;}
    public String incumbencyAlertMessage{get;set;}
    public Opportunity opp{get;set;}
    public Id recordTypeId;
    public Map<String,Set<String>> lobiCategoryMap;
     public Boolean changeDealTypeForEngageChannel;
    
    /* method to populate the Custom Metadata Type Map for ease of computation*/
    public void populateMetadataMap(){
        Set<String> splitSet;
        lobiCategoryMap = new Map<String,Set<String>>();
        for(LOBi_Business_Rules__mdt eachMetaRec : [SELECT Id,Label,Eligible_Product_Codes__c 
                                                    FROM LOBi_Business_Rules__mdt]){
            if( String.isNotBlank( eachMetaRec.Eligible_Product_codes__c )){
                splitSet = new Set<String>();
                splitSet.addAll(eachMetaRec.Eligible_Product_codes__c.toLowerCase().split(';'));  
                lobiCategoryMap.put(eachMetaRec.Label,splitSet);
            }
        }
    }
 
    public void checkForEngageChannelPopUp(Id oppId){
        
        recordTypeId = '012300000004zf2AAA';
        populateMetadataMap();
        System.debug('##### '+lobiCategoryMap);      
          opp = [Select Id,Name,AccountId,
                                     Account.CSG__c,Account.Networking__c,Account.Server__c,Account.Storage__c,
                                     RecordTypeId,Latest_product_id__c  from Opportunity
                                      Where Id =:oppId];
                                      
        set<String> NewlyAddedLineItems  = new set<String>();
        if(opp.Latest_product_id__c!='' && opp.Latest_product_id__c!=null){
            NewlyAddedLineItems.addAll(opp.Latest_product_id__c.split(','));    
            System.debug('#####NewlyAddedLineItems  '+NewlyAddedLineItems);         
            System.debug('$$$$$NewlyAddedLineItems.size() '+NewlyAddedLineItems.size());                                     
        if(NewlyAddedLineItems.size()>0){
        List<OpportunityLineItem> RelatedLineItems          = [Select Id,OpportunityId,Product2Id,Product2.ProductCode 
                                                                from OpportunityLineItem 
                                                                where id IN:NewlyAddedLineItems and OpportunityId=:opp.Id];               

                if(opp.RecordTypeId == recordTypeId){
                 if(opp.Account.CSG__c || opp.Account.Networking__c || 
                   opp.Account.Server__c || opp.Account.Storage__c){
                   System.debug('in 2');
                       Set<String> incumbencySet = OppProdIncumbencyPopup_Ctrl.populateIncumbencySetOfOpp(opp);
                       for(OpportunityLineItem eachOppProd : RelatedLineItems){
                           String productCode = eachOppProd.Product2.ProductCode;
                           System.debug('productCode '+productCode.toLowercase());
                           for(String eachIncumbency : incumbencySet){
                           System.debug(lobiCategoryMap.get(eachIncumbency) +' ^^^^^^^^^^ '+lobiCategoryMap.get(eachIncumbency).contains(productCode.toLowercase()));
                               if( lobiCategoryMap.get(eachIncumbency).contains(productCode.toLowercase()))  {
                                   if(!incumbencyAlertMessage.contains(eachIncumbency)){
                                      //incumbencyAlertMessage += eachIncumbency+',';   
                                     changeDealTypeForEngageChannel = true; 
                                   }
                                            showPopUp = true;
                                   }
                               }    
                           }
                       }
                   }
             }
        
        System.debug('>   showPopUp > '+showPopUp);
        if( showPopUp || Test.isRunningTest()){
            //incumbencyAlertMessage = incumbencyAlertMessage.removeEnd(',');
            incumbencyAlertMessage = System.Label.OpportunityIncumbentMessage;
            //String label = System.Label.OpportunityIncumbentMessage;
            //incumbencyAlertMessage = String.format(label, new list<String>{incumbencyAlertMessage});        
        }
        }  
    }
    
    /* Extension class Constructor which queries down the Opportunity along with its Account and 
       child OpportunityLineItem Information and compare it with Custom Metadata types map
       for incumbency check and accordingly shows pop up with a valid message put in custom label*/
    public OppProdIncumbencyPopup_Ctrl(ApexPages.StandardController ctrl){
        this();
        checkForEngageChannelPopUp(ctrl.getId());
    }
    
    /* No Arguement Constructor to be called by DealOppCreationCntl to instantiate the Controller without
        the need of ApexPages.StandardController*/
    public OppProdIncumbencyPopup_Ctrl(){
        showPopUp = false;
        incumbencyAlertMessage = '';
        changeDealTypeForEngageChannel = false;    
    }
    
    /* static method to help identify the number of incumbencies the Opportunitys Account have.
       This method collects all types of incumbencies in a set and returns it to the constructor where
       this is called*/
    static Set<String> populateIncumbencySetOfOpp(Opportunity opp){
        Set<String> tempSet = new Set<String>();
        if(opp.Account.CSG__c){
            tempSet.add('Client');
        }
        if(opp.Account.Networking__c){
            tempSet.add('Networking');
        }
        if(opp.Account.Server__c){
            tempSet.add('Server');
        }
        if(opp.Account.Storage__c){
            tempSet.add('Storage');
        }
        return tempSet;
    }
    
  public  void removeNewlyAddedIds(){  
    System.debug('closing Popup ');
    if(showPopUp ){
        opp.Latest_product_id__c = '';
         TriggerExecutionController.setSkipOpportunityTriggers(true);
       SYstem.debug( database.update( opp,false));
        SYstem.debug(opp);
        }   
    }
    
   public void checkForEngageChannelPopUp_new(Id oppId){
       checkForEngageChannelPopUp(oppId);       
    }
}