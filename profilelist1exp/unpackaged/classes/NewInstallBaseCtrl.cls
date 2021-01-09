/**********************************************************************************************
 * Name         : NewInstallBaseCtrl
 * Description  : CR 9554 ( Autopopulation of fields on install base edit page)
 * Created      : 11-June-2014
 * Created By   : Samridh Manucha
 ************************************************************************************************/

public class NewInstallBaseCtrl{

    public Install_Base__c installbase;
    public Account act;

    public NewInstallBaseCtrl(ApexPages.StandardController controller){

        installBase = (Install_Base__c) controller.getRecord();
        System.debug('### installbase : ' + installBase);
            
    }
    
 /*----Fetching  Name, NumberOfEmployees from account Record to autopopulate it in install base record ----*/
 
    public void getAccount(){           
       
       system.debug('### account id : ' + installBase.Account__c);
       system.debug('### retURL : ' + ApexPages.currentPage().getParameters().get('retURL'));
       system.debug('### install base: ' + installBase.id);
                
       String retURL_id = ApexPages.currentPage().getParameters().get('retURL').substring(1);
        String URLid = retURL_id.substring(0, 15);
       system.debug('### TestretURL_id: ' + retURL_id);
       system.debug('### URLid: ' + URLid);
       if(installBase.Account__c==null && retURL_id.substring(0, 3)!='001')
       {
           installBase = [SELECT Account__c FROM Install_Base__c where id = :retURL_id];           
       }
        system.debug('### TestretURL_id: ' + retURL_id.substring(0, 3)); 
       if(retURL_id.substring(0, 3)=='001')
       {
          //act =[select Name, NumberOfEmployees from account where id =: retURL_id];
           act =[select Name, NumberOfEmployees from account where id =: URLid]; 
       }
       else
       {
           act =[select Name, NumberOfEmployees from account where id =: installBase.Account__c];
       }
       
       system.debug('### account : ' + act);
      
    }

 /*---- Constructing URL to autopopulate LOB,account name and # of employees in install base record-----*/
 
    public String constructUrl(){
            
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
    
        return String.format(
                    System.Label.InstallBase_CreationOverwrite_URL, 
                    new string[] 
                        {
                            installBase.RecordTypeId,
                            ((retURL==null)?('/' + installBase.Account__c):retURL),
                            ((act.NumberOfEmployees==null)?'':String.valueOf(act.NumberOfEmployees)),
                            (installBase.Account__c==null?act.id:installBase.Account__c),
                            EncodingUtil.urlEncode(act.Name,'UTF-8')
                        }
                );
      
    }
    
    public PageReference redirect() {
        
        getAccount();
        
        PageReference pgref = new PageReference(constructUrl());
        pgref.setRedirect(true);
        return pgref;
       
     }      

}