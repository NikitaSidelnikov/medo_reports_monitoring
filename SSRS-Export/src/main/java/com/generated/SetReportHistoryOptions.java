
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
 *         &lt;element name="Report" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="EnableManualSnapshotCreation" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="KeepExecutionSnapshots" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;choice&gt;
 *           &lt;element name="ScheduleDefinition" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ScheduleDefinition" minOccurs="0"/&gt;
 *           &lt;element name="ScheduleReference" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ScheduleReference" minOccurs="0"/&gt;
 *           &lt;element name="NoSchedule" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}NoSchedule" minOccurs="0"/&gt;
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
@XmlType(name = "", propOrder = {
    "report",
    "enableManualSnapshotCreation",
    "keepExecutionSnapshots",
    "scheduleDefinition",
    "scheduleReference",
    "noSchedule"
})
@XmlRootElement(name = "SetReportHistoryOptions")
public class SetReportHistoryOptions {

    @XmlElement(name = "Report")
    protected String report;
    @XmlElement(name = "EnableManualSnapshotCreation")
    protected boolean enableManualSnapshotCreation;
    @XmlElement(name = "KeepExecutionSnapshots")
    protected boolean keepExecutionSnapshots;
    @XmlElement(name = "ScheduleDefinition")
    protected ScheduleDefinition scheduleDefinition;
    @XmlElement(name = "ScheduleReference")
    protected ScheduleReference scheduleReference;
    @XmlElement(name = "NoSchedule")
    protected NoSchedule noSchedule;

    /**
     * Gets the value of the report property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReport() {
        return report;
    }

    /**
     * Sets the value of the report property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReport(String value) {
        this.report = value;
    }

    /**
     * Gets the value of the enableManualSnapshotCreation property.
     * 
     */
    public boolean isEnableManualSnapshotCreation() {
        return enableManualSnapshotCreation;
    }

    /**
     * Sets the value of the enableManualSnapshotCreation property.
     * 
     */
    public void setEnableManualSnapshotCreation(boolean value) {
        this.enableManualSnapshotCreation = value;
    }

    /**
     * Gets the value of the keepExecutionSnapshots property.
     * 
     */
    public boolean isKeepExecutionSnapshots() {
        return keepExecutionSnapshots;
    }

    /**
     * Sets the value of the keepExecutionSnapshots property.
     * 
     */
    public void setKeepExecutionSnapshots(boolean value) {
        this.keepExecutionSnapshots = value;
    }

    /**
     * Gets the value of the scheduleDefinition property.
     * 
     * @return
     *     possible object is
     *     {@link ScheduleDefinition }
     *     
     */
    public ScheduleDefinition getScheduleDefinition() {
        return scheduleDefinition;
    }

    /**
     * Sets the value of the scheduleDefinition property.
     * 
     * @param value
     *     allowed object is
     *     {@link ScheduleDefinition }
     *     
     */
    public void setScheduleDefinition(ScheduleDefinition value) {
        this.scheduleDefinition = value;
    }

    /**
     * Gets the value of the scheduleReference property.
     * 
     * @return
     *     possible object is
     *     {@link ScheduleReference }
     *     
     */
    public ScheduleReference getScheduleReference() {
        return scheduleReference;
    }

    /**
     * Sets the value of the scheduleReference property.
     * 
     * @param value
     *     allowed object is
     *     {@link ScheduleReference }
     *     
     */
    public void setScheduleReference(ScheduleReference value) {
        this.scheduleReference = value;
    }

    /**
     * Gets the value of the noSchedule property.
     * 
     * @return
     *     possible object is
     *     {@link NoSchedule }
     *     
     */
    public NoSchedule getNoSchedule() {
        return noSchedule;
    }

    /**
     * Sets the value of the noSchedule property.
     * 
     * @param value
     *     allowed object is
     *     {@link NoSchedule }
     *     
     */
    public void setNoSchedule(NoSchedule value) {
        this.noSchedule = value;
    }

}
