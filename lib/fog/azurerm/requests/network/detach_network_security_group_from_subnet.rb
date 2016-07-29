module Fog
  module Network
    class AzureRM
      # Real class for Network Request
      class Real
        def detach_network_security_group_from_subnet(resource_group, subnet_name, virtual_network_name, address_prefix, route_table_id)
          Fog::Logger.debug "Detaching Network Security Group from Subnet: #{subnet_name}."

          subnet = define_subnet_object_for_detach_network_security_group(address_prefix, route_table_id)
          begin
            promise = @network_client.subnets.create_or_update(resource_group, virtual_network_name, subnet_name, subnet)
            result = promise.value!
            Fog::Logger.debug 'Network Security Group detached successfully.'
            Azure::ARM::Network::Models::Subnet.serialize_object(result.body)
          rescue  MsRestAzure::AzureOperationError => e
            msg = "Exception detaching Network Security Group from Subnet: #{subnet_name}. #{e.body['error']['message']}"
            raise msg
          end
        end

        private

        def define_subnet_object_for_detach_network_security_group(address_prefix, route_table_id)
          subnet = Azure::ARM::Network::Models::Subnet.new
          subnet_properties = Azure::ARM::Network::Models::SubnetPropertiesFormat.new
          route_table = Azure::ARM::Network::Models::RouteTable.new

          route_table.id = route_table_id
          subnet_properties.address_prefix = address_prefix
          subnet_properties.route_table = route_table unless route_table_id.nil?
          subnet_properties.network_security_group = nil
          subnet.properties = subnet_properties
          subnet
        end
      end

      # Mock class for Network Request
      class Mock
        def detach_network_security_group_from_subnet(*)
          {
            'id' => '/subscriptions/########-####-####-####-############/resourceGroups/fog-rg/providers/Microsoft.Network/virtualNetworks/fog-vnet/subnets/fog-subnet',
            'properties' =>
              {
                'addressPrefix' => '10.1.0.0/24',
                'provisioningState' => 'Succeeded'
              },
            'name' => 'fog-subnet'
          }
        end
      end
    end
  end
end
