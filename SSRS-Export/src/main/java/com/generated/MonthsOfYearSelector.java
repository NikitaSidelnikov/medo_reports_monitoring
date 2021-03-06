
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for MonthsOfYearSelector complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="MonthsOfYearSelector"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="January" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="February" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="March" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="April" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="May" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="June" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="July" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="August" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="September" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="October" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="November" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="December" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MonthsOfYearSelector", propOrder = {
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december"
})
public class MonthsOfYearSelector {

    @XmlElement(name = "January")
    protected boolean january;
    @XmlElement(name = "February")
    protected boolean february;
    @XmlElement(name = "March")
    protected boolean march;
    @XmlElement(name = "April")
    protected boolean april;
    @XmlElement(name = "May")
    protected boolean may;
    @XmlElement(name = "June")
    protected boolean june;
    @XmlElement(name = "July")
    protected boolean july;
    @XmlElement(name = "August")
    protected boolean august;
    @XmlElement(name = "September")
    protected boolean september;
    @XmlElement(name = "October")
    protected boolean october;
    @XmlElement(name = "November")
    protected boolean november;
    @XmlElement(name = "December")
    protected boolean december;

    /**
     * Gets the value of the january property.
     * 
     */
    public boolean isJanuary() {
        return january;
    }

    /**
     * Sets the value of the january property.
     * 
     */
    public void setJanuary(boolean value) {
        this.january = value;
    }

    /**
     * Gets the value of the february property.
     * 
     */
    public boolean isFebruary() {
        return february;
    }

    /**
     * Sets the value of the february property.
     * 
     */
    public void setFebruary(boolean value) {
        this.february = value;
    }

    /**
     * Gets the value of the march property.
     * 
     */
    public boolean isMarch() {
        return march;
    }

    /**
     * Sets the value of the march property.
     * 
     */
    public void setMarch(boolean value) {
        this.march = value;
    }

    /**
     * Gets the value of the april property.
     * 
     */
    public boolean isApril() {
        return april;
    }

    /**
     * Sets the value of the april property.
     * 
     */
    public void setApril(boolean value) {
        this.april = value;
    }

    /**
     * Gets the value of the may property.
     * 
     */
    public boolean isMay() {
        return may;
    }

    /**
     * Sets the value of the may property.
     * 
     */
    public void setMay(boolean value) {
        this.may = value;
    }

    /**
     * Gets the value of the june property.
     * 
     */
    public boolean isJune() {
        return june;
    }

    /**
     * Sets the value of the june property.
     * 
     */
    public void setJune(boolean value) {
        this.june = value;
    }

    /**
     * Gets the value of the july property.
     * 
     */
    public boolean isJuly() {
        return july;
    }

    /**
     * Sets the value of the july property.
     * 
     */
    public void setJuly(boolean value) {
        this.july = value;
    }

    /**
     * Gets the value of the august property.
     * 
     */
    public boolean isAugust() {
        return august;
    }

    /**
     * Sets the value of the august property.
     * 
     */
    public void setAugust(boolean value) {
        this.august = value;
    }

    /**
     * Gets the value of the september property.
     * 
     */
    public boolean isSeptember() {
        return september;
    }

    /**
     * Sets the value of the september property.
     * 
     */
    public void setSeptember(boolean value) {
        this.september = value;
    }

    /**
     * Gets the value of the october property.
     * 
     */
    public boolean isOctober() {
        return october;
    }

    /**
     * Sets the value of the october property.
     * 
     */
    public void setOctober(boolean value) {
        this.october = value;
    }

    /**
     * Gets the value of the november property.
     * 
     */
    public boolean isNovember() {
        return november;
    }

    /**
     * Sets the value of the november property.
     * 
     */
    public void setNovember(boolean value) {
        this.november = value;
    }

    /**
     * Gets the value of the december property.
     * 
     */
    public boolean isDecember() {
        return december;
    }

    /**
     * Sets the value of the december property.
     * 
     */
    public void setDecember(boolean value) {
        this.december = value;
    }

}
