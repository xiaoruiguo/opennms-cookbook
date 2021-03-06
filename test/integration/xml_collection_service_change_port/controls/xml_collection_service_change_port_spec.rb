# frozen_string_literal: true
control 'xml_collection_service_change_port' do
  describe xml_collection_service('XMLFoo', 'foo', 'foo') do
    its('interval') { should eq 400_000 }
    its('user_defined') { should eq true }
    its('status') { should eq 'off' }
    its('collection_timeout') { should eq 5000 }
    its('retry_count') { should eq 10 }
    its('port') { should eq 12 }
    its('thresholding_enabled') { should eq true }
  end
end
