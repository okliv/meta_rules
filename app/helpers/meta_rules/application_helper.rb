module MetaRules
  module ApplicationHelper

    def meta_rule
      @meta_rule ||= MetaRules::Rule.matched(request.fullpath)
    end

    def meta_rule_substitutions
      meta_rule.try(:substitutions)||MetaRules::Rule.default_substitutions
    end

    %w(title keywords description h1).each do |method|
      define_method "meta_#{method}".to_sym do |extra_snippets={}|
        meta_rule.try(method.to_sym, extras.merge(extra_snippets))
      end
    end

    def meta_rule_name
      meta_rule.try(:name)
    end

    def image_tag(source, options={})
      options = options.try(:symbolize_keys)||{}

      src = options[:src] = path_to_image(source)

      unless src =~ /^(?:cid|data):/ || src.blank?
        options[:alt] = options.fetch(:alt){ image_alt(src) }
      end

      ### >>> custom
      css_classes = options[:class].try(:split, /\s+/)

      attr_hash = Hash[options.map{|key,val| [key.to_s.split('meta-')[1], val] }].except(nil).symbolize_keys
      img_alt, img_title = [], []
      css_classes.try(:map) do |css_class|
        img_alt << I18n.t("meta_rules.image_alt.#{css_class}", (meta_rule_substitutions.merge(extras)).merge(attr_hash)).presence
        img_title << I18n.t("meta_rules.image_title.#{css_class}", (meta_rule_substitutions.merge(extras)).merge(attr_hash)).presence
      end

      img_alt = img_alt.compact
      img_title = img_title.compact

      options[:alt] = img_alt.join(' ') if img_alt.size>0
      options[:title] = img_title.join(' ') if img_title.size>0
      ### <<<

      options[:width], options[:height] = extract_dimensions(options.delete(:size)) if options[:size]
      tag('img', options)
    end

    private

    def extras
      respond_to?(:meta_rules_extras) ? meta_rules_extras : {} # Hash[self.module.public_methods.map{|name| meta_rules_method = name.split('meta_rules')[1]; [meta_rules_method, send(meta_rules_method)] if meta_rules_method.presence }.compact]
    end

  end
end
