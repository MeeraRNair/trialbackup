/*

History:
    
    Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     12-Oct-2010     Raymond         Created
...     ...             ...             ...
2.0     07-Aug-2012     KP              R13.7, Fix for Defect #39015;prevent showing message, when delivery date input box is not displayed.
        12-Dec-2018     Hari  A           STORY 5907651 Removed reference for the field total_aggregated_volume__c 
*/

public class OceanLOTMandatoryFieldInputController {
        
    String oldQuoteNumber;
    Double oldHowManyShipments;
    Date oldCustomerRequestedDate;
    Decimal oldTotalAggregatedVolume;
    String oldIsCFIIncluded;
    //DE-SCOPED for Release 12.1 String oldDirectTrailerOppty;
    String oldStageName;
    Decimal oldProbability;
    String calcDeliveryDate = ' ';
        
    public boolean toPursue = false;
    @TestVisible private boolean noPursueOption = false;
    
    ApexPages.StandardController controller;

    public OceanLOTMandatoryFieldInputController(ApexPages.StandardController controller) {
        this.controller = controller;
        Opportunity tempOppty = (Opportunity)controller.getRecord();
        oldQuoteNumber = tempOppty.Quote_Numbers__c;
        oldHowManyShipments = tempOppty.How_many_shipments__c;
        oldCustomerRequestedDate = tempOppty.Customer_Requested_Delivery_Date__c;
        oldIsCFIIncluded = tempOppty.Is_CFI_included__c;
        oldStageName = tempOppty.StageName;
        oldProbability = tempOppty.Probability;     
        
        PageReference pageRef = ApexPages.currentPage();
        Map<String, String> params = pageRef.getParameters();

        if(params.get('pursue') == 'true') {    
            toPursue = true;
        } else if(params.get('pursue') == null) {           
            noPursueOption = true;          
        }
    }
       
    public String getEligibleToMessage() {
        Opportunity currentOppty = (Opportunity)controller.getRecord();
        String str = '';
        
        //LOT ONLY
        if(currentOppty.LOT_Mandatory_Fields__c && !(currentOppty.Eligible_for_Ocean__c == 'Yes')) {
            str='This Opportunity has been identified as a Large Order and requires Quote Number to be populated. Clicking \'Cancel\' will result in the Opportunity not being marked as LOT and the Stage / Probability will be reduced to 30%.';
        }
        
        //OCEAN ONLY
        /* 2.0 */
        //if(!currentOppty.LOT_Mandatory_Fields__c && currentOppty.Eligible_for_Ocean__c == 'Yes') {
         if(currentOppty.Eligible_for_Ocean__c == 'Yes' && currentOppty.Customer_Requested_Delivery_Date__c == null  &&  !currentOppty.LOT_Mandatory_Fields__c ) {
            str = 'You have chosen to pursue Ocean shipping and this requires Customer Requested Delivery Date to be populated.';
        }
        
        //LOT and OCEAN
        if(currentOppty.LOT_Mandatory_Fields__c && currentOppty.Eligible_for_Ocean__c == 'Yes' && toPursue) {
            str = 'This Opportunity has been identified as a Large Order or eligible to pursue Ocean shipping. Please populate Quote Number and Customer Requested Delivery Date. Clicking \'Cancel\' will result in the Opportunity not being marked as LOT, not being marked to pursue Ocean, and the Stage / Probability will be reduced to 30%.';
        }
        
        //LOT but decided not to pursue OCEAN
        if(currentOppty.LOT_Mandatory_Fields__c && currentOppty.Eligible_for_Ocean__c == 'Yes' && !toPursue) {
            str = 'This Opportunity has been identified as a Large Order and requires Quote Number to be populated. Clicking \'Cancel\' will result in the Opportunity not being marked as LOT and the Stage / Probability will be reduced to 30%.';
        }
        
        return str;
    }
    
    // CR3366: Defect 65776 - Init calcDeliveryDate with the current Datetime in long date format
    public String getCalcDeliveryDate() {
        Opportunity currentOppty = (Opportunity)controller.getRecord();
        Datetime DT = DateTime.valueOf(currentOppty.Calculated_Delivery_Date__c + '00:00:00');
        calcDeliveryDate = DT.format('d MMMM yyyy');
        return calcDeliveryDate;
    }
    
    public PageReference doSave() {
        Opportunity currentOppty = (Opportunity)controller.getRecord();
        if(currentOppty.Quote_Numbers__c == null || currentOppty.How_many_shipments__c == null  
            || currentOppty.Customer_Requested_Delivery_Date__c == null) {
            
            Boolean returnNull = false;
            
            //Added LOT_Mandatory_Fields__C for CR4118, to remove dependency of Quote Numbers and OCEAN
            if(currentOppty.Quote_Numbers__c == null && currentOppty.LOT_Mandatory_Fields__c) {
                ApexPages.addMessages(new dellUtil.dellException('Quote Number(s): This field must not be null'));
                returnNull = true;
            }
            
             /*******Modification for CR 2810*****************/
            if(currentOppty.Customer_Requested_Delivery_Date__c == null && currentOppty.Eligible_for_Ocean__c == 'Yes' && currentOppty.Do_you_want_to_pursue_Ocean__c == 'Yes') {
                ApexPages.addMessages(new dellUtil.dellException('Customer Requested Delivery Date: This field must not be null'));
                returnNull = true;
            }
            
            if(currentOppty.How_many_shipments__c == null) {                
                ApexPages.addMessages(new dellUtil.dellException('Number of Shipments / Deliveries?: This field must not be null'));
                returnNull = true;
            }
                                    
            if(currentOppty.How_many_shipments__c > 1) {             
                ApexPages.addMessages(new dellUtil.dellException('Largest Volume to be Delivered is mandatory when Number of Shipments / Deliveries is more than 1'));
                returnNull = true;
            }
            
            if (returnNull) {
                return null;
            }
        }
        
        if(currentOppty.Customer_Requested_Delivery_Date__c != null && currentOppty.Customer_Requested_Delivery_Date__c < currentOppty.CloseDate) {
            ApexPages.addMessages(new dellUtil.dellException('Customer Requested Delivery Date: Customer Requested Delivery Date should not be earlier than the Book Date.'));
            return null;
        }
        
        if(currentOppty.LOT_Mandatory_Fields__c) {
            currentOppty.LOT_Large_Opportunity__c = true;
            currentOppty.LOT_Mandatory_Fields__c = false;
        }
        
        if(currentOppty.Eligible_for_Ocean__c == 'Yes' && currentOppty.Ocean_Opportunity_Notification_Pop_Up__c) {
            currentOppty.Ocean_Opportunity_Notification_Pop_Up__c = false;
            
            if(!noPursueOption) {                  
                if (toPursue)
                {
                    currentOppty.Do_you_want_to_pursue_Ocean__c = 'Yes';
                }
                else
                {        
                    currentOppty.Do_you_want_to_pursue_Ocean__c = 'No';
                }
            }
        }       
        
        try {
            GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION = true;
            update currentOppty;
            GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION = false;
            return new PageReference('/'+currentOppty.Id);  
        } catch(Exception e) {
            ApexPages.addMessages(e);
            System.debug('###DEBUG### Exception in OceanLOTMandatoryFieldInput - '  + e);
            return null;
        }
        
    }
    
    public PageReference doCancel() {
        Opportunity currentOppty = (Opportunity)controller.getRecord();     
               
        currentOppty.Quote_Numbers__c = oldQuoteNumber;
        currentOppty.How_many_shipments__c = oldHowManyShipments;
        currentOppty.Customer_Requested_Delivery_Date__c = oldCustomerRequestedDate;
        currentOppty.Is_CFI_included__c = oldIsCFIIncluded;     
        currentOppty.StageName = oldStageName;
        currentOppty.Probability = oldProbability;  
            
        //currentOppty.LOT_Mandatory_Fields__c = false;
        
        //CR#8979 - Defect#97050 - Sree Prakash on 25 Feb 2014.
        if(currentOppty.StageName == 'Qualify - 30%'){
            currentOppty.Probability = 30;
            currentOppty.Probability_Currently_Overridden__c = false;
        }
        
        //CR 4188: Cancelling LOT sets Stage to 30% when Deal is actually less than that      
        if (currentOppty.LOT_Mandatory_Fields__c  && (currentOppty.StageName == 'Propose - 60%' || currentOppty.StageName == 'Commit - 90%'))
        {
            currentOppty.StageName = 'Qualify - 30%';
            currentOppty.Probability = 30;
            currentOppty.Probability_Currently_Overridden__c = false;
            currentOppty.Region__c='APJ';
            currentOppty.Competitor_Lost_To__c='Unknown';
        }   
         
        currentOppty.LOT_Mandatory_Fields__c = false;
         
        currentOppty.LOT_Large_Opportunity_Potential__c = true;
        currentOppty.Do_you_want_to_pursue_Ocean__c = 'No';
        
        currentOppty.Ocean_Opportunity_Notification_Pop_Up__c = false;

        try {
            GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION = true;
            currentOppty.Skip_Calculate_LOT_OCEAN__c= true;     
            System.debug('###Debug### Carmen before update Skip_Calculate_LOT_OCEAN__c ' +currentOppty.Skip_Calculate_LOT_OCEAN__c);
            update currentOppty;
            System.debug('###Debug### Carmen after update Skip_Calculate_LOT_OCEAN__c ' +currentOppty.Skip_Calculate_LOT_OCEAN__c);
            GlobalVariables.SKIP_OCEAN_POPUP_NOTIFICATION = false;   
            return new PageReference('/'+currentOppty.Id);  
        } catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
 }