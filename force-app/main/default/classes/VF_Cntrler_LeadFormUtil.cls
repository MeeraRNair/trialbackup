/* 
Description: Apex controller Class which contains the methods which help in displaying and manipulating lead information using VF page : "Talk To Dell WebForm"
Version: 2.0

History:

1.0 - 27-Jan-2009:  Creation
2.0 - 05-Jan-2009:  Updated ::  Included Site Template and changed parameter passing mechanisam 
3.0 - 24-Mar-2009:  updated ::  Implimented language translation for the Form; used DescribeObject for getting the Picklist values
4.0 - 21-Dec-2010:  Added Industry / Vertical Needs column
5.0 - 09-Jul-2018:  Sakshi: Reduce Code

Author: Hardeep/Krishnaprasad P/Meera Nair 
*/
public class VF_Cntrler_LeadFormUtil {

    //Create new Lead object to be used in the VF page
    private Lead leadItem=new Lead();
    
    String[] DataCenterOptimizationList = new String[]{};
    String[] EndUserProductivityList = new String[]{};
    String[] ITProcessSimplificationList = new String[]{};
    
    //4.0
    String[] IndustryVerticalNeedList = new String[]{};
    
    string languageCode = PartnerUtils.getPreferredLanguageCode();
    
    //Get all URL parameters in to a map
    Map<String,String> paramMap=ApexPages.currentPage().getParameters();    
    
    public String getPreferredLanguageCode(){  
        return languageCode; 
    }

    public Lead getLeadItem(){
        return leadItem;
    }
    public String[] getDataCenterOptimizationList(){
        return DataCenterOptimizationList;
    }
    public String[] getEndUserProductivityList(){
        return EndUserProductivityList;
    }
    public String[] getITProcessSimplificationList(){
        return ITProcessSimplificationList;
    }

    //4.0
    public String[] getIndustryVerticalNeedList(){
        return IndustryVerticalNeedList ;
    }
    
    //Create and get values for multiselect checkboxes
    public List<SelectOption> getItemsDataCenterOptimizationList() {
        List<SelectOption> optiondcp = new List<SelectOption>();
        Schema.DescribeFieldResult picklistFieldSchema = Lead.Data_Center_Optimization__c.getDescribe();
        optiondcp = createOptionsForMultiPickList(picklistFieldSchema);     
        return optiondcp;
    }
    public List<SelectOption> getItemsEndUserProductivityList() {
        List<SelectOption> optioneup = new List<SelectOption>();
        Schema.DescribeFieldResult picklistFieldSchema = Lead.End_user_Productivity__c.getDescribe();
        optioneup = createOptionsForMultiPickList(picklistFieldSchema);     
        return optioneup;
    }

    public List<SelectOption> getItemsITProcessSimplificationList() {
        List<SelectOption> optionips= new List<SelectOption>();
        Schema.DescribeFieldResult picklistFieldSchema = Lead.IT_Process_Simplification__c.getDescribe();
        optionips = createOptionsForMultiPickList(picklistFieldSchema);     
        return optionips;
    }
    
    //4.0
    public List<SelectOption> getItemsIndustryVerticalNeedList() {
        List<SelectOption> optionivns= new List<SelectOption>();
        Schema.DescribeFieldResult picklistFieldSchema = Lead.Industry_Vertical_Need__c.getDescribe();
        optionivns = createOptionsForMultiPickList(picklistFieldSchema);     
        return optionivns;
    }
    
    //This method creates a list of  SelectOptions from the DescribeFieldResult of a multipicklist field  
    public List<SelectOption> createOptionsForMultiPickList(Schema.DescribeFieldResult picklistFieldSchema) {
        
        List<Schema.PicklistEntry> PicklistEntrySchema = picklistFieldSchema.getPicklistValues();    
        
        List<SelectOption> optiondcp = new List<SelectOption>();
        for(integer i=0; i< PicklistEntrySchema.size();i++){
            if(PicklistEntrySchema[i].isActive()){
                optiondcp.add(new SelectOption(PicklistEntrySchema[i].getValue(),PicklistEntrySchema[i].getLabel()));                
            }
        }
        return optiondcp;         
    }
    
    //Method to convert selected checkbox values to multipicklist values
    private string Convert_To_MultiPicklist(List<String> selectedList) {
        string actualValue='';
        integer i=0;
        for(i=0; i< selectedList.size()-1;i++){
            actualvalue += selectedList[i]+';';
        }            
       if(selectedList.size()>0)
            actualvalue += selectedList[i];
        
        return actualvalue ;
    }
    
    //Set methods for the controller variables
    public void setDataCenterOptimizationList (String[] DataCenterOptimizationList ) {
        this.DataCenterOptimizationList = DataCenterOptimizationList ;
    }
    
    public void setEndUserProductivityList (String[] EndUserProductivityList) {
        this.EndUserProductivityList= EndUserProductivityList;
    }
    
    public void setITProcessSimplificationList (String[] ITProcessSimplificationList) {
        this.ITProcessSimplificationList= ITProcessSimplificationList;
    }
    
    //4.0
    public void setIndustryVerticalNeedList (String[] IndustryVerticalNeedList) {
        this.IndustryVerticalNeedList= IndustryVerticalNeedList;
    }
    
    //Method for saving lead information
    public PageReference SaveLead() {

        leadItem.LeadSource='Web';
        
        String url='/apex/TalkToDellWebFormSaved';
        
        try{
           
            //Call method to convert multiselect checkbox values to multipicklist values
            leadItem.Data_Center_Optimization__c= Convert_To_MultiPicklist(DataCenterOptimizationList);
            leadItem.End_user_Productivity__c= Convert_To_MultiPicklist(EndUserProductivityList);
            leadItem.IT_Process_Simplification__c= Convert_To_MultiPicklist(ITProcessSimplificationList);
            
            //4.0
            leadItem.Industry_Vertical_Need__c = Convert_To_MultiPicklist(IndustryVerticalNeedList);
          
            leadItem.Country_Code__c= paramMap.get('c');
            leadItem.Segment_Code__c= paramMap.get('s');       
            leadItem.Referral_Code__c= paramMap.get('cs'); 
            leadItem.Language_Code__c= paramMap.get('l');           
            leadItem.Campaign_ID_LinkTracker__c=paramMap.get('cid');//Added as a part of CR#1823. [Ambily 30-Apr-2010]

            insert leadItem;
            
            if(paramMap.size()!=0){
                String paramToPass='?';
                for(String paramKey:paramMap.keyset()){
                    paramToPass+=paramKey+'='+paramMap.get(paramKey)+'&';
                }            
                //removes the trailing "&" symbol from paramToPass.                
                String paramToPassActual=paramToPass.subString(0,(paramToPass.length())-1);   
                          
                url=url + paramToPassActual;
            }
                  
        
        }
        catch(Exception e){
                System.debug(e.getMessage());            
                //Exception are not displayed on the page.If exception occurs navigate to "unavailable" page
          
                //ApexPages.addMessages(e); 
                url='/apex/TalkToDellWebFormUnavailable'; 
                PageReference pageref=new PageReference(url);      
                return pageref;        
        }
        
        PageReference pageref=new PageReference(url);
        
        return pageref;
    }
}