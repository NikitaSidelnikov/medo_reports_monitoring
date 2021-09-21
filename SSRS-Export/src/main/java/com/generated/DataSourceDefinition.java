
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for DataSourceDefinition complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="DataSourceDefinition"&gt;
 *   &lt;complexContent&gt;
 *     &lt;extension base="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}DataSourceDefinitionOrReference"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Extension" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ConnectString" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="UseOriginalConnectString" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="OriginalConnectStringExpressionBased" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="CredentialRetrieval" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}CredentialRetrievalEnum"/&gt;
 *         &lt;element name="WindowsCredentials" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="ImpersonateUser" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="Prompt" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="UserName" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Password" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/extension&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "DataSourceDefinition", propOrder = {
    "extension",
    "connectString",
    "useOriginalConnectString",
    "originalConnectStringExpressionBased",
    "credentialRetrieval",
    "windowsCredentials",
    "impersonateUser",
    "prompt",
    "userName",
    "password",
    "enabled"
})
public class DataSourceDefinition
    extends DataSourceDefinitionOrReference
{

    @XmlElement(name = "Extension")
    protected String extension;
    @XmlElement(name = "ConnectString")
    protected String connectString;
    @XmlElement(name = "UseOriginalConnectString")
    protected boolean useOriginalConnectString;
    @XmlElement(name = "OriginalConnectStringExpressionBased")
    protected boolean originalConnectStringExpressionBased;
    @XmlElement(name = "CredentialRetrieval", required = true)
    @XmlSchemaType(name = "string")
    protected CredentialRetrievalEnum credentialRetrieval;
    @XmlElement(name = "WindowsCredentials")
    protected boolean windowsCredentials;
    @XmlElement(name = "ImpersonateUser")
    protected Boolean impersonateUser;
    @XmlElement(name = "Prompt")
    protected String prompt;
    @XmlElement(name = "UserName")
    protected String userName;
    @XmlElement(name = "Password")
    protected String password;
    @XmlElement(name = "Enabled")
    protected Boolean enabled;

    /**
     * Gets the value of the extension property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExtension() {
        return extension;
    }

    /**
     * Sets the value of the extension property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExtension(String value) {
        this.extension = value;
    }

    /**
     * Gets the value of the connectString property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getConnectString() {
        return connectString;
    }

    /**
     * Sets the value of the connectString property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setConnectString(String value) {
        this.connectString = value;
    }

    /**
     * Gets the value of the useOriginalConnectString property.
     * 
     */
    public boolean isUseOriginalConnectString() {
        return useOriginalConnectString;
    }

    /**
     * Sets the value of the useOriginalConnectString property.
     * 
     */
    public void setUseOriginalConnectString(boolean value) {
        this.useOriginalConnectString = value;
    }

    /**
     * Gets the value of the originalConnectStringExpressionBased property.
     * 
     */
    public boolean isOriginalConnectStringExpressionBased() {
        return originalConnectStringExpressionBased;
    }

    /**
     * Sets the value of the originalConnectStringExpressionBased property.
     * 
     */
    public void setOriginalConnectStringExpressionBased(boolean value) {
        this.originalConnectStringExpressionBased = value;
    }

    /**
     * Gets the value of the credentialRetrieval property.
     * 
     * @return
     *     possible object is
     *     {@link CredentialRetrievalEnum }
     *     
     */
    public CredentialRetrievalEnum getCredentialRetrieval() {
        return credentialRetrieval;
    }

    /**
     * Sets the value of the credentialRetrieval property.
     * 
     * @param value
     *     allowed object is
     *     {@link CredentialRetrievalEnum }
     *     
     */
    public void setCredentialRetrieval(CredentialRetrievalEnum value) {
        this.credentialRetrieval = value;
    }

    /**
     * Gets the value of the windowsCredentials property.
     * 
     */
    public boolean isWindowsCredentials() {
        return windowsCredentials;
    }

    /**
     * Sets the value of the windowsCredentials property.
     * 
     */
    public void setWindowsCredentials(boolean value) {
        this.windowsCredentials = value;
    }

    /**
     * Gets the value of the impersonateUser property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isImpersonateUser() {
        return impersonateUser;
    }

    /**
     * Sets the value of the impersonateUser property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setImpersonateUser(Boolean value) {
        this.impersonateUser = value;
    }

    /**
     * Gets the value of the prompt property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPrompt() {
        return prompt;
    }

    /**
     * Sets the value of the prompt property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPrompt(String value) {
        this.prompt = value;
    }

    /**
     * Gets the value of the userName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUserName() {
        return userName;
    }

    /**
     * Sets the value of the userName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUserName(String value) {
        this.userName = value;
    }

    /**
     * Gets the value of the password property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPassword() {
        return password;
    }

    /**
     * Sets the value of the password property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPassword(String value) {
        this.password = value;
    }

    /**
     * Gets the value of the enabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isEnabled() {
        return enabled;
    }

    /**
     * Sets the value of the enabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setEnabled(Boolean value) {
        this.enabled = value;
    }

}
