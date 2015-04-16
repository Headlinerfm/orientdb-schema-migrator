require "rake"

shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { self.class.top_level_description }
  let(:root) { Pathname.new(File.expand_path('../../../../', __FILE__)) }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == root.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [root.to_s], loaded_files_excluding_current_rake_file)
  end
end
