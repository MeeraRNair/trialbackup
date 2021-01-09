/*
REVISION HISTORY
================
Version     Author          Date            Release#        CR#              Description
-------     ------          ----            --------        ---             -----------
1.0         Harikrishna     August-2013      14.10           8365          Including the Account Name as a filter to search for resources in Sales Connect 
2.0         Karthik         November-2013    14.10           Defect 83574  Pagination is not working and hence all the specialists are not displayed to the User
3.0         Mohammad        Jan-2015         Sprint5         10527         Included Account Country in search to avoid SOQL Query Exception 
*/

public class SpecialistSearchCtrl {
    private String OppId;
    private String OppName;
    private integer counter = 0;  // keeps track of the offset
    private integer list_size = 20; // number of rows
    public integer total_size; // number of records
    public integer current_size; // number of records in a page
    public boolean disablePrevious {get;set;} // Defect85374 changes
    public boolean disableNext {get;set;}  // Defect85374 changes
    public User SpecialistUser {get;set;}
    //public List<SelectOption> RoleOptions {get;set;}
    //public List<Specialist_Role__c> SpecialistRoleList = new List<Specialist_Role__c>();
    //public String SpecialistRole;
    static String SpecialistSR_RecordTypeId = '012A0000000ViNJ'; // the record type id for Request Specialist Support.
    static String SRStatusFieldId = '00NZ0000000WZAU'; // field id for Status in Support Request object.
    static String SROpportunityFieldId = '00N70000002NKud'; // field id for Opportunity in Support Request object.
    public String Geography{get; set;}
    public String JobTitle{get; set;}
    public String SegmentBusinessUnit{get; set;}
    public String ServicesLOB{get; set;}
    public String Specialization{get; set;}
    public String Territory{get; set;}
    public String Verticals{get; set;}
    public String SpecialistName{get; set;}
    public String AccountName{get;set;} // added by Hari
    public String QueryConditions = '';
    public String Conditions = '';
    public String QueryInitial = 'SELECT Id, Name, Geography__c, Job_Title__c, Segment_Business_Unit__c, Services_LOB__c, Specialization__c, Territory__c, Verticals__c, Region__c, User__r.Id, User__r.Name, User__r.Email, User__r.Phone, User__r.MobilePhone FROM Sales_Connect_User__c WHERE IsUserActive__c = \'true\' AND IsSpecialistActive__c = true ';
    public String QueryFinal;
    public String SupportRequestURL;
    public map<string,set<string>> accountUsers;
    public map<string,string> connectUserAccountNames{get;set;}
    public SpecialistSearchCtrl() {
        disablePrevious = true; // Defect85374 changes
  
        OppId = System.currentPageReference().getParameters().get('id');
        OppName = System.currentPageReference().getParameters().get('name');
       
        // Fenny TODO: OppName = OppName.remove('%');
        //OppName = PageUtils.encodeVariable(OppName); // Fenny TODO
        Geography = System.currentPageReference().getParameters().get('country');
        //Specialization = System.currentPageReference().getParameters().get('domain');
        SegmentBusinessUnit = System.currentPageReference().getParameters().get('businessUnit');
        Verticals = System.currentPageReference().getParameters().get('verticals');
        //ServicesLOB = System.currentPageReference().getParameters().get('serviceLOB');
        // Added by Hari
        if(oppId!=null)
        {
            AccountName=[select account.name from Opportunity where id=:oppId limit 1].account.name;
        
        }
        QueryConditions = getConditions();
        List<Sales_Connect_User__c> countList = Database.query(QueryInitial + QueryConditions);
        total_size = countList.size();
        Previous(); // Defect85374 changes 
        Next();
        //total_size = [SELECT count() from Sales_Connect_User__c WHERE IsActive__c = 'true'];
        /*if(SpecialistRole != null){
            total_size = [SELECT count() from User WHERE Specialist_Role__c = :SpecialistRole]; //set total_size 
        }
        else{
            total_size = [SELECT count() from User WHERE Specialist_Role__c != '']; //set total_size 
        }*/
        
        //SpecialistUser = new User();
        
        /*RoleOptions = new List<SelectOption>();
        RoleOptions.add(new SelectOption('','All Role'));
        
        for(Specialist_Role__c SpecialistRoleList: [SELECT Name FROM Specialist_Role__c ORDER BY Name ASC]){
            RoleOptions.add(new SelectOption(SpecialistRoleList.Name, SpecialistRoleList.Name));        
        }*/

        /*Schema.DescribeFieldResult statusFieldDescription = User.Specialist_Role__c.getDescribe();

        for (Schema.Picklistentry picklistEntry: statusFieldDescription.getPicklistValues()){
            RoleOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));

            if (picklistEntry.defaultValue){
                SpecialistUser.Specialist_Role__c = pickListEntry.getValue();
            }  
        }*/
    }

    public List<Sales_Connect_User__c> getSpecialist() {
        /*if(SpecialistRole != null){
            //return [SELECT Id, Name, Specialist_Role__c, Phone, MobilePhone FROM User WHERE Specialist_Role__c = :SpecialistRole LIMIT :list_size OFFSET :counter];
        }
        else{
            //return [SELECT Id, Name, Specialist_Role__c, Phone, MobilePhone FROM User WHERE Specialist_Role__c != '' LIMIT :list_size OFFSET :counter];
        }*/
        connectUserAccountNames=new map<string,string>();
        QueryFinal = 'ORDER BY Name ASC LIMIT ' + list_size + ' OFFSET ' + counter;
        /*if(Geography != '' && Geography != null){
            PrefixGeography = ' AND Geography__c LIKE \'%' + Geography  + '%\'';
        }*/
        QueryConditions = getConditions();
        List<Sales_Connect_User__c> countList = Database.query(QueryInitial + QueryConditions + QueryFinal);
        system.debug('--------Final output-----'+countList);
        system.debug('--------QueryInitial -----'+QueryInitial);
        system.debug('--------QueryConditions-----'+QueryConditions);
        system.debug('--------QueryFinal-----'+QueryFinal);
        current_size = countList.size();
       // total_size =current_size ;
       // counter = 0;
        string accountNames;
        system.debug('===MAP VALUE======'+accountUsers);
        for(Sales_Connect_User__c scUser:countList)
        {
            accountNames='';
            for(string acctName:accountUsers.keySet())
            {
                system.debug('--sc id-'+scUser.Id+'===='+accountName+'====='+accountUsers.get(accountName));
                set<string> userIds=new set<string>();
                userIds=accountUsers.get(acctName);
                if(userIds.size()>0)
                {
                    if(userIds.contains(scUser.User__c))
                    {
                        if(accountNames!='' && !accountNames.contains(acctName)){
                             accountNames+=acctName+' ; ';
                        }
                        else{
                         accountNames=acctName+' ; ';
                        }
                    }
                }
            }
            if(accountNames!='')
                accountNames=accountNames.subString(0,accountNames.lastIndexOf(';'));
            connectUserAccountNames.put(scUser.Id,accountNames);
        }
       // return Database.query(QueryInitial + QueryConditions + QueryFinal); commented by hari
       return countList ;
    }
   
    public String getConditions(){
        Conditions = '';
         accountUsers=new map<string,set<string>>();
        if(Geography != '' && Geography != null){
            Conditions += ' AND Geography__c LIKE \'%' + Geography.replace('\'', '\\\'').replace('%', '\\%')  + '%\'';
        }
        if(JobTitle != '' && JobTitle != null){
            Conditions += ' AND Job_Title__c LIKE \'%' + JobTitle.replace('\'', '\\\'').replace('%', '\\%') + '%\'';
        }
        if(SegmentBusinessUnit != '' && SegmentBusinessUnit != null){
            Conditions += ' AND Segment_Business_Unit__c LIKE \'%' + SegmentBusinessUnit.replace('\'', '\\\'').replace('%', '\\%')  + '%\'';
        }
        if(ServicesLOB != '' && ServicesLOB != null){
            Conditions += ' AND Services_LOB__c LIKE \'%' + ServicesLOB.replace('\'', '\\\'').replace('%', '\\%')  + '%\'';
        }
        if(Specialization != '' && Specialization != null){
            Conditions += ' AND Specialization__c LIKE \'%' + Specialization.replace('\'', '\\\'').replace('%', '\\%')  + '%\'';
        }
        if(Territory != '' && Territory != null){
            Conditions += ' AND Territory__c LIKE \'%' + Territory.replace('\'', '\\\'').replace('%', '\\%')  + '%\'';
        }
        if(Verticals != '' && Verticals != null){
            Conditions += ' AND Verticals__c LIKE \'%' + Verticals.replace('\'', '\\\'').replace('%', '\\%')  + '%\'';
        }
        if(SpecialistName != '' && SpecialistName != null){
            Conditions += ' AND Name LIKE \'%' + SpecialistName.replace('\'', '\\\'').replace('%', '\\%')  + '%\'';
        }
        // Hari adding to search through Account name
        system.debug('============='+AccountName);
        if(AccountName!='' && AccountName!=null)
        {
            // Query on account object using account Name and get all User Ids of that account
            string tempAccountName='%'+AccountName+'%';
            system.debug('####Temp Account Name#####'+tempAccountName);
            string accountQuery='', userIdString='(';
            set<id> userIds=new set<id>();
            list<string> userFieldNames=new list<string>();
            for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.Account_User_Fields.getFields()) 
            {
                    accountQuery += f.getFieldPath() + ', ';
                    userFieldNames.add(f.getFieldPath());
            }
            if(accountQuery!=null && accountQuery!=''){
              system.debug('---account query-----'+Geography);
              if(Geography!=null && Geography!='')
                accountQuery='select '+accountQuery+' id,name, (select userId from accountTeamMembers) from Account where name like :tempAccountName AND Account_country__c=:Geography';  
              else
              accountQuery='select '+accountQuery+' id,name, (select userId from accountTeamMembers) from Account where name like :tempAccountName '; 
              
               } 
            else
                accountQuery='select id,name, (select userId from accountTeamMembers) from Account where name like:tempAccountName';
            system.debug('---account query-----'+accountQuery);
            
            List<Account> accountRecords=Database.query(accountQuery);
            system.debug('---account rows-----'+accountRecords);
            set<string> tempuserIds;
            for(Account acc:accountRecords)
            {
                tempuserIds=new set<string>();
                system.debug('---'+acc.Id+'----------'+acc.accountTeamMembers);
                for(AccountTeamMember accTeam: acc.accountTeamMembers)
                {
                    tempuserIds.add(accTeam.userId);
                    userIds.add(accTeam.userId);
                }
                for(string fieldName:userFieldNames)
                {
                    if(acc.get(fieldName)!=null)
                    {
                        userIds.add(string.valueOf(acc.get(fieldName)));
                         tempuserIds.add(string.valueOf(acc.get(fieldName)));
                    }
                }
                accountUsers.put(acc.Name,tempuserIds);
            }
            for(String userId:userIds)
            {  
                userIdString+='\''+userId+'\''+',';
            }
            system.debug('----user Id string------'+userIdString);
            Integer result = userIdString.length();
           // userIdString =userIdString.left(result-1)+') ';
           if(userIdString!='(')
           {
                userIdString=userIdString.subString(0,userIdString.lastIndexOf(','))+') ';
                  Conditions += ' AND User__c IN '+userIdString;
           }
           else{
               userIdString='('+'\''+'\''+')';
                Conditions += ' AND User__c IN '+userIdString;
           }
            
            system.debug('--user id string--'+userIdString);
           
        }
        return Conditions;
    }
    
    public String getOppId(){
        return OppId;
    }
    
    public String getOppName(){
        return OppName;
    }
    
    public PageReference Display(){
        /*SpecialistRole = SpecialistUser.Specialist_Role__c;
        System.debug('### SpecialistRole: ' + SpecialistRole);
        if(SpecialistRole != null){
            total_size = [SELECT count() from User WHERE Specialist_Role__c = :SpecialistRole]; //set total_size
        }
        else{
            total_size = [SELECT count() from User WHERE Specialist_Role__c != '']; //set total_size 
        }*/
       // QueryConditions = getConditions();
      //  system.debug('############'+QueryInitial);
      //  system.debug('############'+QueryConditions);
      //List<Sales_Connect_User__c> countList = Database.query(QueryInitial + QueryConditions);
      //total_size = countList.size();
       // counter = 0;
       // Defect85374 changes Start
        counter = 0; 
        
        QueryConditions = getConditions();
        List<Sales_Connect_User__c> countList = Database.query(QueryInitial + QueryConditions);
        total_size = countList.size();
        Previous();
        Next();
        // Defect85374 changes End
        return null;
    }
    
    public PageReference gotoOpportunity() {
        PageReference pageRef = new PageReference('/' + OppId);
        return pageRef;
    }
    
  
   /* public PageReference gotoSpecialistRequest(){ 
        String retURL = ('/apex/SpecialistSearch?id=' + OppId + '&name=' + PageUtils.encodeVariable(OppName) + '&country=' + Geography + '&businessUnit=' +PageUtils.encodeVariable(SegmentBusinessUnit)  + '&verticals=' + Verticals);
        return PageUtils.redirect('/a0J/e?RecordType=' + SpecialistSR_RecordTypeId + '&' + SRStatusFieldId + '=New&CF' + SROpportunityFieldId + '_lkid=' + OppId + '&CF' + SROpportunityFieldId + '=' + OppName + '&retURL=' + retURL);
        
    }*/
    
    
    public String getSupportRequestURL(){
        SupportRequestURL = '/a0J/e?RecordType=' + SpecialistSR_RecordTypeId + '&' + SRStatusFieldId + '=New&CF' + SROpportunityFieldId + '_lkid=' + OppId + '&CF' + SROpportunityFieldId + '=' + PageUtils.encodeVariable(OppName) + '&retURL=' + PageUtils.encodeVariable('/apex/SpecialistSearch?id=' + OppId + '&name=' + PageUtils.encodeVariable(StringUtils.defaultString(OppName)) + '&country=' + StringUtils.defaultString(Geography) + '&businessUnit=' +PageUtils.encodeVariable(StringUtils.defaultString(SegmentBusinessUnit))  + '&verticals=' + StringUtils.defaultString(Verticals));
        return SupportRequestURL;
    }

   // Defect85374 changes Start
   /* public PageReference Previous() { //previous button
        counter -= list_size;
        return null;
    }

    public PageReference Next() { //next button
        counter += list_size;
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //disable the previous buttons
        if (counter > 0) return false; else return true;
    }
    
    public Boolean getDisableNext() { 
        //disable the next buttons
        if (counter + list_size < total_size) return false; else return true;
    }*/
    
    public PageReference Previous() 
    { 
       counter -= list_size;
       
       if (counter == 0) 
           disablePrevious = TRUE;
       else 
           disablePrevious = FALSE;
           
       if (counter + list_size < total_size) 
          disableNext = false; 
      else 
          disableNext = true;
          
        return null;
    }

    public PageReference Next() 
    { 
      counter += list_size;
      
      if (counter > 0) 
           disablePrevious = false;
       else 
           disablePrevious = true;
           
      if (counter + list_size < total_size) 
          disableNext = false; 
      else 
          disableNext = true;
          
      return null;
    }
    // Defect85374 changes End
    
    public String getPageNumber(){
        integer totalPageNum;
        if(math.mod(total_size, list_size) > 0)
            totalPageNum = total_size/list_size + 1;
        else{
            totalPageNum = total_size/list_size;
            if(totalPageNum == 0) totalPageNum++;
        }
        String pageString = 'Page ' + ((counter/list_size) + 1) + ' of ' + totalPageNum; 
        return pageString;
    }
    
    public String getRecordNumber(){
        String recordString;
        if(total_size == 0) 
            recordString = '' + counter + ' - ' + (counter + current_size) + ' of ' + total_size;
        else
            recordString = '' + (counter + 1) + ' - ' + (counter + current_size) + ' of ' + total_size;
        return recordString;
    }
    
    public class salesConnectUserWrapper
    {
        public String accountName{get;set;}
        public Sales_Connect_User__c sconnectUser{get;set;}
        public salesConnectUserWrapper(String accountName, Sales_Connect_User__c sconnectUser)
        {
            this.accountName=accountName;
             this.sconnectUser=sconnectUser;
            
        }   
    
    }
}