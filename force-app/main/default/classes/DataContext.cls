/**
 * Created by Bruno_Frosi on 1/8/2020.
 *
 * This virtual class is used to ensure a consistent implementation of context objects for Order Processing
 */

public virtual class DataContext {
    @testVisible
    protected virtual void save(){}
    
    @testVisible
    protected virtual void refresh(Set<Id> ids){}
    
    @testVisible
    protected virtual void refresh(Map<Id,Id> ids){}

    @testVisible
    protected virtual void refresh(){}
}