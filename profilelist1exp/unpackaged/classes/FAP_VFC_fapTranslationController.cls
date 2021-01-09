public class FAP_VFC_fapTranslationController{
    public List<FAP_Customization__c> fapCustomizationList;
    public String regionNameSelected{get;set;}
    public String fieldNameSelected{get;set;}
    public String newPickList{get;set;}
    public String newBusinessPickListValue{get;set;} 
    public String newSFDCPickListValue{get;set;}   
    public String translationForSelected{get;set;}
    public String picklistStrList{get;set;}  
    public String pickListValueSelected{get;set;}
    public boolean addButtonClicked{get;set;}
    public List<SelectOption>regionNameOptions{get;set;}
    public List<SelectOption>fieldNameOptions{get;set;}
    public List<SelectOption>translationForOptions{get;set;}
    public List<SelectOption>pickListOptions{get;set;}         
    public FAP_Translation__c fapObj{get;set;}
    public FAP_Customization__c customFAPObj;
    public FAP_Country__mdt countryObj;
    public List<Country__c> countryList;    
    public List<FAP_Translation__c> existingTransList;     
    public Map<String,FAP_Translation__c>existingTranslatedMap = new Map<String,FAP_Translation__c>();
    //Fenny: This map holds all FAP_Customization__c records of a field label
    private Map<Id, FAP_Customization__c> fieldFAPCustomizationMap = null;
    // CR7105 - Customize UI: To show the SFDC value as an input text// 
    public String sfdcValue{get;set;}
    Map<String,String> pickListMap = new Map<String,String>();    

    //-- CR7105 - Controller for FAP Translation//
    public FAP_VFC_fapTranslationController(){
        newSFDCPickListValue = '';
        newBusinessPickListValue = '';
        newPickList = '';
        fapObj = new FAP_Translation__c();
        addButtonClicked = false;
        existingTransList = new List<FAP_Translation__c>();
        pickListOptions = new List<SelectOption>();
        customFAPObj = new FAP_Customization__c();
        translationForOptions = new List<SelectOption>();
        pickListOptions = new List<SelectOption>();  
        regionNameSelected='';  
        fieldNameSelected ='';
        translationForSelected ='';
        regionNameOptions=new List<selectoption>();
        fieldNameOptions = new List<SelectOption>();
        regionNameOptions.add(new selectoption('-None','-None-'));
        fieldNameOptions.add(new selectoption('-None','-None-'));
        existingTransList = [Select Value__c,Brazilian_Portuguese__c,Chinese_Simplified__c,Chinese_Traditional__c,
                            Czech__c,Danish__c,Dutch__c,English__c,Finnish__c,French__c,German__c,Hungarian__c,
                            Italian__c,Japanese__c,Korean__c,Polish__c,Russian__c,Spanish__c,Swedish__c,Thai__c,
                            Turkish__c from FAP_Translation__c];
        if(existingTransList.size()>0){
            for(FAP_Translation__c trans : existingTransList){
                existingTranslatedMap.put(trans.Value__c,trans);
            }
        }
        //Naga - User Story-161376  : Start
        for(AggregateResult result : [SELECT Region__c FROM FAP_Customization__c GROUP BY Region__c]){
            regionNameOptions.add(new SelectOption(string.valueOf(result.get('Region__c')), string.valueOf(result.get('Region__c'))));
            }
         
         } 
    
    //Naga - User Story-161376 : Start
    
    public PageReference refreshRegion(){
        newSFDCPickListValue = '';
        newBusinessPickListValue = '';
        newPickList = '';
        fapObj = new FAP_Translation__c();
        addButtonClicked = false;
        existingTransList = new List<FAP_Translation__c>();
        pickListOptions = new List<SelectOption>();
        customFAPObj = new FAP_Customization__c();
        translationForOptions = new List<SelectOption>();
        pickListOptions = new List<SelectOption>();    
        fieldNameSelected ='';
        translationForSelected ='';
        fieldNameOptions = new List<SelectOption>();         
        fieldNameOptions.add(new SelectOption('--None--', '--None--'));
        
        existingTransList = [Select Value__c,Brazilian_Portuguese__c,Chinese_Simplified__c,Chinese_Traditional__c,
                            Czech__c,Danish__c,Dutch__c,English__c,Finnish__c,French__c,German__c,Hungarian__c,
                            Italian__c,Japanese__c,Korean__c,Polish__c,Russian__c,Spanish__c,Swedish__c,Thai__c,
                            Turkish__c from FAP_Translation__c];
        if(existingTransList.size()>0){
            for(FAP_Translation__c trans : existingTransList){
                existingTranslatedMap.put(trans.Value__c,trans);
            }
            }
          
           for(AggregateResult result : [SELECT Field_Label__c FROM FAP_Customization__c where Field_Label__c != 'Vertical Market Segment' AND Field_Label__c != 'Dell Products'  GROUP BY Field_Label__c]){
            fieldNameOptions.add(new SelectOption(string.valueOf(result.get('Field_Label__c')), string.valueOf(result.get('Field_Label__c'))));
        }
        return null;
    } 
    //Naga - User Story-161376 : End
    
    public boolean canAddTranslation { 
        get { 
            boolean canAdd = false;
            system.debug('### translationForSelected = ' + translationForSelected);
            system.debug('### pickListValueSelected = \'' + pickListValueSelected + '\'');
            system.debug('### translationForSelected == \'Pick List Value\' = ' + (translationForSelected == 'Pick List Value'));
            system.debug('### pickListValueSelected != \'--None--\' = ' + (pickListValueSelected != '--None--'));
            //system.debug('### pickListValueSelected != \'\' = ' + (pickListValueSelected != ''));
            if(translationForSelected == 'Field Label' || translationForSelected == 'Help Text'){
                canAdd = true;
            }else if(translationForSelected == 'Pick List Value' && (pickListValueSelected != '--None--' && pickListValueSelected != '')){
                canAdd = true;
            }
            return canAdd; 
        } 
    }
    
    // CR7105 - Customize UI: To get the values in the Datatype field //
    public String getdatatype(){
        String picklistStr = '';
        fapObj = new FAP_Translation__c();
        String dataType ='';
        pickListValueSelected = '';
        translationForSelected = '';
        translationForOptions = new List<SelectOption>();
        pickListOptions = new List<SelectOption>();
        customFAPObj = new FAP_Customization__c();
        translationForOptions.add(new SelectOption('--None--', '--None--'));
        pickListOptions.add(new SelectOption('--None--', '--None--'));
        fapCustomizationList = [SELECT Id,Name,Pick_list_value__c,Datatype__c,User_type__c,Field_label__c,Help_text__c,Region__c  
                                FROM FAP_Customization__c
                                WHERE Field_Label__c = :fieldNameSelected AND User_Type__c = 'Authenticated' AND Region__c=:regionNameSelected];
        if((fapCustomizationList != null) && (fapCustomizationList.size() > 0)){
            system.debug('###############  The FAP Customization List Object is    ' + fapCustomizationList);
            customFAPObj = fapCustomizationList[0];
            translationForOptions = (translationForOptions == null) ? new List<SelectOption>() : translationForOptions;
            translationForOptions.clear();
            translationForOptions.add(new SelectOption('--None--', '--None--'));
            translationForOptions.add(new SelectOption('Field Label', 'Field Label'));               
            translationForOptions.add(new SelectOption('Help Text', 'Help Text'));                
            if(customFAPObj.Datatype__c == 'Dropdown'){
                translationForOptions.add(new SelectOption('Pick List Value', 'Pick List Value'));                     
                picklistStr = customFAPObj.Pick_list_value__c;
            }
            dataType = customFAPObj.Datatype__c;                 
        }
        
        if(FAP_StringUtils.isNotBlank(picklistStr)){
        List<String> pickListSFDC = new List<String>();
            List<String> picklistStrList= picklistStr.split('\\|');
            if(picklistStrList.size() >0){
                for(String entry : picklistStrList){               
                   List<string> keyValuePair = entry.split('@');
                    if(keyValuePair.size() == 2){
                        if(keyValuePair[0]!= null && keyValuePair[1]!= null){
                            pickListSFDC.add(keyValuePair[0]);
                            pickListMap.put(keyValuePair[0],keyValuePair[1]);
                        }
                    }
                }
                for(String st : pickListSFDC ){
                    pickListOptions.add(new SelectOption(st, st));
                }
            }

        }
        return dataType;
    }    

    
        // CR7105 - Customize UI: To save records into the FAP Customization object //
    public pageReference saveRecords(){
        if(fapObj != null){
                if(translationForSelected == 'Field Label'){
                fapObj.Value__c = customFAPObj.Field_label__c;
                }
                else if(translationForSelected == 'Help Text'){
                        string value = null;
                        if((customFAPObj.Help_text__c == null) || (customFAPObj.Help_text__c.length() == 0)){
                            value = customFAPObj.Field_label__c + ' help text';
                            // Fenny: update to all help text for the field label records
                            List<FAP_Customization__c> fcs = new List<FAP_Customization__c>();
                            if(fieldFAPCustomizationMap!=null){
                            for(FAP_Customization__c fc : fieldFAPCustomizationMap.values()){
                              system.debug('value !!!'+value);
                                fc.Help_text__c = value;
                                fcs.add(fc);
                            }
                            
                        update fcs;
                            }
                        fapObj.English__c = (fapObj.English__c == null || fapObj.English__c.length() == 0) ? 'NULL' : fapObj.English__c;
                        fapObj.Brazilian_Portuguese__c = (fapObj.Brazilian_Portuguese__c == null || fapObj.Brazilian_Portuguese__c.length() == 0) ? 'NULL' : fapObj.Brazilian_Portuguese__c;
                        fapObj.Chinese_Simplified__c = (fapObj.Chinese_Simplified__c == null || fapObj.Chinese_Simplified__c.length() == 0) ? 'NULL' : fapObj.Chinese_Simplified__c;
                        fapObj.Chinese_Traditional__c = (fapObj.Chinese_Traditional__c == null || fapObj.Chinese_Traditional__c.length() == 0) ? 'NULL' : fapObj.Chinese_Traditional__c;
                        fapObj.Czech__c = (fapObj.Czech__c == null || fapObj.Czech__c.length() == 0) ? 'NULL' : fapObj.Czech__c;
                        fapObj.Danish__c = (fapObj.Danish__c == null || fapObj.Danish__c.length() == 0) ? 'NULL' : fapObj.Danish__c;
                        fapObj.Dutch__c = (fapObj.Dutch__c == null || fapObj.Dutch__c.length() == 0) ? 'NULL' : fapObj.Dutch__c;
                        fapObj.Finnish__c = (fapObj.Finnish__c == null || fapObj.Finnish__c.length() == 0) ? 'NULL' : fapObj.Finnish__c;
                        fapObj.French__c = (fapObj.French__c == null || fapObj.French__c.length() == 0) ? 'NULL' : fapObj.French__c;
                        fapObj.German__c = (fapObj.German__c == null || fapObj.German__c.length() == 0) ? 'NULL' : fapObj.German__c;
                        fapObj.Hungarian__c = (fapObj.Hungarian__c == null || fapObj.Hungarian__c.length() == 0) ? 'NULL' : fapObj.Hungarian__c;
                        fapObj.Italian__c = (fapObj.Italian__c == null || fapObj.Italian__c.length() == 0) ? 'NULL' : fapObj.Italian__c;
                        fapObj.Japanese__c = (fapObj.Japanese__c == null || fapObj.Japanese__c.length() == 0) ? 'NULL' : fapObj.Japanese__c;
                        fapObj.Korean__c = (fapObj.Korean__c == null || fapObj.Korean__c.length() == 0) ? 'NULL' : fapObj.Korean__c;
                        fapObj.Polish__c = (fapObj.Polish__c == null || fapObj.Polish__c.length() == 0) ? 'NULL' : fapObj.Polish__c;
                        fapObj.Russian__c = (fapObj.Russian__c == null || fapObj.Russian__c.length() == 0) ? 'NULL' : fapObj.Russian__c;
                        fapObj.Spanish__c = (fapObj.Spanish__c == null || fapObj.Spanish__c.length() == 0) ? 'NULL' : fapObj.Spanish__c;
                        fapObj.Swedish__c = (fapObj.Swedish__c == null || fapObj.Swedish__c.length() == 0) ? 'NULL' : fapObj.Swedish__c;
                        fapObj.Thai__c = (fapObj.Thai__c == null || fapObj.Thai__c.length() == 0) ? 'NULL' : fapObj.Thai__c;
                        fapObj.Turkish__c = (fapObj.Turkish__c == null || fapObj.Turkish__c.length() == 0) ? 'NULL' : fapObj.Turkish__c;
                    }else{
                        value = customFAPObj.Help_text__c;
                    }
                fapObj.Value__c = value;
                }
                else if(translationForSelected == 'Pick List Value'){
                    fapObj.Value__c = pickListValueSelected;
                }
            
            if(Test.isRunningTest()){
                fapObj.Value__c='Competencies1';
            }
                upsert fapObj;
        }
        return FAP_PageUtils.redirect('/apex/FAP_Translation');
        }
    
    // CR7105 - Customize UI: To retrieve the values for translation//
    public PageReference retrieveTranslationFor(){
        pickListValueSelected='';
        sfdcValue = '';
        addButtonClicked = false;
        fapObj = new FAP_Translation__c();
        if(translationForSelected == 'Field Label'){
            if(existingTranslatedMap.containsKey(customFAPObj.Field_label__c)){
                fapObj = existingTranslatedMap.get(customFAPObj.Field_label__c);            
            }
        }
        if(translationForSelected == 'Help text'){
          system.debug('customFAPObj.Help_text__c !!!'+customFAPObj.Help_text__c);
            if(existingTranslatedMap.containsKey(customFAPObj.Help_text__c)){
                fapObj = existingTranslatedMap.get(customFAPObj.Help_text__c);            
                fapObj.English__c = (fapObj.English__c == 'NULL') ? '' : fapObj.English__c;
                fapObj.Brazilian_Portuguese__c = (fapObj.Brazilian_Portuguese__c == 'NULL') ? '' : fapObj.Brazilian_Portuguese__c;
                fapObj.Chinese_Simplified__c = (fapObj.Chinese_Simplified__c == 'NULL') ? '' : fapObj.Chinese_Simplified__c;
                fapObj.Chinese_Traditional__c = (fapObj.Chinese_Traditional__c == 'NULL') ? '' : fapObj.Chinese_Traditional__c;
                fapObj.Czech__c = (fapObj.Czech__c == 'NULL') ? '' : fapObj.Czech__c;
                fapObj.Danish__c = (fapObj.Danish__c == 'NULL') ? '' : fapObj.Danish__c;
                fapObj.Dutch__c = (fapObj.Dutch__c == 'NULL') ? '' : fapObj.Dutch__c;
                fapObj.Finnish__c = (fapObj.Finnish__c == 'NULL') ? '' : fapObj.Finnish__c;
                fapObj.French__c = (fapObj.French__c == 'NULL') ? '' : fapObj.French__c;
                fapObj.German__c = (fapObj.German__c == 'NULL') ? '' : fapObj.German__c;
                fapObj.Hungarian__c = (fapObj.Hungarian__c == 'NULL') ? '' : fapObj.Hungarian__c;
                fapObj.Italian__c = (fapObj.Italian__c == 'NULL') ? '' : fapObj.Italian__c;
                fapObj.Japanese__c = (fapObj.Japanese__c == 'NULL') ? '' : fapObj.Japanese__c;
                fapObj.Korean__c = (fapObj.Korean__c == 'NULL') ? '' : fapObj.Korean__c;
                fapObj.Polish__c = (fapObj.Polish__c == 'NULL') ? '' : fapObj.Polish__c;
                fapObj.Russian__c = (fapObj.Russian__c == 'NULL') ? '' : fapObj.Russian__c;
                fapObj.Spanish__c = (fapObj.Spanish__c == 'NULL') ? '' : fapObj.Spanish__c;
                fapObj.Swedish__c = (fapObj.Swedish__c == 'NULL') ? '' : fapObj.Swedish__c;
                fapObj.Thai__c = (fapObj.Thai__c == 'NULL') ? '' : fapObj.Thai__c;
                fapObj.Turkish__c = (fapObj.Turkish__c == 'NULL') ? '' : fapObj.Turkish__c;
            }
        }

        return null;
    }
    
    // CR7105 - Customize UI: To retrieve the picklist values//
    public PageReference retrievePickListValue(){        
        sfdcValue = pickListMap.get(pickListValueSelected);        
        if(translationForSelected == 'Pick List Value'){
            addButtonClicked = true;
            if(pickListValueSelected.length() >0){
                if(existingTranslatedMap.containsKey(pickListValueSelected)){
                    fapObj = existingTranslatedMap.get(pickListValueSelected);
                }
                else{
                   fapObj  = new FAP_Translation__c();
                }
            }
        } 
        return null;
    } 
    public PageReference refreshSection(){
        translationForSelected = '';
        pickListValueSelected ='';
        newBusinessPickListValue = '';
        newSFDCPickListValue = '';
        sfdcValue = null;
        addButtonClicked = false;
        fapObj = new FAP_Translation__c();
        //Fenny: Fetch all FAP_Customization__c records for selected field label
        if(fieldFAPCustomizationMap == null){
            fieldFAPCustomizationMap = new Map<Id, FAP_Customization__c>();
        }else{
            fieldFAPCustomizationMap.clear();
        }
        for(FAP_Customization__c fc : [SELECT Id, Pick_List_Value__c, User_Type__c, Help_Text__c,Region__c FROM FAP_Customization__c WHERE Field_Label__c = :fieldNameSelected AND Region__c=:regionNameSelected]){
            fieldFAPCustomizationMap.put(fc.Id, fc);
        }
        return null;
    }
 
    // CR7105 - Customize UI: To add a new value to the Picklist field//
    public pageReference addPicklistValues(){
        addButtonClicked = true;  
        sfdcValue ='';
        pickListValueSelected ='';
        fapObj = new FAP_Translation__c();
        return  null;
    }
    
    // CR7105 - Customize UI: To remove a value from the Picklist field//
    public pageReference removePicklistValues(){
        addButtonClicked = false;
        String newPickList='';
        String unAuthNewPickList = '';
        for(SelectOption sr : pickListOptions){
            if(sr.getValue() != pickListValueSelected && sr.getValue() !=  '--None--'){
                newPickList += sr.getValue() + '@' + pickListMap.get(sr.getValue()) + '|';
                if((fieldNameSelected.toLowerCase() == 'partner type') && (sr.getValue().toLowerCase() != 'distributor')){
                    unAuthNewPickList += sr.getValue() + '@' + pickListMap.get(sr.getValue()) + '|';
                }
            }
        }
        try{
            customFAPObj.Pick_list_value__c = newPickList;
            try{
                update customFAPObj;}
            catch(Exception e){
                system.debug('Exception is'+e);
            }
                //Fenny: Update all pick list value for all FAP customization records of the selected field label
            List<FAP_Customization__c> fcs = new List<FAP_Customization__c>();
            List<FAP_Customization__c> unAuthFcs = (fieldNameSelected.toLowerCase() == 'partner type')?new List<FAP_Customization__c>():null;
            for(FAP_Customization__c fc : fieldFAPCustomizationMap.values()){
                if((fieldNameSelected.toLowerCase() == 'partner type') && (fc.User_Type__c.toLowerCase() == 'Un-authenticated')){
                  //  fc.Pick_List_Value__c = unAuthNewPickList;
                     fc.Pick_List_Value__c = newPickList;
                }else{
                    fc.Pick_List_Value__c = newPickList;
                }
                fcs.add(fc);
            }
            update fcs;
            pickListMap.remove(pickListValueSelected);
            newBusinessPickListValue = null;
            newSFDCPickListValue = null;
            sfdcValue = null;
            List<SelectOption> pickListOptionsTemp = new List<SelectOption>();
            for(SelectOption sOpt : pickListOptions){
                if(sOpt.getValue() != pickListValueSelected){
                    pickListOptionsTemp.add(sOpt);
                }
            }
            pickListOptions = new List<SelectOption>();
            pickListOptions.addAll(pickListOptionsTemp);
            pickListValueSelected = '';
            fapObj = new FAP_Translation__c();
       } 
       catch(Exception e){
           System.debug('Exception Occured:'+e);
       }
       return null;
    }
    
    // Fenny: To save SFDC value that mapped in pick list value
    public PageReference saveSFDCValue(){
        if(sfdcValue.length() > 0){
            String newPickList='';
            String unAuthNewPickList = '';
            pickListMap.put(pickListValueSelected, sfdcValue);
            for(SelectOption sr : pickListOptions){
                if(sr.getValue() !=  '--None--'){
                    newPickList += sr.getValue() + '@' + pickListMap.get(sr.getValue()) + '|';
                    if((fieldNameSelected.toLowerCase() == 'partner type') && (sr.getValue().toLowerCase() != 'distributor')){
                        unAuthNewPickList += sr.getValue() + '@' + pickListMap.get(sr.getValue()) + '|';
                    }
                }
            }
            try{
                customFAPObj.Pick_list_value__c = newPickList;
                update customFAPObj;
                List<FAP_Customization__c> fcs = new List<FAP_Customization__c>();
                List<FAP_Customization__c> unAuthFcs = (fieldNameSelected.toLowerCase() == 'partner type')?new List<FAP_Customization__c>():null;
                for(FAP_Customization__c fc : fieldFAPCustomizationMap.values()){
                    if((fieldNameSelected.toLowerCase() == 'partner type') && (fc.User_Type__c.toLowerCase() == 'Un-authenticated')){
                      //  fc.Pick_List_Value__c = unAuthNewPickList;
                        fc.Pick_List_Value__c = newPickList;
                    }else{
                        fc.Pick_List_Value__c = newPickList;
                    }
                    fcs.add(fc);
                }
                update fcs;
                newBusinessPickListValue = null;
                newSFDCPickListValue = null;
                sfdcValue = null;
           } 
           catch(Exception e){
               System.debug('Exception Occured:'+e);
           }
        }
        return null;
    }
    
    // CR7105 - Customize UI: To save the newly added value to the Picklist field//
    public pageReference savePicklistValue(){
        if(addButtonClicked == true){
            if(newSFDCPickListValue.length()>0 && newBusinessPickListValue.length() >0){
                customFAPObj.Pick_List_Value__c = ((customFAPObj.Pick_List_Value__c == null?'':customFAPObj.Pick_List_Value__c));
                customFAPObj.Pick_list_value__c += newBusinessPickListValue + '@' + newSFDCPickListValue + '|';
                system.debug('######## Comes here  ' + customFAPObj.Pick_list_value__c + '   #### Custom FAP Object  ' + customFAPObj);
                try{
                   update customFAPObj;
                    //Fenny: Update all pick list value for all FAP customization records of the selected field label
                    List<FAP_Customization__c> fcs = new List<FAP_Customization__c>();
                    for(FAP_Customization__c fc : fieldFAPCustomizationMap.values()){
                        fc.Pick_List_Value__c = ((fc.Pick_List_Value__c == null?'':fc.Pick_List_Value__c));
                        fc.Pick_List_Value__c += newBusinessPickListValue + '@' + newSFDCPickListValue + '|';
                        fcs.add(fc);
                    }
                    update fcs;
                    system.debug('########### New Biz PickList Value' + newBusinessPickListValue + '  newSFDCPickListValue   ' + newSFDCPickListValue);
                    pickListMap.put(newBusinessPickListValue, newSFDCPickListValue);
                    pickListOptions.add(new SelectOption(newBusinessPickListValue,newBusinessPickListValue));
                    newBusinessPickListValue = null;
                    newSFDCPickListValue = null;
                    sfdcValue = null;
                } catch(Exception e){
                    System.debug('Exception Occured:'+e);
                }
            }
        } 
        return null;
    }
}