/***********************************************************************

Author      : Devika Pujari
Description : Class to retrieve Account Id values for custom objects not
              related to Account object

Revision  Name            Date            Description
------------------------------------------------------------
*1.0      Devika          23.01.2013      CR 8978 - OMGO WF 15.03


************************************************************************/
public class RecordObjectMap{

    public RecordObjectMap(){      
    }

    public String getObjectName(String recordId){
        try{
            Related_To_Map__c relMap = Related_To_Map__c.getValues(recordId.subString(0,3));

            if(relMap != null){      
                string soqlQuery = 'Select '+ relMap.Account_FieldName__c + ' From ' + relMap.Object_Name__c + ' Where Id = \'' + recordId + '\'';
                List<sObject> soqlResult = Database.query(soqlQuery);     
                if(soqlResult.size() > 0){
                    List<String> accRelSplit = relMap.Account_FieldName__c.split('\\.');                                                                  
                    integer cnt = 1;            
                    sObject AccRelObj = soqlResult[0];
                    
                    for (String strRel : accRelSplit){
                        if (cnt == accRelSplit.size()){
                            return String.ValueOf(AccRelObj.get(strRel));                   
                        }
                        else{
                            AccRelObj = AccRelObj.getSObject(strRel);
                        }
                        cnt++;
                    }
                }                
            }        
        }catch(exception e){
            system.debug('***'+e);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'An Error occured on the Account Name Pre-Populate');
            ApexPages.addMessage(myMsg);     
        }
        return null;
    }  
}