# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2017 the original author or authors.
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

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/framework/oracleapm_agent'
require 'java_buildpack/util/tokenized_version'

describe JavaBuildpack::Framework::OracleapmAgent do
  include_context 'with component help'


    it 'does not detect without oracleapm agent service' do
       expect(component.detect).to be_nil
     end

   context do

     before do
       allow(services).to receive(:find_service).and_return('credentials' => { 'regkey'         => 'test-regkey',
                                                                               'omc-server-url' => 'test-omc-server-url',
                                                                               'tenant-id'      => 'test-tenant-id' })
     end

     it 'downloads OracleAPM agent JAR',
        cache_fixture: 'stub-oracleapm-agent.jar' do
        component.compile
     end

     it 'updates JAVA_OPTS' do
       component.release
       expect(java_opts).to include("-javaagent:$PWD/.java-buildpack/oracleapm_agent/apmagent/lib/system/ApmAgentInstrumentation.jar")
     end

   end

 end
