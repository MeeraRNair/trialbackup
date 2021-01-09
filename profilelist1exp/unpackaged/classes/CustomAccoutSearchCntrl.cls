public class CustomAccoutSearchCntrl{
     public string accName {get;set;}
     public string searchstring{get;set;}
     public list <Deal_Program__c> Cpd {get; set;}
     public list <Custom_Partner_Accounts__c> PartnerAcc {get; set;}
     public list <Custom_End_User_Accounts__c> EndUserAcc {get; set;}
     public list <Custom_Distributor_Reseller_Accounts__c> DistributorReseller {get; set;}
    
     public Id ChannelProgramId {get; set;}

     public string AccountType {get; set;}
     public string AccountTypeString {get; set;}

     public boolean errorbool{get; set;}
     public boolean showPartnerAccountDetails {get; set;}
     public boolean showEndUserAccountDetails {get; set;}
     public boolean showDistribitorResellerAccountDetails {get; set;}
     
    public CustomAccoutSearchCntrl(ApexPages.StandardController controller) {
        ChannelProgramId = ApexPages.currentPage().getParameters().get('id'); 
        AccountType = ApexPages.currentPage().getParameters().get('AccType');         
         if(AccountType == 'Partner') AccountTypeString =    'Partner';
        if(AccountType == 'EndUserAcc') AccountTypeString =    'End User';
        if(AccountType == 'Disti/Reseller') AccountTypeString = 'Disti/Reseller';
    }

public void search(){

  PartnerAcc = null;
  EndUserAcc = null;
  DistributorReseller = null;
  errorbool = false;
  
  if(searchstring == null || searchstring == '')
   {
       errorbool = true;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Enter a keyword to search'));
    }
 else
 {
 if(accName == 'Name'){
        Namesearch();     
    }
if(accName == 'Affinity'){
        AffinitySearch();     
    }
    
    showPartnerAccountDetails  = false;
    showEndUserAccountDetails  = false;
    showDistribitorResellerAccountDetails = false; 
    if(PartnerAcc != null &&  PartnerAcc.size() > 0 ) 
       showPartnerAccountDetails =true;
    if(EndUserAcc != null &&  EndUserAcc.size() > 0)
       showEndUserAccountDetails  = true; 
    if(DistributorReseller != null &&  DistributorReseller .size() > 0)
     showDistribitorResellerAccountDetails = true;   
     
    if(showEndUserAccountDetails  == false && showPartnerAccountDetails  == false && showDistribitorResellerAccountDetails == false)
    {
       errorbool = true;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'No search results found'));
    }
    
    system.debug('***' + showEndUserAccountDetails);
    system.debug('***PartnerAcc ' + PartnerAcc );
 }
}


public void Namesearch(){

  try
  {
    String searchquery;
   if(AccountType  == 'Partner')
   {
      searchquery= 'Select Name, Include__c , Exclude__c,Affinity_Id__c,Account_Name__c,Partner_Type__c,Partner_Tier__c,Partner_Relationship__c,Account_Country__c from Custom_Partner_Accounts__c where Deal_Program__c = \'' + ChannelProgramId  + '\' and ' ;
      searchquery += ' Account_Name__c LIKE ' + '\'%' + searchstring + '%\' LIMIT 1000';
          PartnerAcc = database.query(searchquery);
       
         if(PartnerAcc != null &&  PartnerAcc.size() == 1000)
        {
           errorbool = true;
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
        } 

   }
   else if(AccountType  == 'EndUserAcc')
   {
     searchquery = 'Select Name, Include__c , Exclude__c,Affinity_Id__c,Account_Name__c,Account_Country__c,Account_Classification__c,Unassigned_End_user_account__c,Sales_Channel__c,Coverage__c from  Custom_End_User_Accounts__c where Deal_Program__c = \'' + ChannelProgramId  + '\' and ' ;
     searchquery += ' Account_Name__c LIKE ' + '\'%' + searchstring + '%\' LIMIT 1000';  
         EndUserAcc = database.query(searchquery);
     
   
    if(EndUserAcc != null &&  EndUserAcc .size() == 1000)
    {
       errorbool = true;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
    }
   }
      //** Logic for AccountType =DistribitorReseller and fetching records from Custom DistributorReseller Account object if user selects Account Name  search
      else if(AccountType  == 'Disti/Reseller'){
         searchquery = 'Select Name, Include__c , Exclude__c,Affinity_Id__c,Distributor_Reseller_Account_Name__c,Account_Country__c,Partner_Type__c,Partner_Tier__c,Partner_Relationship__c  from  Custom_Distributor_Reseller_Accounts__c where Channel_Program__c = \'' + ChannelProgramId  + '\' and ' ;
     searchquery += ' Distributor_Reseller_Account_Name__c LIKE ' + '\'%' + searchstring + '%\' LIMIT 1000';  
         DistributorReseller = database.query(searchquery);
       if(DistributorReseller != null &&  DistributorReseller .size() == 1000)
    {
       errorbool = true;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
    }    
          
          
          
      }  
      
  }
  catch(Exception ex)
  {
                errorbool = true;
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));     
  } 
}
public void AffinitySearch(){
try
{
   String searchquery;
    if(AccountType  == 'Partner')
       {
          searchquery = 'Select Name, Include__c , Exclude__c,Affinity_Id__c,Partner_Type__c,Partner_Tier__c,Partner_Relationship__c,Account_Country__c,Account_Name__c from Custom_Partner_Accounts__c where Deal_Program__c = \'' + ChannelProgramId  + '\' and ' ;
         searchquery += 'Affinity_Id__c = \'' + searchstring + '\'   LIMIT 1000 ' ;
                   PartnerAcc = database.query(searchquery);
          if(PartnerAcc != null &&  PartnerAcc.size() == 1000)
            {
               errorbool = true;
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
            }
       }
   else if(AccountType  == 'EndUserAcc')
       {
         searchquery = 'Select Name, Include__c , Exclude__c,Affinity_Id__c,Account_Name__c,Account_Country__c,Account_Classification__c,Unassigned_End_user_account__c,Sales_Channel__c,Coverage__c from Custom_End_User_Accounts__c where Deal_Program__c = \'' + ChannelProgramId  + '\' and ' ;
         searchquery += 'Affinity_Id__c = \'' + searchstring + '\'   LIMIT 1000 ' ;
                  EndUserAcc = database.query(searchquery);
        if(EndUserAcc != null &&  EndUserAcc .size() == 1000)
        {
           errorbool = true;
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
        }
    
       }
    // ** Logic for AccountType =DistribitorReseller and fetching records from Custom Distributor Reseller Account object  if user selects affinityid search
    else if(AccountType  == 'Disti/Reseller'){
         searchquery = 'Select Name, Include__c , Exclude__c,Affinity_Id__c,Distributor_Reseller_Account_Name__c,Account_Country__c,Partner_Type__c,Partner_Tier__c,Partner_Relationship__c  from Custom_Distributor_Reseller_Accounts__c where Channel_Program__c = \'' + ChannelProgramId  + '\' and ' ;
         searchquery += 'Affinity_Id__c = \'' + searchstring + '\'   LIMIT 1000 ' ;
                  DistributorReseller = database.query(searchquery);
     if(DistributorReseller != null &&  DistributorReseller .size() == 1000)
        {
           errorbool = true;
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'The search returned more than the maximum number of rows (1000). Please refine your search criteria using Keyword.'));
        }
    }
     }
      
  catch(Exception ex)
  {
                errorbool = true;
       system.debug(ex.getMessage() +ex.getLineNumber());
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()+ ' ' +'Line No:' +ex.getLineNumber()));     
  } 

}
}