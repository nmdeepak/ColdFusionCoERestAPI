<cfcomponent extends="api.v1.Taskapi" rest="true" restpath="/tasks" produces="application/json">

    <!--- v2 Endpoint: Returns expanded task object --->
    <cffunction name="getTask" access="remote" returntype="struct" httpMethod="GET" restpath="{id:[0-9]+}" returnformat="json">
        <cfargument name="id" type="numeric" required="true" restargsource="Path">
        
        <!--- Call original v1 implementation using super --->
        <cfset var taskData = super.getTask(arguments.id)>
        
        <!--- Update payload for v2 --->
        <cfset taskData["isV2"] = true>
        
        <cfreturn taskData>
    </cffunction>

    

</cfcomponent>