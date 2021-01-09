/*
 * Author   : Sri Harsha Chadalavada
 * Purpose  : Utility class to save territory plan record and to redirect to other pages.
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR14881    	FY18-0102   06-Sep-2017     Harsha          Created
 * 2.0		CR15152    	FY18-0102   21-Nov-2017     Harsha			Added VF pages list
 */


public class TP_PageNavUtils {
    
    //v2.0 start
    public static list<string> vfPageNames = new list<string>{
        	'TP_OnYourTeam',
            'TP_Obj3Goals',
            'TP_Landscape',
            'TP_HTOverview',
            'TP_AccRevTrends',
            'TP_LOBRT_ObsActions',
            'TP_AcctPrityActions',
            'TP_ClientBusiness',
            'TP_BuildYDCBusiness',
            'TP_GCNBusiness',
            'TP_AcctPlanSumry',
            'TP_ChnlStrategy',
            'TP_CustEngmtEvents',
            'TP_SumActRequests'
    };
    public static map<string, integer> vfPageSeq;
        
    public TP_PageNavUtils(){
        vfPageSeq = new map<string, integer>();
        integer i=0;
        for(string pn : vfPageNames){
            vfPageSeq.put(pn, i);
            i++;
        }
        system.debug(vfPageSeq);
    }
    //v2.0 end
    
    public static PageReference gotoPage(String pageName, Id recordID){
        string BaseURL = ApexPages.currentPage().getHeaders().get('Host');
        string url = 'https://'+BaseURL+'/apex/'+pageName+'?id='+recordID;
        pageReference pg = new pageReference(url);
        pg.setRedirect(true);
        return pg;

    }
    
    public static void save(Territory_plan__c tpSave, String pageName, Boolean isUpdated){
        try{
            tpSave.Continue_To_Page__c = pageName;
            if(!isupdated)
                insert tpSave;
            else
                update tpSave;
        } Catch(Exception e){
            system.debug('exception : '+e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, string.valueof(e)));
        }
    }

}