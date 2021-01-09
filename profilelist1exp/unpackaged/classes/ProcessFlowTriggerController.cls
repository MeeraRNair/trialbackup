/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13171       FY17-DCS-0701   26-May-2016     Fenny           @InvocableMethod for skipping triggers by process flow
2.0         13542       FY17-DCS-1101   18-Sep-2016     Gan             Skip Lead triggers by process flow 
3.0         14104       FY18-DCS-0403   16-Mar-2017     SriramaKrishna  Skip User triggers by Process flow
4.0         14068       FY18-DCS-0502   14-Mar-2017     SuiYee          Skip GDM triggers by Process flow
5.0         15781       FY19-DCE-0703   30-May-2018     Fenny           Skip Case triggers by Process flow
*/    
public class ProcessFlowTriggerController{
    
    public static boolean isTest = false;
    
    @InvocableMethod(label='Skip triggers by Process Flow on any Object' 
                     description='This method will skip object triggers based on the given object API name in listObjectAPINames parameter')
    public static void skipTriggers(List<string> listObjectAPINames){
        
        if(!Test.isRunningTest()|| isTest){
            
            for(string strObjectAPIName : listObjectAPINames){
                //2.0 as crumplers request
                List<string> listSubObjectAPINames = strObjectAPIName.split('[,]{1}[\\s]?');
                for(string strSubObjectAPIName : listSubObjectAPINames) {
                    skipObjectTriggers(strSubObjectAPIName);
                }
            }
        }
    }

    private static void skipObjectTriggers(string strObjectAPIName){
        
        if(strObjectAPIName.equalsIgnoreCase('Account')){
            system.debug('>>>>>>>>>> - Skipping ' + strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipAccountTriggers(true);
        }else if(strObjectAPIName.equalsIgnoreCase('Contact')){
            system.debug('>>>>>>>>>> - Skipping ' + strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipContactTriggers(true);
        }else if(strObjectAPIName.equalsIgnoreCase('Opportunity')){
            system.debug('>>>>>>>>>> - Skipping ' + strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipOpportunityTriggers(true);
        }else if(strObjectAPIName.equalsIgnoreCase('OpportunityLineItem')){
            system.debug('>>>>>>>>>> - Skipping ' + strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
            //2.0
        }else if(strObjectAPIName.equalsIgnoreCase('Lead')) {
            system.debug('>>>>>>>>>> - Skipping ' + strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipLeadTriggers(true);
        }else if(strObjectAPIName.equalsIgnoreCase('End Customer')) {
            system.debug('>>>>>>>>>> - Skipping ' + strObjectAPIName + ' triggers');
            TriggerExecutionController.setskipEndCustomerTriggers(true);
        //3.0
        }else if(strObjectAPIName.equalsIgnoreCase('User')){
            system.debug('>>>>>>>>>> - Skipping '+ strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipUserTriggers(true);
        //4.0
        }else if(strObjectAPIName.equalsIgnoreCase('GDM Request')){
            system.debug('>>>>>>>>>> - Skipping '+ strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipGDMRequestTriggers(true);
        //5.0
        }else if(strObjectAPIName.equalsIgnoreCase('Case')){
            system.debug('>>>>>>>>>> - Skipping '+ strObjectAPIName + ' triggers');
            TriggerExecutionController.setSkipCaseTriggers(true);
        }else if(strObjectAPIName.equalsIgnoreCase('S&P Vendors')){
            system.debug('>>>>>>>>>> - Skipping '+ strObjectAPIName + ' triggers');
            TriggerExecutionController.setskipSnPVendorTriggers(true);
        }
        
    }
}