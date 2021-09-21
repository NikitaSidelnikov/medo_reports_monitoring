
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
 *         &lt;element name="PageNumber" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="ReportItem" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="NumPages" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
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
    "pageNumber",
    "reportItem",
    "numPages"
})
@XmlRootElement(name = "SortResponse")
public class SortResponse {

    @XmlElement(name = "PageNumber")
    protected int pageNumber;
    @XmlElement(name = "ReportItem")
    protected String reportItem;
    @XmlElement(name = "NumPages")
    protected int numPages;

    /**
     * Gets the value of the pageNumber property.
     * 
     */
    public int getPageNumber() {
        return pageNumber;
    }

    /**
     * Sets the value of the pageNumber property.
     * 
     */
    public void setPageNumber(int value) {
        this.pageNumber = value;
    }

    /**
     * Gets the value of the reportItem property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReportItem() {
        return reportItem;
    }

    /**
     * Sets the value of the reportItem property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReportItem(String value) {
        this.reportItem = value;
    }

    /**
     * Gets the value of the numPages property.
     * 
     */
    public int getNumPages() {
        return numPages;
    }

    /**
     * Sets the value of the numPages property.
     * 
     */
    public void setNumPages(int value) {
        this.numPages = value;
    }

}
