<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:param name="sort" select="'username'"/>

<xsl:template match="/zarafaadmin/users">
  <xsl:choose>
    <xsl:when test="count(user) = 1">
      <table id="zarafa-user">
      <tr><th colspan="4" class="center">User Detail for <xsl:value-of select="user/@username"/></th></tr>
      <tr><th colspan="2" class="center">Zarafa Details</th><th colspan="2" class="center">LDAP Details</th></tr>
      <tr class="hover"><th>Username</th><td><xsl:value-of select="user/@username"/></td><th>GivenName</th><td><xsl:value-of select="user/@pr_given_name"/></td></tr>
      <tr class="hover"><th>Email</th><td><xsl:value-of select="user/@emailaddress"/></td><th>Surname</th><td><xsl:value-of select="user/@pr_surname"/></td></tr>
      <tr class="hover"><th>Active</th><td><xsl:if test="user/@active = 'yes'">&#x2713;</xsl:if></td><th>Fullname</th><td><xsl:value-of select="user/@fullname"/></td></tr>
      <tr class="hover"><th>Administrator</th><td><xsl:if test="user/@administrator = 'yes'">&#x2713;</xsl:if></td><th>Title</th><td><xsl:value-of select="user/@pr_title"/></td></tr>
      <tr class="hover"><th>Visible</th><td><xsl:if test="user/@addressbook = 'Visible'">&#x2713;</xsl:if></td><th>Section</th><td><xsl:value-of select="user/@pr_department_name"/></td></tr>
      <tr class="hover"><th>Auto-accept</th><td><xsl:if test="user/@autoacceptmeetingreq = 'yes'">&#x2713;</xsl:if></td><th>Location</th><td><xsl:value-of select="user/@location"/></td></tr>
      <tr class="hover"><th>Logon</th><td><xsl:value-of select="user/logon/@date"/></td><th>Telephone</th><td><xsl:value-of select="user/@pr_business_telephone_number"/></td></tr>
      <tr class="hover"><th>Logoff</th><td><xsl:value-of select="user/logoff/@date"/></td><th>Mobile</th><td><xsl:value-of select="user/@pr_mobile_telephone_number"/></td></tr>
      <tr class="hover"><td colspan="2">&#xA0;</td><th>Fax</th><td><xsl:value-of select="user/@pr_business_fax_number"/></td></tr>
      </table>
      <table id="zarafa-user-quota">
      <tr><th colspan="4" class="center">Quota Information<xsl:if test="user/@quotaoverrides = 'yes'">&#xA0;(Override Defaults &#x2713;)</xsl:if></th></tr>
      <tr class="hover"><th>Warning Level</th><td><xsl:value-of select="user/@quotawarn"/></td><th>Soft Level</th><td><xsl:value-of select="user/@quotasoft"/></td></tr>
      <tr class="hover"><th>Hard Level</th><td><xsl:value-of select="user/@quotahard"/></td><th>Current Size</th><td><xsl:value-of select="user/@size"/></td></tr>
      </table>
      <xsl:if test="count(user/sendas) &gt; 0">
        <table id="zarafa-user-sendas">
        <tr><th colspan="2">Send As Rights</th><td colspan="2">
        <xsl:for-each select="user/sendas"><xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
        <a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a><br/>
        </xsl:for-each>
        </td></tr>
        </table>
      </xsl:if>      
      <xsl:if test="count(user/group) &gt; 0">
        <table id="zarafa-user-groups">
        <tr><th colspan="2">Groups</th><td colspan="2">
        <xsl:for-each select="user/group"><xsl:sort select="translate(@groupname, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" />
        <a href="./zarafa-groups.php?group={@groupname}"><xsl:value-of select="@groupname"/></a><br/>
        </xsl:for-each>
        </td></tr>
        </table>
      </xsl:if>
    </xsl:when>

    <xsl:otherwise>
      <table id="zarafa-users">
      <tr>
          <th><a href="./zarafa-users.php?sort=username">Username</a></th>
          <th><a href="./zarafa-users.php?sort=fullname">Full Name</a></th>
          <th><a href="./zarafa-users.php?sort=emailaddress">Email Address</a></th>
          <th><a href="./zarafa-users.php?sort=quotawarn">Warning</a></th>
          <th><a href="./zarafa-users.php?sort=quotasoft">Soft</a></th>
          <th><a href="./zarafa-users.php?sort=quotahard">Hard</a></th>
          <th><a href="./zarafa-users.php?sort=size">Size (MB)</a></th>
          <th><a href="./zarafa-users.php?sort=logon">Last Logon</a></th>
      </tr>
      <xsl:choose>
      <xsl:when test="$sort = 'fullname'">
          <xsl:apply-templates select="user"><xsl:sort select="translate(@fullname, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'emailaddress'">
          <xsl:apply-templates select="user"><xsl:sort select="translate(@emailaddress, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'quotawarn'">
          <xsl:apply-templates select="user"><xsl:sort select="@quotawarn" order="descending" data-type="number"/></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'quotasoft'">
          <xsl:apply-templates select="user"><xsl:sort select="@quotasoft" order="descending" data-type="number"/></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'quotahard'">
          <xsl:apply-templates select="user"><xsl:sort select="@quotahard" order="descending" data-type="number"/></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'size'">
          <xsl:apply-templates select="user"><xsl:sort select="@size" order="descending" data-type="number"/></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'logon'">
          <xsl:apply-templates select="user"><xsl:sort select="logon/@lag" order="descending" data-type="number"/></xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
          <xsl:apply-templates select="user"><xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
      </xsl:otherwise>
      </xsl:choose>
      </table>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="user">
  <tr class="hover">
  <td><a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a></td>
  <td><xsl:value-of select="@fullname"/></td>
  <td><xsl:value-of select="@emailaddress"/></td>
  <td class="quota"><xsl:value-of select="format-number(@quotawarn div 1024,'###,###,##0')"/></td>
  <td class="quota"><xsl:value-of select="format-number(@quotasoft div 1024,'###,###,##0')"/></td>
  <td class="quota"><xsl:value-of select="format-number(@quotahard div 1024,'###,###,##0')"/></td>

  <td>
  <xsl:choose>
  <xsl:when test="number(@size div 1024) &gt;= number(@quotahard)">
  <xsl:attribute name="class">hard</xsl:attribute>
  </xsl:when>
  <xsl:when test="number(@size div 1024) &gt;= number(@quotasoft)">
  <xsl:attribute name="class">soft</xsl:attribute>
  </xsl:when>
  <xsl:when test="number(@size div 1024) &gt;= number(@quotawarn)">
  <xsl:attribute name="class">warn</xsl:attribute>
  </xsl:when>
  <xsl:otherwise>
  <xsl:attribute name="class">size</xsl:attribute>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="format-number(@size div 1048576,'###,###,##0.00')"/></td>

  <td>
  <xsl:choose>
  <xsl:when test="logon/@lag &gt;= 30">
  <xsl:attribute name="class">datelong</xsl:attribute>
  </xsl:when>
  <xsl:otherwise>
  <xsl:attribute name="class">date</xsl:attribute>
  </xsl:otherwise>
  </xsl:choose>
  <xsl:value-of select="logon/@date"/></td>
  </tr>
</xsl:template>

</xsl:stylesheet>