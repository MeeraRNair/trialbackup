/**********************************************************************************************                    
 * Name         : NewContractRedirectController
 * Description  : Auto populates the Contract fields according to the value in the Segment
                  (CR #8008)
 * Created      : 21-April-2013
 * Created By   : Impana
 
 * Revision History
 * ----------------
 * 24-Mar-2014 Emily CR 9259 : Encode free text fields
***********************************************************************************************/ 

public class NewContractRedirectController{
    public Support_Request__c SupportObj = null;
    public string Contract_extension;
    public string RFPsupport;
    public string multinational_opportunity;
    public string Requires_Signature;
    Public list<string> Product;
    public map<string,string> urlmap = null;
    public integer i;
    public ID supportId ;
    public ID supportId1; 
    public integer prod=0;
    public string[] product1;
        
        
    public NewContractRedirectController() {    
         supportId = apexpages.currentpage().getparameters().get('srId');
         
         urlmap = new map<string,string> {'acc_country'=> '00NA00000063RxB','postal_code' => '00NA00000063Ryf'};
         fullRecordURL =null;
         SupportObj = [SELECT name,Id,Segment_Business_Unit_Name__c, Account_country__c,Corporate_Parent_Name__c,Contact_Name__r.Name,Opportunity__c,
                      Email__c,Phone__c,Opportunity__r.Name,Mobile__c,Mailing_Street__c,Mailing_City__c,Mailing_State_Province__c,Mailing_Zip_Postal_Code__c,Contact_Name__r.title,
                      Mailing_Country__c,Dell_Company__c,Region__c,Sub_Region__c,Country__c,Business_Case_Summary__c,Contract_Template_Type__c,
                      Prior_Contact_Agreement__c,If_Yes_Prior_Agreement_Name_or_CC__c,Amend_or_Terminate_prior_Agreement__c,Initial_Contract_Term_Requested__c,
                      Renew__c,Termination_for_Convenience_Days_Notice__c,Payment_Terms__c,Risk_Level__c,Complexity__c,RRC_Required__c,
                      Vetting_Required__c,Products__c,Account_Name__c,Anticipated_Anual_Revenue__c,Business_Unit1__c,Business_Unit_Secondary__c,
                      Title__c,Segment_Business_Unit__c,Expected_Contract_Start_Date__c,Contract_Duration_months__c,Multinational_Opportunity__c,
                      Global_Program__c,Utilization__c,RFP_Support__c,Contract_Requires_Signature__c,Contract_Extension__c,Value_of_Contract__c,
                      Contract_Code__c from Support_Request__c
                      WHERE Id =: supportId ];                
     }

    public String createUrl() {   
       IF(SupportObj.Segment_Business_Unit__c == 'CSMB'){           
           fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + '800' + '/' + 'e?&00NA00000063Rxh='+(supportObj.Dell_Company__c!=null?supportObj.Dell_Company__c:'')+'&00NA00000063RyO='+(supportObj.Region__c!= null ? EncodingUtil.urlEncode(supportObj.Region__c, 'UTF-8'): '')+'&00NA00000063RyY='+(supportObj.Sub_Region__c!= null ? EncodingUtil.urlEncode(supportObj.Sub_Region__c, 'UTF-8'): '')+ '&00NA00000063RxJ='+(supportObj.Business_Unit1__c!= null ? EncodingUtil.urlEncode(supportObj.Business_Unit1__c, 'UTF-8'): '');
           fullRecordURL = fullRecordURL + '&00NA00000063RxJ='+(supportObj.Business_Unit_Secondary__c!= null ? EncodingUtil.urlEncode(supportObj.Business_Unit_Secondary__c, 'UTF-8'): '')+'&00NA00000063Rxc='+(supportObj.Country__c!= null ? EncodingUtil.urlEncode(supportObj.Country__c, 'UTF-8'): '');    
       } 
            
       ELSE{             
           if(supportObj.RFP_Support__c == true){
               RFPsupport= '1';
           }
           else{
               RFPsupport= '0';
           }
           if(supportObj.Contract_Extension__c== true){
               Contract_extension= '1';
           }
           else{
               Contract_extension= '0';
           }
           if(supportObj.Multinational_Opportunity__c== true){
               multinational_opportunity= '1';
           }
           else{
               multinational_opportunity= '0';
           }
           if(supportObj.Contract_Requires_Signature__c== true){
               Requires_Signature= '1';
           }
           else{
               Requires_Signature= '0';
           }
             
           fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + '800' + '/' + 'e?&00NA00000063mXE='+multinational_opportunity+'&00NA00000063mXD='+(supportObj.Global_Program__c!=null?supportObj.Global_Program__c:'')+'&00NA00000063mXG='+(supportObj.Utilization__c!=null?supportObj.Utilization__c:'')+'&00NA00000063mXF='+RFPsupport;
           fullRecordURL = fullRecordURL + '&00NA00000063mXB='+Requires_Signature+'&00NA00000063mXA='+Contract_extension+'&00NA00000063mX9='+(supportObj.Contract_Duration_months__c!=null?supportObj.Contract_Duration_months__c:'')+'&00NA00000063mX8='+(supportObj.Contract_Code__c!= null?EncodingUtil.urlEncode(supportObj.Contract_Code__c, 'UTF-8'): '');
          
           if(supportObj.Expected_Contract_Start_Date__c !=null){
               fullRecordURL=fullRecordURL +'&00NA00000063mXC='+supportObj.Expected_Contract_Start_Date__c.format();
           }
                      
        }    
                  
      fullRecordURL = fullRecordURL + '&00NA00000063RxB='+(supportObj.Account_Country__c!= null ? EncodingUtil.urlEncode(supportObj.Account_Country__c, 'UTF-8'): '')+'&ctrc7='+(supportObj.Account_Name__c!= null ? EncodingUtil.urlEncode(supportObj.Account_Name__c, 'UTF-8'): '')+'&00NA00000063Rxb='+(supportObj.Corporate_Parent_Name__c!= null ? EncodingUtil.urlEncode(supportObj.Corporate_Parent_Name__c, 'UTF-8'): '')+'&00NA00000063Ryb='+(supportObj.Contact_Name__r!= null && supportObj.Contact_Name__r.title!= null ? EncodingUtil.urlEncode(supportObj.Contact_Name__r.title, 'UTF-8'): '')+ '&00NA00000063RxU='+(supportObj.Contact_Name__r!= null && supportObj.Contact_Name__r.Name!= null ? EncodingUtil.urlEncode(SupportObj.Contact_Name__r.Name, 'UTF-8'): '');      
      
      if(supportObj.Products__c != null) { 
          Product= supportObj.Products__c.split(';');
          Prod = Product.size();    
          for(integer i=0; i<Prod;i=i+1){
             fullRecordURL = fullRecordURL +'&00NA00000063RyI='+Product[i];
             system.debug('for loop'+fullRecordURL );
          }
       }   
       list<string> SR_name = supportObj.name.split('#');
             
       fullRecordURL = fullRecordURL + '&CF00NA00000063RyE='+(supportObj.Opportunity__r.Name!= null ? EncodingUtil.urlEncode(supportObj.Opportunity__r.Name, 'UTF-8'): '')+ '&00NA00000063RyX='+(supportObj.Mailing_Street__c!= null ? EncodingUtil.urlEncode(supportObj.Mailing_Street__c, 'UTF-8'): '')+'&00NA00000063RxO='+(supportObj.Mailing_City__c!= null ? EncodingUtil.urlEncode(supportObj.Mailing_City__c, 'UTF-8'): '')+'&00NA00000063RyW='+(supportObj.Mailing_State_Province__c!=null ?EncodingUtil.urlEncode(supportObj.Mailing_State_Province__c, 'UTF-8'): '')+'&00NA00000063Rxt='+(supportObj.Email__c!=null ?EncodingUtil.urlEncode(supportObj.Email__c, 'UTF-8'): '')+'&00NA00000063RyG='+(supportObj.Phone__c!=null ?EncodingUtil.urlEncode(supportObj.Phone__c, 'UTF-8'):'' ); 
       fullRecordURL = fullRecordURL + '&00NA00000063Rxa='+(supportObj.Contract_Template_Type__c!= null ? EncodingUtil.urlEncode(supportObj.Contract_Template_Type__c, 'UTF-8'): '')+'&00NA00000063RyH='+(supportObj.Prior_Contact_Agreement__c!=null? supportObj.Prior_Contact_Agreement__c:'')+'&00NA00000063Ryf='+(supportObj.Mailing_Zip_Postal_Code__c!=null ?supportObj.Mailing_Zip_Postal_Code__c:'' )+'&00NA00000063Rxg='+(supportObj.Mailing_Country__c!=null ?EncodingUtil.urlEncode(supportObj.Mailing_Country__c, 'UTF-8'):'' );
       fullRecordURL = fullRecordURL + '&00NA00000063Ry6='+(supportObj.If_Yes_Prior_Agreement_Name_or_CC__c!=null ?EncodingUtil.urlEncode(supportObj.If_Yes_Prior_Agreement_Name_or_CC__c, 'UTF-8'):'' ) +'&00NA00000063RxG='+(supportObj.Amend_or_Terminate_prior_Agreement__c!=null? supportObj.Amend_or_Terminate_prior_Agreement__c:'')+'&00NA00000063Ry7='+(supportObj.Initial_Contract_Term_Requested__c!= null ? EncodingUtil.urlEncode(supportObj.Initial_Contract_Term_Requested__c, 'UTF-8'): '')+'&CF00NA00000063RxM='+'SR'+(SR_name[1]!= null ? EncodingUtil.urlEncode(SR_name[1], 'UTF-8'): '')+'&00NA00000063Ry9='+(supportObj.Mobile__c!= null ? EncodingUtil.urlEncode(supportObj.Mobile__c, 'UTF-8'): '');
       fullRecordURL = fullRecordURL + '&00NA00000063Rxi='+(supportObj.Dell_Company__c!=null?supportObj.Dell_Company__c:'') + '&00NA00000063RyP='+(supportObj.Renew__c!=null ? supportObj.Renew__c:'')+'&00NA00000063Rya='+(supportObj.Termination_for_Convenience_Days_Notice__c!=null ?EncodingUtil.urlEncode(supportObj.Termination_for_Convenience_Days_Notice__c, 'UTF-8'):'' ) +'&00NA00000063RyF='+(supportObj.Payment_Terms__c!=null ?EncodingUtil.urlEncode(supportObj.Payment_Terms__c, 'UTF-8'):'' ) +'&00NA00000063RyT='+(supportObj.Risk_Level__c!=null?supportObj.Risk_Level__c:'');
       fullRecordURL = fullRecordURL + '&00NA00000063RxR='+(supportObj.Complexity__c!=null?supportObj.Complexity__c:'')+'&00NA00000063RyK='+(supportObj.RRC_Required__c!=null?supportObj.RRC_Required__c:'')+'&00NA00000063Ryd='+(supportObj.Vetting_Required__c!=null?supportObj.Vetting_Required__c:'');
                       
       for (String key : urlmap.keySet()) {
           fullRecordURL += '&' + key + '=' + EncodingUtil.urlEncode(urlmap.get(key), 'UTF-8');
       }
       //Emily CR 9259: put this long area text field as the last querystring
	   fullRecordURL += '&00NA00000063RyZ='+(supportObj.Business_Case_Summary__c!=null ? EncodingUtil.urlEncode(supportObj.Business_Case_Summary__c, 'UTF-8'):'');
	   system.debug('###DEBUG### fullRecordURL: ' + fullRecordURL);

       return fullRecordURL ;
  }

  
  public String fullRecordURL {
    get {
       if (fullRecordURL == null) {
           fullRecordURL = createUrl();
       }
       return fullRecordURL ;
    }
    private set;
  }                        
  
}