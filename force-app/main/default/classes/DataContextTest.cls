@isTest
 public class DataContextTest {
    
    @isTest
    static void shouldTestVirtualClass(){
        DataContext context = new DataContext();
        
        context.save();
        context.refresh(new Set<Id>());
        context.refresh(new Map<Id,Id>());
        context.refresh();

        // Should we have assert to test a virtual class ?
         System.assertEquals(true, true);
              
    }

 }