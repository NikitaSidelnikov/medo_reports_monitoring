
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Definition" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}DataSourceDefinition" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "definition"
})
@XmlRootElement(name = "GetDataSourceContentsResponse")
public class GetDataSourceContentsResponse {

    @XmlElement(name = "Definition")
    protected DataSourceDefinition definition;

    /**
     * Gets the value of the definition property.
     * 
     * @return
     *     possible object is
     *     {@link DataSourceDefinition }
     *     
     */
    public DataSourceDefinition getDefinition() {
        return definition;
    }

    /**
     * Sets the value of the definition property.
     * 
     * @param value
     *     allowed object is
     *     {@link DataSourceDefinition }
     *     
     */
    public void setDefinition(DataSourceDefinition value) {
        this.definition = value;
    }

}