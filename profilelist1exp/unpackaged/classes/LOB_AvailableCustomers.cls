/*
 * Author : Sree Prakash
 *
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 11576    R16.07      29-May-2015     Bikram          Functionality to show a list of LOBS corresponding to the Partner 
                                                                    Account 
 * 2.0      CR 11576    R16.07      29-May-2015     Devika          Functionality to allow users to multi select LOBs which belong to the same 
                                                                    EU Account and Location.
 * 3.0      CR          R16.07      07-Jul-2015     Devika          Filtering only LOBs which are Partner Approved.
 * 4.0      CR 11900    R16.10      02-Sep-2015     Devika          Replace the Location with LOB Award Type,City,State,Subsidiary fields.
 * 5.0      CR 12032    R16.10      01-Oct-2015     Devika          Remove auto population of end user details from End User Account and 
                                                                    auto populate city/state from selected LOB Registration record.     
 * 6.0      CR          R16.12      30-Nov-2015     Devika          To display linkage expiry date column to users. 
 */
   
 
public class LOB_AvailableCustomers 
{
    // Boolean Variables
    Id partnerId = null;
    public boolean ShowColumns {get; set;}
    public boolean ShowBackButton {get; set;}
    
    // Boolean Variable to Enable Button whenever record is selected 
    public Boolean enableButton{get;set;}
    
    //Wrapper Class Variable 
    public List<LobWrapper> lobRecordList {get;set;}

   // Fetching LOB Deatils based on the Account ID 
   public ApexPages.StandardSetController setCon{
        get{
            if(setCon == null){
                partnerId = ApexPages.currentPage().getParameters().get('id');                
                if(partnerId != null){
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select id, LOB_Name__c, Registered_End_User__c,/* Location__c, Location1__c,*/ LOB_registration_status__c, Shared_to_GTM_Partner__c, //Other_Actions__c,
                                                                                           Registered_End_User__r.Name,LOB_Record_ID__c,//Registered_End_User__r.Primary_Contact__c,Registered_End_User__r.Account_Country__c,
                                                                                           //Registered_End_User__r.ShippingStreet,Registered_End_User__r.ShippingCity,Registered_End_User__r.ShippingState,Registered_End_User__r.ShippingPostalCode,
                                                                                           Registered_End_User__r.Tax_Registration_Number__c,//Registered_End_User__r.Primary_Contact__r.FirstName,Registered_End_User__r.Primary_Contact__r.LastName,
                                                                                           //Registered_End_User__r.Primary_Contact__r.Email,Registered_End_User__r.Primary_Contact__r.Phone,Location__r.Name,
                                                                                           LOB_Award_Type__c,City__c,State_Province_Region__c,Subsidiary_Name__c, //v4.0
                                                                                           GTM_Linkage_Expiry_Date__c //6.0
                                                                                           from LOB_Registration__c where Preferred_GTM_Partner_Account__c=: partnerId AND LOB_registration_status__c =: 'Partner(approved)']));
                }
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records 
    public List<LobWrapper> getLOB_Registration(){
        
        ShowColumns = true;
        ShowBackButton = false;
        system.debug('Test==partnerId' + partnerId);
        partnerId = ApexPages.currentPage().getParameters().get('id');
        system.debug('setCon.getResultSize(): ' + setCon.getResultSize());
        if(partnerId == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Partner Account available for this Contact!!'));
            return null;
        }
        else if(setCon.getResultSize() == 0){
            ShowColumns = false;
            ShowBackButton = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.No_LOB_Registration_Granted));
            return null;        
        }else{  
          setCon.setPageSize(setCon.getResultSize());
          lobRecordList = new List<LobWrapper>();
          for(LOB_Registration__c  lob : (List<LOB_Registration__c>) setCon.getRecords()){
          system.debug('****'+lob);
            LobWrapper lobWrapperRecord = new LobWrapper();
            lobWrapperRecord.selected = false;
            lobWrapperRecord.lobRecord = lob;
            lobRecordList.add(lobWrapperRecord);
          }      
          system.debug('****'+lobRecordList);
          return lobRecordList; 
        }       
    }
    
    
    // Check if the LOBs selected are from a single EU and Location and redirect user to Opportunity edit page.
    //Pre populate opportunity fields with values from EU and LOB.
    public pageReference pageRedirect(){
      
      List<Id> selectedLOBs = new List<Id>();
      Set<Account> selectedAccountSet= new Set<Account>();
      Set<String> selectedLocationSet= new Set<String>();
      LOB_Registration__c selectedLOBRecord; // v5.0
      
      for(LobWrapper lob: lobRecordList){
        if(lob.selected){
          if(lob.lobRecord.Registered_End_User__c != null){
            selectedAccountSet.add(lob.lobRecord.Registered_End_User__r);
          }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'LOB with no End User Account selected :'+lob.lobRecord.LOB_Name__c));
            return null;  
          }
          /*******v4.0 Starts********/
          if(lob.lobRecord.LOB_Award_Type__c != null){
            
              String concatenatedRegion = lob.lobRecord.LOB_Award_Type__c;
              
              if(lob.lobRecord.City__c != null){
                concatenatedRegion += lob.lobRecord.City__c.trim();   
              }
              if(lob.lobRecord.State_Province_Region__c != null){
                concatenatedRegion += lob.lobRecord.State_Province_Region__c.trim();
              }
              if(lob.lobRecord.Subsidiary_Name__c != null){
                concatenatedRegion += lob.lobRecord.Subsidiary_Name__c.trim();
              }
              selectedLocationSet.add(concatenatedRegion);  
              
              selectedLOBRecord = lob.lobRecord; //v5.0
                             
              system.debug('***'+selectedLocationSet);           
          }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'LOB with no LOB Award Type selected :'+lob.lobRecord.LOB_Name__c));
            return null;
          }
          /*******v4.0 Ends********/
          selectedLOBs.add(lob.lobRecord.LOB_Record_ID__c);
        }          
      }
      
      if(selectedAccountSet.size() > 1 || selectedLocationSet.size() > 1){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Deal_Multiple_End_User_Accounts_Selected));
        return null;
      }else{
          List<Account> selectedAccountList = new List<Account>(selectedAccountSet);
          Account selectedAccount = selectedAccountList[0];          
          
          
          Date pastDate= Date.today()+43;
          
          
          // ***************************************CR:"12703" Starts Auto Populate Fulfilment Path on Disti deals for the LOB record*********************************
            String stringToAppend;
            if (ApexPages.currentPage().getParameters().get('00NA00000063WJM') != NULL )
            {
                stringToAppend = '&00NA00000063WJM='+ApexPages.currentPage().getParameters().get('00NA00000063WJM');
            }else {
                stringToAppend = '';
            }
           
          PageReference pageRedirect = new PageReference('/006/e?retURL=/apex/PartnerDealRegistration&cancelURL=/apex/PartnerDealRegistration&RecordType=012A0000000VhKk' + stringToAppend);
          
          
           
           
          pageRedirect.getParameters().put('00N70000001mdPS',selectedAccount.Name);
          pageRedirect.getParameters().put('00NA00000043Pva',selectedAccount.Name);
            
   // ***************************************     CR:"12703"  ENDS Auto Populate Fulfilment Path on Disti deals for the LOB record*********************************          
            /* v5.0
            if(selectedAccount.Account_Country__c != null){
              pageRedirect.getParameters().put('00N70000001mdTn',selectedAccount.Account_Country__c);
            } 
            if(selectedAccount.ShippingStreet!= null){
              pageRedirect.getParameters().put('00N70000001mdSs',selectedAccount.ShippingStreet);
            }
            if(selectedAccount.ShippingPostalCode!= null){        
              pageRedirect.getParameters().put('00N70000001mdU8',selectedAccount.ShippingPostalCode);
            } 
            
            if(selectedAccount.Primary_Contact__c != null){
             
              pageRedirect.getParameters().put('00N70000001mdQ0',selectedAccount.Primary_Contact__r.FirstName);
              pageRedirect.getParameters().put('00N70000001mdRP',selectedAccount.Primary_Contact__r.LastName);
              pageRedirect.getParameters().put('00N70000001mdPX',selectedAccount.Primary_Contact__r.Email);
              pageRedirect.getParameters().put('00N70000001mdXn',selectedAccount.Primary_Contact__r.Phone);
              
            } 
            */ 
            
            /**************** v5.0 Starts ************/
            if(selectedLOBRecord != null){
              if(selectedLOBRecord.City__c!= null){
                pageRedirect.getParameters().put('00N70000001mdSm',selectedLOBRecord.City__c);
              }  
              if(selectedLOBRecord.State_Province_Region__c != null){        
                pageRedirect.getParameters().put('00N70000001mdU2',selectedLOBRecord.State_Province_Region__c);
              }        
            }

            /**************** v5.0 Ends ************/
                  
            if(selectedAccount.Tax_Registration_Number__c != null){        
              pageRedirect.getParameters().put('00N7000000284s8',selectedAccount.Tax_Registration_Number__c);
            }        
          
          if(selectedLOBs.size() ==1){
                  pageRedirect.getParameters().put('00NA00000063VVb',selectedLOBs[0]);
          }else{                    
            pageRedirect.getParameters().put('00NA00000063VVb',String.join(selectedLOBs,';'));
          }

          pageRedirect.getParameters().put('00NA0000000b8l9','1');
          pageRedirect.getParameters().put('nooverride','1');
          pageRedirect.getParameters().put('opp9',pastDate.format());
    
          return pageRedirect;
      }
    }
    
    // Function to check if record is selected , then enable the button
    public pageReference checkSelect(){
      enableButton = false;
      for(LobWrapper lob: lobRecordList){
        if(lob.selected){
          enableButton = true;
        }
      } 
      return null; 
    }
    
    // LOB Wrapper class to select multiple records 
    public class LobWrapper{
      
      public Boolean selected {get;set;}
      public LOB_Registration__c lobRecord {get;set;}
      
      public lobWrapper(){
    
      }
    }
}