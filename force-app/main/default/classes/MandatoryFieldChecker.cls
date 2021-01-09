/*
Author: Jessie Tan
History:
Version Date                Modified By     Description
--------------------------------------------------------------------------------------
1.0      04-March-2013      Jessie          Created for CR8140 - Check if some of the mandatory fields (Services Sales Profiles) are empty. Throw error messages if it is empty.
2.0      04-Dec-2013        Azwanti        R15.03 CR8943 - added Location(s) to be Serviced and Existing Services Customer field into the isValid method.
3.0      30-May-2014        Raphael        Moved the variable usrProfileName out of the method to prevent repeated SOQL queres
4.0      07-June-2017       Sriram         CR-14401 Non SSO Profile Clean Up
5.0      20-June-2017       Emily          CR14534 - Include new stage value - Order Submitted - 99%
6.0      14-Aug-2017        Ramesh         CR14721 Full code is commented which is related to service and added testmethod also to cover constructor.
*/

public class MandatoryFieldChecker{       
    // v 6.0 Start
    /*
    //CR 14401 - Start
    private final static Set<String> SERVICES_SALES_PROFILES = 
        new Set<String> {'GBL Dell Services Mgr', //'GBL Dell Services Mgr - Non SSO',
                            'GBL Dell Services Rep', //'GBL Dell Services Rep - Non SSO',
                            'MSG Service Sales' //'MSG Service Sales - Non SSO'
                            };
    //CR 14401 - End
    
    private List<String> errorFieldList = new List<String>(); 
    //CR14534 - Start   
    private OWD__c owd = OWD__c.getOrgDefaults();  
    private Set<String> pricingTypeStage = new Set<String> {owd.Oppty_Stage60__c, owd.Oppty_Stage90__c, owd.Oppty_Stage99__c, owd.Oppty_Stage100__c};
    private Set<String> contractTermStage = new Set<String> {owd.Oppty_Stage30__c, owd.Oppty_Stage60__c, owd.Oppty_Stage90__c, owd.Oppty_Stage99__c, owd.Oppty_Stage100__c};
    private Set<String> serviceLocationStage = new Set<String> {owd.Oppty_Stage30__c, owd.Oppty_Stage60__c, owd.Oppty_Stage90__c, owd.Oppty_Stage99__c, owd.Oppty_Stage100__c};  //CR8943 
    //CR14534 - End
    private static String profileNameWithoutVersion = null ;//3.0
      */      
    // v 6.0 end
    public MandatoryFieldChecker(){
       //v 6.0 Start
        /* 
        if(profileNameWithoutVersion==null){
        
            System.debug('### MandatoryFieldChecker constructor is called.');
            
            String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        
            //String usrProfileName = 'System Administrator';
        
            //remove release version from profile name
            System.debug('Value of usrProfileName: ' + usrProfileName); //3.0
            profileNameWithoutVersion = usrProfileName.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}','');
            //ramesh
            system.debug('profileNameWithoutVersion++'+profileNameWithoutVersion);
        }
        */
        //v 6.0 end
    }
    // v 6.0 Start
    /*
    public boolean isValid(Opportunity opp){
    /*
        if(GlobalVariables.BY_PASS_SERVICES_SALES_MANDATORY_VALIDATION_RULE){ 
            System.debug('### No checking will be done. By Pass flag has been turned on.');
            return true;
        } 
            */
      /*      
        if(opp.RecordTypeId != GlobalVariables.STANDARD_OPP_RECTYPE){ 
            System.debug('### The current Opportunity is not Standard Opportunity. Error will not happen to it.');
            return true;
        } 
        
        System.debug('### Services Sales Owner : ' + opp.Services_Sales_Owner__c + ', Opp Owner : ' +  opp.ownerId);
                      
        if(!(SERVICES_SALES_PROFILES.contains(profileNameWithoutVersion) && (Userinfo.getUserId()==opp.Services_Sales_Owner__c || Userinfo.getUserId() == opp.ownerId))){
            System.debug('### You are not Services Sales Profile user.');
            return true;
        }
              
        if(opp.Confidence_Factor__c == null || opp.Confidence_Factor__c ==''){
            
            opp.Confidence_Factor__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Confidence_Factor__c.getLabel());
            System.debug('### You do not enter Confidence Factor field.');         
            
        }
        
        if(opp.Dell_Defined_Industry__c == null || opp.Dell_Defined_Industry__c ==''){
            
            opp.Dell_Defined_Industry__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Dell_Defined_Industry__c.getLabel());
            System.debug('### You do not enter Dell Defined Industry field.');          
            
        }
        
        if(opp.Dell_Services_Opportunity_Source__c == null || opp.Dell_Services_Opportunity_Source__c == ''){
            
            opp.Dell_Services_Opportunity_Source__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Dell_Services_Opportunity_Source__c.getLabel());         
            System.debug('### You do not enter Dell Services Opportunity Source field.');      
            
        }
        
        System.debug('### opp.Services_Sales_Owner__c : ' + opp.Services_Sales_Owner__c);
        
        if(opp.Services_Sales_Owner__c == null){
            
            opp.Services_Sales_Owner__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Services_Sales_Owner__c.getLabel());         
            System.debug('### You do not enter Services Sales Owner field.');      
            
        }       
        
        
        if(
            pricingTypeStage.contains(opp.StageName) 
                &&
            (opp.Pricing_Type__c == null || opp.Pricing_Type__c == '')
        ){
          
            opp.Pricing_Type__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Pricing_Type__c.getLabel()); 
            System.debug('### You do not enter Pricing Type field.');  
            
        }
        
        if(
            contractTermStage.contains(opp.StageName) 
                &&
            opp.Contract_Term__c == null
        ){
          
            opp.Contract_Term__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Contract_Term__c.getLabel()); 
            System.debug('### You do not enter Contract Term field.');  
            
        } 
        
        //CR8943
        if(
            serviceLocationStage.contains(opp.StageName) 
                &&
            opp.Services_Location_s__c == null
        ){
          
            opp.Services_Location_s__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Services_Location_s__c.getLabel()); 
            System.debug('### You do not enter Location(s) to be Serviced field.');              
        } 
        
        if(opp.Existing_Services_Customer__c == null || opp.Existing_Services_Customer__c == ''){
            
            opp.Existing_Services_Customer__c.addError('You must enter a value.');
            errorFieldList.add(Schema.SObjectType.Opportunity.fields.Existing_Services_Customer__c.getLabel());         
            System.debug('### You do not enter Existing Services Customer field.');      
            
        }
        //CR8943
        
        
        if(!errorFieldList.isEmpty()){
        
            System.debug('### errorFieldList: ' + errorFieldList);
            
            String errorFieldListStr = '';
            
            for(integer i=0; i<=errorFieldList.size()-1; i++){
                if(i!=0)
                    errorFieldListStr += ', ';
                errorFieldListStr += errorFieldList.get(i);
            }
                        
            opp.addError('The following fields need to be completed prior to saving: - ' + errorFieldListStr  + '.');
            return false;
            
        }
        
        return true;
          
   }
        */
    // v 6.0 End
    // V 6.0 -start
    static testMethod void callingMfcconst(){
       MandatoryFieldChecker mfc= new MandatoryFieldChecker(); 
    } 
    // V 6.0 -end
}