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


# PathSet is essentially a Hash of { os_regex => path_templates } pairs,
# paths describing where to look for files (libraries) on each
# operating system.
# 
# * os_regex is a regular expression that matches FFI::Platform::OS
#   for the operating system(s) that the path templates are for.
# 
# * path_templates is an Array of one or more strings describing
#   a template for where a library might be found on this OS.
#   The string [NAME] will be replaced with the library name.
#   So "/usr/lib/lib[NAME].so" becomes e.g. "/usr/lib/libSDL_ttf.so".
# 
# You can use #append!, #prepend!, #replace!, #remove!, and #clear!
# to modify the paths, and #find to look for a file with a matching
# name.
# 
class NiceFFI::PathSet


  def initialize( paths={}, files={} )
    @paths = paths
    @files = files
  end
  
  attr_reader :paths, :files

  def dup
    self.class.new( @paths.dup, @files.dup )
  end


  # Append the new paths to this PathSet. If this PathSet already
  # has paths for a regex in the new paths, the new paths will be
  # added after the current paths.
  # 
  # The given paths can be Hashes or existing PathSets; or
  # Arrays to append the given paths to every existing regex.
  # 
  # 
  # Example:
  # 
  #   ps = PathSet.new( /a/ => ["liba"],
  #                     /b/ => ["libb"] )
  #   
  #   ps.append!( /a/ => ["newliba"],
  #               /c/ => ["libc"] )
  #   
  #   ps.paths
  #   # => { /a/ => ["liba",
  #   #              "newliba"],        # added in back
  #   #      /b/ => ["libb"],           # not affected
  #   #      /c/ => ["libc"] }          # added
  # 
  def append!( *pathsets )
    pathsets.each do |pathset|
      _modify( pathset ) { |a,b|  a + b }
    end
    self
  end

  # Like #append!, but returns a copy instead of modifying the original.
  def append( *pathsets )
    self.dup.append!( *pathsets )
  end

  alias :+  :append


  # Like append!, but only affects @paths.
  def append_paths!( *paths )
    _modify_part( :paths, paths ) { |a,b|  a + b }
    self
  end

  # Like #append_paths!, but returns a copy instead of modifying the
  # original.
  def append_paths( *paths )
    self.dup.append_paths!( *paths )
  end


  # Like append!, but only affects @files.
  def append_files!( *files )
    _modify_part( :files, files ) { |a,b|  a + b }
    self
  end

  # Like #append_files!, but returns a copy instead of modifying the
  # original.
  def append_files( *files )
    self.dup.append_files!( *files )
  end



  # Prepend the new paths to this PathSet. If this PathSet already
  # has paths for a regex in the new paths, the new paths will be
  # added before the current paths.
  # 
  # The given paths can be Hashes or existing PathSets; or
  # Arrays to prepend the given paths to every existing regex.
  # 
  # 
  # Example:
  # 
  #   ps = PathSet.new( /a/ => ["liba"],
  #                     /b/ => ["libb"] )
  #   
  #   ps.prepend!( /a/ => ["newliba"],
  #                /c/ => ["libc"] )
  #   
  #   ps.paths
  #   # => { /a/ => ["newliba",         # added in front
  #   #              "liba"],
  #   #      /b/ => ["libb"],           # not affected                
  #   #      /c/ => ["libc"] }          # added
  # 
  def prepend!( *pathsets )
    pathsets.each do |pathset|
      _modify( pathset ) { |a,b|  b + a }
    end
    self
  end

  # Like #prepend!, but returns a copy instead of modifying the original.
  def prepend( *pathsets )
    self.dup.prepend!( *pathsets )
  end


  # Like prepend!, but only affects @paths.
  def prepend_paths!( *paths )
    _modify_part( :paths, paths ) { |a,b|  b + a }
    self
  end

  # Like #prepend_paths!, but returns a copy instead of modifying the
  # original.
  def prepend_paths( *paths )
    self.dup.prepend_paths!( *paths )
  end


  # Like prepend!, but only affects @files.
  def prepend_files!( *files )
    _modify_part( :files, files ) { |a,b|  b + a }
    self
  end

  # Like #prepend_files!, but returns a copy instead of modifying the
  # original.
  def prepend_files( *files )
    self.dup.prepend_files!( *files )
  end



  # Override existing paths with the new paths to this PathSet.
  # If this PathSet already has paths for a regex in the new paths,
  # the old paths will be discarded and the new paths used instead.
  # Old paths are kept if their regex doesn't appear in the new paths.
  # 
  # The given paths can be Hashes or existing PathSets; or
  # Arrays to replace the given paths for every existing regex.
  # 
  # 
  # Example:
  # 
  #   ps = PathSet.new( /a/ => ["liba"],
  #                     /b/ => ["libb"] )
  #   
  #   ps.replace!( /a/ => ["newliba"],
  #                /c/ => ["libc"] )
  #   
  #   ps.paths
  #   # => { /a/ => ["newliba"],        # replaced
  #   #      /b/ => ["libb"],           # not affected
  #   #      /c/ => ["libc"] }          # added
  # 
  def replace!( *pathsets )
    pathsets.each do |pathset|
      _modify( pathset ) { |a,b|  b }
    end
    self
  end

  # Like #replace!, but returns a copy instead of modifying the original.
  def replace( *pathsets )
    self.dup.replace!( *pathsets )
  end


  # Like replace!, but only affects @paths.
  def replace_paths!( *paths )
    _modify_part( :paths, paths ) { |a,b|  b }
    self
  end

  # Like #replace_paths!, but returns a copy instead of modifying the
  # original.
  def replace_paths( *paths )
    self.dup.replace_paths!( *paths )
  end


  # Like replace!, but only affects @files.
  def replace_files!( *files )
    _modify_part( :files, files ) { |a,b|  b }
    self
  end

  # Like #replace_files!, but returns a copy instead of modifying the
  # original.
  def replace_files( *files )
    self.dup.replace_files!( *files )
  end



  # Remove the given paths from the PathSet, if it has them.
  # This only removes the paths that are given, other paths
  # for the same regex are kept.
  # 
  # The given paths can be Hashes or existing PathSets; or
  # Arrays to remove the given paths from every existing regex.
  # 
  # Regexes with no paths left are pruned.
  # 
  # 
  # Example:
  # 
  #   ps = PathSet.new( /a/ => ["liba", "badliba"],
  #                     /b/ => ["libb"] )
  #   
  #   ps.remove!( /a/ => ["badliba"],
  #               /b/ => ["libb"] )
  #               /c/ => ["libc"] )
  #   
  #   ps.paths
  #   # => { /a/ => ["liba"] }          # removed only "badliba".
  #   #    # /b/ paths were all removed.
  #   #    # /c/ not affected because it had no old paths anyway.
  # 
  def remove!( *pathsets )
    pathsets.each do |pathset|
      _modify( pathset ) { |a,b|  a - b }
    end
    self
  end

  # Like #remove!, but returns a copy instead of modifying the original.
  def remove( *pathsets )
    self.dup.remove!( *pathsets )
  end

  alias :- :remove


  # Like remove!, but only affects @paths.
  def remove_paths!( *paths )
    _modify_part( :paths, paths ) { |a,b|  a - b }
    self
  end

  # Like #remove_paths!, but returns a copy instead of modifying the
  # original.
  def remove_paths( *paths )
    self.dup.remove_paths!( *paths )
  end


  # Like remove!, but only affects @files.
  def remove_files!( *files )
    _modify_part( :files, files ) { |a,b|  a - b }
    self
  end

  # Like #remove_files!, but returns a copy instead of modifying the
  # original.
  def remove_files( *files )
    self.dup.remove_files!( *files )
  end



  # Remove all paths and files for the given regex(es). Has no effect
  # on regexes that are not given.
  # 
  # 
  # Example:
  # 
  #   ps = PathSet.new( /a/ => ["liba"],
  #                     /b/ => ["libb"] )
  #   
  #   ps.delete!( /b/, /c/ )
  #   
  #   ps.paths
  #   # => { /a/  => ["liba"] }  # not affected
  #   #    # /b/ and all paths removed.
  #   #    # /c/ not affected because it had no paths anyway.
  # 
  def delete!( *regexs )
    @paths.delete_if { |regex, paths|  regexs.include? regex }
    @files.delete_if { |regex, files|  regexs.include? regex }
    self
  end

  # Like #delete!, but returns a copy instead of modifying the original.
  def delete( *regexs )
    self.dup.delete!( *regexs )
  end


  # Like delete!, but only affects @paths
  def delete_paths!( *regexs )
    @paths.delete_if { |regex, paths|  regexs.include? regex }
    self
  end

  # Like #delete_paths!, but returns a copy instead of modifying the original.
  def delete_paths( *regexs )
    self.dup.delete_paths!( *regexs )
  end


  # Like delete!, but only affects @files
  def delete_files!( *regexs )
    @files.delete_if { |regex, files|  regexs.include? regex }
    self
  end

  # Like #delete_files!, but returns a copy instead of modifying the original.
  def delete_files( *regexs )
    self.dup.delete_files!( *regexs )
  end


  # Try to find a file based on the paths in this PathSet.
  # 
  # *names:: Strings to try substituting for [NAME] in the paths.
  # 
  # Returns an Array of the paths of matching files, or [] if
  # there were no matches.
  # 
  # Raises LoadError if the current operating system did not match
  # any of the regular expressions in the PathSet.
  # 
  # Examples:
  # 
  #   ps = PathSet.new( /linux/ => ["/usr/lib/lib[NAME].so"],
  #                     /win32/ => ["C:\\windows\\system32\\[NAME].dll"] )
  #   
  #   ps.find( "SDL" )
  #   ps.find( "foo", "foo_alt_name" )
  # 
  def find( *names )
    os = FFI::Platform::OS

    # Fetch the paths and files for the matching OSes.
    paths = @paths.collect{ |regex,ps| regex =~ os ? ps : [] }.flatten
    files = @files.collect{ |regex,fs| regex =~ os ? fs : [] }.flatten

    # Drat, they are using an OS with no matches.
    if paths.empty? and files.empty?
      raise( LoadError, "Your OS (#{os}) is not supported yet.\n" +
             "Please report this and help us support more platforms." )
    end

    results = paths.collect do |path|
      files.collect do |file|
        names.collect do |name|
          # Concat path and file, fill in for [NAME], and expand.
          File.expand_path( (path+file).gsub("[NAME]", name) )
        end
      end
    end

    return results.flatten.select{ |r| File.exist? r }
  end


  private


  def _modify( other, &block )  # :nodoc:
    if other.kind_of? self.class
      # Other is a PathSet, so apply both its paths and its files to ours.
      _modify_set( @paths, other.paths, &block )
      _modify_set( @files, other.files, &block )
    else
      # Not a PathSet, so apply other to our paths.
      _modify_set( @paths, other, &block )
    end
  end

  # This method does the work for #append_paths, #append_files,
  # #prepend_paths, etc.
  # 
  # * part is either :paths or :files. It indicates whether @paths or
  #   @files should be modified, and whether to get values from
  #   other.paths or other.files when other is a PathSet.
  # 
  # * others is an array which may contain one or more PathSets,
  #   Hashes, Arrays, Regexps, or Strings, or a mixture of those
  #   types. Each item is passed to #_modify_set. PathSets are changed
  #   into either other.paths or other.files first, though.
  #
  def _modify_part( part, others, &block ) # :nodoc:
    unless [:paths, :files].include? part
      raise( ArgumentError, "Invalid PathSet part #{part.inspect} " +
             "(expected :paths or :files)" )
    end

    ours = self.send(part)      # self.paths or self.files
    others.each do |other|
      if other.kind_of? self.class
        other = other.send(part)
      end
      _modify_set( ours, other, &block )
    end
  end


  def _modify_set( ours, other, &block )  # :nodoc:
    raise "No block given!" unless block_given?

    case other
    when Hash
      # Apply each of the regexs in `other` to the same regex in `ours`
      other.each do |regex, paths|
        _apply_modifier( ours, regex, (ours[regex] or []), paths, &block )
      end
    when Array
      # Apply `other` to each of the regexs in `ours`
      ours.each { |regex, paths|
        _apply_modifier( ours, regex, paths, other, &block )
      }
    when Regexp, String
      # Apply an Array holding `other` to each of the regexs in `ours`
      ours.each { |regex, paths|
        _apply_modifier( ours, regex, paths, [other], &block )
      }
    end
  end


  def _apply_modifier( ours, regex, a, b, &block ) # :nodoc:
    raise "No block given!" unless block_given?

    result = yield( a, b )

    if result == []
      ours.delete( regex )
    else
      ours[regex] = result
    end
  end

end
