<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />

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

<xsl:key name="session-data" match="/zarafaadmin/sessions/session" use="concat(@username,@ip,@version,@program,@pipe)" />
<xsl:template match="/zarafaadmin/sessions">
  <pre>
    <table id="zarafa-session">
      <tr><th>Username</th><th>IP</th><th>Version</th><th>Program</th><th>Pipe</th></tr>
      <xsl:for-each select="/zarafaadmin/sessions/session[generate-id() = generate-id(key('session-data', concat(@username, @ip, @version, @program, @pipe))[1])]">
        <xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />

        <xsl:if test="(boolean(@username) or boolean(@ip) or boolean(@version) or boolean(@program) or boolean(@pipe)) and @username != 'SYSTEM'">
          <tr class="hover">
            <td><a href="./zarafa-users.php?user={@username}"><xsl:value-of select="translate(@username,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/></a></td>
            <td><xsl:value-of select="@ip"/></td>
            <td><xsl:value-of select="@version"/></td>
            <td><xsl:value-of select="@program"/></td>
            <td><xsl:value-of select="@pipe"/></td>
          </tr>
        </xsl:if>

      </xsl:for-each>
    </table>
  </pre>
</xsl:template>

</xsl:stylesheet>
