/*********************************************************************************
 - CR 10832: Logic Implemented
 * 1.Update fields in the original opportunity as below: 
 *      Field update – opportunity type to “Deal/Bid - Indirect”
 *      Field update – Reason Won/Lost to “Deal moved from direct to partner”
 *      Field update – Stage to “Lost/Cancelled – 0%”
 *      Field update – Primary Competitor to “Unknown”
 *      Field update – Associated Opportunity with new Deal Reg record.
 *  2.Auto populate the “Partner Account” , “Partner Sales Email” and “Partner Sales Rep” fields according to the partner user chose in “Opportunity owner” field
 *  3.Updated fields in the new deal reg opportunity as below:
 *      field update –“Stage” field to “Plan 1%”
 *      Field update –“ Engagement type” to “Collaboration”
 *  4.Prevents users to Engage Channel without checking the “Customer Consent to Partner” field. 
 *      Error message:” Customer consent is required to route an opportunity to a channel partner”
 *  5.Only  End user account ISR, AE, GAM, and opportunity owner can use this functionality. Show the standard insufficient privileges message.
 *      Error message:” Insufficient privileges. You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary
 *  6.Verify if original opportunity is Channel RT and deal reg oppty? = yes, if yes, show the following error message:*
 *      "The Channel Engagement feature is not available for existing Deal Registration opportunities 
 *  7.Send the “collaboration opportunity transfer to partner portal” notification to End User Opportunity Owner, Partner opportunity owner, and to the partner account sales team and segment account (dell internal) sales team  
 *  8.CR 12060: Removed the null exceptional error which occur after clicking the save button
 *  9.Now we are sending the email template has a mail to opportunity contact owner after clicking the save button.
 - CR 12728
 * 10. Added logic to set Engage Channel Opportunity Checkbox as to identify the created deal is from Engage Channel which will be approved upon submission.
  -11 - Engage channel Opportunity will be Auto updated to Fulfillment
 * 12 - Take out the DSG_Placeholder_Opportunity__C in SOQL, as this is related to Seahawk code cleanup
 
 - CR 14268
 * 13. Added branching logic for Engage Channel Opp to check for Incumbency
 * CR 15105 Commented by Rajashekar on 13-11-2107 to Removed GC templete 
 
 - CR 15486 
 * 14.0 Commented field by Manthana Murali - Field Trip clean up for Opportunity
 * STORY 5907651 Removed reference for the fields direct_account_name__c,do_you_need_bid_authorization_from_dell__c,
     open_bid_document_no__c and dsg_deal_referral_registration__c by Haribabu.A
 * 15.0 Emily CR16970 - Removed pam__c, registration_and_referral_discount__c
 **********************************************************************************/
public class DealOppCreationCntrl {

    public PageReference Cancel() {
        //delete c;
        //delete a;
        return new PageReference('/'+ParentID);
    }
    Public list<Disti_Relationship__c> listdistaccounts;
    
    Public Account salesAccountObj;
    Id ParentID{set;get;}
    //Contact c{set;get;}
    public Opportunity DealOpp{set;get;}
    public Boolean test{set;get;}
    public Boolean IsAccountTeamMember{set;get;}
    public static String stroppid;
    Public string strCheckPoint;
    //Bikram
    public String IsEngageChannelOpptyURL {set;get;}
    public static String IsEngageChannelOpptyURL {set;get;}
    EmailTemplate emailTemplate = new emailTemplate();
    //public Account a{set;get;}
    public PageReference UpdateSegOpp() {
        /* a = new Account(Name='TestAccount');
        insert a;
        c = new Contact(Status__c='Prospect',FirstName='FirstName', LastName='Lastname', AccountId = a.Id, Email='noreply@dell.com');
        insert c;  */
        Id ParentOpp = ApexPages.currentpage().getParameters().get('SegmentOppID');
        //oppid = parentOpp;
        IsEngageChannelOpptyURL = ApexPages.currentPage().getParameters().get('EngageChannelCB');
        System.debug('ooooooooooo'+ParentOpp);
        Opportunity SegmentOpp= [SELECT Id,Type,StageName,Probability,Reason_Won_Lost__c,Competitor_Lost_To__c,Engage_Channel_Opportunity__c from Opportunity WHERE ID=: ParentOpp  LIMIT 1]; 
        return null;
    }

    public DealOppCreationCntrl(){  
        strCheckPoint='false';
        listdistaccounts=new list<Disti_Relationship__c>();
        
        
        system.debug('Entryyy...');
        Id DealRTypeId = IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity', TRUE);
        Id ChannelOppRTypeId = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity', TRUE);
        Id ParentOpp = ApexPages.currentpage().getParameters().get('SegmentOppID');
        String stroppid = ApexPages.currentpage().getParameters().get('SegmentOppID');
        system.debug('segementId@@@@@@@'+stroppid );
        //Bikram
        IsEngageChannelOpptyURL = ApexPages.currentPage().getParameters().get('EngageChannelCB');
        ParentID = ParentOpp ;
        DealOpp = new Opportunity();
        Id CurrentUserId = UserInfo.getUserId() ;
        Id EndUSerRecordTypeId =  IdLookupUtils.getRecordTypeId('End-User Account','Account', TRUE);
       

        // CR 13268 
        Id partnerUserId = ApexPages.currentpage().getParameters().get('partnerUserId');
        Id salesmotionID = ApexPages.currentpage().getParameters().get('salesmotionID');
        If(salesmotionID != null){
         salesAccountObj = [SELECT Id, Master_Group_Id__c,Partner_Track__c,Partner_Track__r.Purchase_Path__c,Partner_Track__r.Speciality_Product_Purchase_Path__c FROM Account WHERE id =: salesmotionID];
              listdistaccounts=[select id,Disti_Account__c,Disti_Account_Name__c,Contracted_Disti__c,Disti_Account__r.Name,Disti_Account__r.NameLocal,Disti_Account__r.Account_ID__c,Disti_Account__r.Account_Country__c,Disti_Account__r.Billingcity,Disti_Account__r.Billingstate,Disti_Account__r.BillingCountry,Disti_Account__r.Id,Requested_Distributor__c,Requested_Distributor_Status__c,Requested_Distributor_By__c,Requested_Distributor_Date__c,Secondary_Storage_Preferred_Distributor__c, Requested_Secondary_Distributor__c, Requested_Secondary_Distributor_Status__c from Disti_Relationship__c where Reseller_Account__c = :salesmotionID];
        }
        //CR : 13340
        string fulfilmentpath = ApexPages.currentpage().getParameters().get('fulfilmentpath');
        strCheckPoint = ApexPages.currentpage().getParameters().get('checkpoint');
   
          //  emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :'Dell collaboration opportunity transfer to partner portal email'];
        if(ParentOpp != null)
        //v11.0
              DealOpp = [SELECT Account_Country__c,Unweighted_Rev_Formula__c,RecordTypeId ,Quest_Software_Contact__c,Quest_Software_Contact__r.Account.Name,Quest_Software_Contact__r.FirstName,
             Quest_Software_Contact__r.LastName,Quest_Software_Contact__r.MailingStreet,Quest_Software_Contact__r.MailingCity,Quest_Software_Contact__r.MailingCountry,
             Refresh_Situation__c,Created_by_MIB_Process__c,Number_of_Linked_Assets__c,Trigger_Asset_Contract_End_Date__c,MIB_Comments__c,Trigger_Asset_Days_to_Contract_End_Date__c,
             Quest_Software_Contact__r.MailingState,Quest_Software_Contact__r.MailingPostalCode,Quest_Software_Contact__r.Email,Quest_Software_Contact__r.Phone,
             Opportunity_Customer_Number__c,Dell_Asset_RMA__of_Related_Assets__c,End_User_Mailing_Street__c,Engage_Channel_Opportunity__c, PartnerAccount.Name,PartnerAccount.Account_Country__c, Account.Name, Owner.Name,Owner.Email,CampaignId, Associated_Opportunity__c, Collaboration_Type__c,Deal_Reg_Oppty__c, Related_Strategy__c, Customer_Engagement_Event__c, Opportunity_Customer__c, Quest_Unweighted_Margin_Rev__c, Customer_consent_to_engage_partner__c,
             //14.0 Win_Lost_database_URL__c,
             Override_Probability__c,CurrencyIsoCode,OwnerId,AccountId, Type, Deal_ID__c, Deal_Expiration_Timeframe__c, PartnerAccountId, Public_Tender_Type__c, Deal_Registration_Status__c, End_User_Segment__c, Rejection_Reason_Code__c,Quote_Numbers__c, Engagement_Type__c, Other_Rejection_Reason__c, Order_Number__c, Deal_Type__c, Deal_Assignment_Instruction__c, StageName, DGR_Level__c, Probability, Conflicting_Deal_ID__c, Partner_Type__c  ,Is_close_date_changed__c,Name, Partner_Sales_Rep_Name__c  , Partner_Sales_Rep_Email__c, Total_Expected_Dell_Revenue__c, Partner_Sales_Rep_Phone__c,CloseDate,Partner_Opportunity_Stage__c,Distributor_Name__c,Solution_Type__c,Distributor_ID__c,Solution_Name__c,Driving_Solution__c, Region__c, Solution_Scope__c,Competitor_Lost_To__c, Primary_Competitor__c, Other_Competitor_Lost_To__c, BWL__c, Marketing_Comments__c, Proposal_Due_Date__c, Sales_Comments__c, NextStep, Collaborating_with_Dell_Segment_Team__c, Justification_Statement__c, Dell_Systems_and_Services__c, Domain__c,End_User_First_Name__c,End_User_Account_Name__c,End_User_Last_Name__c,End_User_Registration_Tax_Code__c,End_User_Title__c,End_User_Account_ID__c,End_User_Phone__c,End_User_Account_Department__c,End_User_Mobile__c,End_User_Account_Industry__c,End_User_Fax__c,Total_of_End_of_User_Employees__c,End_User_Email__c,End_User_Website_URL_Address__c ,End_User_Mailing_City__c,Is_the_Customer_Part_of_a_Larger_Group__c,End_User_Mailing_State_Province_Region__c,Meeting_with_Customer__c,End_User_Mailing_Zip_Postal_Code__c,Meeting_Date__c,End_User_Mailing_Country__c, /*15.0 ,Registration_and_Referral_Discount__cPAM__c,*/ OSC_Solution_ID__c,Deal_Created_Date_Time__c,Partner_Account_Name__c,Submitted_for_Approval_Date_Time__c,Partner_User_Full_Name__c,Tier_1_Approved_Rejected__c,Tier_1_Approver_Name__c,Deal_Expiration_Date__c,Partner_Submitter_Country__c,Channel_Lead_Id__c FROM Opportunity WHERE id=: ApexPages.currentpage().getParameters().get('SegmentOppID')];        
      
      /*v11.0
             DealOpp = [SELECT Account_Country__c,Unweighted_Rev_Formula__c,RecordTypeId ,Quest_Software_Contact__c,Quest_Software_Contact__r.Account.Name,Quest_Software_Contact__r.FirstName,
             Quest_Software_Contact__r.LastName,Quest_Software_Contact__r.MailingStreet,Quest_Software_Contact__r.MailingCity,Quest_Software_Contact__r.MailingCountry,
             Quest_Software_Contact__r.MailingState,Quest_Software_Contact__r.MailingPostalCode,Quest_Software_Contact__r.Email,Quest_Software_Contact__r.Phone,
             Opportunity_Customer_Number__c,End_User_Mailing_Street__c,Engage_Channel_Opportunity__c, PartnerAccount.Name, Account.Name, Owner.Name,Owner.Email,CampaignId, Associated_Opportunity__c, Collaboration_Type__c,Deal_Reg_Oppty__c, Related_Strategy__c, Customer_Engagement_Event__c, Opportunity_Customer__c, Quest_Unweighted_Margin_Rev__c, Customer_consent_to_engage_partner__c,Win_Lost_database_URL__c, Override_Probability__c,CurrencyIsoCode,OwnerId,AccountId, Type, Deal_ID__c, Deal_Expiration_Timeframe__c, PartnerAccountId, Public_Tender_Type__c, Deal_Registration_Status__c, End_User_Segment__c, Rejection_Reason_Code__c,Quote_Numbers__c, Engagement_Type__c, Other_Rejection_Reason__c, Order_Number__c, Deal_Type__c, Deal_Assignment_Instruction__c, StageName, DGR_Level__c, Probability, Conflicting_Deal_ID__c, Partner_Type__c  ,Is_close_date_changed__c, DSG_Deal_Referral_Registration__c,Name, Partner_Sales_Rep_Name__c  , DSG_Placeholder_Opportunity__c, Partner_Sales_Rep_Email__c, Total_Expected_Dell_Revenue__c, Partner_Sales_Rep_Phone__c,CloseDate,Partner_Opportunity_Stage__c,Distributor_Name__c,Solution_Type__c,Distributor_ID__c,Solution_Name__c,Driving_Solution__c, Region__c, Solution_Scope__c,Competitor_Lost_To__c, Primary_Competitor__c, Other_Competitor_Lost_To__c, Do_you_need_bid_authorization_from_Dell__c, BWL__c, Open_Bid_Document_No__c, Marketing_Comments__c, Proposal_Due_Date__c, Sales_Comments__c, NextStep, Collaborating_with_Dell_Segment_Team__c, Justification_Statement__c, Dell_Systems_and_Services__c, Domain__c,Direct_Account_Name__c,End_User_First_Name__c,End_User_Account_Name__c,End_User_Last_Name__c,End_User_Registration_Tax_Code__c,End_User_Title__c,End_User_Account_ID__c,End_User_Phone__c,End_User_Account_Department__c,End_User_Mobile__c,End_User_Account_Industry__c,End_User_Fax__c,Total_of_End_of_User_Employees__c,End_User_Email__c,End_User_Website_URL_Address__c ,End_User_Mailing_City__c,Is_the_Customer_Part_of_a_Larger_Group__c,End_User_Mailing_State_Province_Region__c,Meeting_with_Customer__c,End_User_Mailing_Zip_Postal_Code__c,Meeting_Date__c,End_User_Mailing_Country__c, Registration_and_Referral_Discount__c,PAM__c,OSC_Solution_ID__c,Deal_Created_Date_Time__c,Partner_Account_Name__c,Submitted_for_Approval_Date_Time__c,Partner_User_Full_Name__c,Tier_1_Approved_Rejected__c,Tier_1_Approver_Name__c,Deal_Expiration_Date__c,Partner_Submitter_Country__c,Account_Play__c,Channel_Lead_Id__c FROM Opportunity WHERE id=: ApexPages.currentpage().getParameters().get('SegmentOppID')];        
     v11.0*/
        /*List<AccountTeamMember> AccTeamMember = [SELECT TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId=: DealOpp.AccountId AND TeamMemberRole IN: (Label.Deal_Opportunity_Valid_Acc_Team_Roles).split(',') AND Account.RecordTypeId=:EndUSerRecordTypeId];
        System.debug('CurrentUserId :'+CurrentUserId +'DealOpp.OwnerId:'+DealOpp.OwnerId);
        for(AccountTeamMember temp: AccTeamMember ){
            if(CurrentUserId == temp.UserId ){
                IsAccountTeamMember=true;
            }
        }
        if(CurrentUserId == DealOpp.OwnerId){                
                IsAccountTeamMember=true;
        }      
        if(DealOpp.Deal_Reg_Oppty__c == 'Yes' && DealOpp.RecordTypeId == ChannelOppRTypeId)
            test = true;*/
        
 
        DealOpp.RecordTypeId = DealRTypeId ;
        DealOpp.Id=null;
        DealOpp.StageName= 'Plan - 1%';
        DealOpp.Probability= 1;
/*Checking whether the Engagement type is Dell Collobaration ot not   */
/* Mohammad- changed deal type to Fulfillment*/
        if(DealOpp.Engagement_Type__c != 'Dell Collaboration')
            {
        DealOpp.Engagement_Type__c = 'Collaboration';
            }
        DealOpp.Collaboration_Type__c = 'Channel Led';
        Dealopp.Type='Deal/Bid - Indirect'; 
        
/* Pawan Kumar Nitin - added branching logic for Engage Channel Opp to check for Incumbency*/ 
        OppProdIncumbencyPopup_Ctrl incumbencyExtension = new OppProdIncumbencyPopup_Ctrl();
        incumbencyExtension.checkForEngageChannelPopUp(ParentOpp);
        
        if( incumbencyExtension.changeDealTypeForEngageChannel){
            Dealopp.Deal_Type__c = 'Incumbency';
        }
        else{
            Dealopp.Deal_Type__c='Fulfillment';    
        }
/* ====== End Of Logic =========*/
        
        DealOpp.Associated_Opportunity__c = ParentOpp ;
        DealOpp.ownerid = partnerUserId; // CR 13268;
       DealOpp.partnerAccountId = salesmotionID; 
        DealOpp.Distributor_Name__c = fulfilmentpath; //CR: 13340
        String rev = DealOpp.Unweighted_Rev_Formula__c;
        rev = rev.split(' ')[1];
        String amount='';
        for(String s : rev.split(',')){
            amount=amount+s;
        }
        DealOpp.End_User_Account_Name__c = DealOpp.Quest_Software_Contact__r.Account.Name;
        DealOpp.End_User_First_Name__c = DealOpp.Quest_Software_Contact__r.FirstName;
        DealOpp.End_User_Last_Name__c = DealOpp.Quest_Software_Contact__r.LastName;
        DealOpp.End_User_Mailing_Street__c = DealOpp.Quest_Software_Contact__r.MailingStreet;
        DealOpp.End_User_Mailing_City__c = DealOpp.Quest_Software_Contact__r.MailingCity;
        DealOpp.End_User_Mailing_Country__c = DealOpp.Quest_Software_Contact__r.MailingCountry;
        DealOpp.End_User_Mailing_State_Province_Region__c = DealOpp.Quest_Software_Contact__r.MailingState;
        DealOpp.End_User_Mailing_Zip_Postal_Code__c = DealOpp.Quest_Software_Contact__r.MailingPostalCode;
        DealOpp.End_User_Email__c = DealOpp.Quest_Software_Contact__r.Email;
        DealOpp.End_User_Phone__c = DealOpp.Quest_Software_Contact__r.Phone;
        
        DealOpp.Total_Expected_Dell_Revenue__c = decimal.valueOf(amount);
        /*if(DealOpp.CloseDate < System.Today()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Segement Opportunity Book Date is less than Today Date, Please go back and change the Book Date.'));
        }*/
    }
    
    public PageReference SaveOpp() {  
     String stroppid = ApexPages.currentpage().getParameters().get('SegmentOppID');
     boolean IsValidationErrorFired = false;
     if((DealOpp.Distributor_Name__c=='Direct Fulfilment') && (salesAccountObj.Partner_Track__r.Purchase_Path__c=='TIER 2' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='DISTRIBUTION' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='InDirect Partner Purchase') && (salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Distribution' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Indirect' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c==null || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Direct')){
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Fulfilment_Path_Error_Msg));
         IsValidationErrorFired = true;
    }   
     else if(strCheckPoint == 'true' && (DealOpp.Distributor_Name__c=='Direct Fulfilment') && (salesAccountObj.Partner_Track__r.Purchase_Path__c=='TIER 1' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='DIRECT' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='Direct Partner Purchase') && (salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Distribution' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Indirect' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c==null)){
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You are not authorized to register Direct Fulfillment deals with EMC Storage products. Please change the Fulfillment Path to Distribution.'));
         IsValidationErrorFired = true;
    } 
     else{
           TriggerControlHandler.setOpportunityTriggersInactive();
           try{
               List<User> u = [SELECT  Name,AccountId, Email FROM USER WHERE id=:DealOpp.OwnerId];
               if(u.size() > 0){
                  List<Account> TempAcc = [SELECT Name FROM Account WHERE Id=: u[0].AccountId];
                  if(TempAcc.size() > 0 ){
                      DealOpp.Partner_Account_Name__c = TempAcc[0].Name;
                      system.debug('The Partner_Account_Name__c  is : ' + DealOpp.Partner_Account_Name__c);
                  }
                  DealOpp.Partner_Sales_Rep_Name__c = u[0].Name;
                  DealOpp.Partner_Sales_Rep_Email__c = u[0].Email;
                  
               }
           }catch(Exception e){
           }
            //User u = [SELECT  Name,AccountId, Email FROM USER WHERE id=:DealOpp.OwnerId LIMIT 1];
            //Account TempAcc = [SELECT Name FROM Account WHERE Id=: u.AccountId];
            //DealOpp.Partner_Sales_Rep_Name__c = u.Name;
            //DealOpp.Partner_Sales_Rep_Email__c = u.Email;
           // if(TempAcc!= null)
            //DealOpp.Partner_Account_Name__c = TempAcc.Name;
            User checkuserType= [SELECT UserType FROM User WHERE Id=: DealOpp.OwnerId LIMIT 1];
            if(checkuserType.UserType != 'PowerPartner' && checkuserType.UserType != 'Partner' ){
                DealOpp.OwnerId.addError('When using the engage channel feature, an opportunity cannot be assigned to an internal User, please choose a Partner User instead');
                return null;
            }
            if(IsEngageChannelOpptyURL == 'true'){
                DealOpp.Engage_Channel_Opportunity__c= true;
            }
            if(listdistaccounts !=null && listdistaccounts.size() >0 && DealOpp.Distributor_Name__c =='Distribution' && (((salesAccountObj.Partner_Track__r.Purchase_Path__c=='TIER 2' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='DISTRIBUTION') && strCheckPoint == 'true') || (strCheckPoint == 'true' && (salesAccountObj.Partner_Track__r.Purchase_Path__c=='Direct' || salesAccountObj.Partner_Track__r.Purchase_Path__c=='Direct Partner Purchase') &&
                   (salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='Distribution' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c=='InDirect Partner Purchase' || salesAccountObj.Partner_Track__r.Speciality_Product_Purchase_Path__c==null)))){
            for(Disti_Relationship__c distiaccount :listdistaccounts){
            if(distiaccount.Disti_Account__c !=null){
            DealOpp.Distributor_Reseller_Name__c=distiaccount.Disti_Account__c;
            }
            else{
             DealOpp.Distributor_Reseller_Name__c=distiaccount.Secondary_Storage_Preferred_Distributor__c;
            }
            }
            }
           
             // Modified by sai prasanth puvvada on 2-24-2017 for validation rule error Non_GC_partner_cant_select_GC_countries error message displaying
            
           try
           {
          
            upsert DealOpp;
           }
           
           catch(Exception validationError)
           {
           ApexPages.addMessages(validationError);
           IsValidationErrorFired = true;
           }
           
        
        if(!IsValidationErrorFired)
         {  
         // Commented BY SrikanthGanji for Story 3955402:Deal Reg: GC 2.0 - Enable Dell EMC Deal Type values for Greater China Opportunities
     // To update the is it a GC deal? field based on owners profile
      /*  if(DealRegUtils.isOwnerIdhasGcProfile(DealOpp.OwnerId) == true){
            DealOpp.Is_GC_Deal__c = true;
            update DealOpp;
        } */
        
        Opportunity SegmentOpp= [SELECT Associated_Opportunity__c from Opportunity WHERE ID=: ApexPages.currentpage().getParameters().get('SegmentOppID') LIMIT 1];
       
        SegmentOpp.StageName='Lost, Cancelled - 0%';
        SegmentOpp.Type='Deal/Bid - Indirect';
        SegmentOpp.Reason_Won_Lost__c='Deal moved from direct to partner';
        SegmentOpp.Competitor_Lost_To__c='Unknown';
        SegmentOpp.Associated_Opportunity__c = DealOpp.ID;
        //Bikram
        //SegmentOpp.Engage_Channel_Opportunity__c = IsEngageChannelOppty;
        
        update SegmentOpp;
        System.debug('+++++++++'+DealOpp);
        List<OpportunityLineItem> ListoppLineItem = new List<OpportunityLineItem>();
        for(OpportunityLineItem temp:[SELECT PricebookEntryId ,Product_code_for_analytics__c, Pricing_Information__c, Active_Wyse_Product__c, Wyse_Product_Name__c, Suggested_price__c, Potential_Cost_Savings_if_Ocean__c, Estimated_Delivery_Lead_Time_Week__c, EOL_Date__c, Replacing_Platform__c, On_the_Sea_and_Land_from_ODM_to_Customer__c, RTS_Date__c, Product_Type__c, SOC_Qualified__c,Quest_Product_Integration_Status__c, Description, Wyse_Product_Description__c, Service_Support_US__c, ServiceDate, Quantity, UnitPrice, TotalPrice, ListPrice,Discount_off__c, Margin__c,Mrgn__c,Deal_Reg_Unit_Price__c, Deal_Reg_Total_Price__c, DGR_Eligible__c, Extension_Renewal__c, Dell_Business_Model__c, Order_Code__c,Eco_System__c,Legacy_Brand__c,Has_Revenue_Schedule__c,Quote__c,DPID__c,Qualified_for_S_P_Deal_Reg_Program__c, S_P_Deal_Status__c, NET_in_USD__c, Net__c, Rejection_Reason__c  FROM OpportunityLineItem Where OpportunityId =: ApexPages.currentpage().getParameters().get('SegmentOppID')]){
            OpportunityLineItem oppLineItem = new OpportunityLineItem(Potential_Cost_Savings_if_Ocean__c=temp.Potential_Cost_Savings_if_Ocean__c, Estimated_Delivery_Lead_Time_Week__c= temp.Estimated_Delivery_Lead_Time_Week__c, On_the_Sea_and_Land_from_ODM_to_Customer__c= temp.On_the_Sea_and_Land_from_ODM_to_Customer__c, Product_Type__c= temp.Product_Type__c, SOC_Qualified__c= temp.SOC_Qualified__c,Quest_Product_Integration_Status__c= temp.Quest_Product_Integration_Status__c, Description= temp.Description, Wyse_Product_Description__c= temp.Wyse_Product_Description__c, Service_Support_US__c= temp.Service_Support_US__c, ServiceDate= temp.ServiceDate, Rejection_Reason__c= temp.Rejection_Reason__c, Quantity= temp.Quantity, UnitPrice= temp.UnitPrice, PricebookEntryId = temp.PricebookEntryId, Discount_off__c= temp.Discount_off__c, Mrgn__c= temp.Mrgn__c, Extension_Renewal__c= temp.Extension_Renewal__c, Dell_Business_Model__c= temp.Dell_Business_Model__c, Order_Code__c= temp.Order_Code__c, Legacy_Brand__c= temp.Legacy_Brand__c, Quote__c= temp.Quote__c, DPID__c= temp.DPID__c, Qualified_for_S_P_Deal_Reg_Program__c= temp.Qualified_for_S_P_Deal_Reg_Program__c, S_P_Deal_Status__c= temp.S_P_Deal_Status__c, OpportunityId = DealOpp.Id);         
            ListoppLineItem .add(oppLineItem);
        }  
             try{
             TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
             
               insert ListoppLineItem ;
             }
             catch(exception ex){
                  //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage().SPLIT(',')[1]));
                   ApexPages.addMessages(ex); 
                  return null;
             }
            system.debug('First@@@@@@@'+ApexPages.currentpage().getParameters().get('SegmentOppID'));
            processrecords(stroppid);
  //         OpportunityLineItemUtilities.OpportunitySpecialtyQueueFlagUpdate(ListoppLineItem); 

         
        Opportunity NewOpp = [SELECT Id, Owner.Name, Owner.Email,owner.ContactId, Account.Name, PartnerAccount.Name,PartnerAccount.Account_Country__c,PartnerAccountID  FROM Opportunity WHERE ID =: DealOpp.Id LIMIT 1];
    /*     Commented By Rajashekar Kura to remove GC Logic ----------  GC 2.0   CR 15105

           //Logic For Greater China      
           if(DealRegUtils.isGCDeal(NewOpp.PartnerAccount.Account_Country__c)){
      
            emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :'Dell collaboration opportunity transfer to partner portal email GC template'];
          }
   //Logic For NON -GC 
          else{
       */
       
        // emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :'Dell collaboration opportunity transfer to partner portal email for Non GC 1'];
         emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :'Dell collaboration opportunity transfer to partner portal email VF'];
          
       //       }
             List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
          List<Messaging.SendEmailResult> listEmailResult = null;
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           //mail.setTemplateID(Id.valueOf(System.Label.Dell_collaboration_opportunity_transfer));
           mail.setTemplateID(emailTemplate.ID);
           List<string> ToAddress = new List<String>();
           ToAddress.add(NewOpp.OwnerId);
           ToAddress.add(DealOpp.OwnerId);
           system.debug('@@@@@toaddress'+ToAddress);
           for(AccountTeamMember AccTeamMember: [SELECT UserId FROM AccountTeamMember WHERE AccountId IN: new list<String>{DealOpp.AccountId, NewOpp.PartnerAccountID}]){
               ToAddress.add(AccTeamMember.UserId);
               
           }
           
           mail.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No_Reply Mailbox' LIMIT 1].Id);
            //mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.No_Reply_Mailbox));
           mail.setSaveAsActivity(false);
           mail.setWhatId(NewOpp.Id);
           //mail.setTargetObjectId(c.Id);
           /*sending the email template to opportunity owner contact*/
           mail.setTargetObjectId(NewOpp.owner.ContactId);
           
           List<string> ToAddressArray = new List<String>();
           Integer intLastRepetitionCount = ToAddress.size();
           Integer intLoopRepeatCount = intLastRepetitionCount/100;
           final Integer BATCH_SIZE = 100;
           Integer intCount = 0;
           
           for(Integer i = 0; i <= intLoopRepeatCount; i++) {
             for(Integer j = 0; j < BATCH_SIZE && intCount < intLastRepetitionCount; j++) {
               ToAddressArray.add(ToAddress[intCount]);
               intCount++;
             }
             mail.setToAddresses(ToAddressArray);
             listSingleEmailMessages.add(mail);
             listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
             ToAddressArray.clear();
           }
           //delete c;
           //delete a;
           return new PageReference('/'+DealOpp.Id);
           
           
        } // end of catch method written for vlaidation error IsValidationErrorFired boolean value.   
        
        return null;
    }
     return null;
}
    @Future
    public static void processrecords(String stroppid){
    try{
             Opportunity Dealopp;
             Opportunity Deal;
             system.debug('@@@@@@oppid'+ stroppid);
             deal = [SELECT Id,Name,Engage_Channel_Opportunity__c,Associated_Opportunity__c  FROM Opportunity WHERE id=:stroppid]; 
             String strid = deal.Associated_Opportunity__c;
             Dealopp = [SELECT Id,Name,Engage_Channel_Opportunity__c,Associated_Opportunity__c,Opportunity_has_assets_items__c  FROM Opportunity WHERE id=:strid];
             
             system.debug('!!!!DealOpp'+ DealOpp);
            //Added assest
              list<Dell_Asset_RMA__Opportunity_Asset_Junction__c> listAsstOpptyJunction =new list<Dell_Asset_RMA__Opportunity_Asset_Junction__c>();
            for(Dell_Asset_RMA__Opportunity_Asset_Junction__c temp1:[select id,name,Dell_Asset_RMA__Related_Asset__c from Dell_Asset_RMA__Opportunity_Asset_Junction__c where Dell_Asset_RMA__Related_Opportunity__c=:deal.id ]){            
                Dell_Asset_RMA__Opportunity_Asset_Junction__c rec1=new Dell_Asset_RMA__Opportunity_Asset_Junction__c();
                //rec1=temp1.clone(false, false, false, false);
                rec1.Dell_Asset_RMA__Related_Opportunity__c=DealOpp.id;
                rec1.Dell_Asset_RMA__Related_Asset__c=temp1.Dell_Asset_RMA__Related_Asset__c;
                listAsstOpptyJunction.add(rec1);                  
            }              
             TriggerExecutionController.setSkipOpportunityTriggers(True);
             TriggerExecutionController.setSkipblacklistCommentsTriggers(True);
             TriggerExecutionController.setskipBlacklistuserstatusTriggers(True);
             TriggerExecutionController.setskipBlacklistWordFilterOnPostTriggers(True);
            if(listAsstOpptyJunction.size()>0){
                insert listAsstOpptyJunction;
                DealOpp.Opportunity_has_assets_items__c= true;
                update DealOpp;
                system.debug('222222222'+listAsstOpptyJunction);
            }                  
             
        //  Related Competitive Swaps information  
          List<Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c>   listCompet = New List<Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c>();
          for(Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c mytemp: [SELECT Id,Name,RecordTypeId,Dell_Asset_RMA__Related_Opportunity__c,Dell_Asset_RMA__Manufacturer__c,Dell_Asset_RMA__Registration_Type__c,Dell_Asset_RMA__Registration_ID__c,Dell_Asset_RMA__Total_GFS_Rep_Incentive__c,Dell_Asset_RMA__Transfer_of_Title_Letter_Received__c,Dell_Asset_RMA__Comments__c,Dell_Asset_RMA__Promotion_Details__c,Dell_Asset_RMA__Related_Quote_Confirmation__c,Dell_Asset_RMA__Swap_Value__c,Dell_Asset_RMA__Model_Swap__c,Dell_Asset_RMA__AFM__c,Dell_Asset_RMA__Quantity__c,Dell_Asset_RMA__Capacity_TB__c,Dell_Asset_RMA__Other_Model__c,Dell_Asset_RMA__Serial_Number__c,Dell_Asset_RMA__Model_Trade_In__c,Dell_Asset_RMA__Configuration__c,Dell_Asset_RMA__Displacement_Box__c
                                                                     FROM Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c 
                                                                     WHERE Dell_Asset_RMA__Related_Opportunity__c=: deal.id ]){
            Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c competassest = new Dell_Asset_RMA__Trade_Ins_Competitive_Swap__c();
            competassest =mytemp.clone(false, false, false, false);
            competassest.RecordTypeId = mytemp.RecordTypeId;
            competassest.Dell_Asset_RMA__Related_Opportunity__c = DealOpp.Id;
            listCompet.add(competassest);
            system.debug('@@@@@@@@@@@@@@@'+listCompet);
          }

               TriggerExecutionController.setSkipblacklistCommentsTriggers(True);
               TriggerExecutionController.setSkipOpportunityTriggers(True);
               TriggerExecutionController.setskipBlacklistuserstatusTriggers(True);
               TriggerExecutionController.setskipBlacklistWordFilterOnPostTriggers(True);
               if(listCompet.size()>0){              
                   insert listCompet;
                   system.debug('111111111111'+listCompet);
               }
               
          }catch(DmlException e) {
                Exception__c exceptionRecord = new Exception__c();
                exceptionRecord.Process_Name__c = 'Assets,trade and swap';
                exceptionRecord.Object_type__c = 'User';
                exceptionRecord.Object_ID__c = userinfo.getUserId();
                exceptionRecord.Notes__c = string.valueof(e);
                exceptionRecord.Error_messages__c = '';
                Database.SaveResult resultStatus = database.insert(exceptionRecord);
              } 
         
    }
}