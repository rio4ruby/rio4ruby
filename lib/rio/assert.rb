#--
# ===========================================================================
# Copyright (c) 2005-2017 Christopher Kleckner
# All rights reserved
#
# This file is part of the Rio library for ruby.
#
# Rio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Rio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rio; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# =========================================================================== 
#++
#


#!/usr/bin/env ruby

require 'rio/kernel'
module RIO
  module Assert #:nodoc: all
    def ok(a,b,msg=nil)
      puts "PASS" + (msg.nil? ? "" : ": #{msg}")
    end
    def nok(a,b,msg=nil)
      calla = caller.grep(/^#{Regexp.escape($0)}/)
      calls = calla.join("\n") + "\n"
      puts "FAIL" + (msg.nil? ? "" : ": #{msg}") + calls
      puts "   exp: #{a.inspect}"
      puts "   was: #{b.inspect}"
    end
    
    def assert(a,msg=nil)
      assert_equal(true,a,msg)
    end
    def assert_raise(exc,msg=nil,&block)
      begin
        yield
      rescue exc
        return ok(exc,nil,msg)
      end
      return nok(exc,nil,msg)
    end
    
    def assert_equal(a,b,msg=nil)
      if a == b
        ok(a,b,msg)
      else
        nok(a,b,msg)
      end
    end
    def assert_case_equal(a,b,msg=nil)
      if a == b
        ok(a,b,msg)
      else
        nok(a,b,msg)
      end
    end
    def assert_block(msg=nil)
      if yield
        ok(nil,nil,msg)
      else
        nok(nil,nil,msg)
      end
    end
    
    def assert_not_equal(a,b,msg=nil)
      if a != b
        ok(a,b,msg)
      else
        nok(a,b,msg)
      end
    end
    def assert_nil(a,msg=nil)
      if a.nil?
        ok(nil,a)
      else
        nok(nil,a)
      end
    end
    def assert_not_nil(a,msg=nil)
      if a.nil?
        nok(nil,a,msg)
      else
        ok(nil,a,msg)
      end
    end
    def assert_same(a,b,msg=nil)
      if a.equal? b
        ok(a,b)
      else
        nok(a,b)
      end
    end
    def assert_instance_of(a,b,msg=nil)
      if b.instance_of?(a)
        ok(a,b)
      else
        nok(a,b)
      end
    end
    def assert_match(a,b,msg=nil)
      if a =~ b
        ok(a,b)
      else
        nok(a,b)
      end
    end
    def assert_kind_of(a,b,msg=nil)
      if b.kind_of?(a)
        ok(a,b.class)
      else
        nok(a,b.class)
      end
    end

    def assert_equal_s(a,b,msg=nil) assert_equal(a.to_s,b.to_s,msg) end
    def assert_equal_a(a,b,msg=nil) assert_equal(a.sort,b.sort,msg) end

    def assert!(a,msg="negative assertion")
      assert((!(a)),msg)
    end

    def smap(a) a.map { |el| el.to_s } end

    def assert_array_equal(a,b,msg="array same regardless of order")
      if a.nil?
        assert_nil(b)
      elsif b.nil?
        assert_nil(a)
      else
        assert_equal(smap(a).sort,smap(b).sort,msg)
      end
    end
    def assert_dirs_equal(exp,d,msg="")
      exp.each do |ent|
        ds = rio(d,ent.filename)
        assert_equal(ent.symlink?,ds.symlink?,"both symlinks, or not")
        unless ent.symlink?
          assert(ds.exist?,"entry '#{ds}' exists")
        end
        assert_equal(ent.ftype,ds.ftype,"same ftype")
        assert_rios_equal(ent,ds,"sub rios are the same")
      end
    end
    def assert_rios_equal(exp,ans,msg="")
      case
      when exp.symlink?
        assert(ans.symlink?,"entry is a symlink")
        assert_equal(exp.readlink,ans.readlink,"symlinks read the same")
      when exp.file?
        assert(ans.file?,"entry is a file")
        assert_equal(exp.chomp.lines[],ans.chomp.lines[],"file has same contents")
      when exp.dir?
        assert(ans.dir?,"entry is a dir")
        assert_dirs_equal(exp,ans,"directories are the same")
      end
    end

  end
end
