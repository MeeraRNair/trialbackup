/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Sheeba      27-May-2012     13.7        7105    To enhance the Search Page
*/

public class FAP_CustomizationController{   
    public FAP_Customization__c fapCustObj{get;set;}
    public List<String>hiddenStrList = new List<String>();      
    public List<String>regularStrList = new List<String>();     
    //public List<String>advancedStrList = new List<String>();         
    public List<String> selectedHidden { get; set; }
    public List<String> selectedRegular { get; set; }
    //public List<String> selectedAdvanced { get; set; }
    List<SelectOption> regularOptions = new List<SelectOption>();
    //List<SelectOption> advancedOptions = new List<SelectOption>();
    List<SelectOption> hiddenOptions = new List<SelectOption>(); 
    public Map<String,FAP_Customization__c> existingFAPMap = new Map<String,FAP_Customization__c>(); 
    public String fieldLabel;
    
    //CR7105 - Controller for FAP Customization //
    public FAP_CustomizationController(){
        fapCustObj = new FAP_Customization__c();
        selectedHidden = new List<String>();         
    }  
    
    //CR7105 - Customize UI : doQuery will display a different values in the UI page for every selection of Region and UserType //
       
    public void doquery() {
        try{         
            if(fapCustObj.Region__c!= null && fapCustObj.User_type__c !=null){
               List<FAP_Customization__c>existingFAPCustList = new List<FAP_Customization__c>();    
               system.debug('=11===='+fapCustObj.Region__c);
               system.debug('==22==='+fapCustObj.User_type__c);
               
               existingFAPCustList = [select id,Field_label__c, Name,Location__c,Field_Order__c, User_type__c, Region__c, Is_Active__c from  FAP_Customization__c where Region__c =:fapCustObj.Region__c AND User_type__c =:fapCustObj.User_type__c AND Is_Active__c =:fapCustObj.Is_Active__c Order by Field_Order__c];                             
               hiddenStrList.clear(); 
               regularStrList.clear();
               //advancedStrList.clear();               
                    for(FAP_Customization__c fapObj: existingFAPCustList ){                    
                        if(fapObj.Location__c == 'Hidden'){
                            hiddenStrList.add(fapObj.Field_label__c); 
                                                                                                                               
                        }                         
                        else if(fapObj.Location__c == 'Regular'){ 
                            regularStrList.add(fapObj.Field_label__c);                              
                        }
                       /* else if(fapObj.Location__c == 'Advanced'){ 
                            advancedStrList.add(fapObj.Field_label__c);                              
                        } */                        
                    existingFAPMap.put(fapObj.Field_label__c,fapObj);                    
                    }                     
              }            
           
        }
        
        catch(Exception e){
            System.debug('Exception' +e);
        }
        
    }  
    
    //CR7105 - Customize UI : To display values with Location as Hidden //      
    public List<SelectOption> gethiddenSelectOptions() {  
        hiddenOptions = new List<SelectOption>(); 
        for(String s: hiddenStrList){
            hiddenOptions.add(new SelectOption(s, s));
        }      
        return hiddenOptions ;
    }
    
    //CR7105 - Customize UI : To display values with Location as Regular //    
    public List<SelectOption> getregularSelectOptions() {
        regularOptions = new List<SelectOption>();
        for(String s: regularStrList){
            regularOptions.add(new SelectOption(s, s));              
        }
        system.debug('======regularOptions======'+regularOptions);
        return regularOptions;
    }  
    
    
    //CR7105 - Customize UI : To display values when selected from Hidden Combo to Regular Combo// 
    public void selectToRegular() {
        try{
            if(selectedHidden != null){   
            system.debug('========selectedHidden==='+selectedHidden);
           
            Set<String>strSet = new Set<String>();
            strSet.clear();
            strSet.addAll(selectedhidden);
            Set<String>strRegular = new Set<String>();
            strRegular.addAll(regularStrList);
            //Set<String>strAdvanced = new Set<String>();
            //strAdvanced.addAll(advancedStrList); 
            if((strSet.contains('Distance'))&& (!(strSet.contains('Location') ||
               strRegular.contains('Location') /*|| strAdvanced.contains('Location')*/))){
                    FAP_PageUtils.addError('Distance can be added only if Location exists in Advanced/Regular Search');                           
            }
            else{                                       
                if( selectedHidden.size()+regularStrList.size() <= 15){
                List<String> tempStrListRegular = new List<String>();  
                regularStrList.addAll(selectedHidden); 
                Map<String, Integer> removeFromRegularMap = new Map<String, Integer>();             
                for(Integer i=0 ; i< selectedHidden.size(); i++){
                    removeFromRegularMap.put(selectedHidden[i], i);
                }
                for(String strTemp : hiddenStrList){
                    if(!(removeFromRegularMap.containsKey(strTemp))){
                        tempStrListRegular.Add(strTemp);
                    } 
                    
                }   
                hiddenStrList.clear(); 
                hiddenStrList.addAll(tempStrListRegular);              
            }
            else{
                FAP_PageUtils.addError('Total number of fields at regular search is limited to 9');
                //return; //Commented this line by Shravan on 23/12/2018
                system.debug('inside err');
            }
          }
        }
        }
        catch(Exception e){
            System.debug('Exception' +e);
        }
    } 
    
    
    //CR7105 - Customize UI : To display values when selected from Regular Combo to Hidden Combo//       
    public void unSelectFromRegular() {
        try{
            system.debug('---unselect--'+ selectedRegular);         
            if(selectedRegular != null){                                    
                Set<String>strSet = new Set<String>();
                strSet.clear();
                strSet.addAll(selectedRegular);
                Set<String>strRegular = new Set<String>();
                strRegular.addAll(regularStrList);
                //Set<String>strAdvanced = new Set<String>();
               // strAdvanced.addAll(advancedStrList);   
               system.debug('---strSet-111-'+ strSet);  
               system.debug('---strRegular-222-'+ strRegular);  
                 system.debug('---regularStrList-222-'+ regularStrList);
                 system.debug('---selectedRegular-222-'+ selectedRegular);
                 if((strSet.contains('Location') && ((strRegular.contains('Distance') && 
                    !(strSet.contains('Distance'))) /*|| strAdvanced.contains('Distance')*/))){                   
                        FAP_PageUtils.addError('Location can be removed only if Distance is removed from Regular/Advanced Search');                           
                        return;               
                }
                else{              
                    if((regularStrList.size()- selectedRegular.size()) <1 ){
                        FAP_PageUtils.addError('Minimum of one field should be present in the Regular Search');
                        return;                                        
                    }
                    else{
                        system.debug('inside err');
                    List<String> tempStrListUnSelectRegular = new List<String>();  
                    hiddenStrList.addAll(selectedRegular);  
                    Map<String, Integer> removeFromUnSelectRegularMap = new Map<String, Integer>();             
                    for(Integer i=0 ; i< selectedRegular.size(); i++){
                        removeFromUnSelectRegularMap.put(selectedRegular[i], i);
                    }               
                    for(String str : regularStrList){
                        if(!(removeFromUnSelectRegularMap.containsKey(str))){
                            tempStrListUnSelectRegular.Add(str);
                        }                     
                    }
                    regularStrList.clear(); 
                    regularStrList.addAll(tempStrListUnSelectRegular);  
                }
            }
        }
       }
        catch(Exception e){
            System.debug('Exception' +e);
        }
    }
    
    //CR7105 - Customize UI : To move regular combo values in the upward direction //   
    public void moveUpRegular(){
        try{
            integer indexStart=0;
            integer indexEnd=0;
            List<String> finalRegularList= new List<String>();
            String swapValue;
            List<string> selectedvalues= new List<string>();
            if(selectedRegular != null){
                for(Integer i= 0; i< regularStrList.size(); i++){
                    if(regularStrList[i].equals(selectedRegular[0])){                                
                        indexStart = i;
                        break;
                    }
                    else{
                        if(i-1 >=0){
                            finalRegularList.add(regularStrList[i-1]);
                        }
                    }
                }
            }
                if(indexStart != 0){
                    swapValue = regularStrList[indexStart -1];
                    finalRegularList.addAll(selectedRegular);
                    finalRegularList.add(swapValue);
                    indexEnd = indexStart+selectedRegular.size();
                        for(Integer j = indexEnd ; j< regularStrList.size() ; j++){
                            finalRegularList.add(regularStrList[j]);
                        }
                regularStrList = finalRegularList;
                }
            }
        catch(Exception e){
            System.debug('Exception' +e);
        }
    }
    
    //CR7105 - Customize UI : To move regular combo values in the downward direction //
    public void moveDownRegular(){
        try{
            integer indexStart=0;
            integer indexEnd=0;
            List<String> finalRegularList= new List<String>();
            String swapValue;
            List<string> selectedvalues= new List<string>();
            if(selectedRegular != null){
                for(Integer i= 0; i< regularStrList.size(); i++){
                    if(regularStrList[i].equals(selectedRegular[0])){
                        indexStart = i;
                        break;
                    }
                    else{                                     
                        finalRegularList.add(regularStrList[i]);
                    }
            
                }
            }
                if(indexStart <= regularStrList.size()){
                    swapValue = regularStrList[selectedRegular.size() +indexStart];
                    finalRegularList.add(swapValue);
                    finalRegularList.addAll(selectedRegular);
                    indexEnd = indexStart+selectedRegular.size()+1;
                    for(Integer j = indexEnd ; j< regularStrList.size() ; j++){
                        finalRegularList.add(regularStrList[j]);
                    }
                regularStrList = finalRegularList;
                }
            }
        catch(Exception e){
            System.debug('Exception' +e);
        }
    }
    
    //CR7105 - Customize UI : To update the selected record's Location field & Redirect to the FAP Translation page //
    public pageReference save() {
        List<FAP_Customization__c> toupdatelist = new List<FAP_Customization__c> ();
        for(integer i=0; i<hiddenStrList.size(); i++){         
            FAP_Customization__c  tempFapObj = existingFAPMap.get(hiddenStrList[i]);
            tempFapObj.Location__c = 'Hidden';
            tempFapObj.Field_Order__c = i+1;
            toupdatelist.add(tempFapObj);              
          }
          for(integer i=0; i<regularStrList.size(); i++){          
            FAP_Customization__c  tempFapObj = existingFAPMap.get(regularStrList[i]);
            //CSP Change - Start
            tempFapObj.Location__c = 'Regular';
            //CSP Change - End
            
            tempFapObj.Field_Order__c = i+1;
            toupdatelist.add(tempFapObj);             
          }
          system.debug('=========toupdatelist===='+toupdatelist);
        /*  for(integer i=0; i<advancedStrList.size(); i++){           
            FAP_Customization__c  tempFapObj = existingFAPMap.get(advancedStrList[i]);
            tempFapObj.Location__c = 'Advanced'; 
            tempFapObj.Field_Order__c = i+1;
            toupdatelist.add(tempFapObj);              
        }*/
        update toupdatelist;         
        return FAP_PageUtils.redirect('/apex/FAP_Translation');     
        }       
}