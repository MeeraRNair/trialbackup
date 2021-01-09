public class VFCntrlr_MasterProgram_lookup {
    public String search_MP{get; set;}       
    List<Master_Program_Setup__c> mp_results;

    public PageReference go(){          
        try{
            String queryName = '%' + search_MP + '%';
            
            mp_results = [select id, Master_Program_Name__c,Active__c
                                from Master_Program_Setup__c
                                where Name like :queryName 
                                limit 100];
          }
        catch(Exception ex){
            ApexPages.addMessages(ex);              
        }
        return null;
      }  
        
    public List<Master_Program_Setup__c> getResults() {
        return mp_results;
    }    
}