# Oracle APM Agent Framework
The Oracle APM Agent Framework causes an application to be automatically configured to work with a bound [Oracle APM Service][].

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

## User-Provided Service (Optional)
Users may optionally provide their own OracleAPM service. A user-provided OracleAPM service must have a name or tag with `oracleapm` in it so that the Oracle APM Agent Framework will automatically configure the application to work with the service.

The credential payload of the service may contain the following entries:

| Name | Description
| ---- | -----------
| `additional-gateways` |  (Optional) Comma separated list of gateway URLs. A valid gateway URL is in this format: https://host:port
| `agent-uri` | Downloadable APM agent installer location.  
| `classifications` | (Optional) Specify a classifications string that will be sent to the OMC server
| `gateway-host` | (Optional) The gateway host through which the APM java agent communicates with the OMC server.
| `gateway-port` | (Optional) Gateway port.
| `omc-server-url` | Specify the url of the omc server. This parameter is mandatory                                  if the agent zip file was not obtained from the omc server.                                  This parameter is expected to be in the format https://<host>:<port>.
| `ph` | (Optional) Specify your HTTP Proxy Host. If the APM Agent must use an HTTP proxy, this is the proxy's hostname.
| `pp` | (Optional) Specify your HTTP Proxy Port. If the APM Agent must use a n HTTPproxy, this is the proxy's port.
| `pt` | (Optional) Specify the HTTP Proxy Authorization Token to use. If the APM Agent must use an HTTP proxy that requires authentication, this is the *proxy* authorization token the APM Agent will use. It will be added to the APM Agent's credential store that gets provisioned here (i.e., either an Oracle "auto-login" Wallet or the "alternative" credential                     store if a Wallet is not being used.
| `regkey` | Agent registration key.  This parameter is mandatory. 
| `tenant-id` | Specify the tenant id. This parameter is mandatory if the agent zip file was not obtained from the omc server.


