
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for DataSetDefinition complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="DataSetDefinition"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Fields" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfField" minOccurs="0"/&gt;
 *         &lt;element name="Query" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}QueryDefinition" minOccurs="0"/&gt;
 *         &lt;element name="CaseSensitivity" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}SensitivityEnum" minOccurs="0"/&gt;
 *         &lt;element name="Collation" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="AccentSensitivity" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}SensitivityEnum" minOccurs="0"/&gt;
 *         &lt;element name="KanatypeSensitivity" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}SensitivityEnum" minOccurs="0"/&gt;
 *         &lt;element name="WidthSensitivity" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}SensitivityEnum" minOccurs="0"/&gt;
 *         &lt;element name="Name" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "DataSetDefinition", propOrder = {
    "fields",
    "query",
    "caseSensitivity",
    "collation",
    "accentSensitivity",
    "kanatypeSensitivity",
    "widthSensitivity",
    "name"
})
public class DataSetDefinition {

    @XmlElement(name = "Fields")
    protected ArrayOfField fields;
    @XmlElement(name = "Query")
    protected QueryDefinition query;
    @XmlElement(name = "CaseSensitivity")
    @XmlSchemaType(name = "string")
    protected SensitivityEnum caseSensitivity;
    @XmlElement(name = "Collation")
    protected String collation;
    @XmlElement(name = "AccentSensitivity")
    @XmlSchemaType(name = "string")
    protected SensitivityEnum accentSensitivity;
    @XmlElement(name = "KanatypeSensitivity")
    @XmlSchemaType(name = "string")
    protected SensitivityEnum kanatypeSensitivity;
    @XmlElement(name = "WidthSensitivity")
    @XmlSchemaType(name = "string")
    protected SensitivityEnum widthSensitivity;
    @XmlElement(name = "Name")
    protected String name;

    /**
     * Gets the value of the fields property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfField }
     *     
     */
    public ArrayOfField getFields() {
        return fields;
    }

    /**
     * Sets the value of the fields property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfField }
     *     
     */
    public void setFields(ArrayOfField value) {
        this.fields = value;
    }

    /**
     * Gets the value of the query property.
     * 
     * @return
     *     possible object is
     *     {@link QueryDefinition }
     *     
     */
    public QueryDefinition getQuery() {
        return query;
    }

    /**
     * Sets the value of the query property.
     * 
     * @param value
     *     allowed object is
     *     {@link QueryDefinition }
     *     
     */
    public void setQuery(QueryDefinition value) {
        this.query = value;
    }

    /**
     * Gets the value of the caseSensitivity property.
     * 
     * @return
     *     possible object is
     *     {@link SensitivityEnum }
     *     
     */
    public SensitivityEnum getCaseSensitivity() {
        return caseSensitivity;
    }

    /**
     * Sets the value of the caseSensitivity property.
     * 
     * @param value
     *     allowed object is
     *     {@link SensitivityEnum }
     *     
     */
    public void setCaseSensitivity(SensitivityEnum value) {
        this.caseSensitivity = value;
    }

    /**
     * Gets the value of the collation property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollation() {
        return collation;
    }

    /**
     * Sets the value of the collation property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollation(String value) {
        this.collation = value;
    }

    /**
     * Gets the value of the accentSensitivity property.
     * 
     * @return
     *     possible object is
     *     {@link SensitivityEnum }
     *     
     */
    public SensitivityEnum getAccentSensitivity() {
        return accentSensitivity;
    }

    /**
     * Sets the value of the accentSensitivity property.
     * 
     * @param value
     *     allowed object is
     *     {@link SensitivityEnum }
     *     
     */
    public void setAccentSensitivity(SensitivityEnum value) {
        this.accentSensitivity = value;
    }

    /**
     * Gets the value of the kanatypeSensitivity property.
     * 
     * @return
     *     possible object is
     *     {@link SensitivityEnum }
     *     
     */
    public SensitivityEnum getKanatypeSensitivity() {
        return kanatypeSensitivity;
    }

    /**
     * Sets the value of the kanatypeSensitivity property.
     * 
     * @param value
     *     allowed object is
     *     {@link SensitivityEnum }
     *     
     */
    public void setKanatypeSensitivity(SensitivityEnum value) {
        this.kanatypeSensitivity = value;
    }

    /**
     * Gets the value of the widthSensitivity property.
     * 
     * @return
     *     possible object is
     *     {@link SensitivityEnum }
     *     
     */
    public SensitivityEnum getWidthSensitivity() {
        return widthSensitivity;
    }

    /**
     * Sets the value of the widthSensitivity property.
     * 
     * @param value
     *     allowed object is
     *     {@link SensitivityEnum }
     *     
     */
    public void setWidthSensitivity(SensitivityEnum value) {
        this.widthSensitivity = value;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

}
