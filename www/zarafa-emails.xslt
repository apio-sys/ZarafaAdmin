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

<xsl:template match="/zarafaadmin/emails">
  <pre>
    <table id="zarafa-emails">
      <caption>Cached on <xsl:value-of select="@date"/></caption>
      <tr>
        <th align="right">
          1000&#160;<br/>
          800&#160;<br/>
          200&#160;<br/>
        </th>
        <th align="left">
          &#160;Total Accounts<br/>
          &#160;User Accounts<br/>
          &#160;Group Accounts<br/>
        </th>
        <th align="center"&#160;</th>
        <th align="right">
          1000&#160;<br/>
          800&#160;<br/>
          200&#160;<br/>
        </th>
        <th align="left">
          &#160;Zarafa Accounts<br/>
          &#160;Domino Accounts<br/>
          &#160;Zarafa-Only Accounts<br/>
          &#160;Domino-Only Accounts<br/>
        </th>
      </tr>          
      <tr>
        <th align="left"><a href="./zarafa-emails.php?sort=mail">Email Address</a></th>
        <th align="center"><a href="./zarafa-emails.php?sort=type">Account Type</a></th>
        <th align="center"><a href="./zarafa-emails.php?sort=zarafa">Zarafa Account</a></th>
        <th align="center"><a href="./zarafa-emails.php?sort=domino">Domino Account</a></th>
        <th align="center"><a href="./zarafa-emails.php?sort=forward">Forwarding</a></th>
      </tr>
      <xsl:choose>
      <xsl:when test="$sort = 'type'">
        <xsl:apply-templates select="email"><xsl:sort select="@type" order="descending"/></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'zarafa'">
        <xsl:apply-templates select="email"><xsl:sort select="@zarafa" order="descending"/></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'domino'">
        <xsl:apply-templates select="email"><xsl:sort select="@domino" order="descending"/></xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$sort = 'forward'">
        <xsl:apply-templates select="email"><xsl:sort select="@forward" order="descending"/></xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="email"><xsl:sort select="@mail" order="ascending"/></xsl:apply-templates>
      </xsl:otherwise>
      </xsl:choose>
    </table>
  </pre>
</xsl:template>

<xsl:template match="email">
  <tr class="entry">
    <td align="left">
      <xsl:choose>
        <xsl:when test="@username = ''">
          <xsl:value-of select="@mail"/>
        </xsl:when>
        <xsl:otherwise>
          <a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@mail"/></a>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td align="center"><xsl:value-of select="@type"/></td>
    <td align="center">
      <xsl:attribute name="class">    
        <xsl:if test="@zarafa = 'True'">green</xsl:if>
        <xsl:if test="@zarafa = 'False'">red</xsl:if>
      </xsl:attribute>
      <xsl:value-of select="@zarafa"/>
    </td>
    <td align="center">
      <xsl:attribute name="class">    
        <xsl:if test="@domino = 'True'">green</xsl:if>
        <xsl:if test="@domino = 'False'">red</xsl:if>
      </xsl:attribute>
      <xsl:value-of select="@domino"/>
    </td>
    <td align="center">
      <xsl:attribute name="class">    
        <xsl:if test="@forward = 'True'">green</xsl:if>
        <xsl:if test="@forward = 'False'">red</xsl:if>
      </xsl:attribute>
      <xsl:value-of select="@forward"/>
    </td>
  </tr>
</xsl:template>

</xsl:stylesheet>