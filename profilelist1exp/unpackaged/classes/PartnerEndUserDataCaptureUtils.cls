/*---------------------------------------------------------------
Summmary Description : Created for Reusable end user data capture project
History:
    1.0 : 16-Nov-2011: Hanan     : CR 6706,6707,6709 (R13.1)
    1.1 : 13-Dec-2011: Krishna   : CR 6708(R13.1):- Added functionality to create new CMI data Queue records on update.
                                                  - Changed class name
    2.0 : 05-Dec-2012: Jiji      : R14.2: CMAP- To Populate a message to Description Field of Partner Request & defect # 55398
    3.0 : 08-Dec-2015: Anu       :  CR 12370 Duplicate check for End Customer and End Customer Contact
------------------------------------------------------------------*/

Public class PartnerEndUserDataCaptureUtils{

    //CR 6706 : Duplicate check on end user contacts based on  end customer recordId and email field of end customer contact
    public static void DuplicateCheckEndCustomerConatct(Set<Id> idSet,List<End_Customer_Contact__c> ECCList){
        String emailCustomerId;
        Set<Id> ECCIdset=new Set<Id>();
        Map<String,End_Customer_Contact__c> ECCMap=new Map<String,End_Customer_Contact__c>(); 
         
         Map<String,End_Customer__c> ECMap=new Map<String,End_Customer__c>(); 
         for(End_Customer__c ecElt:[select Id,Customer_Id__c from End_Customer__c where id in:idSet]){             
             ECMap.put(ecElt.Id,ecElt);
         }
         
         for(End_Customer_Contact__c ECCElt: ECCList){
            emailCustomerId=String.valueOf(ECCElt.End_Customer__c)+'#'+ String.valueOf(ECCElt.Email__c);
            if (ECCMap.containsKey(emailCustomerId)) {
                ECCElt.addError('Another End Customer Contact has the same End Customer & emailId.');
            }else{
                ECCMap.put(emailCustomerId,ECCElt);
                ECCIdset.add(ECCElt.End_Customer__c);               
            }
        
    }  
    
   
    for(End_Customer_Contact__c ECCElt: [select End_Customer__c,End_Customer__r.Customer_Id__c,Email__c from End_Customer_Contact__c where End_Customer__c IN: ECCIdset]) {
      
        emailCustomerId=String.valueOf(ECCElt.End_Customer__c)+'#'+ String.valueOf(ECCElt.Email__c);
        
        End_Customer_Contact__c ECCvar= ECCMap.get(emailCustomerId);                
        if(ECCvar!=null){
            ECCvar.addError('Another End Customer Contact has the same End Customer & emailId.');
        }                
    }    
    }
    
    //CR 6707
    
    Public static void UpdateExistingEndCustomerDetails(List<Opportunity> opportunityList,Set<Id> EndCstmrIds,Set<Id> ContactIds){
        Map<Id,End_Customer__c> endCstmrMap=new Map<Id,End_Customer__c>([select Name,Account_Department__c,Account_Industry__c,Customer_Id__c,End_User_Account__c,Mailing_city__c,Mailing_country__c,Mailing_State__c,Mailing_street__c,Partner_Account__c,Segment__c,Status__c,Tax_Id__c,Total_of_End_User_Employees__c,Website__c,Zip_Code__c,Mailing_Street2__c,B2BCRTEndUserID__c from End_Customer__c where id in:EndCstmrIds]);         
        Map<Id,End_Customer_Contact__c> endCstmrCntctMap=new Map<Id,End_Customer_Contact__c>([select Name,Email__c,End_Customer__c,Fax__c,Last_Name__c,Mobile__c,Phone__c,Status__c,Title__c from End_Customer_Contact__c where id in:ContactIds]);         
        system.debug('####endCstmrCntctMap'+endCstmrCntctMap);
        for(Opportunity opptyElt:opportunityList){
            //opportunity to end customer mapping
            if(endCstmrMap.size()>0){
                opptyElt.End_User_Account_Name__c=endCstmrMap.get(opptyElt.End_Customer__c).Name; 
                opptyElt.End_User_Registration_Tax_Code__c=endCstmrMap.get(opptyElt.End_Customer__c).Tax_Id__c; 
                opptyElt.End_User_Account_Department__c=endCstmrMap.get(opptyElt.End_Customer__c).Account_Department__c;
                //opptyElt.End_User_Account_Department_VR__c=endCstmrMap.get(opptyElt.End_Customer__c).Account_Department__c;
                opptyElt.End_User_Account_Industry__c=endCstmrMap.get(opptyElt.End_Customer__c).Account_Industry__c;
                opptyElt.End_User_Mailing_Street__c=endCstmrMap.get(opptyElt.End_Customer__c).Mailing_street__c;
                opptyElt.End_User_Mailing_City__c=endCstmrMap.get(opptyElt.End_Customer__c).Mailing_city__c;
                opptyElt.End_User_Mailing_Country__c=endCstmrMap.get(opptyElt.End_Customer__c).Mailing_country__c;
                opptyElt.End_User_Mailing_State_Province_Region__c=endCstmrMap.get(opptyElt.End_Customer__c).Mailing_State__c;
                opptyElt.End_User_Mailing_Zip_Postal_Code__c=endCstmrMap.get(opptyElt.End_Customer__c).Zip_Code__c;
                opptyElt.End_User_Segment__c=endCstmrMap.get(opptyElt.End_Customer__c).Segment__c;
                opptyElt.End_User_Website_URL_Address__c=endCstmrMap.get(opptyElt.End_Customer__c).Website__c;
                opptyElt.B2BCRTEndUserID__c=endCstmrMap.get(opptyElt.End_Customer__c).B2BCRTEndUserID__c;
                opptyElt.Mailing_Street2__c=endCstmrMap.get(opptyElt.End_Customer__c).Mailing_Street2__c;
                system.debug('####opptyElt'+opptyElt);
                System.debug('------------------------ '+opptyElt.B2BCRTEndUserID__c+ ' ----'+endCstmrMap.get(opptyElt.End_Customer__c).B2BCRTEndUserID__c); 
            System.debug('------------------------ '+opptyElt.Mailing_Street2__c+ ' ----'+endCstmrMap.get(opptyElt.End_Customer__c).Mailing_Street2__c);     
            }
            //opportunity to end customer contact mapping
            if(endCstmrCntctMap.size()>0){
                opptyElt.End_User_First_Name__c=endCstmrCntctMap.get(opptyElt.End_Customer_Contact__c).Name; 
                opptyElt.End_User_Last_Name__c=endCstmrCntctMap.get(opptyElt.End_Customer_Contact__c).Last_Name__c; 
                opptyElt.End_User_Mobile__c=endCstmrCntctMap.get(opptyElt.End_Customer_Contact__c).Mobile__c;
                opptyElt.End_User_Phone__c=endCstmrCntctMap.get(opptyElt.End_Customer_Contact__c).Phone__c;
                opptyElt.End_User_Title__c=endCstmrCntctMap.get(opptyElt.End_Customer_Contact__c).Title__c;
                opptyElt.End_User_Email__c=endCstmrCntctMap.get(opptyElt.End_Customer_Contact__c).Email__c;
                opptyElt.End_User_Fax__c=endCstmrCntctMap.get(opptyElt.End_Customer_Contact__c).Fax__c;
            }
        }    
    }
    
  
    
    //CR 6709: DeActivate end customers when partner account is made inactive
    public static void deActivateCustomers(Set<Id> partnerAccountIds){
        List<End_Customer__c> endCustomerList=new List<End_Customer__c>();
        
        for(End_Customer__c customer:[Select id,Status__c,Partner_Account__c,End_User_Account__c from End_Customer__c where Partner_Account__c in:partnerAccountIds]){
            End_Customer__c endCustomer=new End_Customer__c(Id=customer.Id,Status__c='Inactive');
            endCustomerList.add(endCustomer);     
        } 
        
        if(endCustomerList.size()>0){
            Database.SaveResult[] customerUpdate= Database.Update(endCustomerList, false);
        }
    }
    //CR 6709: DeActivate end customer contacts when end customer is made inactive
    public static void deActivateContacts(Set<Id> endCustomerIds){
        List<End_Customer_Contact__c> contactList=new List<End_Customer_Contact__c>();
        
        for(End_Customer_Contact__c contact:[Select id,Status__c from End_Customer_Contact__c where End_Customer__c in:endCustomerIds]){
            End_Customer_Contact__c contactElt=new End_Customer_Contact__c(Id=contact.Id,Status__c='Inactive');
            contactList.add(contactElt);     
        } 
        
        if(contactList.size()>0){
            Database.SaveResult[] contactUpdate= Database.Update(contactList, false);
        }
    }
    
    //CR 6707
    public static void updateDealAssignmentInstruction(List<Opportunity> opptyList,Set<id> customerIds){
        Map<Id,End_Customer__c> customerMap=new Map<Id,End_Customer__c>([select id,End_User_Account__c,end_user_account__r.name,end_user_account__r.Account_ID__c  from End_Customer__c where id in:customerIds]);
        
        
        for(Opportunity opptyElt:opptyList){                      
            if(opptyElt.End_Customer__c==null){
                //opptyElt.addError('no end customer');
            }else if(customerMap.get(opptyElt.End_Customer__c).End_User_Account__c==null){
                //opptyElt.addError('no end user account');
            }else{
                opptyElt.Deal_Assignment_Instruction__c='End Customer is linked to End User Account,  Affinity Account Id: '+ customerMap.get(opptyElt.End_Customer__c).end_user_account__r.Account_ID__c+'    '+
                    'Name: '+customerMap.get(opptyElt.End_Customer__c).End_User_Account__r.name;    
            }
        }
        
    }
    
    
    //CR 6707: function to create  end customer and end customer contact records from oppty
    //function will be called from after insert update trigger of opportunity
    //Public static void CreateCustomerContactPartnerRequest(List<Opportunity> opportunityList,Set<Id> ownerIdSet){
    Public static void CreateCustomerContactPartnerRequest(List<Opportunity> opportunityListWithDuplicates,Set<Id> ownerIdSet){
        Map<Integer,Opportunity> opportunityMap=new Map<Integer,Opportunity>(); 
        List<End_Customer__c> customerList=new List<End_Customer__c>();
        Map<Id,End_Customer__c> endCstmrMap=new Map<Id,End_Customer__c>();
        List<Partner_Request__c> partnerRequests=new List<Partner_Request__c>();
        Map<String,Country__c> countryMap=new Map<STring,Country__c>();
        Set<Id> accIdSet=new Set<Id>();
        Id opptypartnerAccId;
        Map<Id,User> userMap=new Map<Id,User>([select id,contactId,contact.accountId from User where id in:ownerIdSet]);
        //Code Start: R14.2 CMAP:Defect #55398
        Map<Id, End_Customer__c> leadCusMap = new Map<Id, End_Customer__c> ();
        List <Lead> leadtoUpdList = new List<Lead>();
        //Code End: R14.2 CMAP:Defect #55398
        List<Opportunity> opportunityList = new List<Opportunity>(); //added by Anu
        opportunityList = DupCheckOfEndCustomerAndContact(opportunityListWithDuplicates,userMap);//added by Anu
        System.debug('----------------- after DupCheckOfEndCustomerAndContact'+opportunityList);
        if(opportunityList!=null && opportunityList.size()>0){
            for(integer i=0;i<opportunityList.size();i++){
                //Create end customer record
                
                End_Customer__c endCustomer=new End_Customer__c();            
                endCustomer.Name=opportunityList[i].End_User_Account_Name__c; 
                endCustomer.Tax_Id__c=opportunityList[i].End_User_Registration_Tax_Code__c; 
                endCustomer.Account_Department__c=opportunityList[i].End_User_Account_Department__c;                
                endCustomer.Account_Industry__c=opportunityList[i].End_User_Account_Industry__c;
                endCustomer.Mailing_street__c=opportunityList[i].End_User_Mailing_Street__c;
                endCustomer.Mailing_city__c=opportunityList[i].End_User_Mailing_City__c;
                endCustomer.Mailing_country__c=opportunityList[i].End_User_Mailing_Country__c;
                endCustomer.Mailing_State__c=opportunityList[i].End_User_Mailing_State_Province_Region__c;
                endCustomer.Zip_Code__c=opportunityList[i].End_User_Mailing_Zip_Postal_Code__c;
                endCustomer.Segment__c=opportunityList[i].End_User_Segment__c;
                endCustomer.Website__c=opportunityList[i].End_User_Website_URL_Address__c;
                endCustomer.Partner_Account__c=userMap.get(opportunityList[i].ownerId).contact.accountId; 
                endCustomer.B2BCRTEndUserID__c=opportunityList[i].B2BCRTEndUserID__c;
                endCustomer.Mailing_Street2__c=opportunityList[i].Mailing_Street2__c;   
                 System.debug('123------------------------ '+opportunityList[i]+ ' ----'+endCustomer); 
                System.debug('------------------------ '+opportunityList[i].B2BCRTEndUserID__c+ ' ----'+endCustomer.B2BCRTEndUserID__c); 
                System.debug('------------------------ '+opportunityList[i].Mailing_Street2__c+ ' ----'+endCustomer.Mailing_Street2__c);            
                endCustomer.Status__c='Active';
                //Code Start: R14.2 CMAP:Defect #55398
                if(opportunityList[i].Channel_Lead_Id__c != NULL){
                   leadCusMap.Put(opportunityList[i].Channel_Lead_Id__c, endCustomer); 
                   system.Debug('-----leadCusMap---'+leadCusMap);
                }
                //Code End: R14.2 CMAP:Defect #55398
                accIdSet.add(endCustomer.Partner_Account__c);
                customerList.add(endCustomer); 
                opportunityMap.put(i,opportunityList[i]);
               
            }  
        }
        if(customerList.size()>0){
            Database.SaveResult[] customerSaveResultList = Database.Insert(customerList, false);
            System.debug('----------------- end customer Created :'+customerSaveResultList);            
           //Code Start: R14.2 CMAP:Defect #55398
            for(Lead leadRecord :[select id, Search_My_Customer__c from Lead where id IN :leadCusMap.keyset()]){
                leadRecord.Search_My_Customer__c = leadCusMap.get(leadRecord.Id).Id;
                leadtoUpdList.add(leadRecord);
                system.debug('----leadRecord----'+leadRecord);
                system.debug('----leadCusMap.get(leadRecord.Id).Id----'+leadCusMap.get(leadRecord.Id).Id);
                system.debug('----leadtoUpdList----'+leadtoUpdList);
            }
            if(leadtoUpdList.size() > 0){
                Database.SaveResult[] leadUpdResultList = Database.UPDATE(leadtoUpdList, false);
                SYSTEM.DEBUG('----JJJJ---'+leadUpdResultList);
            }
           //Code End: R14.2 CMAP:Defect #55398
           
            Map<Id,Account> partnerAccMap=new Map<Id,Account>([select id,Account_Country__c,Account_Country_Code__c from account where id in:accIdSet]);
            RecordType recType=[SELECT Name,Id,SobjectType FROM RecordType WHERE Name ='New Customer' AND SobjectType='Partner_Request__c'];
            for(Country__c country:[SELECT Name,Id,Partner_Support_Queue_ID__c,Code__c,Dell_Online_Country_Code__c from Country__c]){
                countryMap.put(country.Code__c,country);    
            }
            List<End_Customer_Contact__c> contactList=new List<End_Customer_Contact__c>();
             //opportunity to end customer contact mapping
            for(integer i=0;i<customerSaveResultList.size();i++){
                   System.debug('###Error in insert###'+customerSaveResultList[i].getErrors());
                  if(customerSaveResultList[i].isSuccess()==true){
                    opportunityMap.get(i).end_customer__c=customerSaveResultList[i].getId();
                   } 
                    End_Customer_Contact__c contact=new End_Customer_Contact__c();                    
                    contact.End_Customer__c=customerSaveResultList[i].getId();                    
                    contact.Name=opportunityMap.get(i).End_User_First_Name__c;
                    contact.Last_Name__c=opportunityMap.get(i).End_User_Last_Name__c;
                    contact.Mobile__c=opportunityMap.get(i).End_User_Mobile__c;
                    contact.Phone__c=opportunityMap.get(i).End_User_Phone__c;
                    contact.Title__c=opportunityMap.get(i).End_User_Title__c;
                    contact.Email__c=opportunityMap.get(i).End_User_Email__c;
                    contact.Fax__c=opportunityMap.get(i).End_User_Fax__c;                    
                    contact.Status__c='Active';
                    contactList.add(contact);
                    
                    Partner_Request__c partnerRequest=new Partner_Request__c(); 
                    partnerRequest.Company__c=opportunityMap.get(i).End_User_Account_Name__c; 
                    partnerRequest.Org_Address_1__c=opportunityMap.get(i).End_User_Mailing_Street__c;
                    partnerRequest.Org_City__c=opportunityMap.get(i).End_User_Mailing_City__c;
                    partnerRequest.Org_State__c=opportunityMap.get(i).End_User_Mailing_State_Province_Region__c;
                    partnerRequest.Org_Postal_Code__c=opportunityMap.get(i).End_User_Mailing_Zip_Postal_Code__c;               
                    
                    partnerRequest.End_Customer__c=customerSaveResultList[i].getId(); 
                    partnerRequest.First_Name__c=opportunityMap.get(i).End_User_First_Name__c;
                    partnerRequest.Last_Name__c=opportunityMap.get(i).End_User_Last_Name__c;
                    partnerRequest.Job_Title__c=opportunityMap.get(i).End_User_Title__c;
                    partnerRequest.Email__c=opportunityMap.get(i).End_User_Email__c;
                    partnerRequest.Phone__c=opportunityMap.get(i).End_User_Phone__c;
                    partnerRequest.Mobile__c=opportunityMap.get(i).End_User_Mobile__c;
                    partnerRequest.Fax__c=opportunityMap.get(i).End_User_Fax__c; 
                    partnerRequest.Status__c='New';
                    //Code Start: R14.2 CMAP:To add a Message in the Description Field: FR 7.15
                    if(opportunityMap.get(i).Channel_Lead_Id__c != NULL){
                        partnerRequest.Description__c ='The Customer should be linked to standard SFDC end user Account to which the related lead is linked';
                    }
                    //Code End: R14.2 CMAP:To add a Message in the Description Field: FR 7.15
                    partnerRequest.RecordTypeId=recType.Id;
                  
                    opptypartnerAccId=userMap.get(opportunityList[i].ownerId).contact.accountId;
                    if(partnerAccMap.get(opptypartnerAccId)!=null && partnerAccMap.get(opptypartnerAccId).Account_Country_Code__c!=null){         
                        partnerRequest.Org_Country__c=countryMap.get(partnerAccMap.get(opptypartnerAccId).Account_Country_Code__c).Id;
                        partnerRequest.OwnerId=countryMap.get(partnerAccMap.get(opptypartnerAccId).Account_Country_Code__c).Partner_Support_Queue_ID__c;
                        partnerRequest.Account__c=opptypartnerAccId;
                    } 
                    partnerRequests.add(partnerRequest);
            }
            
            if(contactList.size()>0){
                Database.SaveResult[] contactSaveResultList = Database.Insert(contactList, false);
                for(integer i=0;i<contactSaveResultList.size();i++){
                    if(contactSaveResultList[i].isSuccess()==true){
                        opportunityMap.get(i).end_customer_contact__c=contactSaveResultList[i].getId();    
                    }    
                }      
            }
            System.debug('^^^^^^^^^^^^^ partnerRequests '+partnerRequests);
            if(partnerRequests.size()>0){    
               
                Database.SaveResult[] partnerReqResultList = Database.Insert(partnerRequests, false);
                //Code Start: R14.2 CMAP:To add a Message in the Description Field: FR 7.15
                for(integer i=0;i<partnerReqResultList.size();i++){
                    if(partnerReqResultList[i].isSuccess()==False){
                        System.Debug('Error while inserting Partner Request Record'+partnerReqResultList[i]);   
                    }    
                }
                //Code End: R14.2 CMAP:To add a Message in the Description Field: FR 7.15
            }
           
            
        }  
    }//end of method
    
    /**
     ** This method is to avoid duplicate End Customer and End customer contact get created in the system 
     ** Condition: if opportunirt RT= Deal registration and Save End Customer to my List = Yes
     **  Search for any end customer exists for that partner Account with name=End User Account Name and Country= end user mailing country
     **   if End Customer exists,check whether end customer exists for that end customer witth email = End User Email entered in Opp
     **      if contact exists, then mark the Save end customer to my list=NO
     **      else create the end customer
     **   else, if end cistomer does not exists, follow the existing flow.(create end customer, end customer contact and PR)
    **/

    
    Public static List<Opportunity> DupCheckOfEndCustomerAndContact(List<Opportunity> opportunityList,Map<Id,User> userMap){
        List<String> listOfAllEC = new List<String>();
        List<String> listOfAllECC = new List<String>();
        Set<String> countrySet = new Set<String>();
        Set<String> oppEmailIdSet = new Set<String>();
        //Map<newEndCustomer,Opportunity> newECustomersMap = new Map<newEndCustomer,Opportunity>();
        Set<Id> partnerAccIdSet = new Set<Id>();
        Map<String,End_Customer__c> mapOfEndCustmer = new Map<String,End_Customer__c>();
        Map<Id,String> endCustIdMap = new Map<Id,String>();
        Map<Id,Set<String>> enscustContactMap = new Map<Id,Set<String>>();
        Set<String> unitqEmailSet = new Set<String>();
        List<End_Customer_Contact__c> createEndCustContactList = new List<End_Customer_Contact__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String,Id> endCustomerContMap = new Map<String,Id>();
    
    for(User u:userMap.values()){
        partnerAccIdSet.add(u.contact.accountId);
    }
    for(Opportunity Opp1:opportunityList){
        countrySet.add(opp1.End_User_Mailing_Country__c);
        oppEmailIdSet.add(opp1.End_User_Email__c);
    }
    System.debug('^^^^^^^^^^^^^ countrySet '+countrySet);
    System.debug('^^^^^^^^^^^^^ partnerAccIdSet '+partnerAccIdSet);
    System.debug('^^^^^^^^^^^^^ oppEmailIdSet '+oppEmailIdSet);
    if(partnerAccIdSet.size()>0){
        For(End_Customer__c ec: [SELECT id,name,Mailing_country__c,Partner_Account__c,Partner_Account__r.name FROM End_Customer__c WHERE Partner_Account__c IN:partnerAccIdSet AND Status__c ='Active' AND Mailing_country__c IN:CountrySet ORDER BY LastModifiedDate DESC NULLS LAST]){
                String uniqIden = ec.Name.toUpperCase()+ec.Mailing_country__c+ec.Partner_Account__c;
                endCustIdMap.put(ec.id,uniqIden);
                mapOfEndCustmer.put(uniqIden,ec);
        }
    }
    System.debug('^^^^^^^^^^^^^ endCustIdMap '+endCustIdMap);
    System.debug('^^^^^^^^^^^^^ mapOfEndCustmer '+ mapOfEndCustmer);
    if(endCustIdMap.size()>0){
        for(End_Customer_Contact__c ecc: [select ID,Email__c,End_Customer__c,End_Customer__r.name,End_Customer__r.Mailing_country__c,End_Customer__r.Partner_Account__c from End_Customer_Contact__c WHERE End_Customer__c IN:endCustIdMap.keySet() AND Email__c IN: oppEmailIdSet AND Status__c ='Active' ORDER BY LastModifiedDate DESC NULLS LAST]){
                if(enscustContactMap.containsKey(ecc.End_Customer__c)){
                    enscustContactMap.get(ecc.End_Customer__c).add(ecc.Email__c);
                }else{
                    enscustContactMap.put(ecc.End_Customer__c,new Set<String>{ecc.Email__c});
                    endCustomerContMap.put(ecc.End_Customer__c+':'+ecc.Email__c,ecc.id);
                }
        }
    }
    System.debug('^^^^^^^^^^^^^ enscustContactMap '+ enscustContactMap);
    for(Opportunity opp:opportunityList){
        String uniqEC = opp.End_User_Account_Name__c.toUpperCase() + opp.End_User_Mailing_Country__c+userMap.get(opp.ownerId).contact.accountId;
        String uniqECC = uniqEC+opp.End_User_Email__c;
        //checking if end customer exists, check whether contact exists with same email id
        if(mapOfEndCustmer.containsKey(uniqEC)){
            System.debug('^^^^^^^^^^^^^^^uniqEC: '+uniqEC);
            //check for end customer contact
            Id endCustId = mapOfEndCustmer.get(uniqEC).Id;
            System.debug('^^^^^^^^^^^^^^^endCustId : '+endCustId );
            System.debug('^^^^^^^^^^^^^^^enscustContactMap: '+enscustContactMap);
            if(enscustContactMap.containsKey(endCustId)){
            System.debug('^^^^^^^^^^^^^^^END CUSTOMER EXISTS: ');
                if(!enscustContactMap.get(endCustId).contains(opp.End_User_Email__c) || enscustContactMap.size()==0){//if contact map doesnot contain email id from opp, then create
                     System.debug('^^^^^^^^^^^^^^^END CUSTOMER contact to create: ');
                     if(!unitqEmailSet.contains(uniqECC)){
                        unitqEmailSet.add(uniqECC);
                        End_Customer_Contact__c eContact=new End_Customer_Contact__c();                    
                        eContact.End_Customer__c=endCustId;                    
                        eContact.Name=opp.End_User_First_Name__c;
                        eContact.Last_Name__c=opp.End_User_Last_Name__c;
                        eContact.Mobile__c=opp.End_User_Mobile__c;
                        eContact.Phone__c=opp.End_User_Phone__c;
                        eContact.Title__c=opp.End_User_Title__c;
                        eContact.Email__c=opp.End_User_Email__c;
                        eContact.Fax__c=opp.End_User_Fax__c;                    
                        eContact.Status__c='Active';
                        createEndCustContactList.add(eContact);
                        opp.End_Customer__c = endCustId;
                        System.debug('%%%%%%%%%  opp end cust :'+opp.End_Customer__c );
                        
                     }else{// if contact also existing make Save_End_Customer_to_my_list__c=NO
                        opp.Save_End_Customer_to_my_list__c ='No';
                        opp.End_Customer__c = mapOfEndCustmer.get(uniqEC).id;
                        opp.End_Customer_Contact__c = endCustomerContMap.get(endCustId+':'+opp.End_User_Email__c);
                        System.debug('^^^^^^^^^^^^^^^opp save to NO : '+opp);
                     }
                }else{// if contact also existing make Save_End_Customer_to_my_list__c=NO
                        opp.Save_End_Customer_to_my_list__c ='No';
                        opp.End_Customer__c = mapOfEndCustmer.get(uniqEC).id;
                        opp.End_Customer_Contact__c = endCustomerContMap.get(endCustId+':'+opp.End_User_Email__c);
                        System.debug('^^^^^^^^^^^^^^^opp save to NO : '+opp);
                     }
            }else{
                End_Customer_Contact__c eContact=new End_Customer_Contact__c();                    
                eContact.End_Customer__c=endCustId;                    
                eContact.Name=opp.End_User_First_Name__c;
                eContact.Last_Name__c=opp.End_User_Last_Name__c;
                eContact.Mobile__c=opp.End_User_Mobile__c;
                eContact.Phone__c=opp.End_User_Phone__c;
                eContact.Title__c=opp.End_User_Title__c;
                eContact.Email__c=opp.End_User_Email__c;
                eContact.Fax__c=opp.End_User_Fax__c;                    
                eContact.Status__c='Active';
                createEndCustContactList.add(eContact);
                opp.End_Customer__c = endCustId;
                System.debug('%%%%%%%%% 123 opp end cust :'+opp.End_Customer__c );
            }
        }else{//if end customer does not exists we need to create both end customer and contact
            oppList.add(opp);
        }
    }
    
    System.debug('^^^^^^^^^^^^^^^createEndCustContactList : '+createEndCustContactList);
    System.debug('^^^^^^^^^^^^^^^oppList : '+oppList);
    
    if(createEndCustContactList.size()>0){
        insert createEndCustContactList;
    }
    
    if(oppList.size()>0){
        return oppList;
    }else{
        return null;
    }


}//end of method
   
    /**************/
    
   
    /* Rev 1.1 : (CR 6708) method for creating new CMI Data Queue records.*/ 
    public static void createCMIQueueRecords(Set<Id> IdSet, String type){   
        
        if(idSet ==null || idSet.size() ==0){
            return;
        }   
        //check for existing CMI queue records with "Pending" status
        String queryStr = 'SELECT Account__c, Status__c, Type__c FROM CMI_Data_Queue__c ' +
                        'WHERE Status__c = \'Pending\' ' +
                        'AND Type__c = \''+ type + '\' '  +
                        'AND Account__c IN :IdSet';
        
        //execute the query and type cast the result list to CMI Data queue list.
        List<CMI_Data_Queue__c> cmiDataQueueList = (List<CMI_Data_Queue__c>)Database.query(queryStr);
        
        for(CMI_Data_Queue__c  cmiDataQueue : cmiDataQueueList){        
            Id recordId = cmiDataQueue.Account__c;
            if(IdSet.contains(recordId)){
                IdSet.remove(recordId); //no new queue record to be created, so removing the Id
                
                if(IdSet.isEmpty()){
                    return;
                }
            }           
        }// end of for loop
        
        cmiDataQueueList = new List<CMI_Data_Queue__c>(); //reusing the same variable
        
        for (Id recordId : IdSet){
            CMI_Data_Queue__c queueItem =  new CMI_Data_Queue__c (Type__c = type, Status__c = 'Pending', No_of_retries__c = 0);
            if(type == 'Account'){
                queueItem.Account__c = recordId;            
            }       
            //else TBD
            
            cmiDataQueueList.add(queueItem);        
        }
        if(cmiDataQueueList.size()>0){
            Database.insert(cmiDataQueueList, false);
        }
        
    }
    
    
    
}//end of class