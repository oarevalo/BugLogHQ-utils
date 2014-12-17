<cfcomponent extends="bugLog.extensions.rules.firstMessageAlert" 
            displayName="PushBullet Alert"
            hint="Sends an alert via Pushbullet API on the first occurrence of an message with the given conditions">

    <cfproperty name="accessToken" type="string" displayName="Access Token" hint="PushBullet Access Token">
    <cfproperty name="timespan" type="numeric" displayName="Timespan" hint="The number in minutes for which to count the amount of bug reports received">
    <cfproperty name="application" type="string" buglogType="application" displayName="Application" hint="The application name that will trigger the rule. Leave empty to look for all applications">
    <cfproperty name="host" type="string" buglogType="host" displayName="Host Name" hint="The host name that will trigger the rule. Leave empty to look for all hosts">
    <cfproperty name="severity" type="string" buglogType="severity" displayName="Severity Code" hint="The severity that will trigger the rule. Leave empty to look for all severities">

    <cffunction name="init" access="public" returntype="bugLog.components.baseRule">
        <cfargument name="accessToken" type="string" required="true">
        <cfargument name="timespan" type="string" required="true">
        <cfargument name="application" type="string" required="false" default="">
        <cfargument name="host" type="string" required="false" default="">
        <cfargument name="severity" type="string" required="false" default="">
        <cfset variables.config.accessToken = arguments.accessToken>
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
        
        <cfset var q = arguments.data>
        <cfset var numHours = int(variables.config.timespan / 60)>
        <cfset var numMinutes = variables.config.timespan mod 60>
        <cfset var intro = "">

        <cfsavecontent variable="intro">
            <cfoutput>
                BugLog has received a new bug report 
                <cfif variables.config.application neq "">
                    for application <strong>#variables.config.application#</strong>
                </cfif>
                <cfif variables.config.host neq "">
                    on host <strong>#variables.config.host#</strong>
                </cfif>
                <cfif variables.config.severity neq "">
                    with a severity of <strong>#variables.config.severity#</strong>
                </cfif>
                on the last 
                <b>
                    <cfif numHours gt 0> #numHours# hour<cfif numHours gt 1>s</cfif> <cfif numMinutes gt 0> and </cfif></cfif>
                    <cfif numMinutes gt 0> #numMinutes# minute<cfif numMinutes gt 1>s</cfif></cfif>
                </b>
            </cfoutput>
        </cfsavecontent>

        <cfset var payload = {
            "type" = "link",
            "title" = "BugLog: [#q.ApplicationCode#][#q.hostName#] #q.message#",
            "body" = intro,
            "url" = getBugEntryHREF(q.EntryID)

        } />

        <cfhttp method="post" url="https://api.pushbullet.com/v2/pushes"
                username="#variables.config.accessToken#">
            <cfhttpparam type="header" name="Content-Type" value="application/json">
            <cfhttpparam type="body" value="#serializeJson(payload)#">
        </cfhttp>

        <cfset writeToCFLog("'PushBulletAlert' rule fired. Alert sent. Msg: '#q.message#'")>
    </cffunction>

    <cffunction name="explain" access="public" returntype="string">
        <cfset var rtn = "Sends an alert via PushBullet">
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
