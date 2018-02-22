# frozen_string_literal: true
require 'rexml/document'
class Expression < Inspec.resource(1)
  name 'expression'

  desc '
    OpenNMS expression
  '

  example '
    expr = {
      \'expression\' => \'icmp / 1000\',
      \'group\' => \'cheftest\',
      \'type\' => \'high\',
      \'ds_type\' => \'if\',
      \'filter_operator\' => \'and\',
      \'resource_filters\' => [{ \'field\' => \'ifHighSpeed\', \'filter\' => \'^[1-9]+[0-9]*$\' }],
    }
    describe expression(expr) do
      it { should exist }
      its(\'relaxed\') { should be false }
      its(\'description\') { should eq \'ping latency too high expression\' }
      its(\'value\') { should eq 20.0 }
      its(\'rearm\') { should eq 18.0 }
      its(\'trigger\') { should eq 3 }
      its(\'triggered_uei\') { should eq \'uei.opennms.org/thresholdTest/testThresholdExceeded\' }
      its(\'rearmed_uei\') { should eq \'uei.opennms.org/thresholdTest/testThresholdRearmed\' }
    end
  '

  def initialize(expr)
    @group = expr['group']
    @expression = expr['expression']
    @ds_type = expr['ds_type']
    @type = expr['type']
    @filter_operator = expr['filter_operator']
    @resource_filters = expr['resource_filters']
    doc = REXML::Document.new(inspec.file('/opt/opennms/etc/thresholds.xml').content)
    ex_el = expression_el(doc) unless doc.nil?
    @exists = !ex_el.nil?
    if @exists
      @params = {}
      @params[:relaxed] = false
      @params[:relaxed] = true if ex_el.attributes['relaxed'] == 'true'
      @params[:description] = ex_el.attributes['description'] unless ex_el.attributes['description'].nil?
      @params[:value] = ex_el.attributes['value'].to_f unless ex_el.attributes['value'].nil?
      @params[:rearm] = ex_el.attributes['rearm'].to_f unless ex_el.attributes['rearm'].nil?
      @params[:trigger] = ex_el.attributes['trigger'].to_i unless ex_el.attributes['trigger'].nil?
      @params[:ds_label] = ex_el.attributes['ds-label'] unless ex_el.attributes['ds-label'].nil?
      @params[:triggered_uei] = ex_el.attributes['triggeredUEI'] unless ex_el.attributes['triggeredUEI'].nil?
      @params[:rearmed_uei] = ex_el.attributes['rearmedUEI'] unless ex_el.attributes['rearmedUEI'].nil?
    end
  end

  def exist?
    @exists
  end

  def method_missing(name)
    @params[name]
  end

  private

  def expression_el(doc)
    attrs = "/thresholding-config/group[@name = '#{@group}']/expression[@expression = '#{@expression}' and @ds-type = '#{@ds_type}' and @type = '#{@type}'"
    attrs = "#{attrs} and @filterOperator = '#{@filter_operator}'" unless @filter_operator.nil? || @filter_operator == 'or'
    if @resource_filters.nil? || @resource_filters == []
      attrs = "#{attrs} and not(resource-filter)"
    else
      @resource_filters.each do |rf|
        attrs = "#{attrs} and resource-filter/@field = '#{rf['field']}' and resource-filter/text() = '#{rf['filter']}'"
      end
    end
    attrs = "#{attrs}]"
    doc.elements[attrs]
  end
end
