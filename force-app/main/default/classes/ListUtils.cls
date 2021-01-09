/**
 * Utility methods for varios list functionality
 */

public class ListUtils {
	 
	 
	 public static Boolean containsSameElements(List<String> firstStrList, List<String> secondStrList) {
	 	if(firstStrList == null && secondStrList == null)return true;	 		 	
	 	Set<String> firsStrSet = new Set<String>();	 	
	 	
	 	//adds all elements to a set	 	
	 	firsStrSet.addAll(firstStrList);
	 	//return contains-all result
	 	return firsStrSet.containsAll(secondStrList);
    }

}