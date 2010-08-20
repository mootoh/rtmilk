require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'hoe'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'rtmilk', 'version')

AUTHOR = "takayama"  # can also be an array of Authors
EMAIL = "mootoh@gmail.com"
DESCRIPTION = 'a "Remember the Milk" wrapper library.'
GEM_NAME = "rtmilk" # what ppl will type to install your gem
RUBYFORGE_PROJECT = "rtmilk" # The unix name for your project
HOMEPATH = "http://rtmilk.rubyforge.org"


NAME = "rtmilk"
REV = nil # UNCOMMENT IF REQUIRED: File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ENV['VERSION'] || (Rtmilk::VERSION::STRING + (REV ? ".#{REV}" : ""))
                          CLEAN.include ['**/.*.sw?', '*.gem', '.config']
RDOC_OPTS = ['--quiet', '--title', "rtmilk documentation",
    "--exclude", "test",
    "--exclude", "pkg",
    "--exclude", "setup.rb",
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README.txt",
    "-diagram",
    "--inline-source"]

class Hoe
  def extra_deps 
    @extra_deps.reject { |x| Array(x).first == 'hoe' } 
  end 
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERS) do |p|
  p.author = AUTHOR 
  p.description = DESCRIPTION
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/*_test.rb"]
  p.clean_globs = CLEAN  #An array of file patterns to delete on clean.
  
  # == Optional
  #p.changes        - A description of the release's latest changes.
  #p.extra_deps     - An array of rubygem dependencies.
  #p.spec_extras    - A hash of extra values to set in the gemspec.
end

Rake::RDocTask.new do |rdoc|
   rdoc.rdoc_dir = 'html'
   rdoc.options += RDOC_OPTS
   rdoc.template = "#{ENV['template']}.rb" if ENV['template']
   if ENV['DOC_FILES']
      rdoc.rdoc_files.include(ENV['DOC_FILES'].split(/,\s*/))
   else
      rdoc.rdoc_files.include('README.txt', 'CHANGELOG.txt')
      rdoc.rdoc_files.include('lib/**/*.rb')
   end
end

desc "Publish to RubyForge"
task :rubyforge => [:rdoc, :package] do
   Rake::RubyForgePublisher.new(RUBYFORGE_PROJECT, 'takayama').upload
end

