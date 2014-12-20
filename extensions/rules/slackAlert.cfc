<cfcomponent extends="bugLog.extensions.rules.firstMessageAlert" 
            displayName="Slack Alert"
            hint="Sends an alert via Slack Webhooks on the first occurrence of an message with the given conditions">

    <cfproperty name="webhookURL" type="string" displayName="WebhookURL" hint="Webhook URL">
    <cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes for which to count the amount of bug reports received">
    <cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
    <cfproperty name="host" type="string" buglogType="host" displayName="Host Name" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
    <cfproperty name="severity" type="string" buglogType="severity" displayName="Severity Code" hint="The severity that will trigger the rule. Leave empty to look for all severities">

    <cffunction name="init" access="public" returntype="bugLog.components.baseRule">
        <cfargument name="webhookURL" type="string" required="true">
        <cfargument name="timespan" type="string" required="true">
        <cfargument name="application" type="string" required="false" default="">
        <cfargument name="host" type="string" required="false" default="">
        <cfargument name="severity" type="string" required="false" default="">
        <cfset variables.config.webhookURL = arguments.webhookURL>
        <cfset variables.config.timespan = val(arguments.timespan)>
        <cfset variables.config.application = arguments.application>
        <cfset variables.config.host = arguments.host>
        <cfset variables.config.severity = arguments.severity>
        <cfset variables.applicationID = variables.ID_NOT_SET>
        <cfset variables.hostID = variables.ID_NOT_SET>
        <cfset variables.severityID = variables.ID_NOT_SET>
        <cfset variables.lastEmailTimestamp = createDateTime(1800,1,1,0,0,0)>
        <cfreturn this>
    </cffunction>

    <cffunction name="sendEmail" access="private" returntype="void" output="true">
        <cfargument name="data" type="query" required="true" hint="query with the bug report entries">
        <cfargument name="rawEntry" type="bugLog.components.rawEntryBean" required="true">
            
        <cfscript>
            var q = arguments.data;
            var payload = {
                "username" = "BugLogHQ",
                "icon_url" = getBaseBugLogHREF() & "hq/images/bug.png",
                "text" = "*[#q.severityCode#] #q.message#*" & chr(10)
                        & "Application: `#q.ApplicationCode#`  Host: `#q.hostName#`" & chr(10)
                        & "<" & getBugEntryHREF(q.EntryID) & ">"
            };
        </cfscript>

        <cfhttp method="post" url="#variables.config.webhookURL#">
            <cfhttpparam type="header" name="Content-Type" value="application/json">
            <cfhttpparam type="body" value="#serializeJson(payload)#">
        </cfhttp>

        <cfset writeToCFLog("'SlackAlert' rule fired. Alert sent. Msg: '#q.message#'")>
    </cffunction>

    <cffunction name="explain" access="public" returntype="string">
        <cfset var rtn = "Sends an alert to Slack via Webhooks">
        <cfset rtn &= " on the first ocurrence">
        <cfif variables.config.timespan  neq "">
            <cfset rtn &= " in <b>#variables.config.timespan#</b> minutes">
        </cfif>
        <cfset rtn &= " of a bug report received">
        <cfif variables.config.application  neq "">
            <cfset rtn &= " from application <b>#variables.config.application#</b>">
        </cfif>
        <cfif variables.config.severity  neq "">
            <cfset rtn &= " with a severity of <b>#variables.config.severity#</b>">
        </cfif>
        <cfif variables.config.host  neq "">
            <cfset rtn &= " from host <b>#variables.config.host#</b>">
        </cfif>
        <cfreturn rtn>
    </cffunction>

</cfcomponent>
