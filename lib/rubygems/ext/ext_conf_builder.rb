# frozen_string_literal: true
#--
# Copyright 2006 by Chad Fowler, Rich Kilmer, Jim Weirich and others.
# All rights reserved.
# See LICENSE.txt for permissions.
#++

class Gem::Ext::ExtConfBuilder < Gem::Ext::Builder
  def self.build(extension, dest_path, results, args=[], lib_dir=nil, extension_dir=Dir.pwd)
    require "fileutils"
    require "pathname"

    destdir = ENV["DESTDIR"]

    begin
      require "shellwords"
      cmd = Gem.ruby.shellsplit << "-I" << File.expand_path("../..", __dir__) << File.basename(extension)
      cmd.push(*args)

      run(cmd, results, class_name, extension_dir) do |s, r|
        mkmf_log = File.join(extension_dir, "mkmf.log")
        if File.exist? mkmf_log
          unless s.success?
            r << "To see why this extension failed to compile, please check" \
              " the mkmf.log which can be found here:\n"
            r << "  " + File.join(dest_path, "mkmf.log") + "\n"
          end
          FileUtils.mv mkmf_log, dest_path
        end
      end

      ENV["DESTDIR"] = nil

      rel_dest_path = Pathname.new(dest_path).relative_path_from(Pathname.new(extension_dir))
      make rel_dest_path, results, extension_dir

      # TODO remove in RubyGems 4
      if Gem.install_extension_in_lib && lib_dir
        FileUtils.mkdir_p lib_dir
        entries = Dir.entries(dest_path) - %w[. ..]
        entries = entries.map {|entry| File.join dest_path, entry }
        FileUtils.cp_r entries, lib_dir, :remove_destination => true
      end

      make dest_path, results, extension_dir, ["clean"]
    ensure
      ENV["DESTDIR"] = destdir
    end

    results
  end
end
