global class BoomiContactPaginationCtrlExt {

		private static FINAL Integer PAGESIZE = 25;
		
		global List<Contact> contacts {get;private set;}
		global SObjectPaginator contactPaginator {get;private set;}
		
		global BoomiContactPaginationCtrlExt(){
			contacts = new List<Contact>();		
			this.contactPaginator = new SObjectPaginator(PAGESIZE,new ContactListListener(this));		
		}
		
		global void setContactRecords(List<Contact> contacts){
			this.contactPaginator.setRecords(contacts);				
		}
		
		global class ContactListListener implements SObjectPaginatorListener {
			private BoomiContactPaginationCtrlExt controller;
			global ContactListListener(BoomiContactPaginationCtrlExt controller){
				this.controller = controller;
			}
			global void handlePageChange(List<SObject> newPage){
				controller.handleContactListPageChange(newPage);
			}
		}
		
		global void handleContactListPageChange(List<SObject> newPage){
			contacts.clear();
			if(newPage != null){
				for(SObject item : newPage){
					contacts.add((Contact)item);
				}
			}
		}
	
		global SObjectPaginator getContactPaginator(List<contact> Contacts){
			setContactRecords(Contacts);
			return this.contactPaginator;
		}
}