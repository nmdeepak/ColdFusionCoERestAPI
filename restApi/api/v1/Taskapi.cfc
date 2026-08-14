<cfcomponent rest="true" restpath="/tasks" produces="application/json">

    <!--- Valid API Key for simple header authentication --->
    <cfset variables.VALID_API_KEY = "secret-api-key-12345">

    <!--- 
        ================================================================
        HTTP ENDPOINTS
        ================================================================
    --->

    <!--- GET /api/tasks --->
    <cffunction name="list" access="remote" returntype="struct" httpMethod="GET" restpath="" returnformat="json">
        <cfargument name="page" type="numeric" required="false" default="1" restargsource="Query">
        <cfargument name="perPage" type="numeric" required="false" default="20" restargsource="Query">

        <cftry>
            <cfset authenticateRequest()>
            <cfset enforceRateLimit()>
            <cfreturn listTasks(arguments.page, arguments.perPage)>

            <cfcatch type="AuthException">
                <cfreturn errorResponse(401, "UNAUTHORIZED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="RateLimitException">
                <cfreturn errorResponse(429, "RATE_LIMIT_EXCEEDED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="any">
                <cfreturn errorResponse(500, "INTERNAL_ERROR", "An unexpected error occurred: " & cfcatch.message)>
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- GET /api/tasks/{id} --->
    <cffunction name="getOne" access="remote" returntype="struct" httpMethod="GET" restpath="{id}" returnformat="json">
        <cfargument name="id" type="numeric" required="true" restargsource="Path">

        <cftry>
            <cfset authenticateRequest()>
            <cfset enforceRateLimit()>
            <cfreturn getTask(arguments.id)>

            <cfcatch type="AuthException">
                <cfreturn errorResponse(401, "UNAUTHORIZED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="RateLimitException">
                <cfreturn errorResponse(429, "RATE_LIMIT_EXCEEDED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="NotFoundException">
                <cfreturn errorResponse(404, "NOT_FOUND", cfcatch.message)>
            </cfcatch>
            <cfcatch type="any">
                <cfreturn errorResponse(500, "INTERNAL_ERROR", "An unexpected error occurred: " & cfcatch.message)>
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- POST /api/tasks --->
    <cffunction name="create" access="remote" returntype="struct" httpMethod="POST" restpath="" returnformat="json">
        <cfargument name="data" type="struct" required="true">

        <cftry>
            <cfset authenticateRequest()>
            <cfset enforceRateLimit()>
            <cfset validateTask(arguments.data, false)>
            <cfreturn createTask(arguments.data)>

            <cfcatch type="AuthException">
                <cfreturn errorResponse(401, "UNAUTHORIZED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="RateLimitException">
                <cfreturn errorResponse(429, "RATE_LIMIT_EXCEEDED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="ValidationException">
                <cfreturn errorResponse(400, "VALIDATION_ERROR", cfcatch.message)>
            </cfcatch>
            <cfcatch type="any">
                <cfreturn errorResponse(500, "INTERNAL_ERROR", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- PUT /api/tasks/{id} --->
    <cffunction name="update" access="remote" returntype="struct" httpMethod="PUT" restpath="{id}" returnformat="json">
        <cfargument name="id" type="numeric" required="true" restargsource="Path">
        <cfargument name="data" type="struct" required="true">

        <cftry>
            <cfset authenticateRequest()>
            <cfset enforceRateLimit()>
            <cfset validateTask(arguments.data, true)>
            <cfreturn updateTask(arguments.id, arguments.data)>

            <cfcatch type="AuthException">
                <cfreturn errorResponse(401, "UNAUTHORIZED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="RateLimitException">
                <cfreturn errorResponse(429, "RATE_LIMIT_EXCEEDED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="ValidationException">
                <cfreturn errorResponse(400, "VALIDATION_ERROR", cfcatch.message)>
            </cfcatch>
            <cfcatch type="NotFoundException">
                <cfreturn errorResponse(404, "NOT_FOUND", cfcatch.message)>
            </cfcatch>
            <cfcatch type="any">
                <cfreturn errorResponse(500, "INTERNAL_ERROR", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- DELETE /api/tasks/{id} --->
    <cffunction name="deleteOne" access="remote" returntype="struct" httpMethod="DELETE" restpath="{id}" returnformat="json">
        <cfargument name="id" type="numeric" required="true" restargsource="Path">

        <cftry>
            <cfset authenticateRequest()>
            <cfset enforceRateLimit()>
            <cfreturn deleteTask(arguments.id)>

            <cfcatch type="AuthException">
                <cfreturn errorResponse(401, "UNAUTHORIZED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="RateLimitException">
                <cfreturn errorResponse(429, "RATE_LIMIT_EXCEEDED", cfcatch.message)>
            </cfcatch>
            <cfcatch type="NotFoundException">
                <cfreturn errorResponse(404, "NOT_FOUND", cfcatch.message)>
            </cfcatch>
            <cfcatch type="any">
                <cfreturn errorResponse(500, "INTERNAL_ERROR", cfcatch.message)>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="testPing" access="remote" returntype="struct" httpMethod="GET" restpath="ping" returnformat="json">
       <cftry>
         <cfset authenticateRequest()>
        <cfreturn { "status": "success", "message": "PUT is working!" }>
        <cfcatch type="any">
            <cfreturn errorResponse(500, "INTERNAL_ERROR", cfcatch.message)>
        </cfcatch>
       </cftry>
    </cffunction>

    <!--- 
        ================================================================
        BUSINESS LOGIC & DATA ACCESS
        ================================================================
    --->

    <cffunction name="listTasks" access="private" returntype="struct" >
        <cfargument name="page" type="numeric" required="false" default="1">
        <cfargument name="perPage" type="numeric" required="false" default="20">

        <cfset var maxRows = min(arguments.perPage, 100)>
        <cfset var offset = (max(arguments.page, 1) - 1) * maxRows>
        <cfset var qCount = "">
        <cfset var qData = "">
        <cfset var dataArray = []>

        <cfquery name="qCount" datasource="deepakcf">
            SELECT COUNT(*) AS total FROM tasks
        </cfquery>

        <cfquery name="qData" datasource="deepakcf">
            SELECT id, title, status, created_at 
            FROM tasks 
            ORDER BY id ASC 
            LIMIT <cfqueryparam value="#maxRows#" cfsqltype="cf_sql_integer">
            OFFSET <cfqueryparam value="#offset#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfloop query="qData">
            <cfset arrayAppend(dataArray, {
                "id": qData.id,
                "title": qData.title,
                "status": qData.status,
                "createdAt": dateTimeFormat(qData.created_at, "yyyy-mm-dd'T'HH:nn:ss'Z'")
            })>
        </cfloop>

        
        <cfreturn {
            "data": dataArray,
            "meta": {
                "total": qCount.total,
                "page": arguments.page,
                "perPage": maxRows
            }
        }>
        
    </cffunction>

    <cffunction name="getTask" access="private" returntype="struct">
        <cfargument name="id" type="numeric" required="true">
        <cfset var qData = "">
        <cfset var dataArray = []>

        <cfquery name="qData" datasource="deepakcf">
            SELECT id, title, status, created_at 
            FROM tasks 
            WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif not qData.recordCount>
            <cfthrow type="NotFoundException" message="Task with ID #arguments.id# not found.">
        </cfif>

         <cfloop query="qData">
            <cfset arrayAppend(dataArray, {
                "id": qData.id,
                "title": qData.title,
                "status": qData.status,
                "createdAt": dateTimeFormat(qData.created_at, "yyyy-mm-dd'T'HH:nn:ss'Z'")
            })>
        </cfloop>

        
       <cfreturn {
            "data": dataArray,
            "meta": {
                "total": qData.recordCount,
                "page": 1,
                "perPage": 100
            }
        }> 
    </cffunction>

    <cffunction name="createTask" access="private" returntype="struct">
        <cfargument name="data" type="struct" required="true">

        <cfset var statusVal = structKeyExists(arguments.data, "status") ? arguments.data.status : "pending">
        <cfset var insertResult = "">

        <cfquery result="insertResult" datasource="deepakcf">
            INSERT INTO tasks (title, status, created_at) 
            VALUES (
                <cfqueryparam value="#arguments.data.title#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#statusVal#" cfsqltype="cf_sql_varchar">,
                NOW()
            )
        </cfquery>

        <cfreturn getTask(insertResult.generatedKey)>
    </cffunction>

    <cffunction name="updateTask" access="private" returntype="struct">
        <cfargument name="id" type="numeric" required="true">
        <cfargument name="data" type="struct" required="true">

        <cfset var updateResult = "">

        <cfquery result="updateResult" datasource="deepakcf">
            UPDATE tasks 
            SET title = COALESCE(
                    <cfqueryparam value="#structKeyExists(arguments.data, 'title') ? arguments.data.title : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(arguments.data, 'title')#">,
                    title
                ),
                status = COALESCE(
                    <cfqueryparam value="#structKeyExists(arguments.data, 'status') ? arguments.data.status : ''#" cfsqltype="cf_sql_varchar" null="#not structKeyExists(arguments.data, 'status')#">,
                    status
                )
            WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif updateResult.recordCount eq 0>
            <cfthrow type="NotFoundException" message="Task with ID #arguments.id# not found.">
        </cfif>

        <cfreturn getTask(arguments.id)>
    </cffunction>

    <cffunction name="deleteTask" access="private" returntype="struct">
        <cfargument name="id" type="numeric" required="true">

        <cfset var deleteResult = "">

        <cfquery result="deleteResult" datasource="deepakcf">
            DELETE FROM tasks 
            WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif deleteResult.recordCount eq 0>
            <cfthrow type="NotFoundException" message="Task with ID #arguments.id# not found.">
        </cfif>

        <cfreturn { "message": "Task successfully deleted", "id": arguments.id }>
    </cffunction>

    <!--- 
        ================================================================
        SECURITY & VALIDATION HELPERS
        ================================================================
    --->

    <cffunction name="authenticateRequest" access="private" returntype="void">
        <cfset var httpRequest = getHttpRequestData()>
        <cfset var apiKey = structKeyExists(httpRequest.headers, "X-API-Key") ? httpRequest.headers["X-API-Key"] : "">

        <cfif apiKey neq variables.VALID_API_KEY>
            <cfthrow type="AuthException" message="Missing or invalid API key provided in X-API-Key header.">
        </cfif>
    </cffunction>

    <cffunction name="enforceRateLimit" access="private" returntype="void">
        <cftry>
            <cfset var clientIp = CGI.REMOTE_ADDR>
            <cfset var cacheKey = "rate_limit_" & clientIp>
            <cfset var requestCount = 0>
    
            <cflock scope="Application" timeout="5" type="exclusive">
                <cfset requestCount = cacheGet(cacheKey)>
                
                <cfif isNull(requestCount)>
                    <cfset requestCount = 0>
                </cfif>
    
                <cfif requestCount ge 1>
                    <cfthrow type="RateLimitException" message="Rate limit exceeded. Maximum 100 requests per minute allowed.">
                </cfif>
    
                <cfset cachePut(cacheKey, requestCount + 1, createTimeSpan(0, 0, 1, 0))>
            </cflock>
            <cfcatch type="any">
                <cfdump var="#cfcatch#" >
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="validateTask" access="private" returntype="void">
        <cfargument name="data" type="struct" required="true">
        <cfargument name="isUpdate" type="boolean" required="false" default="false">

        <cfset var validStatuses = ["pending", "in_progress", "completed"]>

        <cfif not arguments.isUpdate or structKeyExists(arguments.data, "title")>
            <cfif not structKeyExists(arguments.data, "title") or not len(trim(arguments.data.title))>
                <cfthrow type="ValidationException" message="Field 'title' is required and cannot be empty.">
            </cfif>
            <cfif len(arguments.data.title) gt 255>
                <cfthrow type="ValidationException" message="Field 'title' must not exceed 255 characters.">
            </cfif>
        </cfif>

        <cfif structKeyExists(arguments.data, "status")>
            <cfif not arrayFindNoCase(validStatuses, arguments.data.status)>
                <cfthrow type="ValidationException" message="Invalid 'status'. Allowed values are: #arrayToList(validStatuses, ', ')#">
            </cfif>
        </cfif>
    </cffunction>

    <cffunction name="errorResponse" access="private" returntype="struct">
        <cfargument name="status" type="numeric" required="true">
        <cfargument name="code" type="string" required="true">
        <cfargument name="message" type="string" required="true">

        <cfset setHTTPStatus(arguments.status)>
        <cfreturn {
            "status": arguments.status,
            "error": {
                "code": arguments.code,
                "message": arguments.message
            }
        }>
    </cffunction>

    <cffunction name="setHTTPStatus" access="private" returntype="void">
        <cfargument name="statusCode" type="numeric" required="true">
        <cfargument name="statusText" type="string" required="false" default="">

        <cfset var responseStruct = {
            "status": arguments.statusCode,
            "message": arguments.statusText
        }>
        
        <cfset restSetResponse(responseStruct)>
    </cffunction>

</cfcomponent>