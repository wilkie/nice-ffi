#--
#
# This file is one part of:
#
# Nice-FFI - Convenience layer atop Ruby-FFI
#
# Copyright (c) 2009 John Croisant
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#++


require 'rake'


#############
##   GEM   ##
#############

require 'rubygems/package_task'

# Load nice-ffi.gemspec, which defines $gemspec.
load File.join( File.dirname(__FILE__), "nice-ffi.gemspec" )

Gem::PackageTask.new( $gemspec ) do |pkg|
  pkg.need_tar_bz2 = true
end

###############
##  VERSION  ##
###############

task :version do
  puts "%s-%s"%[$gemspec.name, $gemspec.version.to_s]
end

rule( /bump:[0-9.]+/ ) do |t|
  ver = t.name.gsub("bump:","")
  today = Date.today.to_s

  puts "Updating version to #{ver} and date to #{today}..."

  print "  README.rdoc... "
  `ruby -pi -e '
     $_.gsub!(/\([Vv]ersion:: +\)[0-9.]+/,   "\\\\1#{ver}")
     $_.gsub!(/\([Dd]ate:: +\)[0-9-]+/,      "\\\\1#{today}")
   ' README.rdoc`
  puts "done"

  print "  nice-ffi.gemspec... "
  `ruby -pi -e '
     $_.gsub!(/\(s.version *= *\)"[0-9.]+"/, "\\\\1\\"#{ver}\\"")
   ' nice-ffi.gemspec`
  puts "done"
end

#############
##  CLEAN  ##
#############

require 'rake/clean'

############
##  DOCS  ##
############

require 'rdoc/task'

Rake::RDocTask.new do |rd|
  rd.title = "Nice-FFI #{$gemspec.version} Docs"
  rd.main = "README.rdoc"
  rd.rdoc_files.include( "lib/**/*.rb", "docs/*.rdoc", "*.rdoc" )
end

#########
# SPECS #
#########

begin
  require 'rspec/core/rake_task'

  desc "Run all specs"
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'spec/*_spec.rb'
  end

  namespace :spec do
    desc "Run all specs"
    RSpec::Core::RakeTask.new(:all) do |t|
      t.pattern = 'spec/*_spec.rb'
    end

    desc "Run spec/[name]_spec.rb (e.g. 'color')"
    task :name do
      puts( "This is just a stand-in spec.",
            "Run rake spec:[name] where [name] is e.g. 'color', 'music'." )
    end
  end

  rule(/spec:.+/) do |t|
    name = t.name.gsub("spec:","")

    path = File.join( File.dirname(__FILE__),'spec','%s_spec.rb'%name )

    if File.exist? path
      RSpec::Core::RakeTask.new(name) do |t|
        t.pattern = path
      end

      puts "\nRunning spec/%s_spec.rb"%name

      Rake::Task[name].invoke
    else
      puts "File does not exist: %s"%path
    end
  end

rescue LoadError
  error = "ERROR: RSpec is not installed?"

  task :spec do
    puts error
  end

  rule( /spec:.*/ ) do
    puts error
  end
end
