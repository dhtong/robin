module Slack
  class RefreshHome
    def initialize(customer_id:, caller_id:)
      @customer_id = customer_id
      @caller_id = caller_id
      @show_channel_cfg_presenter_clz = Presenters::Slack::ShowChannelConfig.new
    end


    def execute
      @customer = Records::Customer.includes(external_accounts: { channel_configs: [:subscribers] }).find(@customer_id)
      @client = Slack::Web::Client.new(token: @customer.slack_access_token)

      external_accounts = @customer.external_accounts
      blocks = display_recent_cases + display_integrations(external_accounts)

      if external_accounts.any?
        blocks.push(*display_channel_configs(external_accounts))
      end

      @client.views_publish(
        user_id: @caller_id,
        view: {type: 'home', blocks: blocks}
      )
    end

    private

    EMPTY_SPACE = {
      "type": "context",
      "elements": [
        {
          "type": "image",
          "image_url": "https://api.slack.com/img/blocks/bkb_template_images/placeholder.png",
          "alt_text": "placeholder"
        }
      ]
    }

    def display_recent_cases
      cases = Records::SupportCase.where(customer: @customer).includes(:instigator_message).order(created_at: :desc).limit(5)
      blocks = [
        {
          "type": "section",
          "text": {"type": "mrkdwn", "text": "*Recent cases*"},
          
        }, 
        {"type": "divider"}
      ]
      cases.each do |sc|
        blocks = blocks + display_case(sc)
      end

      blocks << EMPTY_SPACE
      blocks
    end

    def display_case(sc)
      header = "*<##{sc.channel_id}>*"
      # header = "*<#{sc.instigator_message.external_url}|##{sc.channel_id}>*" if sc.instigator_message.external_url.present?

      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": header
          }
        },
        {
          "type": "context",
          "elements": [
            {
              "type": "plain_text",
              "text": sc.instigator_message.event_payload["text"]
            }
          ]
        }
      ]
    end

    def display_integrations(external_accounts)
      blocks = [
        {
          "type": "section",
          "text": {"type": "mrkdwn", "text": "*Integrations*"},
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "Add",
              "emoji": true
            },
            "action_id": "add_integration-action",
            "value": "add_integration"
          }
        }, 
        {"type": "divider"}
      ]
      external_accounts.each do |account|
        blocks << view_integration(account.platform)
      end

      blocks << EMPTY_SPACE
      blocks
    end

    def display_channel_configs(external_accounts)
      blocks = [
        {
          "type": "section",
          "text": {"type": "mrkdwn", "text": "*Oncall channels*"},
          "accessory": {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "New",
              "emoji": true
            },
            "action_id": "new_channel_config-action",
            "value": "new_channel_config"
          }
        }, 
        {"type": "divider"}
      ]
      external_accounts.each do |account|
        account.channel_configs.each do |channel_config|
          blocks << view_channel(channel_config)
        end
      end
      blocks
    end

    def view_channel(channel_config)
      {
        "type": "section",
        "block_id": channel_config.id.to_s + "_edit_channel_config-block",
        "text": {
          "type": "mrkdwn",
          "text": @show_channel_cfg_presenter_clz.present(channel_config) # "<##{channel_config.channel_id}>"
        },
        "accessory": {
          "type": "overflow",
          "action_id": "edit_channel_config-action",
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "Delete",
                "emoji": true
              },
              "value": "delete"
            }#,
            # {
            #   "text": {
            #     "type": "plain_text",
            #     "text": "Edit",
            #     "emoji": true
            #   },
            #   "value": "edit"
            # }
          ]
        }
      }
    end


    def view_integration(integration_name)
      {
        "type": "section",
        "block_id": integration_name + "_integration-block",
        "text": {
          "type": "mrkdwn",
          "text": integration_name.capitalize
        },
        "accessory": {
          "type": "overflow",
          "action_id": "edit_integration-action",
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "Delete",
                "emoji": true
              },
              "value": "delete"
            }
          ]
        }
      }
    end
  end
end