<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                version="1.0">

<xsl:template match="/zarafa-admin">
<xsl:choose>
<xsl:when test="count(users) &gt; 0">

  <table id="zarafa-users">
  <tr><th class="center">Username</th></tr>
  <xsl:for-each select="users/user"><xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
  <tr><td class="hover"><a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a></td></tr>
  </xsl:for-each>
  <xsl:if test="count(users/user) = 0">
  <tr><td class="hover">No users found!</td></tr>
  </xsl:if>
  </table>

</xsl:when>
<xsl:otherwise>

  <table id="zarafa-user">
  <tr><th colspan="4" class="center">User Detail for <xsl:value-of select="user/@username"/></th></tr>
  <tr><th colspan="2" class="center">Zarafa Details</th><th colspan="2" class="center">LDAP Details</th></tr>
  <tr class="hover"><th>Username</th><td><xsl:value-of select="user/@username"/></td><th>GivenName</th><td><xsl:value-of select="user/@pr_given_name"/></td></tr>
  <tr class="hover"><th>Email</th><td><xsl:value-of select="user/@emailaddress"/></td><th>Surname</th><td><xsl:value-of select="user/@pr_surname"/></td></tr>
  <tr class="hover"><th>Active</th><td><xsl:if test="user/@active = 'yes'">&#x2713;</xsl:if></td><th>Fullname</th><td><xsl:value-of select="user/@fullname"/></td></tr>
  <tr class="hover"><th>Administrator</th><td><xsl:if test="user/@administrator = 'yes'">&#x2713;</xsl:if></td><th>Title</th><td><xsl:value-of select="user/@pr_title"/></td></tr>
  <tr class="hover"><th>Visible</th><td><xsl:if test="user/@addressbook = 'Visible'">&#x2713;</xsl:if></td><th>Section</th><td><xsl:value-of select="user/@pr_department_name"/></td></tr>
  <tr class="hover"><th>Auto-accept</th><td><xsl:if test="user/@autoacceptmeetingreq = 'yes'">&#x2713;</xsl:if></td><th>Location</th><td><xsl:value-of select="user/@location"/></td></tr>
  <tr class="hover"><th>Logon</th><td><xsl:value-of select="user/@lastlogon"/></td><th>Telephone</th><td><xsl:value-of select="user/@pr_business_telephone_number"/></td></tr>
  <tr class="hover"><th>Logoff</th><td><xsl:value-of select="user/@lastlogoff"/></td><th>Mobile</th><td><xsl:value-of select="user/@pr_mobile_telephone_number"/></td></tr>
  <tr class="hover"><td colspan="2">&#xA0;</td><th>Fax</th><td><xsl:value-of select="user/@pr_business_fax_number"/></td></tr>
  </table>
  <table id="zarafa-user-quota">
  <tr><th colspan="4" class="center">Quota Information<xsl:if test="user/@quotaoverrides = 'yes'">&#xA0;(Override Defaults &#x2713;)</xsl:if></th></tr>
  <tr class="hover"><th>Warning Level</th><td><xsl:value-of select="user/@warninglevel"/></td><th>Soft Level</th><td><xsl:value-of select="user/@softlevel"/></td></tr>
  <tr class="hover"><th>Hard Level</th><td><xsl:value-of select="user/@hardlevel"/></td><th>Current Size</th><td><xsl:value-of select="user/@currentstoresize"/></td></tr>
  </table>
  <xsl:if test="count(user/groups/group) &gt; 0">
  <table id="zarafa-user-groups">
  <tr><th colspan="2">Groups</th><td colspan="2">
  <xsl:for-each select="user/groups/group"><xsl:sort select="translate(@groupname, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
  <a href="./zarafa-groups.php?group={@groupname}"><xsl:value-of select="@groupname"/></a><br/>
  </xsl:for-each>
  </td></tr>
  </table>
</xsl:if>

</xsl:otherwise>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>
