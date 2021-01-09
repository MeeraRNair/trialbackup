/***********************************************************
* Name			: VFCntrlr_ToolsForTheJob
* Description	: Controller for VisualForce page ToolsForTheJob
* ---------------------------------------------------------
* Revision	Name		Date			Description
* 1.0		MenMee		16-07-2009		CR 1588 Single Global Home Page
* 2.0       Nooryati	23-02-2011		CR 2629 *QI* BA link Help / hover text.
*
*
************************************************************/

public class VFCntrlr_ToolsForTheJob {
	//Declaration
	private static final String SHARED_HEADER = 'Global Standard Links';
	private static final String SHARED_PICKLISTVALUE = 'Global';
	
	// Description: Method to generate a table in HTML code
	// Parameter: -
	// Return: String:HTML Code
	public string getHTMLCode() {
		
		string htmlCode;
		integer i = 0;		
		List<String> sectionList = new List<String> ();
		List<String> whereList = new List<String> ();
		List<Tools_For_The_Job__c> TFJList = new List<Tools_For_The_Job__c>();
		List<Schema.Picklistentry> sectionValues;							
		
		Schema.DescribeFieldResult fSection = Tools_For_The_Job__c.Section__c.getDescribe();
		sectionValues = fSection.getPicklistValues();
		
		for (Schema.PicklistEntry sectionValue: sectionValues) {
			if (sectionValue.getLabel() != SHARED_PICKLISTVALUE) sectionList.add(sectionValue.getLabel());		
			whereList.add(sectionValue.getLabel());		
		} 
		sectionList.sort();
		
		TFJList = [ SELECT Name, URL__c, Section__c, Sub_section__c, Help_Text__c		 						
					FROM Tools_For_The_Job__c 
					WHERE Active__c = true AND Section__c IN :whereList
					ORDER BY Section__c, sequence__c, Name ASC];
		
		System.debug('###### Create column for ' + SHARED_HEADER + ' section ######');
		
		// Row for Global section
		htmlCode = '<tr>';
		htmlCode = htmlCode + '<td colspan=' + string.valueOf(sectionList.size()) + '>';
		htmlCode = htmlCode + '<div class="bSubBlock">';
		htmlCode = htmlCode + '<h3 class="lbHeader">' + SHARED_HEADER + '</h3>';
		htmlCode = htmlCode + '<div class="lbBody">';
			
		while (i < TFJList.size()) {				
			if (TFJList[i].Section__c == SHARED_PICKLISTVALUE) {
				htmlCode = htmlCode +  '<ul>';
				if (TFJList[i].Sub_Section__c == true) 
					htmlCode = htmlCode + '<br/><li class="lbSubSection">' + TFJList[i].Name + '</li>';
				else {
					  htmlCode = htmlCode + '<li><a style="color:black;" href="' + TFJList[i].URL__c + '" target="_blank" ';
					  //CR 2629: *QI* BA link Help / hover text.
					  if (TFJList[i].Help_Text__c!= null)
					  	htmlCode = htmlCode + 'title="' + TFJList[i].Help_Text__c + '"' ;
					  htmlCode = htmlCode + '>' + TFJList[i].Name + '</a></li>'; }				
					
				htmlCode = htmlCode + '</ul>' ;			
			}			
			i++;
		}
		htmlCode = htmlCode + '</div></div></td></tr>';
		
		System.debug('###### Complete column for ' + SHARED_HEADER + ' section ######');
		
		// Row for non Global section
		htmlCode = htmlCode + '<tr>';
				
		i = 0;		
		for (integer j = 0; j < sectionList.size(); j++) {
						
			// Create new row for every 4 columns
			// formula for mod operator			
			if ((j - Integer.valueOf(j /4 ) * 4) == 0) htmlCode = htmlCode + '</tr><tr>';
			
			System.debug('###### Create column for ' + sectionList[j] + ' section ######');
			
			htmlCode = htmlCode + '<td width="25%">';
			htmlCode = htmlCode + '<div class="bSubBlock">';
			htmlCode = htmlCode + '<h3 class="lbHeader">' + sectionList[j] + '</h3>';
			htmlCode = htmlCode + '<div class="lbBody">';
						
			while (i < TFJList.size()) {
				if (TFJList[i].Section__c == sectionList[j] ) {		
					
					htmlCode = htmlCode +  '<ul>';
					if (TFJList[i].Sub_Section__c == true) 
						htmlCode = htmlCode + '<br/><li class="lbSubSection">' + TFJList[i].Name + '</li>';					
					else {
					  	  htmlCode = htmlCode + '<li><a style="color:black;" href="' + TFJList[i].URL__c + '" target="_blank" ';
					  	  //CR 2629: *QI* BA link Help / hover text. 
					  	  if (TFJList[i].Help_Text__c!= null)
					  		htmlCode = htmlCode + 'title="' + TFJList[i].Help_Text__c + '"' ;
					   	  htmlCode = htmlCode + '>' + TFJList[i].Name + '</a></li>'; }		
					  
					htmlCode = htmlCode + '</ul>' ;
					i++;
				}
				else {
					// Skip Global links
					if (TFJList[i].Section__c == SHARED_PICKLISTVALUE) {
						i++;
						continue;						
					}
					else {
						break;
					}
				}
			}			
			htmlCode = htmlCode + '</div></div></td>';	
			System.debug('###### Complete column for ' + sectionList[j] + ' section ######');	
		}
		htmlCode = htmlCode + '</tr>';
				
		return htmlCode;
	}
}