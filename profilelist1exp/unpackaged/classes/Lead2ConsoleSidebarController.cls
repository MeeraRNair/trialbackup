/*
 * Author   : Ragu
 * Purpose  : This class is used for display all the contacts & Lead related to particular account 
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      11611       16.07           12-Jun-2015     Ragu         This class is used for display all the contacts & Lead related to particular account
 * 2.0      12660       FY17-DCS-0303   19-Feb-2016     Gan          Display the Campaign short name field
 * 2.1      12634       FY17-DCS-0303   19-Feb-2016     Wanti        Added Lead Type, Lead Owner, Lead Owner Role and order by Created Date in Descending order
 * 3.0      13031       FY17-DCS-0502   12-Apr-2016     Gan          LM2_21-Add opportunity view in right panel on a new tab Account Data
 * 3.1      TFS 1751089 FY17-DCS-0502   21-Apr-2016     Gan          Fix error Collection size exceeds maximum size of 1,000 
 * 4.0      13103       FY17-DCS-0602   27-Apr-2016     Azwanti      LM2_21-Adding account product maps views to Sales Console third panel       
 * 5.0      13389       FY17-DCS-0902   08-Aug-2016     Gan          LM2_New product map for Channel Greenfield
 * 6.0      13387       FY17-DCS-0902   09-Aug-2016     SuiYee       LM2_New product map for Storage Capacity % 
 * 7.0      13406       FY17-DCS-1002   11-Aug-2016     Sajith       LM2_New product map for Market Intelligence
 * 8.0      13424       FY17-DCS-1002   11-Aug-2016     SuiYee       LM2_21-Adding contact priority into Sales console view
 * 9.0      13731       FY17-DCS-0103   22-Nov-2016     Azwanti      LM2_Channel Greenfield product map fix
 * 10.0     13850       FY18-DCS-0202   23-Dec-2016     Sajith       LM2_New product map for eRate
 * 10.1     13854       FY18-DCS-0202   23-Dec-2016     SuiYee       LM2_Add Ship date field into Expiring tags product map
 * 10.2     14061       FY18-DCS-0403   09-Mar-2017     Ashok        LM2_New product map for Open Quote Plays
 * 11.0     14307       FY18-DCS-0602   19-May-2017     Sajith       LM2_New product map for Marketing Maintenance
 * 12.0     14735       FY18-DCS-1001   08-Aug-2017     Ashok        LM2_Enhance product map - Lead Opportunities
 * 13.0     15162       FY18-DCS-0102   21-Nov-2017     Ashok        LM2_New product map for Generic Product map
 * 14.0     15609       FY19-DCS-0502   01-apr-2018     Sharad       LM2_New product map for non sfdc contacts
 * 15.0     15733       FY19-DCS-0602   10-may-2018     Sharad       New product map for premier pages
 */
 

public with sharing class Lead2ConsoleSidebarController {
    
    public Lead leadRecord {get; private set;}
    
    //5.0
    public string strChannelGreenfieldSectName {get; private set;}
    
    public Lead2ConsoleSidebarController(ApexPages.StandardController controller) {
        Id leadId = controller.getId();
        if(leadId != null) {
            //5.0 added to retrieve acccount record type
            leadRecord = [select Id, Account__c, Account__r.RecordType.name, Lead_Type__c from Lead where Id = :leadId];
        }
        system.debug('Lead : '+leadRecord); 
    } 
    //v8.0 
    public list<Contact> getContactDetails() {
        return [select Id, Name, Status__c, Email, Phone, Title, Decision_Making_Role__c, Priority__c  from Contact where AccountId = :leadRecord.Account__c order by Priority__c asc limit 1000];
    }
    
    public list<Lead> getLeadDetails() {
        // v2.0
        //return [select Id, Name, Campaign__c, Campaign_Short_Name__c, LeadSource, Status, Lead_Score__c, CreatedDate, Lead_Type__c, OwnerId, Lead_Owner_Role__c // v2.1
        return [select Id, Name, Campaign__c, Campaign_Short_Name__c, Status, CreatedDate, Lead_Type__c, OwnerId, Lead_Owner_Role__c // v2.1
                from Lead 
                where Account__c != null and Account__c = :leadRecord.Account__c
                order by CreatedDate DESC limit 1000]; // v2.1
    }
    
    //3.0
    public list<Opportunity> getOpptyDetails() {
        return [SELECT Id, Name, StageName, Unweighted_Rev_Formula__c, CloseDate, Deal_ID__c 
                FROM Opportunity
                WHERE accountId != null and accountId = :leadRecord.Account__c
                AND stageName NOT in ('Lost, Cancelled - 0%', 'Win - 100%') 
                ORDER BY CloseDate ASC limit 1000];
    }
    
    //4.0//10.1
    public list<Expiring_Tag__c> getExpiringTagDetails() {
        return [SELECT Id, Name, Customer_Name__c, DOMS_Gii_Customer_Number__c, DOMS_Gii_Order_Number__c, Expiration__c, LOB__c, Product__c, Revenue__c, Ship_Date__c, Tag_Serial_Number__c, Account__c
                FROM Expiring_Tag__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c 
                ORDER BY Expiration__c DESC limit 1000];
    }
    
    public list<eQuote__c> geteQuoteDetails() {
        return [SELECT Id, Name, Agent__c, Email__c, Expiration_Date__c, LOB__c, Name__c, Phone__c, Premier_eQuotes_Store_ID__c, Product__c, Quantity__c, Quote_Date__c, Quote_Number__c, Revenue__c 
                FROM eQuote__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c
                ORDER BY Quote_Date__c DESC limit 1000];
    }
        
    public list<Enterprise_Installed_Base__c> getEntInstalledBaseDetails() {
        return [SELECT Id, Name, Priority__c, Recommended_LoB__c, Recommended_Type__c, Recommended_Attach_SKU__c, Recommended_Attach_SKU_Name__c, Recommended_Price__c, Lead_Time__c, Installbase_Type__c, Number__c, Date__c, Product__c, Tag_Serial_Number__c, Quantity__c, Revenue__c
                FROM Enterprise_Installed_Base__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c
                ORDER BY Date__c DESC limit 1000];
    }
        
    public list<Renewal_Software_Hardware__c> getRenewalSwHwDetails() {
        return [SELECT Id, Name, Product__c, Tag_Serial_Number__c, Renewal_Term_Date__c, Quantity__c, Revenue__c, Contact_Name__c, Email__c, Vendor__c, Document_Number__c
                FROM Renewal_Software_Hardware__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c 
                ORDER BY Renewal_Term_Date__c DESC limit 1000];
    }    
    
    public list<Order_Info__c> getOrderInfoDetails() {
        return [SELECT Id, Name, Order_Number__c, Order_Date__c, Customer_Number__c, Account_Name__c, Segment__c, Country__c, Product_Details__c, Product_Revenue__c, Product_Margin__c, Product_Units__c, Quote_Number__c
                FROM Order_Info__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c
                ORDER BY Order_Date__c DESC limit 1000];
    }
    //4.0
    //5.0
    public list<Channel_Greenfield__c> getChannelGreenfieldDetails() {
        //setting default as Channel Greenfield
        strChannelGreenfieldSectName = 'Channel Greenfield'; 
        if (leadRecord.Account__r.RecordType.name == 'End-User Account')
        {
            strChannelGreenfieldSectName = 'Channel Greenfield (End-user Account)';
            //v9.0 replace from Channel_Lead__c to Lead__c and from Channel_Lead__r.name to Lead__r.name
            return [SELECT Id, Name, Lead__c, Lead__r.name, End_user_account__c, Partner_Account__c, Created_Date__c, Deal_ID__c, Stage__c, Unweighted_Rev__c
                FROM Channel_Greenfield__c
                WHERE End_user_account__c != null and End_user_account__c = :leadRecord.Account__c 
                ORDER BY Created_Date__c DESC limit 1000];
        }
        else
        {
            strChannelGreenfieldSectName = 'Channel Greenfield';    
            //v7.0 replace from Channel_Lead__c to Lead__c and from Channel_Lead__r.name to Lead__r.name
            return [SELECT Id, Name, Lead__c, Lead__r.name, End_user_account__c, Partner_Account__c, Created_Date__c, Deal_ID__c, Stage__c, Unweighted_Rev__c
                FROM Channel_Greenfield__c
                WHERE Partner_Account__c != null and Partner_Account__c = :leadRecord.Account__c 
                ORDER BY Created_Date__c DESC limit 1000];
        }
        return null;
    }
    
    //v6.0 start
        public list<Storage_Capacity__c> getStorageCapacityDetails() {
        return [SELECT Id, Name, Campaign__c, Group_Name__c, Service_Tag__c, Date_Recorded__c, Percent_Free__c, 
                Percent_Used__c,Member_Serial_Number__c,Member_Name__c
                FROM Storage_Capacity__c
                WHERE Account_ID__c != null and Account_ID__c = :leadRecord.Account__c 
                ORDER BY Date_Recorded__c DESC limit 1000];
    }
    //v6.0 end
    //7.0
    public list<Market_Intelligence__c> getMarketIntelligenceDetails() {
        return [SELECT Id, Name,Campaign_Name__c,Date__c, Desktop__c, Notebook__c, Server__c, Storage__c,Client__c, 
                Workstation__c, Enterprise__c, Tablet__c 
                FROM Market_Intelligence__c
                WHERE Account_ID__c != null and Account_ID__c = :leadRecord.Account__c
                ORDER BY Date__c DESC limit 1000];
    }
    //7.0
    //10.0 start
        public list<eRate__c> geteRateDetails() {
        return [SELECT Id, Name, Account__c,Lead__c,Lattice_Play__c,View_Form_URL__c,X470_App_Number__c,Posted_Date__c,
                Name_of_Applicant__c,Contact_Person__c,Preferred_Method_of_Contact__c,Contact_Work_Phone__c,Contact_Email__c,
                Name_of_Technical_Contact__c,Telephone_Number_of_Technical__c,Email_Address_of_Technical_Co__c,Manufacturer__c,
                Associated_RFPs__c
                FROM eRate__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c 
                ORDER BY Posted_Date__c DESC limit 1000];
    }
    //10.0 end
    //10.2 start
       public list<Open_Quotes__c> getopenQuoteDetails() {
        return [SELECT Id, Name, Account__c,Lead__c,Lattice_Play__c,Product_brand_model__c,
                Quantity__c,Quote_Create_Date__c,Revenue__c
                FROM Open_Quotes__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c 
                ORDER BY Quote_Create_Date__c DESC limit 1000];
    }
    //10.2 end
        
    //12.0 start
      public list<Lead_Opportunity__c> getLeadOpportunityDetails() {
         return [SELECT Id, Name, Opportunity_Name__c,Opportunity_ID__c,Brand_Description__c,Opportunity_Created_Date__c,
                Stage__c,Total_Price__c,Quantity__c
                FROM Lead_Opportunity__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c 
                ORDER BY Opportunity_Created_Date__c DESC limit 1000];

    }
    //12.0 end
    
    //13.0 start
      public list<Generic_Product_Map__c> getGenericProductMapDetails() {
         return [SELECT Id,Name,Date__c,Product_Map_Type__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,
                Field_6__c,Field_7__c,Field_8__c,Field_9__c,Field_10__c 
                FROM Generic_Product_Map__c
                WHERE Account__c != null and Account__c = :leadRecord.Account__c 
                ORDER BY Date__c DESC limit 1000];

    }
    //13.0 end
    
    //14.0 start
      public list<Non_SFDC_Contacts__c> getNonSFDCContactsDetails() {
         return [SELECT Id, Name, Contact_Name__c, Contact_Phone_1__c, Contact_Phone_2__c,
                 Contact_Rank__c, Contact_Source__c, Job_Title__c, Account_ID__c
                 FROM Non_SFDC_Contacts__c
                 WHERE Account_ID__c != null and Account_ID__c = :leadRecord.Account__c limit 1000];
                 //ORDER BY Date__c DESC limit 1000];

    }
    //14.0 end
    
    //15.0 start
      public list<Premier_Pages__c> getPremierPagesDetails() {
         return [SELECT Id, Name, Account__c, Action_Type__c, Brand_Name__c, Configuration_Type__c,
                 Opportunity_Type__c, Premier_Page_Name__c
                 FROM Premier_Pages__c
                 WHERE Account__c != null and Account__c =: leadRecord.Account__c limit 1000];
                 //ORDER BY Date__c DESC limit 1000];

    }
    //15.0 end
}