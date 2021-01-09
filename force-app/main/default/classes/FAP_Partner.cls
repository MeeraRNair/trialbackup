/* 
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0    19-NOV-2019      Akshita         FAP - FED - Summary page - data display
*/

global class FAP_Partner {
  public ID id {get;set;}
  public Boolean isPartner {get;set;}
  public Boolean isEnabledByOrg {get;set;}
  public Boolean isEnabledByPartner {get;set;}
  public Boolean isTermsAndConditionsSignedByPartner{get;set;}
  public Boolean isEnabled {get{ return isPartner && isEnabledByOrg && isEnabledByPartner && isTermsAndConditionsSignedByPartner; }}
  public String name {get;set;}
  public String logoId {get;set;}
  public String logoRecordId{get; set;}
  public String accountEmail {get;set;}
  public string programPartnerTier {get;set;}
  public string experiencewithus {get;set;}
  public string primaryCustomer {get;set;}
  public string companyDescription{get;set;}
  public string cloudHQLocation{get;set;}
  public string partnerType{get;set;}
  public string websiteUrl{get;set;}
  public string localname{get;set;}
  public string geocoverage{get;set;}
  public string dellAward{get;set;}
  
  //1.0 start
  public string strContractsEnabled{get;set;}
  public string strAdditionalContractsEnabled{get;set;}
  public string strDiversityCertification{get;set;}
  public string strDiversityCertificationOther{get;set;}
  public string strFederalAgencyDivisionSupported{get;set;}
  //1.0 end
       
 
  public static FAP_Partner build(Sobject sObj, FAP_Configuration config){
  FAP_Partner partner = new FAP_Partner();
  partner.id = ID.valueof(String.valueof(sObj.get('id')));
  sObject sb = null;
  String pName = null;
 
 
    partner.isPartner = FAP_Configuration.keyValue == 'Account__r.'?  (Boolean)sObj.get('isPartner'): (Boolean)sObj.get('Partner_Account__c');

  

    partner.isTermsAndConditionsSignedByPartner = !config.isTermsConditionsFeatureEnabled || 
                                                      (sObj.get(FAP_Configuration.strPartnerUsrAgreed) != null 
                                                      && sObj.get('Partner_Date_Agreed_to_PF_Terms_Cond__c') != null);
                                                      
    partner.isEnabledByOrg = (Boolean)sObj.get('Approved_for_Partner_Finder__c');
    partner.isEnabledByPartner = 'yes'.equalsIgnoreCase(String.valueof(sObj.get('Profile_Published_to_Partner_Finder__c')));
    
    
    partner.geocoverage         = String.valueof(sObj.get('Capability__c'));
    partner.name=String.valueof(sObj.get(FAP_Configuration.strRecLegalName));
    //partner.logoId               = getLogoId(sObj);
    //partner.logoRecordId         = String.valueof(sObj.get('Logo__c'));
  if(FAP_Configuration.keyValue != 'Account__r.'){ 
    partner.ProgramPartnerTier  = String.valueof(sObj.get('Partner_Program_Tier__c'));
    partner.Experiencewithus    = String.valueof(sObj.get('Experience_with_us__c'));
    }
    partner.PrimaryCustomer    = String.valueof(sObj.get('Partner_Primary_Customer__c'));
    partner.CompanyDescription = String.valueof(sObj.get('Partner_Self_Description_Long__c'));
    partner.cloudHQLocation    =  String.valueof(sObj.get('Cloud_HQ_Location__c'));
    partner.partnerType = String.valueof(sObj.get('Partner_Type__c'));
    partner.websiteUrl = FAP_Configuration.keyValue == 'Account__r.'?  String.valueof(sObj.get('Website')): String.valueof(sObj.get('Website__c'));
    partner.localname=String.valueof(sObj.get(FAP_Configuration.strAcctLocalName)); 
    partner.dellAward = String.valueof(sObj.get('Dell_Partner_Awards__c'));
    
    //1.0 start
    String strToReplace = String.valueof(sObj.get('Contracts_Enabled__c'));
    if(String.IsNotEmpty(strToReplace) && String.isNotBlank(strToReplace)){
      partner.strContractsEnabled = strToReplace.replace(';',';  ');  
    }else{
      partner.strContractsEnabled = strToReplace;
    }
    partner.strAdditionalContractsEnabled = String.valueof(sObj.get('Additional_Contracts_Enabled__c'));
    
    String strToReplaceDivCer = String.valueof(sObj.get('Diversity_Certification__c'));
    if(String.IsNotEmpty(strToReplaceDivCer) && String.isNotBlank(strToReplaceDivCer)){
      partner.strDiversityCertification = strToReplaceDivCer.replace(';',';  ');  
    }else{
      partner.strDiversityCertification = strToReplaceDivCer;
    }
    partner.strDiversityCertificationOther = String.valueof(sObj.get('Diversity_Certification_Other__c'));
    partner.strFederalAgencyDivisionSupported = String.valueof(sObj.get('Federal_Agencies_Divisions_supported__c'));
    //1.0 end
    
    partner.logoId               = getLogoId(sObj);
    partner.logoRecordId         = String.valueof(sObj.get('Logo__c'));
    
    if(partner.logoRecordId == null || String.isEmpty(partner.logoRecordId)){
        partner.logoRecordId         = String.valueof(sObj.get('Master_Logo_ID__c')); 
    }
    return partner;
  }
    
  private static String getLogoId(Sobject sObj){
        string logoid = String.valueof(sObj.get('Logo__c'));
        if(logoid == null || String.isEmpty(logoid)){
            logoid = String.valueof(sObj.get('Master_Logo_ID__c')); 
        }
        List<Attachment> logos = [select id,parentid from Attachment where parentid =:logoid]; 
        if(logos != null && logos.size() > 0){
            return logos[0].Id;
        } else {
            return null;
        }
   } 


  }