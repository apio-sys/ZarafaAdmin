<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>

<xsl:template match="/zarafaadmin/error">
  <table align="center">
    <caption style="color:red">An Error occurred, Please contact your System Administrator</caption>
    <tr>
      <td align="right" style="color:red">Error Number:</td>
      <td align="left"><xsl:value-of select="@code"/></td>
    </tr>
    <tr>
      <td align="right" style="color:red">Error Message:</td>
      <td align="left"><xsl:value-of select="@msg"/></td>
    </tr>
    <tr>
      <td align="right" style="color:red">Original Command:</td>
      <td align="left"><xsl:value-of select="@cmd"/></td>
    </tr>
  </table>
</xsl:template>

<xsl:template match="/zarafaadmin/groups">
  <xsl:choose>
    <xsl:when test="count(group) = 1">
      <table id="zarafa-group">
      <tr><th colspan="2" class="center">Group Detail for <xsl:value-of select="group/@fullname"/></th></tr>
      <tr class="hover"><th>Groupname</th><td><xsl:value-of select="group/@groupname"/></td></tr>
      <tr class="hover"><th>Fullname</th><td><xsl:value-of select="group/@fullname"/></td></tr>
      <tr class="hover"><th>Email</th><td><xsl:value-of select="group/@emailaddress"/></td></tr>
      <tr class="hover"><th>Visible</th><td><xsl:if test="group/@addressbook = 'Visible'">&#x2713;</xsl:if></td></tr>
      <tr class="hover"><th>Number of Users</th><td><xsl:value-of select="count(group/user)"/></td></tr>
      <tr><th>Users</th>
      <td><xsl:for-each select="group/user"><xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
      <a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a><br/>
      </xsl:for-each>
      </td></tr>
      </table>
    </xsl:when>

    <xsl:otherwise>
      <table id="zarafa-groups">
      <tr><th>Group Name</th></tr>
      <xsl:for-each select="group"><xsl:sort select="translate(@groupname, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
      <tr><td class="hover"><a href="./zarafa-groups.php?group={@groupname}"><xsl:value-of select="@groupname"/></a></td></tr>
      </xsl:for-each>
      </table>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>
