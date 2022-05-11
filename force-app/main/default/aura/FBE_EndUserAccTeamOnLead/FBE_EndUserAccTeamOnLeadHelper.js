({
	  
    navService2 : function(component, pageReference, replace){
        let _replace = replace || false;
        let navService  = component.find('navService');
        navService.navigate(pageReference, _replace);
        
    },
    
    delayedRefresh : function(milliseconds){
        let ms = milliseconds || 100;
        window.setTimeout($A.getCallback(function(){
            $A.get('e.force:refreshView').fire();
        }),ms);
    }
	
})