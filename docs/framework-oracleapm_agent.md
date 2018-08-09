# Oracle APM Agent Framework
The Oracle APM Agent Framework causes an application to be automatically configured to work with a bound [OracleAPM Service].

<table>
  <tr>
    <td><strong>Detection Criterion</strong></td><td>Existence of a single bound Oracle APM service.
      <ul>
        <li>Existence of a Oracle APM service is defined as the <a href="http://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html#VCAP-SERVICES"><code>VCAP_SERVICES</code></a> payload containing a service who's name, label or tag has <code>oracleapm</code> as a substring.</li>
      </ul>
    </td>
  </tr>
 </table>
Tags are printed to standard output by the buildpack detect script

##  Configure Oracle APM Agent Service
Below are steps to configure application with APM Agent Service : <br/>
<ol type="1">
 <li>Push application with custom java build : https://github.com/oracleapm/java-buildpack.git#apmagent e.g. <br/>
 cf push #app_name -b https://github.com/oracleapm/java-buildpack.git#apmagent
</li>
<li>
 Configure oracle apm agent service using cups e.g. <br/>
 cf cups oracleapm -p "{\"regkey\":\"<regkey value>\",\"tenant-id\":\"<tenant_id>\",\"omc-server-url\":\"<omc service url>\",\"agent-uri\":\"<apmagent.zip http download location>\"}"
</li>
<li>
Restage application <br/> 
cf restage #app_name
</li>
</ol>

## APM Agent Logs
APM agent logs can be accessed from below location <br/>
app/.java-buildpack/oracleapm_agent/logs/tomcat_instance/   


## User-Provided Service (Optional)
Users may optionally provide their own OracleAPM service. A user-provided OracleAPM service must have a name or tag with `oracleapm` in it so that the Oracle APM Agent Framework will automatically configure the application to work with the service.

The credential payload of the service may contain the following entries:

| Name | Description
| ---- | -----------
| `additional-gateways` |  (Optional) Comma separated list of gateway URLs. A valid gateway URL is in this format: https://host:port
| `agent-uri` | 	Specify APM agent installer zip location e.g. https://<host>:<port>/1.32_APM_226.zip  
| `classifications` | (Optional) Specify a classifications string that will be sent to the OMC server
| `debug` | Log extended debug information
| `gateway-host` | (Optional) The gateway host through which the APM java agent communicates with the OMC server.
| `gateway-port` | (Optional) Gateway port.
| `insecure` | Use insecure SSL connections during installation, i.e. do not verify the certificates sent by the remote server.
| `omc-server-url` | Specify the url of the omc server. This parameter is mandatory if the agent zip file was not obtained from the omc server. This parameter is expected to be in the format https://<host>:<port>
| `ph` | (Optional) Specify your HTTP Proxy Host. If the APM Agent must use an HTTP proxy, this is the proxy's hostname.
| `pp` | (Optional) Specify your HTTP Proxy Port. If the APM Agent must use a n HTTPproxy, this is the proxy's port.
| `pt` | (Optional) Specify the HTTP Proxy Authorization Token to use. If the APM Agent must use an HTTP proxy that requires authentication, this is the *proxy* authorization token the APM Agent will use. It will be added to the APM Agent's credential store that gets provisioned here (i.e., either an Oracle "auto-login" Wallet or the "alternative" credential                     store if a Wallet is not being used.
| `regkey` | Agent registration key obtained from OMC UI.  This parameter is mandatory.
| `startup-properties` | comma separate agent start up properties for configing APM AgentStartup.properties 
| `tenant-id` | Specify the tenant id. This parameter is mandatory if the agent zip file was not obtained from the omc server.
| `trust-host` | Bypass certificate and host validation
| `v` | Log additional information about user settings




[OracleAPM Service]: https://cloud.oracle.com/en_US/application-performance-monitoring


