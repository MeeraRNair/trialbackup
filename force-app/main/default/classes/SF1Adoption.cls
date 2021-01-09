/*
 * Author   : Swathi
 * Purpose  : SF1 Adoption class to capture user actions(Create/Edit) when done through mobile or browser.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 *   1.0    CR12683     FY17-DCS-0401   29-Feb-2016     Swathi          Created for implementing "User action tracking" functionality
 *   2.0    CR13154     FY17-DCS-0602   24-May-2016     Emily           Removed Browser action tracking and exclude Integration/PRM profiles
 * -------- ---------   ----------      -----------     ------------    -----------------------------------------------------------------------------------
 * 
 * 
 */
 
public class SF1Adoption{

 
    public SF1Adoption(){
    
    } 
   
    public static void trackSF1Usage(List<sobject> listAllRecords, String strAction ){
        String strObjectName;
        String strObjectLabel;
        
        List<Schema.DescribeSObjectResult> listDescribeSobjectsResult = New List<Schema.DescribeSObjectResult>();
        Id idProfileId=userinfo.getProfileId();         
        
        List<Profile> strProfileName=[Select Id, Name from Profile where Id = :idProfileId limit 1];       
        //v2.0
        if(strProfileName[0].Name != 'IT GBL Data Load'
            && (!strProfileName[0].Name.contains('PRM'))
            && (!strProfileName[0].Name.contains('Integration'))
            && (!strProfileName[0].Name.contains('API'))){
        
            list<SF1_Adoption__c> listAdoption = New List<SF1_Adoption__c>();
            
            try{
           
                strObjectName = listAllRecords.getSObjectType().getDescribe().getName();                
                listDescribeSobjectsResult = Schema.describeSObjects(new List<String>{strObjectName});
                strObjectLabel = listAllRecords.getSObjectType().getDescribe().getKeyPrefix();
                
            }
            catch(System.NullPointerException e){
            
            }             
            
            for(sobject sobjectEachRecord :listAllRecords){ 
               
                String strCurrentRequestURL = URL.getCurrentRequestUrl().toExternalForm(); 
                system.debug('strCurrentRequestURL'+strCurrentRequestURL);
                string strAura = 'aura';                       
                SF1_Adoption__c newAdoptionRecord = New SF1_Adoption__c();
                
                if(Test.isRunningTest()){
                    strCurrentRequestURL = 'https://cs50.salesforce.com/aura';
                }
                
                if(strCurrentRequestURL.contains(strAura)){
                                        
                    if(strObjectName == 'SFDC_Acct_Plan__c' ){
                        newAdoptionRecord.Object_Name__c ='Account Plans';
                    }
                    else if(strObjectName == 'CustomerInteraction__c')
                    {
                        newAdoptionRecord.Object_Name__c ='Trip Report'; 
                    }                        
                    else
                    {
                        newAdoptionRecord.Object_Name__c = strObjectName;
                    }              
                    
                    newAdoptionRecord.User_Edited_Date__c = system.Now();
                    newAdoptionRecord.Record_ID__c = sobjectEachRecord.id; 
                    newAdoptionRecord.Source__c = 'Mobile';                       
                    
                    if(strAction == 'AfterInsert'){           
                        newAdoptionRecord.User_Action__c = 'Create';          
                        newAdoptionRecord.User_Name__c = (String)sobjectEachRecord.get('CreatedById');
                        
                        listAdoption.add(newAdoptionRecord);
                    }            
                    else{ 
                        datetime dtCreatedDate = (datetime)sobjectEachRecord.get('CreatedDate');
                        datetime dtCreatedDateAddMin;
                        try{
                            dtCreatedDateAddMin = dtCreatedDate.addminutes(1); 
                        }catch(System.NullPointerException e){
                        
                        }
                        
                        if(dtCreatedDateAddMin <= (datetime)sobjectEachRecord.get('LastModifiedDate') && 
                                (strObjectLabel == '003' || 
                                    strObjectLabel == '00T' || 
                                    strObjectLabel == '006' || 
                                    strObjectLabel == 'a0D' || 
                                    strObjectLabel == '00U')){               
                                
                            newAdoptionRecord.User_Action__c = 'Edit';                                         
                            newAdoptionRecord.User_Name__c = (String)sobjectEachRecord.get('LastModifiedById');
                             
                            listAdoption.add(newAdoptionRecord);
                        }
                        else { 
                             if(strObjectLabel != '003' && 
                                 strObjectLabel != '00T' && 
                                 strObjectLabel != '006' && 
                                 strObjectLabel != 'a0D' && 
                                 strObjectLabel != '00U'){
                                
                                newAdoptionRecord.User_Action__c = 'Edit';                          
                                newAdoptionRecord.User_Name__c = (String)sobjectEachRecord.get('LastModifiedById');
                               
                                listAdoption.add(newAdoptionRecord);
                            }
                        }
                    }                               
                }
            }
            if (listAdoption.size() > 0){
                insert listAdoption;
            }         
        }
    }    
}