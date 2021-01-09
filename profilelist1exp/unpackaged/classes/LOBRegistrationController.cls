/*-------------------------------------------------------------------------
Description: Class  for creating LOB Registration records based on LOB Name
CR #2549
Version:1.0 

History:
    
Rev    Date      Author      Remarks
1.0            Manju      created  
2.0    16/12/2011    Azwanti      CR5786 CRQ0241 : change reference to LOB_Name__c field.  
--------------------------------------------------------------------------*/
public class LOBRegistrationController {
    
    //Class Variables
    public String endUserAccountId;
    public Account accountObj;
    public boolean noDup = false;
    public boolean showList = false;
    public boolean noRec = false;
    List<LOB_Registration__c> listOfLOBRegObjects = new List<LOB_Registration__c>();
    public List<LOB_Reg_Class> listOfLobRecords {get; set;}
    
    //Constructor
    public  LOBRegistrationController(ApexPages.StandardController controller){
        endUserAccountId = controller.getId();
        if(endUserAccountId != null){
            accountObj=[SELECT id FROM account WHERE id=:endUserAccountId]; 
        }   
    }
    
    //Method to get the picklist label
    public PageReference generateLOBRegRecords(){
        List<String> pickList = new List<String>();
        List<String> listOfLOBName = new List<String>(); //r2.0
        List<String> strList= new List<String>(); 
        listOfLobRecords = new List<LOB_Reg_Class>();    
        List<LOB_Registration__c> lobObjList = new List<LOB_Registration__c>();
        Map<String,LOB_Registration__c> mapOfLob = new Map<String, LOB_Registration__c>();
        List<LOB_Registration__c> lobList = new List<LOB_Registration__c>();
        Map<string ,LOB_Registration__c> mapOfLobRegistrationObj = new Map<string ,LOB_Registration__c>();
        
        try{
            for(LOB_Registration__c lobRegObj : [SELECT Registered_End_User__c,
                            //CRQ0241 reminder : uncomment after type change   
                            LOB_Name__c,
                            LOB_registration_status__c,
                                          Preferred_GTM_Partner_Account__c, RecordTypeId
                                                 FROM LOB_Registration__c 
                                                 WHERE Registered_End_User__c=:accountObj.Id]){
            //CRQ0241 reminder : uncomment after type change
                mapOfLobRegistrationObj.put(lobRegObj.LOB_Name__c,lobRegObj);
                if(lobRegObj.LOB_registration_status__c == 'Partner(approved)' &&
                    lobRegObj.Preferred_GTM_Partner_Account__c != null){
                    lobObjList.add(lobRegObj);
                }
          }
          //CRQ0241: change reference to LOB_Name__c field
      for(LOB_Administration__c activeLOBReg : [SELECT Name FROM LOB_Administration__c WHERE Active__c = true]){
        listOfLOBName.add(activeLOBReg.Name);
        if(!mapOfLobRegistrationObj.keySet().contains(activeLOBReg.Name)){
          strList.add(activeLOBReg.Name);  
        }
      }
       /*   Schema.Describefieldresult F = LOB_Registration__c.LOB_Name__c.getDescribe();
          List<Schema.Picklistentry> P = F.getPicklistValues();
          for(Schema.Picklistentry pickListValue : P){
              pickList.add(pickListValue.getLabel()); 
                if(!mapOfLobRegistrationObj.keySet().contains(pickListValue.getLabel())){
                  strList.add(pickListValue.getLabel());
                }
          }*/
          if(mapOfLobRegistrationObj.size() == 0){
              createLOB(listOfLOBName);
          }else if(strList.size() > 0){
              createLOB(strList);
          }
          else if(lobObjList.size() > 0){
              showList = true;
              noDup = true;
              noRec = false;
              for(Integer i=0; i<lobObjList.size(); i++){
                  mapOfLob.put(lobObjList[i].LOB_Name__c, lobObjList[i]);
                  lobList = mapOfLob.values();
              } 
              for(Integer j=0; j<lobList.size(); j++){
                  listOfLobRecords.add(new LOB_Reg_Class(lobList[j]));
              }
              return null;
          }else{
            noRec = true;
            showList = false;
            noDup = false;
            return null;
          } 
        }
        catch(Exception excptn){
            PageUtils.addError(excptn.getMessage());
        } 
        return new PageReference('/'+accountObj.Id);
    }
    
    
    //Method to create LOB Registration Records
    public void createLOB(List<String> listOfLOBName){
        Id lobRecTypeId = IdLookupUtils.getRecordTypeId('LOB_registration_before_Approval', 
                  'LOB_Registration__c', true);
        for(Integer i=0; i<listOfLOBName.size(); i++){
            LOB_Registration__c currentLOBReg = new LOB_Registration__c(
                                                Registered_End_User__c = accountObj.id,LOB_registration_status__c='Closed',
                                                   //CRQ0241 reminder : uncomment after type change: 
                                                   LOB_Name__c = listOfLOBName[i],
                                                   RecordTypeId=lobRecTypeId);
            listOfLOBRegObjects.add(currentLOBReg);
        }
        try{
          insert listOfLOBRegObjects;
        }catch(Exception e){
          PageUtils.addError(e.getMessage());
        }
    }
    
    
    //Method to create duplicate LOB records
    public PageReference continuePage(){
        List<LOB_Registration__c> selectedLOB = new List<LOB_Registration__c>();
        LOB_Registration__c lob;
        Id lobRecTypeId = IdLookupUtils.getRecordTypeId('LOB registration(Partner Approved)', 
                'LOB_Registration__c', true);
        for(LOB_Reg_Class lsLOB : listOfLobRecords){
            if(lsLOB.selected == true){
              lob = new LOB_Registration__c(Registered_End_User__c = lsLOB.lobReg.Registered_End_User__c,
                         //CRQ0241 reminder : uncomment after type change
                                      LOB_Name__c = lsLOB.lobReg.LOB_Name__c,
                                      LOB_registration_status__c = lsLOB.lobReg.LOB_registration_status__c,
                                      RecordTypeId=lobRecTypeId);
                selectedLOB.add(lob);
            }
        }
        try{
          if(selectedLOB.size() > 0){
          insert selectedLOB;
          }
        }catch(Exception e){
          PageUtils.addError(e.getMessage());
        }
        return new PageReference('/'+accountObj.Id);
    }
    
    
    public List<LOB_Reg_Class> getLobs(){
        return listOfLobRecords;
    }
    
    //Getter method for the boolean variable noDup
    public boolean getnoDuplicates(){
        return noDup;
    }
    
    //Getter method for the boolean variable V
    public boolean getnoRecords(){
      return noRec;
    }
    
    //Getter method for the boolean variable showList
    public boolean getshowList(){
        return showList;
    }
    
    //Method to go back to previous page
    public PageReference back(){
        return new PageReference('/'+accountObj.Id);
    }
    
    //Wrapper class
    public class LOB_Reg_Class{
        public LOB_Registration__c lobReg {get; set;}
        public Boolean selected {get; set;}
        
        //Constructor for wrapper class
        public LOB_Reg_Class(LOB_Registration__c lob){
            lobReg = lob;
            selected = false;
        }
    }
    
}//End of Class