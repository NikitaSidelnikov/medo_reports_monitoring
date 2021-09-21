
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
 *         &lt;element name="CatalogItems" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfCatalogItem" minOccurs="0"/&gt;
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
    "catalogItems"
})
@XmlRootElement(name = "ListDependentItemsResponse")
public class ListDependentItemsResponse {

    @XmlElement(name = "CatalogItems")
    protected ArrayOfCatalogItem catalogItems;

    /**
     * Gets the value of the catalogItems property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfCatalogItem }
     *     
     */
    public ArrayOfCatalogItem getCatalogItems() {
        return catalogItems;
    }

    /**
     * Sets the value of the catalogItems property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfCatalogItem }
     *     
     */
    public void setCatalogItems(ArrayOfCatalogItem value) {
        this.catalogItems = value;
    }

}
