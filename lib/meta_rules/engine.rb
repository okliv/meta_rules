module MetaRules
  class Engine < ::Rails::Engine
    # isolate_namespace MetaRules
    initializer 'meta_rules.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper MetaRules::ApplicationHelper
      end
    end
  end
end
