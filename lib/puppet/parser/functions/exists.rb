#
# exists.rb
#
# James Fellows 8/8/12: cloned from git://gist.github.com/1160472.git then 
# modified to resolve puppet:/// paths
#
# Copyright 2011 Puppet Labs Inc.
# Copyright 2011 Krzysztof Wilczynski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Puppet::Parser::Functions
  newfunction(:exists, :type => :rvalue, :doc => <<-EOS
Returns an boolean value if a given file and/or directory exists on Puppet Master.

Prototype:

    exists(x)

Where x is a file or directory.

For example:

  Given the following statements:

    $a = '/etc/resolv.conf'
    $b = '/this/does/not/exists'

    notice exists($a)
    notice exists($b)

  The result will be as follows:

    notice: Scope(Class[main]): true
    notice: Scope(Class[main]): false

  The function will also look in the puppetmaster modules directory if the 
  file path is relative rather than absolute:

    $c = 'puppet:///modules/my_module/exists'

    notice exists ($c)
 
  The result will be as follows, IF the file 'modules/my_module/files/exists' 
  exists

    notice: Scope(Class[main]): true

  An error will be thrown if the a module by that name doesn't exist.

  Note:

    This function will ONLY be evaluated on the Puppet Master side and it
    makes no sense to use it when checking whether a file and/or directory
    exists on the client side.
    EOS
  ) do |arguments|

    #
    # This is to ensure that whenever we call this function from within
    # the Puppet manifest or alternatively from a template it will always
    # do the right thing ...
    #
    arguments = arguments.shift if arguments.first.is_a?(Array)

    raise Puppet::ParseError, "exists(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)" if arguments.size < 1

    file = arguments.shift
    raise Puppet::ParseError, 'exists(): Requires a string type ' +
      'to work with' unless file.is_a?(String)

    if file.slice!('puppet:///')
    # Perform relative lookup in modules/files dir.
        # strip off the modules prefix too if it's there
        file.slice!('modules/')
        env = compiler.environment.to_s
        mod_name, file = file.split(File::SEPARATOR, 2)
        mod = Puppet::Module.find(mod_name, env)
        raise Puppet::Error, "exists(): invalid module name #{mod_name}" unless mod
        path = mod.path
        file = File.join(path, "files", file)
    else
        file = File.expand_path(file)
    end

    result = File.exists?(file)

  end

end

# vim: set ts=2 sw=2 et :
