/***********************************************************
    * Name          : TerritoryPlanNACtrl 
    * ---------------------------------------------------------
    * Revision  Name     CR#        Date           Description
    * 1.0       Swathi   CR13026    11 Apr 2016    Validate region and user for Territory plan printing 
    * 2.0       Swathi   CR13155    24 May 2016    Add Custom Label value instud of hard coding the DDP ID
    * 3.0       Shang    CR13344    27 July 2016   Add additional roles and Exclude Region
    * 4.0       Josie    CR14296    05 May 2017    Add new Roles - C&C SE’s, C&C GSE’s and C&C ISR’s   
*************************************************************/

public class TerritoryPlanNACtrl {

    public string strCurrentUserID {get;set;}
    Public Integer intNoOfRecords;  

    public TerritoryPlanNACtrl() {    
        strCurrentUserID = UserInfo.getUserId();    
    }

    public PageReference ValidateUser() {
     String strParameterRegion = apexpages.currentpage().getparameters().get('Region');
     string strQuery = 'SELECT count()'+
              ' from AccountTeamMember'+
              ' where UserId =: strCurrentUserID'+
              ' and (TeamMemberRole = \'Account Executive\' or TeamMemberRole = \'OEM Account Executive\''+ 
                                     ' or TeamMemberRole = \'OEM Global Account Manager\' or TeamMemberRole = \'Client & Compute Sales Exec\' or TeamMemberRole = \'Client & Compute Global Sales Exec\'';
     strQuery += strParameterRegion == 'NA' ? ' OR TeamMemberRole = \'Inside Sales Rep\' OR TeamMemberRole = \'Client & Compute Inside Sales Rep\')' : ')' ;  
     intNoOfRecords = Database.countquery(strQuery);
     
     
       //For NA user validation
        If(intNoOfRecords <= 0 ){
            if(strParameterRegion == 'NA'){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                    'Territory Plan is only enabled for AE’s, OEM AE’s, OEM GAM’s, ISR’s, C&C SE’s, C&C GSE’s and C&C ISR’s.'
                    + ' Please contact users with respective roles for Territory Plan creation/copy.'));
                    return null;
            }
            else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                    'Territory Plan is only enabled for AE’s, OEM AE’s, OEM GAM’s, C&C SE’s and C&C GSE’s.'
                    + ' Please contact users with respective roles for Territory Plan creation/copy.'));
                    return null;
            
            }
        }
        else{
          PageReference prredirecttodp = new PageReference(System.Label.Territory_Plan_DDP_URL);
                 prredirecttodp.setRedirect(true);            
                 return prredirecttodp ;   
        
        }
                     
    }
}