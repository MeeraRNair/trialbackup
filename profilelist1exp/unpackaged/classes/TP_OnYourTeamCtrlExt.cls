/*
* Author   : Sri Harsha Chadalavada
* Purpose  : Extension class to display team members of respective AE. 
*        
* Revision Ref Number  Release No  Date            Modified By     Description
* -------- ----------  ----------  -----------     ------------    -----------
* 1.0      	CR14887    	FY18-0102   06-Sep-2017     Harsha          Created
* 1.1	   	CR15152		FY18-0102	21-Nov-2017		Harsha			Removed logic related to save and pageNavigation
*/

public class TP_OnYourTeamCtrlExt {
    
    private static final List<string> rolesShortName = new List<string>{
        	'ISR',
            'TSR',
            'DCSS', 
            'ASE', 
            'SC',
            //'EUC SS',
            'CSG',
            'Services',
            'Networking SS',
            'Networking SE',
            'DFS'
                };
                
    private static final integer breakTableAt =5; //break table at index of rolesShortName
    public boolean bQuickSave {get; set;}
    
    public list<TeamMembersWithRole> listTeam1 {get; set;}
    public list<TeamMembersWithRole> listTeam2 {get; set;}
    
    public TP_OnYourTeamCtrlExt(ApexPages.StandardController controller) {

        string sUrlId = apexPages.currentPage().getParameters().get('id');
        //system.debug('teamMembers : ' +teamMembers);
        displayTeam();
        bQuickSave = ((sUrlId!=NULL) ? TRUE : FALSE);
    }
    
    private void displayteam(){
        List<string> teamRoles = TP_Utilities.teamRoles;
        list<list<string>> teamMembers = TP_Utilities.getAccountTeamRecords(teamRoles);
        
        listTeam1 = new list<TeamMembersWithRole>();
        listTeam2 = new list<TeamMembersWithRole>();
        Map<string, Set<string>> usersByRole = TP_Utilities.usersByRole;
        //system.debug('team map by role : '+usersByRole);
        for(integer i=0; i<teamRoles.size();i++){
            string role = TP_Utilities.normalizeRoleFieldName(teamRoles[i]);
            system.debug(rolesShortName[i]+'====='+role+'-------'+usersByRole.get(role));
            if(i<breakTableAt){
                listTeam1.add( new TeamMembersWithRole(rolesShortName[i],concatString(usersByRole.get(role))));
            }
            else{
                listTeam2.add( new TeamMembersWithRole(rolesShortName[i],concatString(usersByRole.get(role))));
            }
        }
        //system.debug('listTeam---'+listTeam);  
    }
    
    private string concatString(set<string> setStr){
        string str ='';
        if(setStr!=NULL){
            for(string s: setStr){
                str+= ', '+s;
            }
            str = str.substringAfter(',');
        }
        return str;
    }
    
    public class TeamMembersWithRole{
        
        public string sRoleName {get; set;}
        public string sTeamMembers {get; set;}

        public TeamMembersWithRole(string roleName, string teamMembers){
            sRoleName = roleName;
            sTeamMembers = teamMembers;
        }
    }
}