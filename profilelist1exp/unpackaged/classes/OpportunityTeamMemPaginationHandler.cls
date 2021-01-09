global class OpportunityTeamMemPaginationHandler {
    
    private static FINAL Integer PAGESIZE = 10;
        
        global List<OpportunityTeamMember> oppTeamMemList {get;private set;}
        global SObjectPaginator oppTeamMemPaginator {get;private set;}
        
        global OpportunityTeamMemPaginationHandler(){
            oppTeamMemList = new List<OpportunityTeamMember>();     
            this.oppTeamMemPaginator = new SObjectPaginator(PAGESIZE,new OppTeamMemListner(this));      
        }
        
        global void setOppTeamMemRecords(List<OpportunityTeamMember> oppTeamMemList){
            this.oppTeamMemPaginator.setRecords(oppTeamMemList);                
        }
        
        global class OppTeamMemListner implements SObjectPaginatorListener {
            private OpportunityTeamMemPaginationHandler controller;
            global OppTeamMemListner(OpportunityTeamMemPaginationHandler controller){
                this.controller = controller;
            }
            global void handlePageChange(List<SObject> newPage){
                controller.handleOppTeamMemListPageChange(newPage);
            }
        }
        
        global void handleOppTeamMemListPageChange(List<SObject> newPage){
            oppTeamMemList.clear();
            if(newPage != null){
                for(SObject item : newPage){
                    oppTeamMemList.add((OpportunityTeamMember)item);
                }
            }
        }
    
        global SObjectPaginator getOppTeamMemPaginator(List<OpportunityTeamMember> oppTeamMemList){
            setOppTeamMemRecords(oppTeamMemList);
            return this.oppTeamMemPaginator;
        }

}