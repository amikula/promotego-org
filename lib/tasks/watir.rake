namespace "test" do
  Rake::TestTask.new("watir") do |t|
    t.test_files = "test/watir/**/*_test.rb"
  end
end
