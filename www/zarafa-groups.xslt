<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/zarafa-admin">
<xsl:choose>
<xsl:when test="count(groups) &gt; 0">

  <table id="zarafa-groups">
  <tr><th>Group Name</th></tr>
  <xsl:for-each select="groups/group"><xsl:sort select="translate(@name, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
  <tr><td class="hover"><a href="./zarafa-groups.php?group={@name}"><xsl:value-of select="@name"/></a></td></tr>
  </xsl:for-each>
  <xsl:if test="count(groups/group) = 0">
  <tr><td class="hover">No groups found!</td></tr>
  </xsl:if>
  </table>

</xsl:when>
<xsl:otherwise>

  <table id="zarafa-group">
  <tr><th colspan="2" class="center">Group Detail for <xsl:value-of select="group/@fullname"/></th></tr>
  <tr class="hover"><th>Groupname</th><td><xsl:value-of select="group/@groupname"/></td></tr>
  <tr class="hover"><th>Fullname</th><td><xsl:value-of select="group/@fullname"/></td></tr>
  <tr class="hover"><th>Email</th><td><xsl:value-of select="group/@emailaddress"/></td></tr>
  <tr class="hover"><th>Visible</th><td><xsl:if test="group/@addressbook = 'Visible'">&#x2713;</xsl:if></td></tr>
  <tr class="hover"><th>Number of Users</th><td><xsl:value-of select="count(group/users/user)"/></td></tr>
  <tr><th>Users</th>
  <td><xsl:for-each select="group/users/user"><xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
  <a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a><br/>
  </xsl:for-each>
  </td></tr>
  </table>

</xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
