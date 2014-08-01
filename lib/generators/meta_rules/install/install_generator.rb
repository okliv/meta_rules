module MetaRules
  class InstallGenerator < Rails::Generators::Base

    def self.source_paths
      paths = []
      paths << File.expand_path('../templates', "../../#{__FILE__}")
      paths << File.expand_path('../templates', "../#{__FILE__}")
      paths << File.expand_path('../templates', __FILE__)
      paths.flatten
    end

    def add_files
      template 'meta_rules.en.yml', 'config/locales/meta_rules.en.yml'
    end

  end
end
