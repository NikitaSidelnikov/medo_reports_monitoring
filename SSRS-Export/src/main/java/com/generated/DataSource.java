
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for DataSource complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="DataSource"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Name" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;choice&gt;
 *           &lt;element name="DataSourceReference" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}DataSourceReference" minOccurs="0"/&gt;
 *           &lt;element name="InvalidDataSourceReference" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}InvalidDataSourceReference" minOccurs="0"/&gt;
 *           &lt;element name="DataSourceDefinition" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}DataSourceDefinition" minOccurs="0"/&gt;
 *         &lt;/choice&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "DataSource", propOrder = {
    "name",
    "dataSourceReference",
    "invalidDataSourceReference",
    "dataSourceDefinition"
})
public class DataSource {

    @XmlElement(name = "Name")
    protected String name;
    @XmlElement(name = "DataSourceReference")
    protected DataSourceReference dataSourceReference;
    @XmlElement(name = "InvalidDataSourceReference")
    protected InvalidDataSourceReference invalidDataSourceReference;
    @XmlElement(name = "DataSourceDefinition")
    protected DataSourceDefinition dataSourceDefinition;

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

    /**
     * Gets the value of the dataSourceReference property.
     * 
     * @return
     *     possible object is
     *     {@link DataSourceReference }
     *     
     */
    public DataSourceReference getDataSourceReference() {
        return dataSourceReference;
    }

    /**
     * Sets the value of the dataSourceReference property.
     * 
     * @param value
     *     allowed object is
     *     {@link DataSourceReference }
     *     
     */
    public void setDataSourceReference(DataSourceReference value) {
        this.dataSourceReference = value;
    }

    /**
     * Gets the value of the invalidDataSourceReference property.
     * 
     * @return
     *     possible object is
     *     {@link InvalidDataSourceReference }
     *     
     */
    public InvalidDataSourceReference getInvalidDataSourceReference() {
        return invalidDataSourceReference;
    }

    /**
     * Sets the value of the invalidDataSourceReference property.
     * 
     * @param value
     *     allowed object is
     *     {@link InvalidDataSourceReference }
     *     
     */
    public void setInvalidDataSourceReference(InvalidDataSourceReference value) {
        this.invalidDataSourceReference = value;
    }

    /**
     * Gets the value of the dataSourceDefinition property.
     * 
     * @return
     *     possible object is
     *     {@link DataSourceDefinition }
     *     
     */
    public DataSourceDefinition getDataSourceDefinition() {
        return dataSourceDefinition;
    }

    /**
     * Sets the value of the dataSourceDefinition property.
     * 
     * @param value
     *     allowed object is
     *     {@link DataSourceDefinition }
     *     
     */
    public void setDataSourceDefinition(DataSourceDefinition value) {
        this.dataSourceDefinition = value;
    }

}
