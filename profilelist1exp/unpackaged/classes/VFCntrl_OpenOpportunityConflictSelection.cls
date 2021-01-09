/* 
History:
Version  Revision     Date           Modified By                     Description     
1.0       R16.07    11-Jun-2015       Devika                         Controller class for Open Opportunity Conflict found
2.0       R16.10    13-Oct-2015       Suresh                         Display rejections
3.0       R16.12    29-Dec-2015       Jiji                           CR:12513: Display Duplicate Found Label
*/

public with sharing class VFCntrl_OpenOpportunityConflictSelection {

    
    //Declare variables
    public Opportunity opp{get;set;}
    public boolean isrefresh{get;set;}    
    //List to store Current Deal Channel Product LOB splitted Value
    public List<String> CurrentSeperatedLOB = new List<String>();
    
    //Set to store Current Deal Channel Product LOB splitted Value
    public Set<String> CurrentSeperatedLOBSet = new Set<String>();
    
    //get all the OpportunityLineItems Records
     List<OpportunityLineItem > FinalOLI = new List<OpportunityLineItem > ();
    
    //get opportunityid
     String oppid=ApexPages.currentPage().getParameters().get('id'); 
   // string oppid;
    
    //List to store final Conflicted Deals
    public Set<OpportunityLineItem> conflictingOLI {get;set;}
              
    // List to store current Deal Channel Product LOB value
    List<OpportunityLineItem > currentchannelLOBs = new List<OpportunityLineItem > ();
    
    // Wrapper Class List to store conflicting deals
    public List<WrapConflictingDeals> wcList {get;set;}
    
    //Set to store conflicting LOBs
    Set<String> conflictingLOBs = new Set<String>();
    
    //List to Store selected conflict deals
    List<OpportunityLineItem> selectedConflicts;   
    
    //List of Direct Recordtypes
    List<String> DirectRT = new list<String>{'Standard Opportunity','SMB Opportunity','Run Rate Opportunity', 'Channel Opportunity'};
    
    //List of Channel Recordtypes
    List<String> ChannelRT = new list<String>{'Channel Opportunity'};
    
    Set<Opportunitylineitem> ConflictProdSet = new Set<Opportunitylineitem>();   
    public List<Opportunitylineitem> ConflictProducts {get;set;}  
    List<OpportunityLineItem> ConflictOpptys= new List<OpportunityLineItem>();
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public boolean noRecordsSelected{get;set;}
    //Ver 3.0: To check whether potential conflicts have same PA as the incoming deal:Start
    public boolean isDuplicateFound{get;set;} 
    Public Set<Id> opplineItemtoPASet = new Set<Id> (); 
    //Ver 3.0: To check whether potential conflicts have same PA as the incoming deal:End
    OpportunityLineItem multiLOBoppty;
    
    // Variables for Sorting the table headers
    /*private String defaultSortColumn = 'Product2.Channel_Product_LOB__c'; /** Set the default sort Column. **/
    /*private String sortDirection = 'DESC';
    public TableSorter_Utils wikiUTIL_Sorter {get; set;} /** Declare TableSorter_Utils class Object. **/

    // Main Class Constructor
   public VFCntrl_OpenOpportunityConflictSelection(ApexPages.StandardController controller) {
      //openOpptySelection();
      //wikiUTIL_Sorter = new TableSorter_Utils(defaultSortColumn, sortDirection); /** Create TableSorter_Utils Object. **/ 
      noRecordsSelected = false;
      isDuplicateFound = false;//Ver 3.0: To check whether potential conflicts have same PA as the incoming deal:Start
      wclist = new list<WrapConflictingDeals>();
      //get opp details
      opp = [SELECT id,name,PartnerAccount.Id ,account.name,accountid,End_User_Account_Name__c,CurrencyIsoCode,Justification_Statement__c,Total_Expected_Dell_Revenue_USD__c,Total_Expected_Dell_Revenue__c,End_User_Mailing_City__c,End_User_Mailing_State_Province_Region__c,End_User_Mailing_Country__c,PartnerAccountId,PartnerAccount.name FROM Opportunity WHERE id=:oppId ];
      //Initialize Wrapper List
      //Global Query on Opportunity Line Item for Open Opportunities
      FinalOLI = [select Id,opportunity.Quest_Software_Contact__r.MailingCity,opportunity.Quest_Software_Contact__r.MailingState,opportunity.Quest_Software_Contact__r.MailingCountry,Opportunity.PartnerAccount.Name,Opportunity.Account.Unassigned_End_User_Account__c, Product2ID,Product2.Id,Product2.Name, Product2.Channel_Product_LOB__c ,Product2.ProductCode,Product2.Description,Opportunity.End_User_Account_Name__c,Opportunity.Tier_1_Approved_Rejected__c,Opportunity.CloseDate,Opportunity.End_User_Mailing_State_Province_Region__c,Opportunity.End_User_Mailing_City__c,Opportunity.Distributor_Reseller_Name__c,
                 Opportunity.Deal_ID__c,Brand_Desc__c,Opportunity.Name,Opportunity.Conflicting_Deal_ID__c ,Opportunity.Owner.Email,Opportunity.StageName,Opportunity.PartnerAccount.ID,Opportunity.Deal_Expiration_Date__c,Opportunity.RecordType.Name
                 from OpportunityLineItem WHERE opportunity.stagename !='Win - 100%' AND  opportunity.stagename != 'Lost, Cancelled - 0%' AND opportunity.AccountId = :opp.AccountId AND Opportunity.RecordType.Name IN :DirectRT ORDER BY Product2.Channel_Product_LOB__c ];
                 //  AND Opportunity.PartnerAccountID != :opp.PartnerAccountID
      
      /*String stringFinalOLIQuery = 'select Id,Opportunity.PartnerAccount.Name,Product2ID,Product2.Id,Product2.Name, Product2.Channel_Product_LOB__c ,Opportunity.End_User_Account_Name__c,Opportunity.End_User_Mailing_State_Province_Region__c,Opportunity.End_User_Mailing_City__c, Opportunity.Deal_ID__c,Brand_Desc__c,Opportunity.Name,Opportunity.Conflicting_Deal_ID__c ,Opportunity.Owner.Email,Opportunity.StageName,Opportunity.PartnerAccount.ID,Opportunity.Deal_Expiration_Date__c from OpportunityLineItem WHERE (opportunity.stagename != ' + '\'' + 'Win - 100%' + '\'' + ' AND  opportunity.stagename != ' + '\'' + 'Lost, Cancelled - 0%' + '\'' + ' AND opportunity.AccountId =' + '\'' + opp.AccountId + '\'' + ' AND Opportunity.RecordType.Name IN : DirectRT) OR (opportunity.stagename !=' + '\'' + 'Win - 100%' + '\'' + ' AND opportunity.stagename != ' + '\'' + 'Lost, Cancelled - 0%' + '\'' + ' AND Opportunity.RecordType.Name IN :ChannelRT AND Opportunity.PartnerAccountID != ' + '\'' +  opp.PartnerAccountID + '\'' + ' AND opportunity.AccountId = ' + '\'' + opp.AccountId + '\'' + ') ORDER BY '+ wikiUTIL_Sorter.getColumn() + ' ' + wikiUTIL_Sorter.getSortDirection() +' NULLS LAST';
      system.debug('****Query: '+ stringFinalOLIQuery);
      FinalOLI = Database.query(stringFinalOLIQuery);*/
      
      conflictingOLI  = new Set<OpportunityLineItem>();        
      fetchConflictingDeals();   
      //next();  
      
    }    

    //Function to fetch Opportunity related Details
    public List<WrapConflictingDeals> fetchConflictingDeals() {
        ConflictProducts  = new List<opportunitylineitem>();
        currentchannelLOBs = [select Id,Product2ID,Opportunity.PartnerAccount.Name,Product2.Name,Quantity,Product2.Channel_Product_LOB__c ,Opportunity.End_User_Account_Name__c,Opportunity.End_User_Mailing_State_Province_Region__c,Opportunity.End_User_Mailing_City__c,
                           Opportunity.Deal_ID__c,Brand_Desc__c,Opportunity.Name,Opportunity.Owner.Email,Opportunity.StageName,Opportunity.PartnerAccount.ID,Opportunity.Deal_Expiration_Date__c
                           from OpportunityLineItem where OpportunityId = :oppId]; 
       
        //Separating the Current Channel Product LOBs   
        for(OpportunityLineItem olim : currentchannelLOBs){
            if(olim.Product2.Channel_Product_LOB__c != null){
                if(olim.Product2.Channel_Product_LOB__c.contains(',')){
                         List<String> CurrentSeperatedLOBTemp = olim.Product2.Channel_Product_LOB__c.split(','); 
                         for(String currentLOB : CurrentSeperatedLOBTemp){
                           CurrentSeperatedLOB.add(currentLOB.toUpperCase());
                         }                  
                }    
                else{
                         CurrentSeperatedLOB.add(olim.Product2.Channel_Product_LOB__c.toUpperCase());
                }  
            }
                CurrentSeperatedLOBSet.addAll(CurrentSeperatedLOB);     
        }
         
        system.debug('--- Current Deals Separated Value---'+CurrentSeperatedLOB );
         
        // Sorting and Comparision on Channel Product LOB field

        for(OpportunityLineItem ol : FinalOLI){
            system.debug('full list of OLI '+ol.brand_desc__c+' Opportunity name '+ol.Opportunity.Name+'Product Desc'+ol.Product2.Channel_Product_LOB__c);
           
            if(ol.Product2.Channel_Product_LOB__c != NULL){
            
               // Adding the common IF ELSE check
               Boolean isRejectionFound = false;
               
               // Check Rejection found for Standard/SMB/Runrate Opportunity
               If( (ol.Opportunity.RecordType.Name == 'Standard Opportunity' || ol.Opportunity.RecordType.Name == 'SMB Opportunity' || ol.Opportunity.RecordType.Name == 'Run Rate Opportunity') 
                    && ol.Opportunity.Quest_Software_Contact__c != NULL 
                    && ( (ol.Opportunity.Quest_Software_Contact__r.MailingCity != NULL && opp.End_User_Mailing_City__c != NULL && opp.End_User_Mailing_City__c.toUpperCase() == ol.Opportunity.Quest_Software_Contact__r.MailingCity.toUpperCase()) || (ol.Opportunity.Quest_Software_Contact__r.MailingState != NULL && opp.End_User_Mailing_State_Province_Region__c != NULL && opp.End_User_Mailing_State_Province_Region__c.toUpperCase() == ol.Opportunity.Quest_Software_Contact__r.MailingState.toUpperCase()) ) ){
                     
                      isRejectionFound = true;
                }
                // Check Rejection found for Channel Opportunity
                else If( ol.Opportunity.RecordType.Name == 'Channel Opportunity' && opp.PartnerAccountID != ol.Opportunity.PartnerAccountID 
                      && ((opp.End_User_Mailing_City__c != NULL && ol.Opportunity.End_User_Mailing_City__c != NULL && opp.End_User_Mailing_City__c.toUpperCase() == ol.Opportunity.End_User_Mailing_City__c.toUpperCase()) || (opp.End_User_Mailing_State_Province_Region__c != NULL && ol.Opportunity.End_User_Mailing_State_Province_Region__c != NULL && opp.End_User_Mailing_State_Province_Region__c.toUpperCase() == ol.Opportunity.End_User_Mailing_State_Province_Region__c.toUpperCase()) ) ){
                         
                         isRejectionFound = true;
                }
                if(ol.Product2.Channel_Product_LOB__c.contains(',')){
                    
                     
                     list<String> lobval = ol.Product2.Channel_Product_LOB__c.split(',');
                     Map<Id,Opportunitylineitem> oliId2OLIMap = new Map<Id,Opportunitylineitem>();
                     
                     for(String lob : lobval){
                  
                         if(CurrentSeperatedLOBSet.contains(lob.toUpperCase())){

                             conflictingLOBs.add(lob);
                             conflictingOLI.add(ol); 
                             oliId2OLIMap.put(ol.Id,ol);
                             
                             opplineItemtoPASet.add(ol.Opportunity.PartnerAccountID);//Ver 3.0: To check whether potential conflicts have same PA as the incoming deal
                             
                             
                         }                       
                     }
                     
                     for(Id oliId : oliId2OLIMap.keySet()){
                     
                          //oliId2OLIMap.get(oliId).Product2.Channel_Product_LOB__c = oliId2OLIMap.get(oliId).Product2.Channel_Product_LOB__c.replace(',' , '\n');
                     
                          wcList.add(new WrapConflictingDeals(oliId2OLIMap.get(oliId), isRejectionFound));

                     }
                     
                }
                else{
                    if(CurrentSeperatedLOBSet.contains(ol.Product2.Channel_Product_LOB__c.toUpperCase())){
                        system.debug('INSIDE ELSE'+ol.Product2.Channel_Product_LOB__c+'OLI name '+ol.brand_desc__c+' opp name ');
                        conflictingLOBs.add(ol.Product2.Channel_Product_LOB__c);
                        conflictingOLI.add(ol);
                        opplineItemtoPASet.add(ol.Opportunity.PartnerAccountID); //Ver 3.0: To check whether potential conflicts have same PA as the incoming deal
     
                        wcList.add(new WrapConflictingDeals(ol, isRejectionFound));
                       
                    }
                }
                
            }             
        }        
        //Ver 3.0: To check whether potential conflicts have same PA as the incoming deal:Start
        if(opplineItemtoPASet.Size() == 1 &&  opp.PartnerAccountID != NULL && opplineItemtoPASet.contains(opp.PartnerAccountID)){
            isDuplicateFound = True;
        }
        //Ver 3.0: To check whether potential conflicts have same PA as the incoming deal:End
        for(opportunitylineitem oli :currentchannelLOBs){
             for(String s:CurrentSeperatedLOB){
                 if(conflictingLOBs.contains(s)) 
                    ConflictProdSet.add(oli);               
             }          
        }
        Conflictproducts.addall(ConflictProdSet);
        system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!' + Conflictproducts);
        system.debug('WCLIST############' + wclist);
        //adding values to wrapper list                
       /* for(OpportunityLineItem o : conflictingOLI){
            wcList.add(new WrapConflictingDeals(o));
        } */     
        return wcList;        
    }
    
    //Method to fetch the selected Conflicting Deals
    public pagereference SelectedConflicts(){
        selectedConflicts = new List<OpportunityLineItem>();  
        //Loop to get the selected conflicts
        for(WrapConflictingDeals w :fetchConflictingDeals()){
            if(w.selected == TRUE){
                selectedConflicts.add(w.oli);
                     
            }         
        }
        System.Debug('--- Selected Opportunity Conflicts1111---'+selectedConflicts);           
        return null;
    }
    
    //Wrapper Class 
    public class WrapConflictingDeals{
        //Wrapper Variables
        public OpportunityLineItem oli {get;set;}
        public Boolean selected {get;set;}
        public Boolean rejectionFoundCheck {get;set;}
        //public Boolean duplicateFoundCheck {get;set;} // To check for duplicate Deal with same PA
        
        // Wrapper Constructor
        //To check for duplicate Deal with same PA: Start
        public WrapConflictingDeals(OpportunityLineItem ol, boolean isRejectFound){
        //public WrapConflictingDeals(OpportunityLineItem ol, boolean isRejectFound, boolean isDuplicateFound){
            oli = ol;
            selected = false;  
            rejectionFoundCheck = isRejectFound; 
            //jjduplicateFoundCheck = isDuplicateFound;
        }
        //To check for duplicate Deal with same PA: End
    }
    
   //Save Function 
   public PageReference SaveFunction(){   
     try{
       Set<String> SaveConflictingSet= new Set<String>();
       List<String> SaveConflictingList = new list<String>();
       SelectedConflicts();
             
       if(selectedConflicts.size() == 0){
           noRecordsSelected = true;
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a deal before saving the record.'));
       }
       else{          
           noRecordsSelected = false;
           Opportunity SaveConflictingIDs = new Opportunity();
           SaveConflictingIDs.Id = opp.id;       
           SaveConflictingIDs.Conflicting_Deal_ID__c = '';       
           if(selectedConflicts.size() == 1){
               SaveConflictingIDs.Conflicting_Deal_ID__c = selectedConflicts[0].Opportunity.Deal_ID__c;
             }
           else
           {           
               for(OpportunitylineItem oli: selectedConflicts){                
                   SaveConflictingSet.add(oli.Opportunity.Deal_ID__c);
               
               }
               SaveConflictingList.addall(SaveConflictingSet);
               SaveConflictingIDs.Conflicting_Deal_ID__c = String.join(SaveConflictingList,';');                              
           }
           
     // Condition to populate Rejection reason Code base on the opportunity record type    
            If(selectedConflicts[0].Opportunity.RecordType.Name == 'Channel Opportunity'){            
                   SaveConflictingIDs.Rejection_Reason_Code__c = 'Registered to Another Partner';
                }
            else if(String.isBlank(SaveConflictingIDs.Rejection_Reason_Code__c) || SaveConflictingIDs.Rejection_Reason_Code__c <> 'Dell Sales forecasted opportunity'){                          
                   SaveConflictingIDs.Rejection_Reason_Code__c = 'Direct Sales forecasted opportunity';   
                }
     upsert SaveConflictingIDs;               
          // PageReference pageRedirect = new PageReference('/'+oppID);
          // pageRedirect.setRedirect(true);
          // return pageRedirect;    
          //return new PageReference('javascript:window.close();');   
          isrefresh = true;         
       }   
        return null;
      }
      catch(exception e){
          system.debug('Catch Exception#########' + e);
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, string.valueOf(e) ));
          return null;
      }  
   }
   
   //Cancel Function
   public PageReference CancelFunction(){
       PageReference pageRef = new PageReference('/'+oppID);
       pageRef.setRedirect(true);
       return pageRef;
   }
   
   
   /******************************* Custom Pagination ****************************/
   
   /*Integer i =0; 
   public Integer setPageSize = Integer.valueOf(System.Label.Open_Opportunity_Conflict_Page_Size); 
   public List<WrapConflictingDeals> oliListRequested {get;set;}
   
   public Boolean hasNext(){
        
          if(i >= wcList.size()) {
               return false; 
           } else {
               return true; 
           }
        
    }
    
    public Boolean hasPrevious() {
        
          if(i <= setPageSize) {
               return false; 
           } else {
               return true; 
           }
       
    }
    
    public Boolean hasNext {
        get {
            return hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return hasPrevious();
        }
        set;
    }
  
    public PageReference next(){       
       system.debug('i value is ' + i);
       oliListRequested = new list<WrapConflictingDeals>(); 
       integer startNumber;
       integer size = wcList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
           
           system.debug('i value is =====' + i);
           system.debug('i value is 2==== ' + (i - setPageSize));
           
           for(integer start = startNumber; start < i; start++)
           {
               oliListRequested.add(wcList[start]);
           }
       } 
       return null;
   } 
   
   public PageReference previous(){    
       oliListRequested = new list<WrapConflictingDeals>(); 
       system.debug('i value is previous before =====' + i);
       integer size = wcList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       system.debug('i value is previous =====' + i);
       system.debug('i value is 2previous ==== ' + (i - setPageSize));
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           oliListRequested.add(wcList[start]);
       } 
       return null;
   }   */

}