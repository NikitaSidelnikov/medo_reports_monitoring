
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *         &lt;element name="SortItem" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Direction" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}SortDirectionEnum"/&gt;
 *         &lt;element name="Clear" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
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
    "sortItem",
    "direction",
    "clear"
})
@XmlRootElement(name = "Sort")
public class Sort {

    @XmlElement(name = "SortItem")
    protected String sortItem;
    @XmlElement(name = "Direction", required = true)
    @XmlSchemaType(name = "string")
    protected SortDirectionEnum direction;
    @XmlElement(name = "Clear")
    protected boolean clear;

    /**
     * Gets the value of the sortItem property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortItem() {
        return sortItem;
    }

    /**
     * Sets the value of the sortItem property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortItem(String value) {
        this.sortItem = value;
    }

    /**
     * Gets the value of the direction property.
     * 
     * @return
     *     possible object is
     *     {@link SortDirectionEnum }
     *     
     */
    public SortDirectionEnum getDirection() {
        return direction;
    }

    /**
     * Sets the value of the direction property.
     * 
     * @param value
     *     allowed object is
     *     {@link SortDirectionEnum }
     *     
     */
    public void setDirection(SortDirectionEnum value) {
        this.direction = value;
    }

    /**
     * Gets the value of the clear property.
     * 
     */
    public boolean isClear() {
        return clear;
    }

    /**
     * Sets the value of the clear property.
     * 
     */
    public void setClear(boolean value) {
        this.clear = value;
    }

}
