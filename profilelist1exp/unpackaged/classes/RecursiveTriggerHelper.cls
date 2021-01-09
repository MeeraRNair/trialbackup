//TODO: This class will stop allowing trigger to fire-in twice 
 
public class RecursiveTriggerHelper {
 
  // initialize a variable to hold state  
  private static boolean alreadyModified = false;
  
  // get the state
    public static boolean isAlreadyModified() {
        return alreadyModified;
    }
 
    // set this to true to keep track of and avoid recursive updates.  Generally set after first time through
    // a trigger.  We can access this in the trigger and avoid recursive updates...
   
    public static void setAlreadyModified() {
        alreadyModified = true;
    }
}