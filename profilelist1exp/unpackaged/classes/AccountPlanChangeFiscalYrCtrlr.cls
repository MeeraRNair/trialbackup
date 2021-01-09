/***********************************************************
* Name          : AccountPlanChangeFiscalYrCtrlr
* Description   : Class to Change FY of Account Plans and the associated related lists 
* ---------------------------------------------------------
* Revision  Name                    Date         Description
* 1.0       Jananii Guruswamy       02-Sep-2015  CR 11912  - Class to Change FY for the Account Plans. 
*                                                    
* 1.1       Jananii Guruswamy       04-Sep-2015  CR 11930  - Query to move the Next FY Strategies to the Cloned Account Plan  
* 1.2       Jananii Guruswamy       14-Sep-2015  CR 11944  - Query to move Open Activities, Activity History, Trip Reports, 
Notes & Attachments to the Next FY Account Plan

* 1.3       Jananii Guruswamy       23-Sep-2015  CR 11943/Defect 198968 - Set the Calculated_Annual_Value_of_Strategies field value initially to 0.00
* 1.4       Jananii Guruswamy       09-Oct-2015  CR 12053  - Query to move the Partner Detailing and Partner Business Enablement to the Cloned Account Plan 
* 1.5       Krishnakumar M          17-Oct-2016  CR 13607 - Story 2411885:Auto Populate ATM names in DIRECT AP’s upon change year (AE,ISR,RSM,Account Plan Owner)
* 1.6       Syuhada                 17-Oct-2016  CR 13608 - Story 2495447:Auto Populate ATM names in PARTNER AP’s upon change year (PDM,CAM,ISM)
* 1.7       Vasavi.M                14-Feb-2017  CR 13990   DSG related code clean up -  remove This_FY_DSG__c,Last_FY_DSG__c fields from SOQL
***************************************************************/


public class AccountPlanChangeFiscalYrCtrlr  {
    
    public Integer nextFiscalYear{get;set;}
    Id originalAccPlan=ApexPages.currentPage().getParameters().get('id');
    public SFDC_Acct_Plan__c accPlan{get;set;}
    public SFDC_Acct_Plan__c newAccPlan;
    public Integer planningyear{get;set;}
    public Boolean isException{get;set;}
    public String exceptionMessageDetail{get;set;}
    public String exceptionMessageTitle{get;set;}
    public String newAccPlanIDString;
    public String newAccPlanID;
    
    
    public AccountPlanChangeFiscalYrCtrlr(ApexPages.StandardController controller) {
        
        try{
            
            retrieveFinancialYear ();
            
            accPlan = [SELECT Name,CurrencyIsoCode,Account__c,Account_Plan_Owner__c,AE_Customer_1st_Half_Quota__c,
                       AE_Customer_2nd_Half_Quota__c,Anticipated_IT_Spend_with_Dell__c,RecordTypeId,Approved_by_Sales_Management__c,Business_Description__c,
                       Description_Comments__c,Overall_Customer_Short_Term_Goals__c,Overall_Customer_Long_Term_Goals__c,
                       Customer_Industry_Challenges__c,Sponsor_Champion__c,Date_Approved_by_Sales_Management__c,Date_Rejected__c,
                       Date_Submitted_for_Approval__c,Dell_s_Value_Proposition__c,Dell_Executive_Sponsor__c,Go_To_Market_Approach__c,
                       Large_Scale_Related_Initiatives_Planned__c,Large_Scale_Related_Initiatives_Planned2__c,
                       Large_Scale_Related_Initiatives_Planned3__c,Large_Scale_Related_Initiatives_Planned4__c,
                       Large_Scale_Related_Initiatives_Planned5__c,Inside_Sales_Representative__c,
                       Last_4Q_Margin__c,Last_4Q_Revenue__c,Mission_Statement__c,Marketing_NPS_Initiatives__c,Obsolete_Record_Type__c,
                       Plan_Starting_Fiscal_Year__c,Plan_Starting_Quarter__c,Power_Sponsor_Decision_Maker__c,Reason_for_Rejection__c,
                       Rejected_by__c,Risks_and_Mitigation__c,Go_To_Market_Approach_Comments__c,Sales_Manager__c,Satisfaction_Issues__c,
                       Services_Account_Sales_Executive__c,Services_Apps_Margin__c,Services_Apps_Revenue__c,Services_BPO_Margin__c,
                       Services_BPO_Revenue__c,Services_Contract_Start_Date__c,Services_Contract_Term__c,Services_Customer_Executive__c,
                       Services_Engagement_Model__c,Services_I_CC_Margin__c,Services_I_CC_Revenue__c,
                       Services_Total_Margin__c,Services_Total_Revenue__c,TSP__c,font_color_F3F3EC_Message__c,
                       X4Q_Margin_Plan__c,X4Q_Revenue_Plan__c,Account_Annual_IT_Spend__c,
                       Account_Executive__c, Calculated_Annual_Value_of_Strategies__c,Last_FY_CS__c,//Last_FY_DSG__c, v1.7
                       Last_FY_ESG__c,Last_FY_Financed__c,Last_FY_Full_Year__c,Last_FY_Q1__c,Last_FY_Q2__c,
                       Last_FY_Q3__c,Last_FY_Q4__c,Last_FY_Services__c,LOB_Expansion__c,Manager__c,This_FY_CS__c,//This_FY_DSG__c, v1.7
                       This_FY_ESG__c,This_FY_Financed__c,This_FY_Full_Year__c,This_FY_Q1__c,This_FY_Q2__c,This_FY_Q3__c,This_FY_Q4__c,This_FY_Services__c
                       ,Joint_Business_Goals_Long_Terms__c,Partnership_Executive_Summary__c,Size_Employees__c,Risks_Mitigation_Incl_NPS__c,PDM__c,
                       Partner_Sponsor__c,Partner_Sign_off_Date__c,Partner_Sign_off__c,Partner_Selling_Power_Total__c,Partner_Inhouse_Financial_Services__c,
                       Joint_Business_Goals_Short_Terms__c,CAM__c,Vertical_Market_Growth__c,Vertical_Focus__c,
                       Valued_Contracts_held_by_Partner__c,Storage__c,Status_of_Partner__c,Services_Capabilities__c,Servers__c,Security__c,Other_Goals__c,Other__c,Networking__c,
                       Geographical_Focus__c,Geographic_Expansion__c,Cloud__c,Client__c,Blueprints_Solutions__c
                       
                       FROM SFDC_Acct_Plan__c 
                       WHERE id =: originalAccPlan];
            
            System.debug('accPlan::'+accPlan);
            
            if(accPlan.Plan_Starting_Fiscal_Year__c==null){
                
                isException=true;
                exceptionMessageDetail='Plan_Starting_Fiscal_Year__c';
                exceptionMessageTitle='<b>Make sure to update the field that is listed as having invalid or missing data: \n\n</b> ';
                
                throw new MissingFYException (exceptionMessageDetail);
            }
            else{
                
                planningyear=Integer.valueOf(accPlan.Plan_Starting_Fiscal_Year__c.substring(2,4));
            }
            
            
        }catch(Exception e){
            
            System.debug('Error : ' + e.getStackTraceString());
            apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));  
            
        }
        
        
    }
    
    
    //1.1 - Start
    
    //Move the Strategies of Next FY and above to the Next FY Account Plan
    
    @TestVisible
    private void bringOverStrategy(Id accPlanId){
        
        List<SFDC_Strategy__c> strategies = [SELECT SFDC_Acct_Plan__c, When_do_you_plan_to_realize_Strategy__c FROM SFDC_Strategy__c WHERE SFDC_Acct_Plan__c  = :originalAccPlan ];
        
        for(SFDC_Strategy__c strategy: strategies ){
            
            if(Integer.valueOf(strategy.When_do_you_plan_to_realize_Strategy__c.substring(2,4))>planningyear){
                strategy.SFDC_Acct_Plan__c = accPlanId;
                
            }
            
            
        }
        
        update strategies ;
        
    } 
    
    @TestVisible
    private void retrieveFinancialYear(){
        
        
        List<Accnt_Plan_Target_FY__c> AcctPlanFYList = [Select Target_FY__c from Accnt_Plan_Target_FY__c where  start_date__c <= today and end_date__c >=  today order by start_date__c];
        
        if(AcctPlanFYList==null || AcctPlanFYList.isEmpty())
            throw new MissingFYException ('You can only change the FY of your Account Plan once the new FY has started ; continue to update your plan until EOY and then change the FY');
        
        nextFiscalYear = AcctPlanFYList.get(0).Target_FY__c.intValue(); 
        system.debug('nextFiscalYear::'+nextFiscalYear);
        system.debug('planningyear::'+planningyear);
        
    }
    
    // 1.1 - End
    
    // 1.2 - Start
    
    //Move the Activities to the Next FY Account Plan
    
    @TestVisible
    private void bringOverActivities(Id accPlanId){
        
        List<Event> events= [Select WhatId from Event where WhatId = :originalAccPlan ];
        System.debug('Inside bringOverActivities:: Before Update :events::'+events);     
        
        for(Event event: events){
            event.WhatId = accPlanId;
        }
        
        List<Task> tasks = [Select WhatId from Task where WhatId = :originalAccPlan ];
        for(Task task : tasks ){
            task.WhatId = accPlanId;
        }
        
        update events;
        update tasks;
        
    }
    
    //Move the Trip Report(s) to the Next FY Account Plan   
    
    @TestVisible
    private void bringOverTripReport(Id accPlanId){
        
        List<CustomerInteraction__c> tripReports = [Select Related_Account_Plans__c from CustomerInteraction__c where Related_Account_Plans__c  = :originalAccPlan ];
        for(CustomerInteraction__c tripReport: tripReports){
            
            tripReport.Related_Account_Plans__c = accPlanId;
            
        }
        update tripReports ;   
    }
    
    //Move the Notes to the Next FY Account Plan
    
    @TestVisible
    private void bringOverNotes(Id accPlanId){
        
        List<Note> notesToInsert=new List<Note>();
        List<Note> notesToMove=[SELECT Id,Title,IsPrivate,Body FROM Note WHERE ParentId=: originalAccPlan];
        System.debug('Inside bringOverNotes::notesToMove::'+notesToMove);
        for(Note note:notesToMove){
            
            notesToInsert.add(new Note(Title=note.Title,IsPrivate=note.IsPrivate, Body = note.Body, ParentId=accPlanId));
        }
        
        insert notesToInsert; 
        delete notesToMove;
    }
    
    //Move the Attachments to the Next FY Account Plan
    @TestVisible
    private void bringOverAttachments(Id accPlanId){
        
        System.debug('Inside bringOverAttachments -- accPlanId ::'+accPlanId);
        System.debug('Inside bringOverAttachments -- originalAccPlan ::'+originalAccPlan);
        List<Attachment> listOfAttachmentsInSourceAccPlan=new List<Attachment>();
        List<Attachment> listOfAttachmentsInNextFYAccPlan=new List<Attachment>();
        
        for(Attachment attachment : [SELECT Id, Name, isPrivate, Description, ParentId, Body FROM Attachment WHERE ParentId=:originalAccPlan]){ 
            listOfAttachmentsInSourceAccPlan.add(attachment); 
            
        }
        System.debug('***bringOverAttachments ***_1 heapSize=' + Limits.getHeapSize());
        for(Attachment attachment : listOfAttachmentsInSourceAccPlan){
            listOfAttachmentsInNextFYAccPlan.add(new Attachment(Name = attachment.Name, Body = attachment.Body, ParentId=accPlanId, isPrivate=attachment.isPrivate,Description=attachment.Description));
            
        }
        
        
        System.debug('***bringOverAttachments  heapSize=' + Limits.getHeapSize());
        System.debug('getLimitHeapSize::'+Limits.getLimitHeapSize());
        insert listOfAttachmentsInNextFYAccPlan;
        delete listOfAttachmentsInSourceAccPlan;
        
    }
    
    //Logic proposed during Sprint11 
    /* @TestVisible
private void bringOverAttachments(Id accPlanId){

System.debug('Inside bringOverAttachments -- accPlanId ::'+accPlanId);
List<Attachment> attachmentsToInsert = new List<Attachment>();
List<Attachment> attachmentsToMove=new List<Attachment>();
List<List<Id>> batches = new List<List<Id>>();
List<Integer> batchSizes = new List<Integer>();
System.debug('Inside bringOverAttachments -- originalAccPlan ::'+originalAccPlan);
for(Attachment attachment : [SELECT Id, BodyLength FROM Attachment WHERE ParentId=:originalAccPlan]){ 

Boolean batched = false;
System.debug('Just Above for Integer i  0;i < batches.size(); batches.size()::'+ batches.size());
for(Integer i = 0; i < batches.size(); i++){
System.debug('Inside for Integer i  0;i < batches.size(); batches.size()::'+ batches.size());

Integer batchSize = batchSizes[i];

if(batchSize + attachment.BodyLength < 10000000){
System.debug('Inside if batchSize + attachment.BodyLength < 10000000 ::');
batches[i].add(attachment.Id);
batchSizes[i] += attachment.BodyLength;
batched = true;
break;
}
}

if(!batched){
System.debug('Inside if batched::');
batches.add(new List<Id>{attachment.Id});
batchSizes.add(attachment.BodyLength);
}

System.debug('>>>first loop heap=' + Limits.getHeapSize());
}


for(List<Id> batchIds : batches){



for(Attachment attachment : [SELECT Name, Body,isPrivate,Description FROM Attachment WHERE Id IN :batchIds]){

attachmentsToMove.add(attachment);
attachmentsToInsert.add(new Attachment(Name = attachment.Name, Body = attachment.Body, ParentId=accPlanId,isPrivate=attachment.isPrivate,Description=attachment.Description));
}

}
System.debug('>>>second loop heap=' + Limits.getHeapSize());
insert attachmentsToInsert;
delete attachmentsToMove;

}*/
    
    
    
    
    // 1.2 - End
    
    //1.4 - Start
    
    @TestVisible
    private void bringOverPartnerBusinessEnablement(Id accPlanId){
        
        List<Partner_Business_Enablement__c> partnerBusinessEnablementList = [SELECT Channel_Plan_Name__c FROM Partner_Business_Enablement__c WHERE Channel_Plan_Name__c  = :originalAccPlan ];
        
        for(Partner_Business_Enablement__c partnerBusinessEnablement: partnerBusinessEnablementList ){
            
            
            partnerBusinessEnablement.Channel_Plan_Name__c = accPlanId;
            
        }
        
        update partnerBusinessEnablementList ;
        
        
    } 
    
    
    @TestVisible
    private void bringOverPartnerDetailing(Id accPlanId){
        
        List<Partner_Detailing__c> partnerDetailing = [SELECT Partner_Business_Plan_Name__c FROM Partner_Detailing__c WHERE Partner_Business_Plan_Name__c  = :originalAccPlan ];
        
        for(Partner_Detailing__c partnerDetail: partnerDetailing ){
            
            
            partnerDetail.Partner_Business_Plan_Name__c = accPlanId;
            
        }
        
        update partnerDetailing ;
        System.debug('Syuhada Debug partnerDetailing:' +partnerDetailing);
        
    } 
    
    //1.4 - End
    
    //1.5 & 1.6 - Start
    
    @TestVisible
    
    private void autopopulateAccTeamMember(){ 
        System.debug('autopopulateAccTeamMember -- account Id ::'+accPlan.Account__c);
        System.debug('autopopulateAccTeamMember -- originalAccPlan ::'+originalAccPlan);
        
        ID accId = accPlan.Account__c;
        //Map<String, ID> teamMemberMap = new Map<String, ID>();
        Set<AccountTeamMember> teamMemberSet = new Set<AccountTeamMember>();
        Id recordTypeId=IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true);
        
        List <AccountTeamMember> accTeamMemberList = [SELECT UserId, User.Name, TeamMemberRole, LastModifiedDate from AccountTeamMember WHERE 
                                                      AccountId = :accId  AND TeamMemberRole in  ('Account Executive','Partner Development Manager','Inside Channel Account Manager','Channel Inside Sales Manager','Inside Sales Rep','Regional Sales Manager') ORDER BY LastModifiedDate DESC];
        
        /*for(AccountTeamMember PDM: PDMTeamMemberList ){

        PDM.AccountId = accPlanId;
        }
        update PDMTeamMemberList;  */
        // System.debug('Syuhada Debug PDMTeamMemberList :' +PDMTeamMemberList);
        
        if(!accTeamMemberList.isEmpty()){
            Boolean aeAdded = false;
            Boolean pdmAdded = false;
            Boolean camAdded = false;
            Boolean mgrAdded = false;
            Boolean isrAdded = false;
            Boolean smgrAdded = false;
            
            newAccPlan.Account_Executive__c = null;
            newAccPlan.PDM__c = null;
            newAccPlan.CAM__c = null;  
            newAccPlan.Manager__c = null;
            newAccPlan.Inside_Sales_Representative__c = null;
            newAccPlan.Sales_Manager__c = null;  
            
            for(AccountTeamMember accTeam: accTeamMemberList ){
                system.debug('newAccPlan.Account_Executive__c--'+newAccPlan.Account_Executive__c);
                if( !aeAdded && 'Account Executive'.equalsIgnoreCase(accTeam.TeamMemberRole)){
                    aeAdded = true;
                    newAccPlan.Account_Executive__c = accTeam.userId;
                }else if( (recordTypeId == newAccPlan.RecordTypeId) && !pdmAdded &&'Partner Development Manager'.equalsIgnoreCase(accTeam.TeamMemberRole)){
                    newAccPlan.PDM__c = accTeam.userId; 
                    pdmAdded = true;
                }else if((recordTypeId == newAccPlan.RecordTypeId) && !camAdded && 'Inside Channel Account Manager'.equalsIgnoreCase(accTeam.TeamMemberRole)){
                    newAccPlan.CAM__c = accTeam.userId;
                    camAdded = true;
                }else if((recordTypeId == newAccPlan.RecordTypeId) && !mgrAdded && 'Channel Inside Sales Manager'.equalsIgnoreCase(accTeam.TeamMemberRole)){
                    newAccPlan.Manager__c = accTeam.userId; 
                    mgrAdded = true;
                }else if((recordTypeId != newAccPlan.RecordTypeId) && !isrAdded && 'Inside Sales Rep'.equalsIgnoreCase(accTeam.TeamMemberRole)){
                    newAccPlan.Inside_Sales_Representative__c = accTeam.userId;
                    isrAdded = true;
                }
            }
            
            //Account Plan owner
            newAccPlan.Account_Plan_Owner__c = UserInfo.getUserId();
            if(!String.isEmpty(newAccPlan.Account_Executive__c) && (recordTypeId != newAccPlan.RecordTypeId) && !smgrAdded){ 
                List<User> AEManagerList = [SELECT Manager__c, ManagerId, Manager.Name FROM User
                                            WHERE Id = :newAccPlan.Account_Executive__c];
                if(!AEManagerList.isEmpty()){
                    system.debug('###DEBUG### AEManagerList - ' + AEManagerList ); 
                    newAccPlan.Sales_Manager__c = AEManagerList[0].ManagerId;
                }                        
                smgrAdded = true;
            }
        }
    }
    
    //1.5 & 1.6 - End
    
    
    //1.1 - Start
    
    public String cloneAccPlan(Id originalAccPlan){
        
        newAccPlan=accPlan.clone(false,true);
        newAccPlan.Plan_Starting_Fiscal_Year__c='FY'+nextFiscalYear;
        newAccPlan.Date_Submitted_for_Approval__c=null;
        newAccPlan.Date_Rejected__c=null;
        newAccPlan.Date_Approved_by_Sales_Management__c=null;
        newAccPlan.Rejected_by__c=null;
        newAccPlan.Approved_by_Sales_Management__c=null;
        newAccPlan.Reason_for_Rejection__c=null;  
        
        //1.3 - Start
        
        newAccPlan.Calculated_Annual_Value_of_Strategies__c=0.00;    
        
        //1.3 - End
        
        //1.6 - Start
        autopopulateAccTeamMember(); //syuhada
        //1.6 - End
        
        insert newAccPlan;
        
        if(newAccPlan.Id!=null){
            newAccPlanIDString=String.valueOf(newAccPlan.Id);
        }
        
        return newAccPlanIDString;
        
    }
    
    public PageReference changeFY_Yes(){
        
        System.debug('Inside ChangeFY_Yes');
        
        PageReference accPlanPage;
        Savepoint sp1 = Database.setSavepoint();
        
        
        try{
            
            newAccPlanID=cloneAccPlan(originalAccPlan);
            System.debug('New AP--->'+newAccPlan);
            if(newAccPlanID!=null&&newAccPlanID!=''){
                
                //1.2-Start
                
                bringOverAttachments(newAccPlanID);
                bringOverNotes(newAccPlanID);
                bringOverTripReport(newAccPlanID);
                bringOverActivities(newAccPlanID);
                
                //1.2-End
                
                //1.4 - Start
                
                // Partner Detailing and Partner Business Enablement is applicable only for Partner Account Plans
                
                if(accPlan.RecordTypeId==IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true)) {
                    System.debug('This Account Plan'+accPlan.Id+'is Channel/Partner Account Plan'+accPlan.RecordTypeId );
                    bringOverPartnerDetailing(newAccPlanID);
                    bringOverPartnerBusinessEnablement(newAccPlanID);
                }
                
                //1.4 - End
                
                bringOverStrategy(newAccPlanID);
                accPlanPage = new PageReference('/'+newAccPlanID);
                accPlanPage.setRedirect(true);
                
            }
        }catch(DMLException de){
            
            accPlanPage=null;
            isException=true;
            exceptionMessageDetail=de.getMessage();
            exceptionMessageTitle='<b>Make sure to update the field that is listed as having invalid or missing data: \n\n</b> ';
            Database.rollback(sp1);  
        }
        catch(Exception e){
            
            apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())); 
            Database.rollback(sp1);
            
        }
        
        return accPlanPage ;
        
    } 
    
    public PageReference changeFY_No(){
        
        PageReference oldAccPlanPage=new PageReference('/'+originalAccPlan);
        oldAccPlanPage.setRedirect(true);
        return oldAccPlanPage;
    }
    
    
    public class MissingFYException extends Exception {}
    
    //1.1 - End
    
}