<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:ti="http://chs.harvard.edu/xmlns/cts"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:cpt="http://purl.org/capitains/ns/1.0#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs tei"
    version="2.0">

    <xsl:output omit-xml-declaration="yes" indent="yes"/>

    <xsl:template match="/">
        <xsl:param name="folderName"><xsl:value-of select="replace(base-uri(), tokenize(base-uri(), '/')[last()], '')"/></xsl:param>
        <xsl:param name="urn" select="tokenize(/tei:TEI/tei:text/tei:body/tei:div/@n, '\.')"/>
        <xsl:param name="title">
            <xsl:copy-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
        </xsl:param>
        <xsl:element name="ti:work" namespace="http://chs.harvard.edu/xmlns/cts">
            <xsl:attribute name="groupUrn"><xsl:value-of select="$urn[1]"/></xsl:attribute>
            <xsl:attribute name="xml:lang"><xsl:value-of select="/tei:TEI/tei:text/tei:body/tei:div/@xml:lang"/></xsl:attribute>
            <xsl:attribute name="urn"><xsl:value-of select="concat($urn[1], '.', $urn[2])"/></xsl:attribute>
            <xsl:element name="ti:title" namespace="http://chs.harvard.edu/xmlns/cts">
                <xsl:attribute name="xml:lang">lat</xsl:attribute>
                <xsl:value-of select="$title"/>
            </xsl:element>
            <xsl:for-each select="collection(concat($folderName, '?select=*.xml;on-error=ignore'))">
                <xsl:if test="tokenize(document-uri(.), '/')[last()] != '__cts__.xml'">
                    <xsl:call-template name="createCTS">
                        <xsl:with-param name="textURI"><xsl:value-of select="document-uri(.)"/></xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template name="createCTS">
        <xsl:param name="git" select="'git-commit_liste.xml'"/>
        <xsl:param name="textURI"/>
        <xsl:param name="textFile" select="document($textURI)"/>
        <xsl:param name="urn" select="tokenize($textFile/tei:TEI/tei:text/tei:body/tei:div/@n, '\.')"/>
        <xsl:param name="lang" select="$textFile/tei:TEI/tei:text/tei:body/tei:div/@xml:lang"/>
        <xsl:param name="title">
            <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
        </xsl:param>
        <xsl:param name="isManuscript"><xsl:value-of select="boolean($textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc)"/></xsl:param>
        <xsl:param name="isEdition"><xsl:value-of select="boolean($textFile/tei:TEI/tei:text/tei:body/tei:div/@type='edition')"/></xsl:param>
        <xsl:param name="isTranslation"><xsl:value-of select="boolean($textFile/tei:TEI/tei:text/tei:body/tei:div/@type='translation')"/></xsl:param>
        <xsl:param name="hasCorresp"><xsl:value-of select="boolean($textFile/tei:TEI/tei:text/tei:body/tei:div/@corresp)"/></xsl:param>
        <xsl:param name="hasBiblStruct"><xsl:value-of select="boolean($textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct)"/></xsl:param>
        <xsl:param name="hasBibl"><xsl:value-of select="boolean($textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl)"/></xsl:param>
        <xsl:param name="isNew"><xsl:value-of select="boolean($textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:p)"/></xsl:param>
        <xsl:param name="docSource">
            <xsl:choose>
              <!-- Case: Transcription -->
                <xsl:when test="$isManuscript = true()">
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier/@type"/>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier/tei:idno"/>
                    <xsl:text>)</xsl:text>
                </xsl:when>
              <!-- Case: from book, either bibl or biblStruct -->
                <xsl:when test="$hasBibl = true()">
                  <xsl:if test="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:editor">
                  <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:editor">
                    <xsl:value-of select="./tei:forename"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./tei:surname|./tei:name"/>
                    <xsl:if test="position() != last()"><xsl:text>/</xsl:text></xsl:if>
                  </xsl:for-each>
                    <xsl:text> (ed.), </xsl:text>
                  </xsl:if>
                  <xsl:if test="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
                  <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
                    <xsl:value-of select="./tei:forename"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./tei:surname|./tei:name"/>
                    <xsl:if test="position() != last()"><xsl:text>/</xsl:text></xsl:if>
                  </xsl:for-each>
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                    <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:title">
                          <xsl:value-of select="."/>
                          <xsl:text>. </xsl:text>
                    </xsl:for-each>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:pubPlace"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:date"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:biblScope"/>
                </xsl:when>
                <xsl:when test="$hasBiblStruct = true()">
                  <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct">
                    <xsl:if test="current()/tei:analytic">
                      <xsl:for-each select="current()/tei:analytic/tei:editor">
                        <xsl:value-of select="./tei:forename"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./tei:surname|./tei:name"/>
                        <xsl:if test="position() != last()"><xsl:text>/</xsl:text></xsl:if>
                      </xsl:for-each>
                      <xsl:if test="current()/tei:analytic/tei:editor"><xsl:text> (ed.)</xsl:text></xsl:if>
                      <xsl:for-each select="current()/tei:analytic/tei:author">
                        <xsl:value-of select="./tei:forename"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./tei:surname|./tei:name"/>
                        <xsl:if test="position() != last()"><xsl:text>/</xsl:text></xsl:if>
                      </xsl:for-each>
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="current()/tei:analytic/tei:title"/>
                      <xsl:text>. </xsl:text>
                    </xsl:if>
                    <xsl:if test="current()/tei:monogr/tei:author">
                      <xsl:for-each select="current()/tei:monogr/tei:author">
                        <xsl:value-of select="./tei:forename"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./tei:surname|./tei:name"/>
                        <xsl:if test="position() != last()"><xsl:text>/</xsl:text></xsl:if>
                      </xsl:for-each>
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="current()/tei:monogr/tei:editor">
                      <xsl:for-each select="current()/tei:monogr/tei:editor">
                        <xsl:value-of select="./tei:forename"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./tei:surname|./tei:name"/>
                        <xsl:if test="position() != last()"><xsl:text>/</xsl:text></xsl:if>
                      </xsl:for-each>
                      <xsl:text> (ed.), </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="current()/tei:monogr/tei:title"/>
                    <xsl:if test="current()/tei:monogr/tei:biblScope[@unit='volume']">
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="current()/tei:monogr/tei:biblScope[@unit='volume']"/>
                    </xsl:if>
                    <xsl:text>. </xsl:text>
                    <xsl:if test="current()/tei:monogr/tei:edition">
                      <xsl:value-of select="current()/tei:monogr/tei:edition"/>
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="current()/tei:monogr/tei:imprint/tei:pubPlace"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="current()/tei:monogr/tei:imprint/tei:date"/>
                    <xsl:if test="current()/tei:monogr/tei:biblScope[@unit='page']">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="current()/tei:monogr/tei:biblScope[@unit='page']"/>
                    </xsl:if>
                    <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!-- new edition -->
                <xsl:otherwise>
                    <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor">
                    <xsl:value-of select="current()/tei:persName"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="current()/tei:roleName"/>
                    <xsl:text>)</xsl:text>
                    <xsl:if test="current()/tei:orgName">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="current()/tei:orgName"/>
                    </xsl:if>
                    <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                  </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:param name="markedUpTitle">
          <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName"><xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName"/><xsl:text>: </xsl:text></xsl:if>
          <xsl:value-of select="$title"/>
        </xsl:param>

        <xsl:param name="dateCopyrighted">
            <xsl:choose>
                <xsl:when test="$isManuscript = true()">
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date"/>
                </xsl:when>
                <xsl:when test="$hasBibl = true()">
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:date"/>
                </xsl:when>
                <xsl:when test="$hasBiblStruct = true()">
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>

        <xsl:param name="dateCreated">
            <xsl:choose>
                <xsl:when test="$textFile/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@when">
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@when"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@notBefore"/>
                    <xsl:text>–</xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@notAfter"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>

        <xsl:param name="metacollection">
                <xsl:if test="$isNew = true()">
                    <xsl:text>Neueditionen</xsl:text>
                </xsl:if>
                <!-- muss jeweils ergänzt werden -->
                <xsl:if test="matches($textURI, 'pta0036|pta0037|pta0003.pta001|pta0007.pta007')">
                      <xsl:text>GCS-Retrodigitalisate</xsl:text>
                </xsl:if>
        </xsl:param>
        <xsl:param name="lastModified"><xsl:value-of select="document($git)/root/item[urn=string-join($urn, '.')]/date"/>
      </xsl:param>
        <xsl:param name="gitHash">
          <xsl:value-of select="document($git)/root/item[urn=string-join($urn, '.')]/hash"/>
        </xsl:param>
        <xsl:param name="allEds">
            <xsl:choose>
                <xsl:when test="$isManuscript = true()">
                    <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt">
                        <xsl:value-of select="current()/tei:persName"/>
                        <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$isNew = true()">
                        <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor">
                        <xsl:value-of select="current()/tei:persName"/>
                        <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                      </xsl:for-each>
                </xsl:when>
                <xsl:when test="$hasBibl = true()">
                  <xsl:if test="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
                        <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:author">
                        <xsl:value-of select="current()/tei:forename"/><xsl:text> </xsl:text><xsl:value-of select="current()/tei:surname"/>
                        <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                      </xsl:for-each>
                  </xsl:if>
                  <xsl:if test="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:editor">
                        <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:editor">
                        <xsl:value-of select="current()/tei:forename"/><xsl:text> </xsl:text><xsl:value-of select="current()/tei:surname"/>
                        <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                      </xsl:for-each>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:author">
                  <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:author/tei:forename"/><xsl:text></xsl:text><xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:author/tei:surname"/>
                  <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:editor">
                  <xsl:value-of select="current()/tei:forename"/><xsl:text> </xsl:text>
                  <xsl:value-of select="current()/tei:surname"/>
                  <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:param name="textURL">
          <xsl:text>https://pta.bbaw.de/reader?left=</xsl:text>
          <xsl:value-of select="translate(string-join($urn, '.'),':','-')"/>
        </xsl:param>
        <xsl:param name="bibliographicCitation">
            <xsl:choose>
                <xsl:when test="$isManuscript = true()">
                    <xsl:value-of select="$markedUpTitle"/>
                    <xsl:text>. Transcribed from </xsl:text>
                    <xsl:value-of select="$docSource"/><xsl:text> by </xsl:text>
                    <xsl:value-of select="$allEds"/><xsl:text>. </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:distributor/text()"/><xsl:text> </xsl:text>
                    <xsl:value-of select="$dateCopyrighted"/><xsl:text>. Version: </xsl:text><xsl:value-of select="substring($gitHash,1,8)"/><xsl:text>, committed on </xsl:text><xsl:value-of select="$lastModified"/><xsl:text>, </xsl:text>
                    <xsl:value-of select="$textURL"/><xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:when test="$isNew = true()">
                  <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor">
                  <xsl:value-of select="current()/tei:persName"/>
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="current()/tei:roleName"/>
                  <xsl:text>)</xsl:text>
                  <xsl:if test="current()/tei:orgName">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="current()/tei:orgName"/>
                  </xsl:if>
                  <xsl:if test="position() != last()"><xsl:text> / </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>, </xsl:text>
                    <xsl:value-of select="$markedUpTitle"/>
                    <xsl:text>. </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:distributor/text()"/><xsl:text> </xsl:text>
                    <xsl:value-of select="$dateCopyrighted"/><xsl:text>. Version: </xsl:text><xsl:value-of select="substring($gitHash,1,8)"/><xsl:text>, committed on </xsl:text><xsl:value-of select="$lastModified"/><xsl:text>, </xsl:text>
                    <xsl:value-of select="$textURL"/><xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$markedUpTitle"/>
                  <xsl:text>, edited according to </xsl:text>
                  <xsl:value-of select="$docSource"/><xsl:text>. </xsl:text>
                  <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:distributor/text()"/><xsl:text> </xsl:text>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date"/><xsl:text>. Version: </xsl:text><xsl:value-of select="substring($gitHash,1,8)"/><xsl:text>, committed on </xsl:text><xsl:value-of select="$lastModified"/><xsl:text>, </xsl:text>
                    <xsl:value-of select="$textURL"/><xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:param name="metadata">
            <cpt:structured-metadata xml:lang="deu">
                <dc:title><xsl:value-of select="$markedUpTitle"/></dc:title>
                <dc:creator>
                  <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName"/>
                </dc:creator>
                <dc:source><xsl:value-of select="$docSource"/></dc:source>
                <dc:contributor><xsl:value-of select="$allEds"/></dc:contributor>
                <dc:publisher xml:lang="eng">Patristic Text Archive (BBAW)</dc:publisher>
                <dc:publisher xml:lang="deu">Patristisches Textarchiv (BBAW)</dc:publisher>
                <dc:format>application/tei+xml</dc:format>
                <dc:rights>
                  <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/tei:licence/@target"/>
                </dc:rights>
                <dct:isVersionOf><xsl:text>https://github.com/PatristicTextArchive/pta_data/blob/public</xsl:text><xsl:value-of select="substring-after($textURI,'data')"/></dct:isVersionOf>
                <dct:hasVersion><xsl:text>https://github.com/PatristicTextArchive/pta_data/blob/</xsl:text><xsl:value-of select="$gitHash"/><xsl:value-of select="substring-after($textURI,'data')"/></dct:hasVersion>
                <xsl:if test="$hasCorresp = true()">
                  <dct:relation>
                  <xsl:text>Translation from </xsl:text><xsl:value-of select="$textFile/tei:TEI/tei:text/tei:body/tei:div/@corresp"/>
                  </dct:relation>
                </xsl:if>
                <dc:date><xsl:value-of select="$lastModified"/></dc:date>
                <dct:created><xsl:value-of select="$dateCreated"/></dct:created>
                <dct:spatial>
                    <xsl:value-of select="$textFile/tei:TEI/tei:teiHeader/tei:profileDesc/tei:creation/tei:placeName/@ref"/>
                </dct:spatial>
                <xsl:for-each select="$textFile/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term">
                  <dct:type><xsl:value-of select="normalize-space(.)"/></dct:type>
                </xsl:for-each>
                <dct:dateCopyrighted><xsl:value-of select="$dateCopyrighted"/></dct:dateCopyrighted>
                <dct:bibliographicCitation><xsl:value-of select="$bibliographicCitation"/></dct:bibliographicCitation>
                <dct:isPartOf><xsl:value-of select="$metacollection"/></dct:isPartOf>
            </cpt:structured-metadata>
        </xsl:param>

        <xsl:choose>
            <xsl:when test="contains(string-join($urn, '.'), 'deu') or contains(string-join($urn, '.'), 'eng') or contains(string-join($urn, '.'), 'rum')">
                <xsl:element name="ti:translation" namespace="http://chs.harvard.edu/xmlns/cts">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$textFile/tei:TEI/tei:text/tei:body/tei:div/@xml:lang"/></xsl:attribute>
                    <xsl:attribute name="urn"><xsl:value-of select="string-join($urn, '.')"/></xsl:attribute>
                    <xsl:attribute name="workUrn"><xsl:value-of select="concat($urn[1], '.', $urn[2])"/></xsl:attribute>
                    <xsl:element name="ti:label" namespace="http://chs.harvard.edu/xmlns/cts">
                        <xsl:attribute name="xml:lang">eng</xsl:attribute>
                        <xsl:value-of select="$markedUpTitle"/>
                    </xsl:element>
                    <xsl:element name="ti:description" namespace="http://chs.harvard.edu/xmlns/cts">
                        <xsl:attribute name="xml:lang">eng</xsl:attribute>
                        <xsl:copy-of select="$docSource"/>
                    </xsl:element>
                    <xsl:copy-of select="$metadata"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="ti:edition" namespace="http://chs.harvard.edu/xmlns/cts">
                    <xsl:attribute name="urn"><xsl:value-of select="string-join($urn, '.')"/></xsl:attribute>
                    <xsl:attribute name="workUrn"><xsl:value-of select="concat($urn[1], '.', $urn[2])"/></xsl:attribute>
                    <xsl:element name="ti:label" namespace="http://chs.harvard.edu/xmlns/cts">
                        <xsl:attribute name="xml:lang">eng</xsl:attribute>
                                <xsl:value-of select="$markedUpTitle"/>
                    </xsl:element>
                    <xsl:element name="ti:description" namespace="http://chs.harvard.edu/xmlns/cts">
                        <xsl:attribute name="xml:lang">eng</xsl:attribute>
                        <xsl:copy-of select="$docSource"/>
                    </xsl:element>
                    <xsl:copy-of select="$metadata"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
