module Slack::Actions
  class AddIntegration

    def initialize
    end

    def execute
      @slack_client.views_open(trigger_id: @trigger_id, view: new_integration_selection)
    end

    private

    def new_integration_selection
      existing_options = @customer.external_accounts.pluck(:platform)
      available_options = INTEGRATION_OPTIONS - existing_options
      if available_options.empty?
        return Presenters::Slack::Integration.no_integrations_available
      end
      Presenters::Slack::Integration.new_integration_selection(available_options)
    end
  end
end