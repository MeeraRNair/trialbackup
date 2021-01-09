/*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR16149      FY19-DCS-0802  12.07.2018       Jatin           Removed commented logics as part of code reduce story 5240511
    */



public class SupportRequestUtil {
    
    public static Boolean SKIP_SUPPORT_REQUEST_TRIGGERS = false; //Used to bypass Support Request triggers - CR11543  16.07(MAJ-S-03)
    
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR11561     16.07(MAJ-S-03) 02-Jun-2015     Fenny           Method to populate 8 fields from contact record as per user story 162173 
    */
    public static void populateSolutionArchitectInformation(List<Support_Request__c> supportReqList, Map<Id, Contact> contactMap){
        if((supportReqList != null) && (supportReqList.size() > 0) && (contactMap != null) && (contactMap.size() > 0)){
            Contact con = null;
            for(Support_Request__c sr : supportReqList){
                con = contactMap.get(sr.Customer_Contact_InformationName__c);
                sr.Customer_Contact_Information_Name__c = con.Name;
                sr.Customer_Contact_Information_Phone__c = con.Phone;
                sr.Customer_Contact_Information_Email__c = con.Email;
                sr.Primary_Work_Delivery_Address_1__c = con.MailingStreet;
                sr.Primary_Work_Delivery_City__c = con.MailingCity;
                sr.Primary_Work_Delivery_State_Province__c = con.MailingState;
                sr.Primary_Work_Delivery_Country__c = con.MailingCountry;
            }
        }
    }
    
    //==============================================================================================================================
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR11543     16.07(MAJ-S-03) 04-Jun-2015     Krishnamoorthi  Method to populate Account_Margin_Rolling_Last_4_Qtrs__c and 
                                                                            Account_Revenue_Rolling_Last_4_Qtrs__c (Total Account Revenue and Margin for last 4 Quarters) from Revenue object as per user story 162174 
    */
    public static void populateAccountRevMarLast4Qtrs(List<Support_Request__c> supportReqList){
        
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> FYQSet = new Set<String>();
        Map<String, Revenue__c> revenueMap = new Map<String, Revenue__c>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<String> revFYQSet = new Set<String>();

        //Variables to identify the current date is in which Quarter and Fiscal Year
        Map<String, Map<Integer, Period>> FYQTRInfoMap = new Map<String, Map<Integer, Period>>();
        Map<String, FiscalYearSettings> mapFYInfo = new Map<String, FiscalYearSettings>();
        Set<Id> setFYSId = new Set<Id>();
        String sFiscalYear,sQuarter,strxYear;
        Integer iFiscalYear,iQuarter,intxYear,minCloseYearInt;
        integer iCloseYear =0 , maxCloseYearInt=0;      
        Date quarterStartDate;
        
        //Current Fiscal Quarter and Fiscal Year calculation -- Start
        Date dCloseDate = date.today(); 
        iCloseYear = dCloseDate.year();    
        
        //Find minimum and maximum Fiscal close years, and capture the close year into an array (For example, if current year is 2015, add 2016 also in set)
        minCloseYearInt = iCloseYear; 
        maxCloseYearInt = iCloseYear+1;  

        Set<String> setxYearStr = new Set<String>{String.valueof(minCloseYearInt),String.valueof(maxCloseYearInt)};  
        
        //Create a map of fiscal years, and start and end dates for DELL org
        for(FiscalYearSettings FYSetting : [SELECT Id, Name, StartDate, EndDate, YearType FROM FiscalYearSettings WHERE YearType = 'Custom' and Name IN:setxYearStr]) {

                setFYSId.add(FYSetting.Id);
                mapFYInfo.put(FYSetting.Name, FYSetting);
                
        }
                
        if(setFYSId.size() > 0) {
            
            //Create maps of fiscal years and quarters, and fiscal years from Period
            for (Period FYPeriod : [SELECT Id, FiscalYearSettings.Name, Number, Type, StartDate, EndDate FROM Period WHERE FiscalYearSettingsId IN: setFYSId AND Type = 'Quarter']) {
            
                // Create a map of fiscal year and quarter information
                if(FYPeriod.Type == 'Quarter') {
                    
                    Period dtStartEndDates = new Period(StartDate = FYPeriod.StartDate, EndDate = FYPeriod.EndDate); 
                    // Get the map associated to fiscal year
                    Map<Integer, Period> mapQP = FYQTRInfoMap.get(FYPeriod.FiscalYearSettings.Name);
                    
                    if (mapQP == null) 
                    {
                        mapQP = new map<Integer, Period>();
                    }        
                        mapQP.put(FYPeriod.Number, dtStartEndDates);  
                        FYQTRInfoMap.put(FYPeriod.FiscalYearSettings.Name, mapQP); 
                }
            }
        }

            sFiscalYear = '';
            sQuarter = '';
                        
            intxYear = (Integer)dCloseDate.year();
            strxYear = String.valueOf(intxYear); 

            // Get start and end dates corresponding to xYear by querying table[FiscalYearSettings]. 
            FiscalYearSettings FYStartEndDates =  mapFYInfo.get(strxYear);
            if(FYStartEndDates != null)
            {
                // Calculate the fiscal year
                if (dCloseDate > FYStartEndDates.EndDate) 
                {
                    iFiscalYear = intxYear + 1;
                }        
                else 
                {
                    iFiscalYear = intxYear;
                   
                }
                sFiscalYear = String.valueOf(iFiscalYear);
          
                // Determine the quarter that the Support Request created date (today) falls into
                map<Integer, Period> mapQtrStartEndDates = FYQTRInfoMap.get(sFiscalYear);
                if (mapQtrStartEndDates != null && mapQtrStartEndDates.size() > 0) 
                {
                    iQuarter = 0;
                    for (Integer i=1; i<=mapQtrStartEndDates.size(); i++) 
                    {        
                        Period StartEndRange = mapQtrStartEndDates.get(i);                    
                       
                       if (dCloseDate >= StartEndRange.StartDate && dCloseDate <= StartEndRange.EndDate) 
                        {
                            iQuarter = i;
                            quarterStartDate = StartEndRange.StartDate; 
                            break;
                        }                    
                    }
                    sQuarter = String.valueOf(iQuarter);
                }
                
                //Create a combination of Fiscal year and last four Quarters to query the records from Revenue object. The format is FY2015Q01.
                switch on iQuarter{
                    when 1{
                        FYQSet = new Set<String>{'FY' + String.valueOf(iFiscalYear - 1) + 'Q04',  
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q03',
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q02',
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q01'};
                    }
                    when 2{
                        FYQSet = new Set<String>{'FY' + String.valueOf(iFiscalYear) + 'Q01',  
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q04',
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q03',
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q02'};
                    }
                    when 3{
                        FYQSet = new Set<String>{'FY' + String.valueOf(iFiscalYear) + 'Q02',  
                                                        'FY' + String.valueOf(iFiscalYear) + 'Q01',
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q04',
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q03'};
                    }
                    when 4{
                        FYQSet = new Set<String>{'FY' + String.valueOf(iFiscalYear) + 'Q03',  
                                                        'FY' + String.valueOf(iFiscalYear) + 'Q02',
                                                        'FY' + String.valueOf(iFiscalYear) + 'Q01',
                                                        'FY' + String.valueOf(iFiscalYear - 1) + 'Q04'};
                    }
                }                
                     
            } //Current Fiscal Quarter and Fiscal Year calculation -- End
            
            for(Support_Request__c sr : supportReqList) {
                oppIdSet.add(sr.Opportunity__c);
            }

            //Take related Account from Opportunity
            if(oppIdSet != null) {
                for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN: oppIdSet]) {
                    
                    accountIdSet.add(opp.AccountId);
                    oppMap.put(opp.Id, opp);
                }
            }
            
            //Query the Revenue records related to the Account for last 4 quarters 
            if(accountIdSet != null) {
                for(Revenue__c rev : [SELECT Id, Account__c, Total_QTR_Rev__c, Total_QTR_Margin__c,  FiscalYearQuarter__c FROM Revenue__c 
                                        WHERE Account__c IN: accountIdSet AND FiscalYearQuarter__c IN: FYQSet ]) {
                    
                    revenueMap.put(rev.Account__c + rev.FiscalYearQuarter__c, rev);
                    revFYQSet.add(rev.Account__c + rev.FiscalYearQuarter__c);
                }
            }
        
            //Iterate through the list and assign the Revenue and Margin values
            for(Support_Request__c sre : supportReqList) {
                
                for(String FYQCombination : FYQSet) {
        
                    if(revenueMap != null && revFYQSet.contains(oppMap.get(sre.Opportunity__c).AccountId + FYQCombination)) {
                        
                        if(sre.Account_Revenue_Rolling_Last_4_Qtrs__c != null) {
                            sre.Account_Revenue_Rolling_Last_4_Qtrs__c = sre.Account_Revenue_Rolling_Last_4_Qtrs__c + revenueMap.get(oppMap.get(sre.Opportunity__c).AccountId + FYQCombination).Total_QTR_Rev__c;
                        } else {
                            sre.Account_Revenue_Rolling_Last_4_Qtrs__c = revenueMap.get(oppMap.get(sre.Opportunity__c).AccountId + FYQCombination).Total_QTR_Rev__c;
                        }
                        
                        if(sre.Account_Margin_Rolling_Last_4_Qtrs__c != null) {
                            sre.Account_Margin_Rolling_Last_4_Qtrs__c = sre.Account_Margin_Rolling_Last_4_Qtrs__c + revenueMap.get(oppMap.get(sre.Opportunity__c).AccountId + FYQCombination).Total_QTR_Margin__c;
                        } else {
                            sre.Account_Margin_Rolling_Last_4_Qtrs__c =  revenueMap.get(oppMap.get(sre.Opportunity__c).AccountId + FYQCombination).Total_QTR_Margin__c;
                        }
    
                    }

                }
            
            }   

    } //CR11543 - End
    //=================================================================================================================    
    
    //add every new SE into new list of OpportunityTeamMember and OpportunityShare to be inserted
    //add every old SE into old list of OpportunityTeamMember to be deleted 
    public static void addNewAndOldSE2List(OpportunityTeamMember[] newOppTMList, OpportunityShare[] newOppShareList, 
        OpportunityTeamMember[] oldOppTMList, Map<String, OpportunityTeamMember> oldOppTMMap, Map<Id, Opportunity> oppOwnerMap,
        Support_Request__c newRequest, Support_Request__c oldRequest, String fieldName) {
                
        Id oldId = (Id)oldRequest.get(fieldName);
        Id newId = (Id)newRequest.get(fieldName);
     
        //if new SE different from old SE
        if (oldId!=newId){
           
            //if old SE is not null and it exist in OTM 
            //add the OTM Id into oldOppTMList to be deleted
            if (oldId!=null && oldOppTMMap.containsKey(newRequest.Opportunity__c+':'+oldId)){
                oldOppTMList.add(oldOppTMMap.get(newRequest.Opportunity__c+':'+oldId));
            }
            
            //if new SE is not null
            if (newId!=null){
                //add the new OTM into newOppTMList to be created
                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(userId=newId,
                        TeamMemberRole='Sys Eng',
                        opportunityId = newRequest.Opportunity__c); 
                                                                
                newOppTMList.add(oppTeamMember);
                
                //if the new SE is not opportunity 's owner
                //add the new OShare into newOppShareList to be created
                if (oppOwnerMap.get(newRequest.Opportunity__c).OwnerId!=newId){
                                   
                    OpportunityShare oppShare = new OpportunityShare(opportunityId=newRequest.Opportunity__c, 
                            UserOrGroupId=newId, 
                            OpportunityAccessLevel='Edit');                    
                    newOppShareList.add(oppShare);      
                }
            }    
        }       
    }
    
    public static void addNewShareList(OpportunityTeamMember[] newOppTMList, OpportunityShare[] newOppShareList, 
        OpportunityTeamMember[] oldOppTMList, Map<String, OpportunityTeamMember> oldOppTMMap, Map<Id, Opportunity> oppOwnerMap,
        Support_Request__c newRequest, String fieldName) {
                
        Id newId = (Id)newRequest.get(fieldName);
   
        //if new SE is not null
        if (newId!=null){
            //add the new OTM into newOppTMList to be created
            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(userId=newId,
                    TeamMemberRole='Sys Eng',
                    opportunityId = newRequest.Opportunity__c); 
                                                      
            newOppTMList.add(oppTeamMember);
            
            //if the new SE is not opportunity 's owner
            //add the new OShare into newOppShareList to be created
            if (oppOwnerMap.get(newRequest.Opportunity__c).OwnerId!=newId){
                            
                OpportunityShare oppShare = new OpportunityShare(opportunityId=newRequest.Opportunity__c, 
                        UserOrGroupId=newId, 
                        OpportunityAccessLevel='Edit');
                                        
                newOppShareList.add(oppShare);   
            }
        }  
    }    
}