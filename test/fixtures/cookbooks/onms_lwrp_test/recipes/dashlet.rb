# frozen_string_literal: true
include_recipe 'onms_lwrp_test::wallboard'

opennms_dashlet 'summary2' do
  wallboard 'schlazorboard'
  dashlet_name 'Summary'
  parameters 'timeslot' => '3600'
  # dashboard config get read only once unless editied via WebUI
  notifies :restart, 'service[opennms]'
end

# no parameters
opennms_dashlet 'summary3' do
  wallboard 'schlazorboard'
  dashlet_name 'Summary'
  notifies :restart, 'service[opennms]'
end
