<cfcomponent displayname="Tasks API Application" output="false">

    <cfset this.name = "TasksApiApplication">
    <cfset this.applicationTimeout = createTimeSpan(0, 12, 0, 0)>
    <cfset this.sessionManagement = false>
    
    <!--- Define your database datasource name --->
    <cfset this.datasource = "deepakcf">

    <!--- 
        REST Configuration (ColdFusion 2018+ / Lucee 5+)
        Maps standard REST paths automatically without needing manual web.xml settings
    --->
    <cfset this.restSettings.skipCFCWithError = false>
    <cfset this.restSettings.cfcBasePackage = "api.v1">

    <cffunction name="onApplicationStart" returntype="boolean">
        <cftry>
        <cfset local.apiPath = expandPath("./api/v1")>
        
        <!--- 1. Unregister existing application if previously cached --->
        <cfset restDeleteApplication(local.apiPath)>
        
        <!--- 2. Register fresh REST application mapping --->
        <cfset restInitApplication(local.apiPath, "api")>
        
        <cfcatch type="any">
            <cflog file="rest_errors" text="REST Init Warning: #cfcatch.message#">
        </cfcatch>
    </cftry>
    <cfreturn true>
    </cffunction>

    <cffunction name="onRequestStart" returntype="boolean">
        <cfargument name="targetPage" type="string" required="true">

        <!--- Quick reload mechanism during development: http://localhost/index.cfm?reinit=1 --->
        <cfif structKeyExists(url, "reinit")>
            <cfset onApplicationStart()>
            <cfoutput>REST application reloaded successfully.</cfoutput>
            <cfabort>
        </cfif>

        <cfreturn true>
    </cffunction>

</cfcomponent>