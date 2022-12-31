class Slack::InteractionsController < ApplicationController
  def create
    payload = JSON.parse(params[:payload])
    # only handle the first action and throw away the rest

    p "========================"
    p payload
    p "++++++++++++++++++++++++"

    trigger_id = payload["trigger_id"]


    @slack_client = Slack::Web::Client.new
    @slack_client.views_open(trigger_id: trigger_id, view: view)
    head :ok
  end

  private

  def view
    {
      "title": {
        "type": "plain_text",
        "text": "Modal Title"
      },
      "submit": {
        "type": "plain_text",
        "text": "Submit"
      },
      "blocks": [
        {
          "type": "input",
          "element": {
            "type": "plain_text_input",
            "action_id": "title",
            "placeholder": {
              "type": "plain_text",
              "text": "What do you want to ask of the world?"
            }
          },
          "label": {
            "type": "plain_text",
            "text": "Title"
          }
        }
      ],
      "type": "modal"
    }
  end
end
