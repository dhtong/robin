module Domain
  class ChannelConfigView < Dry::Struct

  end
end

builder/request <-> response 

payload 1. view 2 actions

block -> action -> common


state {
  blocks {
    actions 
  }
}


new_blocks 


Domain::Block.new(hash, block_id)
BlockAction.new(hash, action_id)



Form -> section -> field


class action
  def initialize(state, action_h)

  def handle
  end
end