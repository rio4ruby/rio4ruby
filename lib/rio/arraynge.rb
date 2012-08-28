#--
# ===========================================================================
# Copyright (c) 2005,2006,2007,2008,2009,2010 Christopher Kleckner
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
#
# ==== Rio - Ruby I/O Facilitator
#
# Rio is a facade for most of the standard ruby classes that deal with
# I/O; providing a simple, intuitive, succinct interface to the
# functionality provided by IO, File, Dir, Pathname, FileUtils,
# Tempfile, StringIO, OpenURI and others. Rio also provides an
# application level interface which allows many common I/O idioms to be
# expressed succinctly.
#
# ===== Suggested Reading
#
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#
# Project::       http://rubyforge.org/projects/rio/
# Documentation:: http://rio4ruby.com/
# Bugs::          http://rubyforge.org/tracker/?group_id=821
# Blog::          http://rio4ruby.blogspot.com/
# Email::         rio4ruby@rubyforge.org
#

#Arraynge
module RIO
  class Arraynge
    def self.ml_to_ranges(rl)
      rl.map{|el| (Range === el) ? el : (el..el)}
    end

    def self.ml_to_singles(rl)
      rl.inject([]) do  |ary,el|
        ary + (Range === el ? el.map{|rel| rel } : [el])
      end
    end

    def self.range_to_singles(r)
      r.map{|s| s}
    end

    def self.flatten_single(r)
      max = r.exclude_end? ? r.end-1 : r.end
      r.begin == max ? r.begin : r
    end

    def self.flatten_singles(rl)
      rl.map{|r| flatten_single(r) }
    end

    def self.ml_reduce(ml)
      rl = ml_to_ranges(ml)
      reduced_list = reduce(rl)
      flatten_singles(reduced_list)
    end

    def self.ml_arraynge(mx,ml)
      ml.map{|rng| (rng.is_a?(::Range) ? arraynge(mx,rng) : rng)}
    end

    def self.arraynge(mx,rng)
      #p "arraynge(#{mx},#{rng})"
      begr = rng.begin
      mxlim = (rng.exclude_end? ? mx.succ : mx)
      endr = (rng.end > mxlim ? mxlim : rng.end)
      endr = mx + rng.end + 1 if rng.end < 0
      begr = mx + rng.begin + 1 if rng.begin < 0
      return (1..0) if begr < 0 or endr <0
      rng.exclude_end? ? (begr...endr) : (begr..endr)
    end

    def self.ml_expand(ml)
      rl = ml_to_ranges(ml)
      reduced_list = reduce(rl)
      ml_to_singles(reduced_list)
    end

    def self.reduce(rl)
      return rl if rl.empty?
      rl = rl.sort {|a,b| a.begin <=> b.begin}
      #p rl
      (1...rl.size).inject([rl[0]]) do |ans,i|
        ans[0...ans.size-1] + reduce_ranges(ans[-1],rl[i])
      end
    end

    def self.reduce_ranges(r1,r2)
      # requires that r2.min >= r1.min
      #puts("reduce_ranges(#{r1},#{r2})")
      max1 = r1.exclude_end? ? r1.end-1 : r1.end
      if (r1.begin..max1.succ).include?(r2.begin)
        max2 = r2.exclude_end? ? r2.end-1 : r2.end
        r1.include?(max2) ? [r1] : [(r1.begin..max2)]
      else
        [r1,r2]
      end
    end

    def self.ml_diff(ml1,ml2)
      rl1 = ml_to_ranges(ml_reduce(ml1))
      rl2 = ml_to_ranges(ml_reduce(ml2))
      dl = diff(rl1,rl2)
      flatten_singles(dl)
    end

    def self.ml_diff2(ml1,ml2)
      el1 = ml_expand(ml1)
      el2 = ml_expand(ml2)
      dl = el1 - el2
      ml_reduce(dl)
    end

    def self.diff(rl1,rl2)
      rd1 = reduce(rl1)
      rd2 = reduce(rl2)
      ans = []
      rd1.each do |r1|
        ans += difflist(r1,rd2)
      end
      ans
    end

    def self.difflist(r,rl2)
      rl2.inject([r]) do |ans,r2|
        (0...ans.size).inject([]) do |newans,n|
          newans + diff1(ans[n],r2)
        end
      end
    end

    def self.diff1(r1,r2)
      ans = []
      max2 = r2.exclude_end? ? r2.end-1 : r2.end
      if !r1.include?(r2.begin) and !r1.include?(max2)
        ans << r1 unless r2.include?(r1.begin)
      else
        max1 = r1.exclude_end? ? r1.end-1 : r1.end
        ans << (r1.begin...r2.begin) if r1.include?(r2.begin) and r1.begin != r2.begin
        ans << (max2.succ..max1) if r1.include?(max2) and max1 != max2
      end
      ans
    end
  end
end

__END__
