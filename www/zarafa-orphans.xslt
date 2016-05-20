<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />
<xsl:param name="sort" select="'username'"/>

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

<xsl:template match="/zarafaadmin/users">
  <pre>
    <table id="zarafa-orphans">
    <tr>
      <th align="left"><a href="./zarafa-users.php?sort=guid">Store GUID</a></th>
      <th align="left"><a href="./zarafa-users.php?sort=username">Guessed Username</a></th>
      <th align="right"><a href="./zarafa-users.php?sort=size">Size (MB)</a></th>
      <th align="right"><a href="./zarafa-users.php?sort=type">Store Type</a></th>
      <th align="center"><a href="./zarafa-users.php?sort=logon">Last Logon</a></th>      
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
  </pre>
</xsl:template>

<xsl:template match="orphan">
  <tr class="entry">
  <td><a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a></td>
  <td><xsl:value-of select="@fullname"/></td>
  <td><xsl:value-of select="@emailaddress"/></td>
  <td class="number"><xsl:value-of select="format-number(@quotawarn div 1024,'###,###,##0')"/></td>
  <td class="number"><xsl:value-of select="format-number(@quotasoft div 1024,'###,###,##0')"/></td>
  <td class="number"><xsl:value-of select="format-number(@quotahard div 1024,'###,###,##0')"/></td>

  <td>
    <xsl:choose>
    <xsl:when test="number(@size div 1024) &gt;= number(@quotahard)">
      <xsl:attribute name="class">number hard</xsl:attribute>
    </xsl:when>
    <xsl:when test="number(@size div 1024) &gt;= number(@quotasoft)">
      <xsl:attribute name="class">number soft</xsl:attribute>
    </xsl:when>
    <xsl:when test="number(@size div 1024) &gt;= number(@quotawarn)">
      <xsl:attribute name="class">number warn</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="class">number</xsl:attribute>
    </xsl:otherwise>
    </xsl:choose>
  <xsl:value-of select="format-number(@size div 1048576,'###,###,##0.00')"/></td>

  <td align="center">
    <xsl:if test="logon/@lag &gt;= 30">
      <xsl:attribute name="class">red</xsl:attribute>
    </xsl:if>   
    <xsl:value-of select="logon/@date"/></td>
  </tr>
</xsl:template>

<xsl:template match="sendas" mode="first">
<xsl:param name="columns"/>  
  <tr>
     <xsl:apply-templates select=".|following-sibling::sendas[position() &lt; $columns]"/>
     <xsl:if test="count(following-sibling::sendas) &lt; ($columns - 1)">
        <xsl:call-template name="emptycell">
           <xsl:with-param name="columns" select="$columns"/>
           <xsl:with-param name="cells" select="$columns - 1 - count(following-sibling::sendas)"/>
        </xsl:call-template>
     </xsl:if>
  </tr>
</xsl:template>

<xsl:template match="sendas">
  <td align="center" class="hover" colspan="3">
    <a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a>
  </td>
</xsl:template>


<xsl:template match="group" mode="first">
<xsl:param name="columns"/>  
  <tr>
     <xsl:apply-templates select=".|following-sibling::group[position() &lt; $columns]"/>
     <xsl:if test="count(following-sibling::group) &lt; ($columns - 1)">
        <xsl:call-template name="emptycell">
           <xsl:with-param name="columns" select="$columns"/>
           <xsl:with-param name="cells" select="$columns - 1 - count(following-sibling::group)"/>
        </xsl:call-template>
     </xsl:if>
  </tr>
</xsl:template>

<xsl:template match="group">
  <td align="center" class="hover" colspan="3">
    <a href="./zarafa-groups.php?group={@groupname}"><xsl:value-of select="@groupname"/></a>
  </td>
</xsl:template>

<xsl:template name="emptycell">
<xsl:param name="columns"/>  
  <xsl:param name="cells"/>
  <td colspan="3">&#xA0;</td>
  <xsl:if test="$cells &gt; 1">
     <xsl:call-template name="emptycell">
        <xsl:with-param name="cells" select="$cells - 1"/>
     </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>