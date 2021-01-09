/*
* Author   : Sneha
* Purpose  : Helper Class for Qualified Programs which handles all the methods.
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR# 4161253 0203        12-Dec-2017     Sneha           Created for implementing trigger architecture - Best practices
* 2.0      CR# 5873250 0202        04-Dec-2018     Chethana        Display non NBI channel Programs in Channel Program Field on Opportunity Product
* 3.0      CR# 6095382 0402        28-Jan-2019     Chethana        Adding HCI and UDS to NBI Incentive category field
*/


public class QualifiedProgramTriggerHelper {
    
    public static void updateOpportunityLineItemWithNBIRelatedInfo(List<Qualified_Program__c> listNewRecords,String strMode){
        System.debug('Entered UpdateOpportunityLineItemWithNBIRelatedInfo::'+listNewRecords.size());
        // To hold the Opportunity Ids 
        Set<String> setOpptyIds = new Set<String>();
        //To hold List of Qualified Programs for a Opportunity
        Map<String,List<Qualified_Program__c>> mapOpptyWithQP = new Map<String,List<Qualified_Program__c>>();
        //To hold List of OpportunityLineItem for a Opportunity
        Map<String,List<OpportunityLineItem>> mapOpptyWithLineItems = new Map<String,List<OpportunityLineItem>>();
        //To hold Oppty Line Items
        List<OpportunityLineItem> listOpptyLineItems = new List<OpportunityLineItem>();
        // To hold the Oppty Line Items to update
        Map<String,OpportunityLineItem> mapOpptyLineItem = new Map<String,OpportunityLineItem>();
        // To hold the Valid NBI Category Name
        Set<String> setValidNBICategory = new Set<String>();
        for(String str : System.Label.NBI_Category_Values.split(';')) {
            setValidNBICategory.add(str);
        }
        for(Qualified_Program__c qp : listNewRecords){
            if(qp.Opportunity__c != null){
                // setOpptyIds.add(qp.Opportunity__c);
                // Populate the Map of Oppty with Qualified Programs
                if(mapOpptyWithQP.containsKey(qp.Opportunity__c)){
                    mapOpptyWithQP.get(qp.Opportunity__c).add(qp);
                }
            else {
                mapOpptyWithQP.put(qp.Opportunity__c, new List<Qualified_Program__c>{qp});
            }
          }
        }
        
        //Query Oppty Line Items
        if(mapOpptyWithQP.size() > 0){
            listOpptyLineItems = [SELECT Id, OpportunityId, Product2Id,NBI_Category_Map__c,NBI_Category__c,Product2.NBI_Category__c,Product2.NBI_Eligible__c,Channel_Program_Name__c  
                                  FROM OpportunityLineItem 
                                  WHERE OpportunityId IN : mapOpptyWithQP.keySet() ];
            
        }
        
        if(listOpptyLineItems.size() > 0){
            for(OpportunityLineItem olt : listOpptyLineItems){
                if(mapOpptyWithLineItems.containskey(olt.OpportunityId)){
                    mapOpptyWithLineItems.get(olt.OpportunityId).add(olt);
                }
                else{
                    mapOpptyWithLineItems.put(olt.OpportunityId,new List<OpportunityLineItem>{olt});
                }
            }
            System.debug('@@@mapOpptyWithLineItems::'+mapOpptyWithLineItems.size());
            System.debug('@@@mapOpptyWithLineItems Details::'+mapOpptyWithLineItems);
        }
        
        for(Qualified_Program__c qp : listNewRecords){
            if(qp.Opportunity__c != null && String.isNotBlank(qp.Deal_Program__c) && mapOpptyWithLineItems.containskey(qp.Opportunity__c) && mapOpptyWithQP.containskey(qp.Opportunity__c)){
                // If the Oppty Id existing in both Map
                //if(mapOpptyWithLineItems.containskey(qp.Opportunity__c) && mapOpptyWithQP.containskey(qp.Opportunity__c))
                    System.debug('@@@ Update Opty Line Item for NBI');
                    // Update the Oppty Line Item
                    for(OpportunityLineItem opptyLineItem : mapOpptyWithLineItems.get(qp.Opportunity__c)){
                        if(String.isNotBlank(qp.Product__c) && qp.Product__c == opptyLineItem.Product2Id && strMode == 'Insert'){
                            System.debug('line 74'+ strMode +'------------------------'+opptyLineItem );
                            //if(strMode == 'Insert')
                                System.debug('Prior Value of NBI_Category__c::'+opptyLineItem.NBI_Category__c);
                                System.debug('Prior Value of NBI_Category_Map__c::'+opptyLineItem.NBI_Category_Map__c);
                                
                                OpportunityLineItem newrecord = QualifiedProgramTriggerHelper.includeNBICategory(opptyLineItem,qp);
                                mapOpptyLineItem.put(newrecord.Id,newrecord);
                                // mapOpptyLineItem.put(opptyLineItem.Id,opptyLineItem);

                               }
                            else if(String.isNotBlank(qp.Product__c) && qp.Product__c == opptyLineItem.Product2Id && strMode == 'Delete'){
                                System.debug('Delete Mode');
                                System.debug('NBI Category'+opptyLineItem.NBI_Category__c+'strExistingCategory::'+opptyLineItem.NBI_Category_Map__c+'Deal Program::'+qp.Deal_Program_Name__c);
                                if(String.isNotBlank(opptyLineItem.NBI_Category_Map__c)){
                                  opptyLineItem.NBI_Category_Map__c = QualifiedProgramTriggerHelper.excludeNBICategory(String.valueOf(opptyLineItem.NBI_Category_Map__c),qp);
                                    System.debug('Value after deletion of NBI_Category_Map__c'+opptyLineItem.NBI_Category_Map__c);
                                    //mapOpptyLineItem.put(opptyLineItem.Id,opptyLineItem);
                                }
                                if(String.isNotBlank(opptyLineItem.NBI_Category__c)){
                                    opptyLineItem.NBI_Category__c = QualifiedProgramTriggerHelper.excludeNBICategory(String.valueOf(opptyLineItem.NBI_Category__c),qp);
                                    System.debug('Value after deletion of NBI_Category__c'+opptyLineItem.NBI_Category__c);
                                    // mapOpptyLineItem.put(opptyLineItem.Id,opptyLineItem);
                                
                                }
                                if(String.isNotBlank(opptyLineItem.channel_program_name__c)){
                                    opptyLineItem.channel_Program_name__c = QualifiedProgramTriggerHelper.excludeNBICategory(String.valueOf(opptyLineItem.channel_program_name__c),qp);
                                    // mapOpptyLineItem.put(opptyLineItem.Id,opptyLineItem);
                                
                                }
                                mapOpptyLineItem.put(opptyLineItem.Id,opptyLineItem);
                                System.debug('Updated Value of NBI_Category__c::'+opptyLineItem.NBI_Category__c);
                                System.debug('Updated Value of NBI_Category_Map__c::'+opptyLineItem.NBI_Category_Map__c);
                                
                            }
                        
                    }
                
                
            }
            
        }
        //5665125- Chethana Pormuni-Avoiding Duplicates to store in NBI incentive cateogory and NBI category
        if(mapOpptyLineItem.size()>0){
 
            for(OpportunityLineItem opl : mapOpptyLineItem.values()){
            set<string> setDupvalues = new set<string>();
            string str = opl.NBI_Category_Map__c;
            system.debug('-----------'+str);
            string strNew='';
            if(str != null && str != ''){
                for(string strDup : str.split(';')){
                  system.debug('11111111111111'+strDup);
                      if(setDupvalues.add(strDup)){                       
                         strNew+= strDup+';';
                        }
                }
            }  
            opl.NBI_Category_Map__c = strNew.removeEnd(';');
            }

            for(OpportunityLineItem oplne : mapOpptyLineItem.values()){
            set<string> setNBIdupvalues = new set<string>();
            string strOpp = oplne.NBI_Category__c;
            system.debug('-----------'+strOpp);
            string strNewopl='';
            if(strOpp!= null && strOpp!= ''){
                for(string strNg : strOpp.split(';')){
                  system.debug('11111111111111'+strNg);
                      if(setNBIdupvalues.add(strNg)){                       
                         strNewopl+= strNg+';';
                    }
                }
            }
            oplne.NBI_Category__c= strNewopl.removeEnd(';');
            }
            
            // Skip OpptyLineItems Trigger execution
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
            Database.SaveResult[] listSr = Database.update(mapOpptyLineItem.values(), false);
            // Iterate through each returned result
            for (Database.SaveResult sr : listSr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated OpportunityLineItemTriggers ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('QP fields that affected this error: ' + err.getFields());
                        // To display the Error.
                        //listNewRecords[0].adderror('Invalid value of Channel Program Name');
               
                    }
                }
            } 
        }
    }
    
    public static String excludeNBICategory(String strExistingcategory,Qualified_Program__c deletedRecord)
    {
            System.debug('in excludeNBICategory method'+strExistingcategory+deletedRecord);
  
        Set<String> setUniqueNBICategory = new Set<String>();
        String strupdatedCategory='';
            if(String.isNotBlank(strExistingcategory))
            {
                for(String str : strExistingcategory.split(';')) {
                    setUniqueNBICategory.add(str);
                }
            System.debug('setUniqueNBICategory'+setUniqueNBICategory);
            //if(setUniqueNBICategory.size() > 0)
                //if(String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category))
                
                    if(setUniqueNBICategory.size() > 0 && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category) && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Client)){
                       setUniqueNBICategory.remove(System.Label.NBI_Client);
                    }
                    else if(setUniqueNBICategory.size() > 0 && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category) && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Server)){
                     setUniqueNBICategory.remove(System.Label.NBI_Server);
                    }
                    else if(setUniqueNBICategory.size() > 0 && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category) && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Networking)){
                     setUniqueNBICategory.remove(System.Label.NBI_Networking); 
                    }
                    else if(setUniqueNBICategory.size() > 0 && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category) && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Storage)){
                     setUniqueNBICategory.remove(System.Label.NBI_Storage); 
                    }
                    else if(setUniqueNBICategory.size() > 0 && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category) && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_UDS)){
                     setUniqueNBICategory.remove(System.Label.NBI_UDS); 
                    }
                    else if(setUniqueNBICategory.size() > 0 && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category) && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_HCI)){
                     setUniqueNBICategory.remove(System.Label.NBI_HCI); 
                    }
                    else if(setUniqueNBICategory.size() > 0 && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().contains(System.Label.NBI_Incentive_Category) && String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Data_Protection)){
                                         setUniqueNBICategory.remove(System.Label.NBI_Data_Protection); 
                    }                    
        /*else if(String.Valueof(deletedRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Data_Protection)){
          setUniqueNBICategory.remove(System.Label.NBI_Data_Protection); 
        }*/
         //To remove Program names which contain NBI but none of the above Business Lines
                else
                {
                 setUniqueNBICategory.remove(deletedRecord.Deal_Program_Name__c);
                }
                
                
                
                
            System.debug('setUniqueNBICategoryafter removal::'+setUniqueNBICategory);
            
            if(setUniqueNBICategory.size() > 0){
                for(String str : setUniqueNBICategory){
                   strupdatedCategory+= str+';'; 
                }
                
            System.debug('@@112'+strupdatedCategory);
            
            if(String.IsNotBlank(strupdatedCategory)){
              strupdatedCategory= strupdatedCategory.removeEnd(';');
                System.debug('@@115'+strupdatedCategory);
              //return String.valueOf(strupdatedCategory);
              
            }
            // if not value exists update to null
            
                else
                {
            System.debug('@@in else'+strupdatedCategory);
              //return String.valueOf(strupdatedCategory);
                }
            }
            
                else{
                  strupdatedCategory='';
            //return '';
            
                }
            
            
           } 
        return String.valueOf(strupdatedCategory);
    }
    
    public static OpportunityLineItem includeNBICategory(OpportunityLineItem opptyLineItem,Qualified_Program__c insertRecord){
          
        set<string> setDupstrng = new set<string>();
        
            //if(opptyLineItem != null)
            

                    //This field will be sent to EBI.
            if(opptyLineItem != null && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Client))
            {
                    //To check if the value already exists
                   
            //if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))
            
       
                if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category) && String.isNotBlank(opptyLineItem.NBI_Category_Map__c))
                {                
                 opptyLineItem.NBI_Category_Map__c = opptyLineItem.NBI_Category_Map__c+';'+ System.Label.NBI_Client;               
                }
            else 
            {
               opptyLineItem.NBI_Category_Map__c = System.Label.NBI_Client;  
            } 
      
            if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category) && String.isNotBlank(opptyLineItem.NBI_Category__c))
            {
                opptyLineItem.NBI_Category__c = opptyLineItem.NBI_Category__c+';'+ System.Label.NBI_Client; 
            }
            
            else 
            {
                opptyLineItem.NBI_Category__c = System.Label.NBI_Client;  
            }
          
            
      
            }
            else if(opptyLineItem != null && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Server) && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))           
            {
      
                //if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))
                
         
                    if(String.isNotBlank(opptyLineItem.NBI_Category_Map__c))
                    {
                        opptyLineItem.NBI_Category_Map__c = opptyLineItem.NBI_Category_Map__c+';'+ System.Label.NBI_Server;
                    }
              
                    else 
                    {
                        opptyLineItem.NBI_Category_Map__c = System.Label.NBI_Server; 
                    }
                      
            if(String.isNotBlank(opptyLineItem.NBI_Category__c)) 
            {
                opptyLineItem.NBI_Category__c = opptyLineItem.NBI_Category__c+';'+ System.Label.NBI_Server; 
            }
            else 
            {
                opptyLineItem.NBI_Category__c = System.Label.NBI_Server; 
            }
            
            
            }
            else if(opptyLineItem != null && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Networking) && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category)){
            
            //if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))
      
                if(String.isNotBlank(opptyLineItem.NBI_Category_Map__c)){
                    opptyLineItem.NBI_Category_Map__c = opptyLineItem.NBI_Category_Map__c+';'+ System.Label.NBI_Networking;
           }
            else {
                opptyLineItem.NBI_Category_Map__c = System.Label.NBI_Networking; }
                
            if(String.isNotBlank(opptyLineItem.NBI_Category__c)) {
                    opptyLineItem.NBI_Category__c = opptyLineItem.NBI_Category__c+';'+ System.Label.NBI_Networking; }
            else {
                opptyLineItem.NBI_Category__c = System.Label.NBI_Networking; 
            }
            
        
      
      
        }
            else if(opptyLineItem != null && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Storage) && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category)){
      
                //if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))
      
                    if(String.isNotBlank(opptyLineItem.NBI_Category_Map__c)){
                        opptyLineItem.NBI_Category_Map__c = opptyLineItem.NBI_Category_Map__c+';'+ System.Label.NBI_Storage;
          }
                else {
                 opptyLineItem.NBI_Category_Map__c = System.Label.NBI_Storage;  
                 }
                 
                if(String.isNotBlank(opptyLineItem.NBI_Category__c)) {
                opptyLineItem.NBI_Category__c = opptyLineItem.NBI_Category__c+';'+ System.Label.NBI_Storage;  
            }
                else {
                opptyLineItem.NBI_Category__c = System.Label.NBI_Storage; 
            }
          
        
    }
    // 5967682- Chethana Pormuni- "Adding HCI and UDS to NBI Incentive category field"
    else if(opptyLineItem != null && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_UDS) && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category)){
      
      //if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))
      
          if(String.isNotBlank(opptyLineItem.NBI_Category_Map__c)){
                opptyLineItem.NBI_Category_Map__c = opptyLineItem.NBI_Category_Map__c+';'+ System.Label.NBI_UDS;
          }
             else {
                 opptyLineItem.NBI_Category_Map__c = System.Label.NBI_UDS;  
                 }
                 
          if(String.isNotBlank(opptyLineItem.NBI_Category__c)) {
            opptyLineItem.NBI_Category__c = opptyLineItem.NBI_Category__c+';'+ System.Label.NBI_UDS;  
            }
          else {
            opptyLineItem.NBI_Category__c = System.Label.NBI_UDS; 
            }
          
        
    }
    //5967682- Chethana Pormuni- "Adding HCI and UDS to NBI Incentive category field"
    else if(opptyLineItem != null && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_HCI) && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category)){
      
      //if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))
      
          if(String.isNotBlank(opptyLineItem.NBI_Category_Map__c)){
                opptyLineItem.NBI_Category_Map__c = opptyLineItem.NBI_Category_Map__c+';'+ System.Label.NBI_HCI;
          }
             else {
                 opptyLineItem.NBI_Category_Map__c = System.Label.NBI_HCI;  
                 }
                 
          if(String.isNotBlank(opptyLineItem.NBI_Category__c)) {
            opptyLineItem.NBI_Category__c = opptyLineItem.NBI_Category__c+';'+ System.Label.NBI_HCI;  
            }
          else {
            opptyLineItem.NBI_Category__c = System.Label.NBI_HCI; 
            }
          
        
    }
     else if(opptyLineItem != null && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Data_Protection) && String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category)){
      
      //if(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))
      
          if(String.isNotBlank(opptyLineItem.NBI_Category_Map__c)){
                opptyLineItem.NBI_Category_Map__c = opptyLineItem.NBI_Category_Map__c+';'+ System.Label.NBI_Data_Protection;
          }
             else {
                 opptyLineItem.NBI_Category_Map__c = System.Label.NBI_Data_Protection;  
                 }
                 
          if(String.isNotBlank(opptyLineItem.NBI_Category__c)) {
            opptyLineItem.NBI_Category__c = opptyLineItem.NBI_Category__c+';'+ System.Label.NBI_Data_Protection;  
            }
          else {
            opptyLineItem.NBI_Category__c = System.Label.NBI_Data_Protection; 
            }
          
        
    }
       
      /*5665125  - Display non NBI channel Programs in Channel Program Field on Opportunity Product . (Programs which does not have "NBI" in their name) start*/
       if(!(String.Valueof(insertRecord.Deal_Program_Name__c).trim().containsIgnoreCase(System.Label.NBI_Incentive_Category))){
          if(String.isNotBlank(opptyLineItem.channel_program_Name__c )) {
            opptyLineItem.channel_Program_name__c= opptyLineItem.channel_program_Name__c +';'+ insertRecord.Deal_Program_Name__c; 
            }
          else {
                 opptyLineItem.channel_Program_name__c=  insertRecord.Deal_Program_Name__c ; 
            }
          
        }   
        /*5665125  -  end*/
         
       
        
         return opptyLineItem;
}
    
    }