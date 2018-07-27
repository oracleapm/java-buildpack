# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2018 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch Oracle APM Agent support.
    class OracleapmAgent < JavaBuildpack::Component::VersionedDependencyComponent

    # Creates an instance
      #
      # @param [Hash] context a collection of utilities used the component
      def initialize(context)
        super(context)
        @version, @uri = agent_download_url if supports?
      end


      def agent_download_url
        credentials = @application.services.find_service(FILTER)['credentials']
        agentUri = credentials[AGENT_ZIP_URI]
        ['latest', agentUri]
      end

    # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        credentials = @application.services.find_service(FILTER)['credentials']
        tenantId = credentials[TENANT_ID]
        agentUri = credentials[AGENT_ZIP_URI]
        regKey   = credentials[REGKEY]
        omcUrl   = credentials[OMC_URL]
        gatewayH = credentials[GATEWAY_HOST]
        gatewayP = credentials[GATEWAY_PORT]
        # download APm agent zip file
        download_zip false
        #expect(@droplet.sandbox + "ProvisionApmJavaAsAgent.sh").to exist
        # Run apm provisioning script to install agent
        run_apm_provision_script(tenantId, regKey, omcUrl, gatewayH, gatewayP, credentials[PROXY_HOST], credentials[PROXY_PORT],
                                 credentials[CLASSIFICATIONS], credentials[PROXY_AUTH_TOKEN], credentials[ADDITIONAL_GATEWAY],
                                 credentials[V], credentials[DEBUG], credentials[INSECURE], credentials[H])

        cert = credentials[CERTIFICATE]
        # use user specified certificates
        if not_blank?(cert)
          target_directory = @droplet.sandbox
          apm_cert = "#{target_directory}/apmagent/config/apm.cer"
          shell "echo  -----BEGIN CERTIFICATE----- > #{apm_cert}"
          shell "echo  #{cert} >> #{apm_cert}"
          shell "echo  -----END CERTIFICATE----- >> #{apm_cert}"
          shell "echo oracle.apmaas.common.pathToCertificate = ./apm.cer >>  #{target_directory}/apmagent/config/AgentStartup.properties"
        end

        noCertificate = credentials[TRUST_HOST]
        if not_null?(noCertificate)
          target_directory = @droplet.sandbox
          shell "echo oracle.apmaas.common.trustRemoteSSLHost = true >>  #{target_directory}/apmagent/config/AgentStartup.properties"
          shell "echo oracle.apmaas.common.disableHostnameVerification = true >>  #{target_directory}/apmagent/config/AgentStartup.properties"
        end

        add_startup_props = credentials[STARTUP_PROPERTIES]
        if not_blank?(add_startup_props)
          target_directory = @droplet.sandbox
          for property in add_startup_props.split(',')
            shell "echo #{property} >>  #{target_directory}/apmagent/config/AgentStartup.properties"
          end
        end

        target_directory = @droplet.sandbox
        shell "unzip -x #{target_directory}/apmagent/lib/system/ApmAgentInstrumentation.jar oracle/apmaas/agent/instrumentation/Aspect.filters"
        shell "sed '/EXCLUDE/a  org.cloudfoundry.tomcat.logging.' oracle/apmaas/agent/instrumentation/Aspect.filters > Aspect.filters_temp"
        shell "cat Aspect.filters_temp > oracle/apmaas/agent/instrumentation/Aspect.filters"
        shell "zip -u #{target_directory}/apmagent/lib/system/ApmAgentInstrumentation.jar oracle/apmaas/agent/instrumentation/Aspect.filters"
        shell "rm Aspect.filters_temp"
       # shell "rm -rf oracle"


      end


      def run_apm_provision_script(tenant_id, regkey, omc_url, gateway_host, gateway_port, proxy_host, proxy_port,
                                   classifications, proxy_auth_token, additional_gateway, v, debug, insecure, hostname,
                                   target_directory = @droplet.sandbox,
                                   name = @component_name)
       shell "chmod +x #{target_directory}/ProvisionApmJavaAsAgent.sh"
       puts "component name = #{name}"
       puts "tenant_id : #{tenant_id}"
       puts "regkey : #{regkey}"
       puts "omc_url : #{omc_url}"
       puts "gateway_host : #{gateway_host}"
       puts "gateway_port : #{gateway_port}"
       puts "proxy_host : #{proxy_host}"
       puts "proxy_port : #{proxy_port}"
       puts "classifications : #{classifications}"
       puts "proxy_auth_token : #{proxy_auth_token}"
       puts "additional_gateways : #{additional_gateway}"
       puts "java_home : #{@droplet.java_home.root}"
       puts "v : #{v}"
       puts "h : #{hostname}"
       puts "debug : #{debug}"
       puts "insecure : #{insecure}"

       provision_cmd = StringIO.new
       provision_cmd << "#{target_directory}/ProvisionApmJavaAsAgent_CF.sh -regkey #{regkey} -no-wallet -d #{target_directory} -exact-hostname -no-prompt  "
       if not_blank?(tenant_id)
        provision_cmd << " -tenant-id  #{tenant_id}"
       end
       if not_blank?(omc_url)
         provision_cmd << " -omc-server-url #{omc_url}"
       end
       if not_blank?(gateway_host)
         provision_cmd << " -gateway-host #{gateway_host}"
       end
       if not_blank?(gateway_port)
         provision_cmd << " -gateway-port #{gateway_port}"
       end
       if not_blank?(proxy_host)
         provision_cmd << " -ph #{proxy_host}"
       end
       if not_blank?(proxy_port)
         provision_cmd << " -pp #{proxy_port}"
       end
       if not_blank?(classifications)
         provision_cmd << " -classifications #{classifications}"
       end
       if not_blank?(proxy_auth_token)
         provision_cmd << " -pt #{proxy_auth_token}"
       end
       if not_blank?(additional_gateway)
         provision_cmd << " -additional-gateways #{additional_gateway}"
       end
       if not_blank?(hostname)
         provision_cmd << " -h #{hostname}"
       end
       if not_null?(v)
         provision_cmd << " -v "
       end
       if not_null?(debug)
         provision_cmd << " -debug "
       end
      if not_null?(insecure)
        provision_cmd << " -insecure "
      end

       provision_cmd << "  > #{target_directory}/provisionApmAgent.log "
       puts "command : #{provision_cmd.string}"
       Dir.chdir target_directory do
       #shell "#{target_directory}/ProvisionApmJavaAsAgent.sh -regkey #{regkey} -no-wallet -ph #{proxy_host} -d #{target_directory} -exact-hostname -no-prompt -omc-server-url #{omc_url} -tenant-id  #{tenant_id} -java-home #{@droplet.java_home.root} 2>&1"
       javaBin="JAVA_BIN=#{@droplet.java_home.root}/bin/java"
       puts " java : #{javaBin}"
       shell "echo #{javaBin} > ProvisionApmJavaAsAgent_CF.sh"
       shell "sed -e 's/locate_java$/#locate_java/g' ProvisionApmJavaAsAgent.sh > ProvisionApmJavaAsAgent_tmp.sh"
       shell "sed -e 's/^_java=/_java=$JAVA_BIN/g' ProvisionApmJavaAsAgent_tmp.sh >> ProvisionApmJavaAsAgent_CF.sh"
       shell "rm ProvisionApmJavaAsAgent_tmp.sh"
       shell "chmod +x ProvisionApmJavaAsAgent_CF.sh"
       shell "#{provision_cmd.string}"
       end
     end

     def not_blank?(value)
       !value.nil? && !value.empty?
     end

     def not_null?(value)
        !value.nil?
     end

    # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        @droplet.java_opts.add_javaagent(@droplet.sandbox + 'apmagent/lib/system/ApmAgentInstrumentation.jar')
      end

       protected

           # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
            def supports?
              @application.services.one_service? FILTER, REGKEY, AGENT_ZIP_URI
            end


            FILTER = /oracleapm/

            OMC_URL             = 'omc-server-url'
            TENANT_ID           = 'tenant-id'
            REGKEY              = 'regkey'
            GATEWAY_HOST        = 'gateway-host'
            GATEWAY_PORT        = 'gateway-port'
            CLASSIFICATIONS     = 'classifications'
            PROXY_HOST          = 'ph'
            PROXY_PORT          = 'pp'
            PROXY_AUTH_TOKEN    = 'pt'
            ADDITIONAL_GATEWAY  = 'additional-gateways'
            AGENT_ZIP_URI       = 'agent-uri'
            V                   = 'v'
            DEBUG               = 'debug'
            INSECURE            = 'insecure'
            H                   = 'h'
            CERTIFICATE         = 'gateway-certificate'
            TRUST_HOST          = 'trust-host'
            STARTUP_PROPERTIES  = 'startup-properties'

            private_constant :FILTER, :OMC_URL, :TENANT_ID, :REGKEY, :GATEWAY_HOST, :GATEWAY_PORT,
            :CLASSIFICATIONS, :PROXY_HOST, :PROXY_PORT,  :PROXY_AUTH_TOKEN, :ADDITIONAL_GATEWAY,
            :AGENT_ZIP_URI, :V, :DEBUG, :INSECURE, :H, :CERTIFICATE, :TRUST_HOST, :STARTUP_PROPERTIES

    end
  end
end
