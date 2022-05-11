({    
    recordUpdate: function(component, event, helper) {
        var leadtype = component.get("v.record").FBE_Lead_Type__c;
        var Rectype_Name = component.get("v.record").RecordType.Name;
        if(leadtype){  
        if(leadtype === 'Inbound' && Rectype_Name === 'Direct Lead'){
            component.set("v.outboundflag", false);
            component.set("v.inboundflag", true);
        }
        else if(leadtype === 'Outbound' && Rectype_Name === 'Direct Lead'){
            component.set("v.inboundflag", false);
            component.set("v.outboundflag", true);
        }
         else if(leadtype != 'Outbound' && leadtype != 'Inbound' && Rectype_Name === 'Direct Lead'){
            component.set("v.inboundflag", false);
            component.set("v.outboundflag", false);
        }
       
        }  
        
    }

})