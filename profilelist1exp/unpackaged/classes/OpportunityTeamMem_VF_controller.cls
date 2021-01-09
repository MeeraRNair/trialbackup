/*
* Revision CR Number   Release No  Date            Modified By              Description
* -------- ---------   ----------  -----------     ------------             -----------
* 1.0      CR 12988     16.10       29-Mar-2016     JVSANTOSH         Display External Opportunity Team Members on Oppty Detail Page   
* 2.0      CR15930      FY19-0703   07-Jun-2018     Akshita           Removed Commented lines And, system.debug statements as part of Opportunity code reduce story
* 3.0      CR 12988     1201&0102   27-Dec-2019     Meera         Display External Opportunity Team Members on Oppty Detail Page
* -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
*/

//To  Display External Opportunity Team Members on Oppty Detail Page 
Public without sharing Class OpportunityTeamMem_VF_controller {
    
    Private final Opportunity oppty;   
    //Id opportunityId ;        
    public SObjectPaginator oppTeamMemPaginator    {get;set;}       
    public List<OpportunityTeamMember> oppTeamMemPaginationList  {get;set;}     
    Set<OpportunityTeamMember> listUpdateOppTeamMember ;
    // Constructor
    Public OpportunityTeamMem_VF_controller(ApexPages.StandardController controller) {
        String partnerAccountType;
        Try{
          Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge');
          Id opportunityId = Apexpages.Currentpage().getParameters().get('id') ;
          this.oppty = [Select Id, AccountId, PartnerAccountId, Distributor_Reseller_Name__c from Opportunity where Id =: opportunityId];

          Id strDistributor ;
          Id strReseller;
          
          If (!Test.isRunningTest()){
            partnerAccountType = DistiVisibilityHelperClass.getPartnerTypeFromAccount(oppty.PartnerAccountId);
          }
          Else{
              partnerAccountType = 'Distributor';
          }

          Id strEndUserAccId = oppty.AccountId;

          If (partnerAccountType == 'Distributor' ){
              strDistributor = oppty.PartnerAccountId;
              strReseller = oppty.Distributor_Reseller_Name__c;
          }else{
              strDistributor = oppty.Distributor_Reseller_Name__c;
              strReseller = oppty.PartnerAccountId;
          }
                
          list<OpportunityTeamMember> listOpptyTeamMember = [ Select Id, OpportunityAccessLevel, TeamMemberRole, OpportunityId, Opportunity.Name, Opportunity.Distributor_Reseller_Name__c,UserId, User.Name, User.ContactId, User.Contact.Name,  
                                                             User.Contact.Email, User.Phone,User.Email, User.Contact.Phone, Opportunity.PartnerAccountId, Opportunity.AccountId  From OpportunityTeamMember Where 
                                                             OpportunityId =: opportunityId And TeamMemberRole IN ( 'Reseller Contact','Distributor Contact','Inside Sales Rep','Technical Sales Rep','Technical Sales Rep SME','Account Executive',
                                                            'Global Account Manager','Inside Channel Account Manager','Data Center Sales Specialist','Partner Development Manager','Business Development Manager','Distribution Partner Development Manager','Partner AE',
                              'DC Sales Specialist', 'Account System Engineer', 'Partner System Engineer PreSales') ];
          Set<Id> setUserIds = new Set<Id>();
          Set<Id> setAccountIds = new Set<Id>();
          Map<Id, OpportunityTeamMember> mapOppTeamMember = new Map<Id, OpportunityTeamMember>();
          listUpdateOppTeamMember = new Set<OpportunityTeamMember>();

          If( listOpptyTeamMember.size() > 0 ){
            setAccountIds.add(listOpptyTeamMember[0].opportunity.AccountId);
            setAccountIds.add(listOpptyTeamMember[0].opportunity.PartnerAccountId);
            setAccountIds.add(listOpptyTeamMember[0].opportunity.Distributor_Reseller_Name__c);

            for(OpportunityTeamMember otm: listOpptyTeamMember){
              If(otm.TeamMemberRole =='Distributor Contact' || otm.TeamMemberRole =='Reseller Contact' || otm.TeamMemberRole == 'Partner AE'){
                listUpdateOppTeamMember.add(otm);
              }else{
                setUserIds.add(otm.UserId);        
                mapOppTeamMember.put(otm.UserId, otm);
              }
            } //end of for-loop
          }

          List<AccountTeamMember> accTeamMembers = new List<AccountTeamMember>();
          accTeamMembers = [Select
                              Id, UserId, AccountId, TeamMemberRole 
                            From 
                              AccountTeamMember 
                            Where
                              UserId IN: setUserIds
                              AND AccountId IN: setAccountIds ];

          for(AccountTeamMember atm: accTeamMembers){
              // Check for End User Account
              If(atm.AccountId == strEndUserAccId && (mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Inside Sales Rep' ||mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Account Executive' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Technical Sales Rep' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Technical Sales Rep SME' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Global Account Manager' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Data Center Sales Specialist' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'DC Sales Specialist'|| mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Account System Engineer' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Partner System Engineer PreSales' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Inside Channel Account Manager') ){
                listUpdateOppTeamMember.add(mapOppTeamMember.get(atm.UserId));
              }
              // Check for Reseller Account
              else If( atm.AccountId == strReseller && (mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Inside Sales Rep' ||mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Account Executive' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Inside Channel Account Manager' ||  mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Partner Development Manager' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Business Development Manager' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Technical Sales Rep' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Technical Sales Rep SME' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Data Center Sales Specialist' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'DC Sales Specialist'|| mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Account System Engineer' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Partner System Engineer PreSales' ) ){
                listUpdateOppTeamMember.add(mapOppTeamMember.get(atm.UserId));
              }
              // Check for Distributor Account
              else If( atm.AccountId == strDistributor && (mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Inside Sales Rep' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Account Executive' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Inside Channel Account Manager' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Distribution Partner Development Manager' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Business Development Manager' ||mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Technical Sales Rep' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Technical Sales Rep SME' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Data Center Sales Specialist'|| mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'DC Sales Specialist'|| mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Account System Engineer' || mapOppTeamMember.get(atm.UserId).TeamMemberRole == 'Partner System Engineer PreSales') ){
                listUpdateOppTeamMember.add(mapOppTeamMember.get(atm.UserId));
              }
          } //end of for-loop
        OpportunityTeamMemPaginationHandler PaginatorCtrl = new OpportunityTeamMemPaginationHandler();
        
        List<OpportunityTeamMember> listOppTeamMem = new List<OpportunityTeamMember>(listUpdateOppTeamMember);
        
        oppTeamMemPaginator                            = PaginatorCtrl.getOppTeamMemPaginator(listOppTeamMem);           
        oppTeamMemPaginationList  = PaginatorCtrl.oppTeamMemList;
        
        System.debug('##oppTeamMemPaginationList:'+oppTeamMemPaginationList);
        for(OpportunityTeamMember opp : oppTeamMemPaginationList) {
            System.debug('----User.Contact.Email--'+opp.User.Contact.Email);
        }
          
        }
        catch(QueryException qEx){
            system.debug('----QueryException---' + qEx.getMessage());
        }
        catch(DmlException dmlEx){
            system.debug('----DmlException---' + dmlEx.getMessage());
        }
        catch(Exception ex){
            system.debug('----Generic Exception---' + ex.getMessage());
        }       
    }   
}