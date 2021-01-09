@IsTest
private class FAP_VFC_fapTranslationControllerTest {
 private static testmethod void executeBasicFields()
 {
     
     FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
     controller.regionNameSelected ='Test';
     controller.fieldNameSelected ='Test';
     controller.newPickList ='Test';
     controller.newBusinessPickListValue ='Test';
     controller.newSFDCPickListValue ='Test';
     controller.translationForSelected ='Test';
     controller.picklistStrList ='Test';
     controller.pickListValueSelected ='Test';
     controller.addButtonClicked =true;
     controller.sfdcValue ='test';
     controller.refreshSection();
 	 controller.addPicklistValues();
     controller.retrievePickListValue();
 }
    
 private static testmethod void executeConstructor()
 {
     
     FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
	 FAP_Translation__c fapObj = new FAP_Translation__c();
     List<selectoption> regionNameOptions = new List<selectoption>();
     controller.existingTransList = new List<FAP_Translation__c>();

     FAP_Translation__c trans = new FAP_Translation__c();
     trans.Value__c='Communications';
     trans.Swedish__c='Kommunikation';
     insert trans;
     controller.existingTranslatedMap.put(trans.Value__c,trans);
     
     controller.existingTransList.add(trans);
      System.assertNOtEquals(null, controller.existingTransList.size() >0);
      System.assertNOtEquals(true, controller.canAddTranslation);
 }   
    
  private static testmethod void executeSaveRecords(){
      FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();

      FAP_Customization__c customFAPObj = new FAP_Customization__c();
      customFAPObj.Datatype__c='test';
      customFAPObj.Field_label__c ='Help Text';
      customFAPObj.Help_text__c ='Help Text';
      insert customFAPObj;
      FAP_Translation__c fapObj = new FAP_Translation__c();
      fapObj.Value__c= 'Competencies';
      fapObj.Czech__c='test';
      insert fapObj;
      controller.translationForSelected ='Pick List Value';
      fapObj.Czech__c='test1';
      fapObj.Value__c='Competencies';
      update fapObj;
      controller.saveRecords();
  }
    
  private static testmethod void executeSaveRecordsNew(){
      
      FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
      controller.regionNameSelected ='EMEA';
      controller.fieldNameSelected ='Help Text';
      controller.translationForSelected ='Help Text';
      FAP_Customization__c customFAPObj = new FAP_Customization__c();
      customFAPObj.Datatype__c='test';
      customFAPObj.Field_label__c ='Help Text';
      customFAPObj.Help_text__c ='Help Text';
      customFAPObj.Region__c='EMEA' ;
      customFAPObj.User_Type__c = 'Authenticated';
      customFAPObj.Datatype__c = 'Dropdown';
      customFAPObj.Pick_list_value__c = 'Storage@Storage|Server@Server|Networking@Networking|Data Protection@Data Protection|Converged/Hyper-Converged Infrastructure@Converged Infrastructure,Converged/Hyper-Converged Infrastructure|Core Client@Core Client|Client Data Security@Client Data Security|Workstation@Workstation|Cloud Client-Computing@Cloud Client-Computing|Digital Transformation@Digital Transformation|IT Transformation@IT Transformation|Hybrid Cloud@Hybrid Cloud|Software Defined Infrastructure@Software Defined Infrastructure|Connected Workforce@Connected Workforce|Services@Services|';

      insert customFAPObj;
      controller.removePicklistValues();

      controller.refreshSection();
      controller.regionNameSelected ='EMEA';
      controller.fieldNameSelected ='Help Text';
      controller.translationForSelected ='Help Text';
      FAP_Translation__c fapObj = new FAP_Translation__c();
      fapObj.Value__c= 'Competencies';
      fapObj.Czech__c='test';
      insert fapObj;
      controller.translationForSelected ='Help Text';
      fapObj.Czech__c='test1';
      fapObj.Value__c='Competencies';
      update fapObj;
controller.getdatatype();
      controller.retrieveTranslationFor();
      //controller.saveRecords();

      controller.refreshRegion();
      customFAPObj.Help_text__c =null;
      customFapObj.Field_label__c='Help Text';
      String value = customFAPObj.Field_label__c + ' help text';

      update  customFAPObj;
      controller.removePicklistValues();
      controller.existingTranslatedMap.put(value,fapObj);
      controller.translationForSelected ='Help Text';
      controller.existingTranslatedMap.put('Help Text',fapObj);

      controller.retrieveTranslationFor();
      controller.translationForSelected ='Help Text';
      fapObj.Value__c= 'Competencies2';
      update fapObj;
      controller.saveRecords();
      controller.translationForSelected ='Help Text';

      controller.translationForSelected ='Pick List Value';
      controller.pickListValueSelected='-None';
      controller.existingTranslatedMap.put('-None',fapObj);
      controller.retrievePickListValue();

  }
 private static testmethod void executeSaveSFDCValue()
 {
     
     FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
     FAP_Translation__c fapObj = new FAP_Translation__c();
     FAP_Customization__c  customFAPObj = new FAP_Customization__c();
     customFAPObj.Pick_list_value__c ='Find a Partner@Commercial General,Commercial SMB Partner,Commercial LE Partner,Commercial Public Partner,Solution Provider|Find a Distributor@Distributor (GCC),Distributor (GDC),Distributor (Shared),Commercial Distributor,Consumer Distributor,Federal Distributor,Sub-Distributor|Find an OEM Partner@OEM|Find a Cloud Service Provider@MSP/CSP/Service Provider|Find a System Integrator@System Integrator (Global Alliance)|';
   	 customFAPObj.Is_Active__c=true;
     customFAPObj.Field_label__c='Competencies';
     customFAPObj.Pick_list_value__c ='Find a Partner@Commercial General,Commercial SMB Partner,Commercial LE Partner,Commercial Public Partner,Solution Provider|Find a Distributor@Distributor (GCC),Distributor (GDC),Distributor (Shared),Commercial Distributor,Consumer Distributor,Federal Distributor,Sub-Distributor|Find an OEM Partner@OEM|Find a Cloud Service Provider@MSP/CSP/Service Provider|Find a System Integrator@System Integrator (Global Alliance)|';
   	 customFAPObj.Is_Active__c=true;
     insert customFAPObj;
     Map<String,String> pickListMap= new Map<String,String>(); 
     controller.getdatatype();
     pickListMap.put('test',customFAPObj.Pick_list_value__c );
     controller.sfdcValue =pickListMap.get('test');
     controller.saveSFDCValue();
 } 
    
 private static testmethod void executeRetrieveTranslationFor()
 {
     
     FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
     FAP_Translation__c fapObj = new FAP_Translation__c();
     FAP_Customization__c  customFAPObj = new FAP_Customization__c();
     Map<String,FAP_Translation__c> existingTranslatedMap = new Map<String,FAP_Translation__c>();
     FAP_Translation__c trans = new FAP_Translation__c();
     trans.Value__c='Communications';
     trans.Swedish__c='Kommunikation';
     insert trans;
     existingTranslatedMap.put(trans.Value__c,trans);
     customFAPObj.Pick_list_value__c ='Find a Partner@Commercial General,Commercial SMB Partner,Commercial LE Partner,Commercial Public Partner,Solution Provider|Find a Distributor@Distributor (GCC),Distributor (GDC),Distributor (Shared),Commercial Distributor,Consumer Distributor,Federal Distributor,Sub-Distributor|Find an OEM Partner@OEM|Find a Cloud Service Provider@MSP/CSP/Service Provider|Find a System Integrator@System Integrator (Global Alliance)|';
   	 customFAPObj.Is_Active__c=true;
     customFAPObj.Field_label__c='Competencies';
     insert customFAPObj;
     List<SelectOption> translationForOptions = new List<SelectOption>();
     translationForOptions.add(new selectoption('-None','-None-'));
     Map<String,String> pickListMap= new Map<String,String>(); 
     controller.getdatatype();
     pickListMap.put('test',customFAPObj.Pick_list_value__c );
     controller.sfdcValue =pickListMap.get('test');
	 controller.translationForSelected = 'Field Label';
     controller.retrieveTranslationFor();
     
     controller.translationForSelected = 'Help text';
     controller.retrieveTranslationFor();
 }
 private static testmethod void executeSavePicklistValue()
 {
     
     FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
     FAP_Translation__c fapObj = new FAP_Translation__c();
     FAP_Customization__c  customFAPObj = new FAP_Customization__c();
     Map<String,FAP_Translation__c> existingTranslatedMap = new Map<String,FAP_Translation__c>();
     FAP_Translation__c trans = new FAP_Translation__c();
     trans.Value__c='Communications';
     trans.Swedish__c='Kommunikation';
     insert trans;
     existingTranslatedMap.put(trans.Value__c,trans);

     Map<String,String> pickListMap= new Map<String,String>(); 
	 controller.addButtonClicked= true;
     pickListMap.put('test',customFAPObj.Pick_list_value__c );
     controller.sfdcValue =pickListMap.get('test');
	 controller.translationForSelected = 'Field Label';
     controller.newSFDCPickListValue ='Find a Partner@Commercial General,Commercial SMB Partner,Commercial LE Partner,Commercial Public Partner,Solution Provider|Find a Distributor@Distributor (GCC),Distributor (GDC),Distributor (Shared),Commercial Distributor,Consumer Distributor,Federal Distributor,Sub-Distributor|Find an OEM Partner@OEM|Find a Cloud Service Provider@MSP/CSP/Service Provider|Find a System Integrator@System Integrator (Global Alliance)|';
     controller.savePicklistValue();
     
     customFAPObj.Pick_list_value__c ='Find a Partner@Commercial General,Commercial SMB Partner,Commercial LE Partner,Commercial Public Partner,Solution Provider|Find a Distributor@Distributor (GCC),Distributor (GDC),Distributor (Shared),Commercial Distributor,Consumer Distributor,Federal Distributor,Sub-Distributor|Find an OEM Partner@OEM|Find a Cloud Service Provider@MSP/CSP/Service Provider|Find a System Integrator@System Integrator (Global Alliance)|';
   	 customFAPObj.Is_Active__c=true;
     customFAPObj.Field_label__c='Competencies';
     insert customFAPObj;
     List<SelectOption> translationForOptions = new List<SelectOption>();
     translationForOptions.add(new selectoption('-None','-None-'));     
 }  
    
 private static testmethod void executeRemovePicklistValues()
 {

     FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
     controller.addButtonClicked= false;
     String newPickList='';
     FAP_Translation__c fapObj = new FAP_Translation__c();
     FAP_Customization__c  customFAPObj = new FAP_Customization__c();
     Map<String,FAP_Translation__c> existingTranslatedMap = new Map<String,FAP_Translation__c>();
     
     List<SelectOption> pickListOptions = new List<SelectOption>();
     pickListOptions.add(new selectoption('-None','-None-'));  
		
     SelectOption sr = pickListOptions.get(0);
     sr.setValue('value');
	 controller.pickListValueSelected ='-None' ;  
        try{
            customFAPObj.Pick_list_value__c = newPickList;
            update customFAPObj;
        } catch(Exception e){
           System.debug('Exception Occured:'+e);
       }
     controller.removePicklistValues();
 }        
 private static testmethod void executeRefreshRegion()
 {

     FAP_VFC_fapTranslationController controller = new FAP_VFC_fapTranslationController();
     controller.newSFDCPickListValue = '';
     controller.newBusinessPickListValue = '';
     controller.newPickList = '';
     controller.addButtonClicked= false;
     FAP_Translation__c fapObj = new FAP_Translation__c();
     FAP_Customization__c  customFAPObj = new FAP_Customization__c();
     Map<String,FAP_Translation__c> existingTranslatedMap = new Map<String,FAP_Translation__c>();
     
     List<SelectOption> translationForOptions = new List<SelectOption>();
     translationForOptions.add(new selectoption('-None','-None-'));  

     Map<String,String> pickListMap= new Map<String,String>(); 

	List<FAP_Translation__c> existingTransList = new List<FAP_Translation__c>();
     FAP_Translation__c trans = new FAP_Translation__c();
     trans.Value__c='Communications';
     trans.Swedish__c='Kommunikation';
     existingTransList.add(trans);
     controller.refreshRegion();
 }         
}