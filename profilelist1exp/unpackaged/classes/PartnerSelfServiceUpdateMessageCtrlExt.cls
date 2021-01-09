public class PartnerSelfServiceUpdateMessageCtrlExt {

    public static String NO_CHANGE {get{return 'NO_CHANGE';}} 
    public static String SLA{get{return 'SLA';}}
    
    public String messageType { get; set; }

    public PageReference navigateToCompanyProfile(){
        return PageUtils.redirect('/apex/PartnerSelfServiceMyCompany');
    }

    public PartnerSelfServiceUpdateMessageCtrlExt (){
        messageType= SLA; 
        String paramType=PageUtils.get('type');        
        if(paramType=='nochange'){
            messageType = NO_CHANGE;
        }        
    }
    
}