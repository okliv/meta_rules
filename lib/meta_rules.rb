require 'meta_rules/engine'
require 'meta_rules/hash_class_extension'

module MetaRules

  class Rule

    attr_accessor :name, :action, :get_params, :url

    def self.any
      @any ||= I18n.t('meta_rules.any', :default => 'ANY')
    end

    def self.none
      @none ||= I18n.t('meta_rules.none', :default => 'NONE')
    end

    def self.all_rules
      @all_rules ||= I18n.t('meta_rules.rules').to_a
    end

    def self.all
      all_rules.map { |rule_hash| new(rule_hash[0], rule_hash[1]) }
    end

    def self.default_substitutions
      @default_substitutions ||= I18n.t('meta_rules.substitutions')
    end

    def self.all_matched(url)
      all.select { |rule| rule.url=url; rule.actions_passed&&rule.get_params_passed }
    end

    def self.matched(url)
      all_matched(url).try(:first)
    end

    def initialize(rule_name, rule_values)
      self.name = rule_name
      self.action = rule_values[:action]
      self.get_params = rule_values[:get_params]
    end

    def path_params
      @path_params ||= Rails.application.routes.recognize_path(url) rescue {}
    end

    def url_params
      @url_params ||= CGI.parse(URI.parse(url).query.to_s)||{}
    end

    def route_params
      @route_params ||= path_params.merge(url_params)
    end

    def controller_name
      @controller_name ||= route_params[:controller]
    end

    def action_name
      @action_name ||= route_params[:action]
    end

    def controller_action
      @controller_action ||= [controller_name, action_name]*'#'
    end

    def url_get_params
      @url_get_params ||= route_params.except(:controller, :action)
    end

    def allowed_actions
      @allowed_actions ||= [*(action.try(:[], :allowed))]||[]
    end

    def restricted_actions
      @restricted_actions ||= [*(action.try(:[], :restricted))]||[]
    end

    def allowed_actions_passed
      @allowed_actions_passed ||= (allowed_actions.include?(controller_action)||allowed_actions.include?(controller_name)||allowed_actions.include?(Rule.any))&&!allowed_actions.include?(Rule.none)
    end

    def restricted_actions_passed
      @restricted_actions_passed ||= !(restricted_actions.include?(controller_action)||restricted_actions.include?(controller_name)||restricted_actions.include?(Rule.any))
    end

    def actions_passed
      @actions_passed ||= allowed_actions_passed&&restricted_actions_passed
    end

    def get_params_passed
      @get_params_passed ||= eval(true_or_false_arr*'&&')
    end

    def true_or_false_arr
      @true_or_false_arr ||= url_get_params.map do |key, value| #id: 12
        rule_hash_values = [*(get_params.try(:[], key))].compact.presence
        # rule_hash_values.try(:include?, value)||
        rule_hash_values.to_a.select{ |r| value[Regexp.new(r)].presence }.size>0||rule_hash_values.try(:include?, Rule.any)&&!rule_hash_values.try(:include?, Rule.none)
      end.compact.presence||[true]
    end

    def substitutions
      @substitutions ||= Rule.default_substitutions.merge(route_params)
    end

    def data(key, extra_snippets={})
      I18n.t("meta_rules.#{key}.#{Rule.matched(url).name}", substitutions.merge(extra_snippets))
    end

    def title(extra_snippets={})
      data('title', extra_snippets)
    end

    def keywords(extra_snippets={})
      data('keywords', extra_snippets)
    end

    def description(extra_snippets={})
      data('description', extra_snippets)
    end

    def h1(extra_snippets={})
      data('h1', extra_snippets)
    end

  end

end
