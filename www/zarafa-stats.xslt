<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:param name="sort" select="'username'"/>

<xsl:template match="/zarafa-stats/users">

<table id="zarafa-stats-user">
<tr>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=username">Username</a></th>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=fullname">Full Name</a></th>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=emailaddress">Email Address</a></th>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=quotawarn">Warning</a></th>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=quotasoft">Soft</a></th>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=quotahard">Hard</a></th>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=size">Size (MB)</a></th>
    <th><a href="./zarafa-stats.php?cmd=users&amp;sort=logon">Last Logon</a></th>
</tr>


<xsl:choose>
<xsl:when test="$sort = 'fullname'">
    <xsl:apply-templates select="user"><xsl:sort select="translate(fullname, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'emailaddress'">
    <xsl:apply-templates select="user"><xsl:sort select="translate(emailaddress, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'quotawarn'">
    <xsl:apply-templates select="user"><xsl:sort select="quotawarn" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'quotasoft'">
    <xsl:apply-templates select="user"><xsl:sort select="quotasoft" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'quotahard'">
    <xsl:apply-templates select="user"><xsl:sort select="quotahard" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'size'">
    <xsl:apply-templates select="user"><xsl:sort select="size" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'logon'">
    <xsl:apply-templates select="user"><xsl:sort select="logon/@lag" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates select="user"><xsl:sort select="translate(username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
</xsl:otherwise>
</xsl:choose>
</table>
</xsl:template>



<xsl:template match="user">
<xsl:if test="boolean(username) and not(username='SYSTEM')">
<tr class="hover">
<td><a href="./zarafa-users.php?user={username}"><xsl:value-of select="username"/></a></td>
<td><xsl:value-of select="fullname"/></td>
<td><xsl:value-of select="emailaddress"/></td>
<td class="quota"><xsl:value-of select="format-number(quotawarn div 1024,'###,###,##0')"/></td>
<td class="quota"><xsl:value-of select="format-number(quotasoft div 1024,'###,###,##0')"/></td>
<td class="quota"><xsl:value-of select="format-number(quotahard div 1024,'###,###,##0')"/></td>

<td>
<xsl:choose>
<xsl:when test="number(size div 1024) &gt;= number(quotahard)">
<xsl:attribute name="class">hard</xsl:attribute>
</xsl:when>
<xsl:when test="number(size div 1024) &gt;= number(quotasoft)">
<xsl:attribute name="class">soft</xsl:attribute>
</xsl:when>
<xsl:when test="number(size div 1024) &gt;= number(quotawarn)">
<xsl:attribute name="class">warn</xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="class">size</xsl:attribute>
</xsl:otherwise>
</xsl:choose>
<xsl:value-of select="format-number(size div 1048576,'###,###,##0.00')"/></td>

<td>
<xsl:choose>
<xsl:when test="logon/@lag &gt;= 30">
<xsl:attribute name="class">datelong</xsl:attribute>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="class">date</xsl:attribute>
</xsl:otherwise>
</xsl:choose>
<xsl:value-of select="logon"/></td>
</tr>
</xsl:if>
</xsl:template>


<xsl:key name="session-data" match="/zarafa-stats/sessions/session" use="concat(username,ip,version,program,pipe)" />
<xsl:template match="/zarafa-stats/sessions">
<table id="zarafa-stats-session">
<tr><th>Username</th><th>IP</th><th>Version</th><th>Program</th><th>Pipe</th></tr>
<xsl:for-each select="/zarafa-stats/sessions/session[generate-id()
            = generate-id(key('session-data',concat(username,ip,version,program,pipe))[1])]">
    <xsl:sort select="translate(username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />

    <xsl:if test="(boolean(username) or boolean(ip) or boolean(version) or boolean(program) or boolean(pipe)) and username != 'SYSTEM'">
        <tr class="hover">

        <td><a href="./zarafa-users.php?user={username}"><xsl:value-of select="translate(username,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/></a></td>
        <td><xsl:value-of select="ip"/></td>
        <td><xsl:value-of select="version"/></td>
        <td><xsl:value-of select="program"/></td>
        <td><xsl:value-of select="pipe"/></td>
        </tr>
    </xsl:if>

</xsl:for-each>
</table>
</xsl:template>

<xsl:template match="/zarafa-stats/system">
<table id="zarafa-stats-system">
<tr class="hover"><td><xsl:value-of select="server_start_date/@description"/></td><td><xsl:value-of select="server_start_date"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_purge_date/@description"/></td><td><xsl:value-of select="cache_purge_date"/></td></tr>
<tr class="hover"><td><xsl:value-of select="config_reload_date/@description"/></td><td><xsl:value-of select="config_reload_date"/></td></tr>
<tr class="hover"><td><xsl:value-of select="connections/@description"/></td><td><xsl:value-of select="connections"/></td></tr>
<tr class="hover"><td><xsl:value-of select="max_socket/@description"/></td><td><xsl:value-of select="max_socket"/></td></tr>
<tr class="hover"><td><xsl:value-of select="redirections/@description"/></td><td><xsl:value-of select="redirections"/></td></tr>
<tr class="hover"><td><xsl:value-of select="soap_request/@description"/></td><td><xsl:value-of select="soap_request"/></td></tr>
<tr class="hover"><td><xsl:value-of select="response_time/@description"/></td><td><xsl:value-of select="response_time"/></td></tr>
<tr class="hover"><td><xsl:value-of select="processing_time/@description"/></td><td><xsl:value-of select="processing_time"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchfld_loaded/@description"/></td><td><xsl:value-of select="searchfld_loaded"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchfld_threads/@description"/></td><td><xsl:value-of select="searchfld_threads"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchupd_retry/@description"/></td><td><xsl:value-of select="searchupd_retry"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchupd_fail/@description"/></td><td><xsl:value-of select="searchupd_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_connect/@description"/></td><td><xsl:value-of select="sql_connect"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_select/@description"/></td><td><xsl:value-of select="sql_select"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_insert/@description"/></td><td><xsl:value-of select="sql_insert"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_update/@description"/></td><td><xsl:value-of select="sql_update"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_delete/@description"/></td><td><xsl:value-of select="sql_delete"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_connect_fail/@description"/></td><td><xsl:value-of select="sql_connect_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_select_fail/@description"/></td><td><xsl:value-of select="sql_select_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_insert_fail/@description"/></td><td><xsl:value-of select="sql_insert_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_update_fail/@description"/></td><td><xsl:value-of select="sql_update_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_delete_fail/@description"/></td><td><xsl:value-of select="sql_delete_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sql_last_fail_time/@description"/></td><td><xsl:value-of select="sql_last_fail_time"/></td></tr>
<tr class="hover"><td><xsl:value-of select="mwops/@description"/></td><td><xsl:value-of select="mwops"/></td></tr>
<tr class="hover"><td><xsl:value-of select="mrops/@description"/></td><td><xsl:value-of select="mrops"/></td></tr>
<tr class="hover"><td><xsl:value-of select="deferred_fetches/@description"/></td><td><xsl:value-of select="deferred_fetches"/></td></tr>
<tr class="hover"><td><xsl:value-of select="deferred_merges/@description"/></td><td><xsl:value-of select="deferred_merges"/></td></tr>
<tr class="hover"><td><xsl:value-of select="deferred_records/@description"/></td><td><xsl:value-of select="deferred_records"/></td></tr>
<tr class="hover"><td><xsl:value-of select="row_reads/@description"/></td><td><xsl:value-of select="row_reads"/></td></tr>
<tr class="hover"><td><xsl:value-of select="counter_resyncs/@description"/></td><td><xsl:value-of select="counter_resyncs"/></td></tr>
<tr class="hover"><td><xsl:value-of select="login_password/@description"/></td><td><xsl:value-of select="login_password"/></td></tr>
<tr class="hover"><td><xsl:value-of select="login_ssl/@description"/></td><td><xsl:value-of select="login_ssl"/></td></tr>
<tr class="hover"><td><xsl:value-of select="login_sso/@description"/></td><td><xsl:value-of select="login_sso"/></td></tr>
<tr class="hover"><td><xsl:value-of select="login_unix/@description"/></td><td><xsl:value-of select="login_unix"/></td></tr>
<tr class="hover"><td><xsl:value-of select="login_failed/@description"/></td><td><xsl:value-of select="login_failed"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sessions_created/@description"/></td><td><xsl:value-of select="sessions_created"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sessions_deleted/@description"/></td><td><xsl:value-of select="sessions_deleted"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sessions_timeout/@description"/></td><td><xsl:value-of select="sessions_timeout"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sess_int_created/@description"/></td><td><xsl:value-of select="sess_int_created"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sess_int_deleted/@description"/></td><td><xsl:value-of select="sess_int_deleted"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sess_grp_created/@description"/></td><td><xsl:value-of select="sess_grp_created"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sess_grp_deleted/@description"/></td><td><xsl:value-of select="sess_grp_deleted"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_connect/@description"/></td><td><xsl:value-of select="ldap_connect"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_reconnect/@description"/></td><td><xsl:value-of select="ldap_reconnect"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_connect_fail/@description"/></td><td><xsl:value-of select="ldap_connect_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_connect_time/@description"/></td><td><xsl:value-of select="ldap_connect_time"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_max_connect/@description"/></td><td><xsl:value-of select="ldap_max_connect"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_auth/@description"/></td><td><xsl:value-of select="ldap_auth"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_auth_fail/@description"/></td><td><xsl:value-of select="ldap_auth_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_auth_time/@description"/></td><td><xsl:value-of select="ldap_auth_time"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_max_auth/@description"/></td><td><xsl:value-of select="ldap_max_auth"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_avg_auth/@description"/></td><td><xsl:value-of select="ldap_avg_auth"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_search/@description"/></td><td><xsl:value-of select="ldap_search"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_search_fail/@description"/></td><td><xsl:value-of select="ldap_search_fail"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_search_time/@description"/></td><td><xsl:value-of select="ldap_search_time"/></td></tr>
<tr class="hover"><td><xsl:value-of select="ldap_max_search/@description"/></td><td><xsl:value-of select="ldap_max_search"/></td></tr>
<tr class="hover"><td><xsl:value-of select="index_search_errors/@description"/></td><td><xsl:value-of select="index_search_errors"/></td></tr>
<tr class="hover"><td><xsl:value-of select="index_search_max/@description"/></td><td><xsl:value-of select="index_search_max"/></td></tr>
<tr class="hover"><td><xsl:value-of select="index_search_avg/@description"/></td><td><xsl:value-of select="index_search_avg"/></td></tr>
<tr class="hover"><td><xsl:value-of select="search_indexed/@description"/></td><td><xsl:value-of select="search_indexed"/></td></tr>
<tr class="hover"><td><xsl:value-of select="search_database/@description"/></td><td><xsl:value-of select="search_database"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_obj_items/@description"/></td><td><xsl:value-of select="cache_obj_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_obj_size/@description"/></td><td><xsl:value-of select="cache_obj_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_obj_maxsz/@description"/></td><td><xsl:value-of select="cache_obj_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_obj_req/@description"/></td><td><xsl:value-of select="cache_obj_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_obj_hit/@description"/></td><td><xsl:value-of select="cache_obj_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_store_items/@description"/></td><td><xsl:value-of select="cache_store_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_store_size/@description"/></td><td><xsl:value-of select="cache_store_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_store_maxsz/@description"/></td><td><xsl:value-of select="cache_store_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_store_req/@description"/></td><td><xsl:value-of select="cache_store_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_store_hit/@description"/></td><td><xsl:value-of select="cache_store_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_acl_items/@description"/></td><td><xsl:value-of select="cache_acl_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_acl_size/@description"/></td><td><xsl:value-of select="cache_acl_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_acl_maxsz/@description"/></td><td><xsl:value-of select="cache_acl_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_acl_req/@description"/></td><td><xsl:value-of select="cache_acl_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_acl_hit/@description"/></td><td><xsl:value-of select="cache_acl_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_quota_items/@description"/></td><td><xsl:value-of select="cache_quota_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_quota_size/@description"/></td><td><xsl:value-of select="cache_quota_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_quota_maxsz/@description"/></td><td><xsl:value-of select="cache_quota_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_quota_req/@description"/></td><td><xsl:value-of select="cache_quota_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_quota_hit/@description"/></td><td><xsl:value-of select="cache_quota_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_uquota_items/@description"/></td><td><xsl:value-of select="cache_uquota_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_uquota_size/@description"/></td><td><xsl:value-of select="cache_uquota_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_uquota_maxsz/@description"/></td><td><xsl:value-of select="cache_uquota_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_uquota_req/@description"/></td><td><xsl:value-of select="cache_uquota_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_uquota_hit/@description"/></td><td><xsl:value-of select="cache_uquota_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_extern_items/@description"/></td><td><xsl:value-of select="cache_extern_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_extern_size/@description"/></td><td><xsl:value-of select="cache_extern_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_extern_maxsz/@description"/></td><td><xsl:value-of select="cache_extern_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_extern_req/@description"/></td><td><xsl:value-of select="cache_extern_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_extern_hit/@description"/></td><td><xsl:value-of select="cache_extern_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_userid_items/@description"/></td><td><xsl:value-of select="cache_userid_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_userid_size/@description"/></td><td><xsl:value-of select="cache_userid_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_userid_maxsz/@description"/></td><td><xsl:value-of select="cache_userid_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_userid_req/@description"/></td><td><xsl:value-of select="cache_userid_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_userid_hit/@description"/></td><td><xsl:value-of select="cache_userid_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_abinfo_items/@description"/></td><td><xsl:value-of select="cache_abinfo_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_abinfo_size/@description"/></td><td><xsl:value-of select="cache_abinfo_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_abinfo_maxsz/@description"/></td><td><xsl:value-of select="cache_abinfo_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_abinfo_req/@description"/></td><td><xsl:value-of select="cache_abinfo_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_abinfo_hit/@description"/></td><td><xsl:value-of select="cache_abinfo_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_server_items/@description"/></td><td><xsl:value-of select="cache_server_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_server_size/@description"/></td><td><xsl:value-of select="cache_server_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_server_maxsz/@description"/></td><td><xsl:value-of select="cache_server_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_server_req/@description"/></td><td><xsl:value-of select="cache_server_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_server_hit/@description"/></td><td><xsl:value-of select="cache_server_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_cell_items/@description"/></td><td><xsl:value-of select="cache_cell_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_cell_size/@description"/></td><td><xsl:value-of select="cache_cell_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_cell_maxsz/@description"/></td><td><xsl:value-of select="cache_cell_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_cell_req/@description"/></td><td><xsl:value-of select="cache_cell_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_cell_hit/@description"/></td><td><xsl:value-of select="cache_cell_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index1_items/@description"/></td><td><xsl:value-of select="cache_index1_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index1_size/@description"/></td><td><xsl:value-of select="cache_index1_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index1_maxsz/@description"/></td><td><xsl:value-of select="cache_index1_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index1_req/@description"/></td><td><xsl:value-of select="cache_index1_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index1_hit/@description"/></td><td><xsl:value-of select="cache_index1_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index2_items/@description"/></td><td><xsl:value-of select="cache_index2_items"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index2_size/@description"/></td><td><xsl:value-of select="cache_index2_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index2_maxsz/@description"/></td><td><xsl:value-of select="cache_index2_maxsz"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index2_req/@description"/></td><td><xsl:value-of select="cache_index2_req"/></td></tr>
<tr class="hover"><td><xsl:value-of select="cache_index2_hit/@description"/></td><td><xsl:value-of select="cache_index2_hit"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sessions/@description"/></td><td><xsl:value-of select="sessions"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sessions_size/@description"/></td><td><xsl:value-of select="sessions_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sessiongroups/@description"/></td><td><xsl:value-of select="sessiongroups"/></td></tr>
<tr class="hover"><td><xsl:value-of select="sessiongroups_size/@description"/></td><td><xsl:value-of select="sessiongroups_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="persist_conn/@description"/></td><td><xsl:value-of select="persist_conn"/></td></tr>
<tr class="hover"><td><xsl:value-of select="persist_conn_size/@description"/></td><td><xsl:value-of select="persist_conn_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="persist_sess/@description"/></td><td><xsl:value-of select="persist_sess"/></td></tr>
<tr class="hover"><td><xsl:value-of select="persist_sess_size/@description"/></td><td><xsl:value-of select="persist_sess_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tables_subscr/@description"/></td><td><xsl:value-of select="tables_subscr"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tables_subscr_size/@description"/></td><td><xsl:value-of select="tables_subscr_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="object_subscr/@description"/></td><td><xsl:value-of select="object_subscr"/></td></tr>
<tr class="hover"><td><xsl:value-of select="object_subscr_size/@description"/></td><td><xsl:value-of select="object_subscr_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchfld_stores/@description"/></td><td><xsl:value-of select="searchfld_stores"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchfld_folders/@description"/></td><td><xsl:value-of select="searchfld_folders"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchfld_events/@description"/></td><td><xsl:value-of select="searchfld_events"/></td></tr>
<tr class="hover"><td><xsl:value-of select="searchfld_size/@description"/></td><td><xsl:value-of select="searchfld_size"/></td></tr>
<tr class="hover"><td><xsl:value-of select="queuelen/@description"/></td><td><xsl:value-of select="queuelen"/></td></tr>
<tr class="hover"><td><xsl:value-of select="queueage/@description"/></td><td><xsl:value-of select="queueage"/></td></tr>
<tr class="hover"><td><xsl:value-of select="threads/@description"/></td><td><xsl:value-of select="threads"/></td></tr>
<tr class="hover"><td><xsl:value-of select="threads_idle/@description"/></td><td><xsl:value-of select="threads_idle"/></td></tr>
<tr class="hover"><td><xsl:value-of select="usercnt_licensed/@description"/></td><td><xsl:value-of select="usercnt_licensed"/></td></tr>
<tr class="hover"><td><xsl:value-of select="usercnt_active/@description"/></td><td><xsl:value-of select="usercnt_active"/></td></tr>
<tr class="hover"><td><xsl:value-of select="usercnt_nonactive/@description"/></td><td><xsl:value-of select="usercnt_nonactive"/></td></tr>
<tr class="hover"><td><xsl:value-of select="usercnt_na_user/@description"/></td><td><xsl:value-of select="usercnt_na_user"/></td></tr>
<tr class="hover"><td><xsl:value-of select="usercnt_room/@description"/></td><td><xsl:value-of select="usercnt_room"/></td></tr>
<tr class="hover"><td><xsl:value-of select="usercnt_equipment/@description"/></td><td><xsl:value-of select="usercnt_equipment"/></td></tr>
<tr class="hover"><td><xsl:value-of select="usercnt_contact/@description"/></td><td><xsl:value-of select="usercnt_contact"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tc_allocated/@description"/></td><td><xsl:value-of select="tc_allocated"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tc_reserved/@description"/></td><td><xsl:value-of select="tc_reserved"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tc_page_map_free/@description"/></td><td><xsl:value-of select="tc_page_map_free"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tc_page_unmap_free/@description"/></td><td><xsl:value-of select="tc_page_unmap_free"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tc_threadcache_max/@description"/></td><td><xsl:value-of select="tc_threadcache_max"/></td></tr>
<tr class="hover"><td><xsl:value-of select="tc_threadcache_cur/@description"/></td><td><xsl:value-of select="tc_threadcache_cur"/></td></tr>
</table>
</xsl:template>

</xsl:stylesheet>