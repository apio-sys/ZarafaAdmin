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

<xsl:template match="/zarafaadmin/licensed">
  <pre>
    <table id="zarafa-license">
      <tr>
        <th colspan="8">
          <table align="center" id="zarafa-users-totals">
            <caption>License information</caption>
            <tr>
              <td align="center">&#160;</td>
              <th align="right">Allowed</th>
              <th align="right">&#160;&#160;Used</th>
              <th align="right">&#160;&#160;Available</th>
            </tr>
            <tr class="entry">
              <th align="left">Active:</th>
              <td align="right"><xsl:value-of select="licensed/active/@allowed"/></td>
              <td align="right"><xsl:value-of select="licensed/active/@used"/>&#160;</td>
              <td align="right"><xsl:value-of select="licensed/active/@available"/></td>
            </tr>
            <tr class="entry">
              <th align="left">Non-Active:</th>
              <td align="right"><xsl:value-of select="licensed/nonactive/@allowed"/></td>
              <td align="right"><xsl:value-of select="licensed/nonactive/@used"/>&#160;</td>
              <td align="right"><xsl:value-of select="licensed/nonactive/@available"/></td>
            </tr>
            <tr class="entry">
              <th align="left">&#160;&#160;Users:</th>
              <td align="right">&#160;</td>
              <td align="right"><xsl:value-of select="licensed/nonactive/@users"/>&#160;</td>
              <td align="right">&#160;</td>
            </tr>            
            <tr class="entry">
              <th align="left">&#160;&#160;Rooms:</th>
              <td align="right">&#160;</td>
              <td align="right"><xsl:value-of select="licensed/nonactive/@rooms"/>&#160;</td>
              <td align="right">&#160;</td>
            </tr>            
            <tr class="entry">
              <th align="left">&#160;&#160;Equipment:</th>
              <td align="right">&#160;</td>
              <td align="right"><xsl:value-of select="licensed/nonactive/@equipment"/>&#160;</td>
              <td align="right">&#160;</td>
            </tr>            
            <tr class="entry">
              <th align="left">Total:</th>
              <td align="right">&#160;</td>
              <td align="right"><xsl:value-of select="licensed/total/@used"/>&#160;</td>
              <td align="right">&#160;</td>
            </tr>
          </table>
        </th>
      </tr>   
    </table>
  </pre>
</xsl:template>

</xsl:stylesheet>