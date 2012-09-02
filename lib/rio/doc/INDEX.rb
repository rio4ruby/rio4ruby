#--
# ===========================================================================
# Copyright (c) 2005-2012 Christopher Kleckner
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


module RIO
module Doc

##
# = Rio - Index
#
# Constructors:
# RIO::{#rio}[rdoc-ref:RIO.rio]
# RIO::{#cwd}[rdoc-ref:RIO.cwd]
# RIO::{#root}[rdoc-ref:RIO.root]
#
# Directories:
# RIO::{#chdir}[rdoc-ref:IF::Dir#chdir]
# RIO::{#find}[rdoc-ref:IF::Dir#find]
# RIO::{#glob}[rdoc-ref:IF::Dir#glob]
# RIO::{#mkdir}[rdoc-ref:IF::Dir#mkdir]
# RIO::{#mkpath}[rdoc-ref:IF::Dir#mkpath]
# RIO::{#rmdir}[rdoc-ref:IF::Dir#rmdir]
# RIO::{#rmtree}[rdoc-ref:IF::Dir#rmtree]
#
# Files:
# RIO::{#clear}[rdoc-ref:IF::File#clear]
# RIO::{#rm}[rdoc-ref:IF::File#rm]
# RIO::{#touch}[rdoc-ref:IF::File#touch]
# RIO::{#truncate}[rdoc-ref:IF::File#truncate]
#
# Files or Directories:
# RIO::{#open}[rdoc-ref:IF::FileOrDir#open]
# RIO::{#pos}[rdoc-ref:IF::FileOrDir#pos]
# RIO::{#pos=}[rdoc-ref:IF::FileOrDir#pos=]
# RIO::{#read}[rdoc-ref:IF::FileOrDir#read]
# RIO::{#readlink}[rdoc-ref:IF::FileOrDir#readlink]
# RIO::{#rename}[rdoc-ref:IF::FileOrDir#rename]
# RIO::{#rename!}[rdoc-ref:IF::FileOrDir#rename!]
# RIO::{#reopen}[rdoc-ref:IF::FileOrDir#reopen]
# RIO::{#rewind}[rdoc-ref:IF::FileOrDir#rewind]
# RIO::{#seek}[rdoc-ref:IF::FileOrDir#seek]
# RIO::{#symlink}[rdoc-ref:IF::FileOrDir#symlink]
# RIO::{#tell}[rdoc-ref:IF::FileOrDir#tell]
#
# Path:
# RIO::{#/}[link:RIO/IF/Path.html#method-i-2F]
# RIO::{#abs}[rdoc-ref:IF::Path#abs]
# RIO::{#base}[rdoc-ref:IF::Path#base]
# RIO::{#basename}[rdoc-ref:IF::Path#basename]
# RIO::{#basename=}[rdoc-ref:IF::Path#basename=]
# RIO::{#cleanpath}[rdoc-ref:IF::Path#cleanpath]
# RIO::{#dirname}[rdoc-ref:IF::Path#dirname]
# RIO::{#dirname=}[rdoc-ref:IF::Path#dirname=]
# RIO::{#expand_path}[rdoc-ref:IF::Path#expand_path]
# RIO::{#ext}[rdoc-ref:IF::Path#ext]
# RIO::{#ext?}[rdoc-ref:IF::Path#ext?]
# RIO::{#extname}[rdoc-ref:IF::Path#extname]
# RIO::{#extname=}[rdoc-ref:IF::Path#extname=]
# RIO::{#filename}[rdoc-ref:IF::Path#filename]
# RIO::{#filename=}[rdoc-ref:IF::Path#filename=]
# RIO::{#fspath}[rdoc-ref:IF::Path#fspath]
# RIO::{#host}[rdoc-ref:IF::Path#host]
# RIO::{#join}[rdoc-ref:IF::Path#join]
# RIO::{#join!}[rdoc-ref:IF::Path#join!]
# RIO::{#merge}[rdoc-ref:IF::Path#merge]
# RIO::{#noext}[rdoc-ref:IF::Path#noext]
# RIO::{#opaque}[rdoc-ref:IF::Path#opaque]
# RIO::{#path}[rdoc-ref:IF::Path#path]
# RIO::{#realpath}[rdoc-ref:IF::Path#realpath]
# RIO::{#rel}[rdoc-ref:IF::Path#rel]
# RIO::{#route_from}[rdoc-ref:IF::Path#route_from]
# RIO::{#route_to}[rdoc-ref:IF::Path#route_to]
# RIO::{#scheme}[rdoc-ref:IF::Path#scheme]
# RIO::{#splitpath}[rdoc-ref:IF::Path#splitpath]
# RIO::{#to_uri}[rdoc-ref:IF::Path#to_uri]
# RIO::{#to_url}[rdoc-ref:IF::Path#to_url]
# RIO::{#urlpath}[rdoc-ref:IF::Path#urlpath]
#
# String:
# RIO::{#+}[link:RIO/IF/String.html#method-i-2B]
# RIO::{#gsub}[rdoc-ref:IF::String#gsub]
# RIO::{#sub}[rdoc-ref:IF::String#sub]
#
# Grande:
# RIO::{#[]}[link:RIO/IF/Grande.html#method-i-5B-5D]
# RIO::{#<}[link:RIO/IF/Grande.html#method-i-3C]
# RIO::{#<<}[link:RIO/IF/Grande.html#method-i-3C-3C]
# RIO::{#>}[link:RIO/IF/Grande.html#method-i-3E]
# RIO::{#>>}[link:RIO/IF/Grande.html#method-i-3E-3E]
# RIO::{#|}[link:RIO/IF/Grande.html#method-i-7C]
# RIO::{#append_from}[rdoc-ref:IF::Grande#append_from]
# RIO::{#append_to}[rdoc-ref:IF::Grande#append_to]
# RIO::{#copy_from}[rdoc-ref:IF::Grande#copy_from]
# RIO::{#copy_to}[rdoc-ref:IF::Grande#copy_to]
# RIO::{#delete}[rdoc-ref:IF::Grande#delete]
# RIO::{#delete!}[rdoc-ref:IF::Grande#delete!]
# RIO::{#each}[rdoc-ref:IF::Grande#each]
# RIO::{#empty?}[rdoc-ref:IF::Grande#empty?]
# RIO::{#get}[rdoc-ref:IF::Grande#get]
# RIO::{#skip}[rdoc-ref:IF::Grande#skip]
# RIO::{#split}[rdoc-ref:IF::Grande#split]
# RIO::{#to_a}[rdoc-ref:IF::Grande#to_a]
#
# Grande Directory:
# RIO::{#all}[rdoc-ref:IF::GrandeEntry#all]
# RIO::{#all?}[rdoc-ref:IF::GrandeEntry#all?]
# RIO::{#dirs}[rdoc-ref:IF::GrandeEntry#dirs]
# RIO::{#entries}[rdoc-ref:IF::GrandeEntry#entries]
# RIO::{#files}[rdoc-ref:IF::GrandeEntry#files]
# RIO::{#norecurse}[rdoc-ref:IF::GrandeEntry#norecurse]
# RIO::{#recurse}[rdoc-ref:IF::GrandeEntry#recurse]
# RIO::{#skipdirs}[rdoc-ref:IF::GrandeEntry#skipdirs]
# RIO::{#skipentries}[rdoc-ref:IF::GrandeEntry#skipentries]
# RIO::{#skipfiles}[rdoc-ref:IF::GrandeEntry#skipfiles]
#
# Grande Stream:
# RIO::{#+}[rdoc-ref:IF::GrandeStream#+]
# RIO::{#a}[rdoc-ref:IF::GrandeStream#a]
# RIO::{#a!}[rdoc-ref:IF::GrandeStream#a!]
# RIO::{#bytes}[rdoc-ref:IF::GrandeStream#bytes]
# RIO::{#chomp}[rdoc-ref:IF::GrandeStream#chomp]
# RIO::{#chomp?}[rdoc-ref:IF::GrandeStream#chomp?]
# RIO::{#closeoncopy}[rdoc-ref:IF::GrandeStream#closeoncopy]
# RIO::{#closeoncopy?}[rdoc-ref:IF::GrandeStream#closeoncopy?]
# RIO::{#closeoneof}[rdoc-ref:IF::GrandeStream#closeoneof]
# RIO::{#closeoneof?}[rdoc-ref:IF::GrandeStream#closeoneof?]
# RIO::{#contents}[rdoc-ref:IF::GrandeStream#contents]
# RIO::{#getline}[rdoc-ref:IF::GrandeStream#getline]
# RIO::{#getrec}[rdoc-ref:IF::GrandeStream#getrec]
# RIO::{#getrow}[rdoc-ref:IF::GrandeStream#getrow]
# RIO::{#gzip}[rdoc-ref:IF::GrandeStream#gzip]
# RIO::{#gzip?}[rdoc-ref:IF::GrandeStream#gzip?]
# RIO::{#line}[rdoc-ref:IF::GrandeStream#line]
# RIO::{#lines}[rdoc-ref:IF::GrandeStream#lines]
# RIO::{#noautoclose}[rdoc-ref:IF::GrandeStream#noautoclose]
# RIO::{#nocloseoncopy}[rdoc-ref:IF::GrandeStream#nocloseoncopy]
# RIO::{#nocloseoneof}[rdoc-ref:IF::GrandeStream#nocloseoneof]
# RIO::{#putrec}[rdoc-ref:IF::GrandeStream#putrec]
# RIO::{#r}[rdoc-ref:IF::GrandeStream#r]
# RIO::{#r!}[rdoc-ref:IF::GrandeStream#r!]
# RIO::{#record}[rdoc-ref:IF::GrandeStream#record]
# RIO::{#records}[rdoc-ref:IF::GrandeStream#records]
# RIO::{#row}[rdoc-ref:IF::GrandeStream#row]
# RIO::{#rows}[rdoc-ref:IF::GrandeStream#rows]
# RIO::{#skiplines}[rdoc-ref:IF::GrandeStream#skiplines]
# RIO::{#skiprecords}[rdoc-ref:IF::GrandeStream#skiprecords]
# RIO::{#skiprows}[rdoc-ref:IF::GrandeStream#skiprows]
# RIO::{#splitlines}[rdoc-ref:IF::GrandeStream#splitlines]
# RIO::{#strip}[rdoc-ref:IF::GrandeStream#strip]
# RIO::{#strip?}[rdoc-ref:IF::GrandeStream#strip?]
# RIO::{#w}[rdoc-ref:IF::GrandeStream#w]
# RIO::{#w!}[rdoc-ref:IF::GrandeStream#w!]
#
# Ruby I/O:
# RIO::{#binmode}[rdoc-ref:IF::RubyIO#binmode]
# RIO::{#close}[rdoc-ref:IF::RubyIO#close]
# RIO::{#close_write}[rdoc-ref:IF::RubyIO#close_write]
# RIO::{#each_byte}[rdoc-ref:IF::RubyIO#each_byte]
# RIO::{#each_line}[rdoc-ref:IF::RubyIO#each_line]
# RIO::{#eof?}[rdoc-ref:IF::RubyIO#eof?]
# RIO::{#fcntl}[rdoc-ref:IF::RubyIO#fcntl]
# RIO::{#fileno}[rdoc-ref:IF::RubyIO#fileno]
# RIO::{#flush}[rdoc-ref:IF::RubyIO#flush]
# RIO::{#fsync}[rdoc-ref:IF::RubyIO#fsync]
# RIO::{#getc}[rdoc-ref:IF::RubyIO#getc]
# RIO::{#gets}[rdoc-ref:IF::RubyIO#gets]
# RIO::{#ioctl}[rdoc-ref:IF::RubyIO#ioctl]
# RIO::{#ioh}[rdoc-ref:IF::RubyIO#ioh]
# RIO::{#ios}[rdoc-ref:IF::RubyIO#ios]
# RIO::{#lineno}[rdoc-ref:IF::RubyIO#lineno]
# RIO::{#lineno=}[rdoc-ref:IF::RubyIO#lineno=]
# RIO::{#mode}[rdoc-ref:IF::RubyIO#mode]
# RIO::{#mode?}[rdoc-ref:IF::RubyIO#mode?]
# RIO::{#nosync}[rdoc-ref:IF::RubyIO#nosync]
# RIO::{#pid}[rdoc-ref:IF::RubyIO#pid]
# RIO::{#print}[rdoc-ref:IF::RubyIO#print]
# RIO::{#print!}[rdoc-ref:IF::RubyIO#print!]
# RIO::{#printf}[rdoc-ref:IF::RubyIO#printf]
# RIO::{#printf!}[rdoc-ref:IF::RubyIO#printf!]
# RIO::{#putc}[rdoc-ref:IF::RubyIO#putc]
# RIO::{#putc!}[rdoc-ref:IF::RubyIO#putc!]
# RIO::{#puts}[rdoc-ref:IF::RubyIO#puts]
# RIO::{#puts!}[rdoc-ref:IF::RubyIO#puts!]
# RIO::{#readline}[rdoc-ref:IF::RubyIO#readline]
# RIO::{#readlines}[rdoc-ref:IF::RubyIO#readlines]
# RIO::{#readpartial}[rdoc-ref:IF::RubyIO#readpartial]
# RIO::{#recno}[rdoc-ref:IF::RubyIO#recno]
# RIO::{#sync}[rdoc-ref:IF::RubyIO#sync]
# RIO::{#sync?}[rdoc-ref:IF::RubyIO#sync?]
# RIO::{#to_i}[rdoc-ref:IF::RubyIO#to_i]
# RIO::{#to_io}[rdoc-ref:IF::RubyIO#to_io]
# RIO::{#tty?}[rdoc-ref:IF::RubyIO#tty?]
# RIO::{#ungetc}[rdoc-ref:IF::RubyIO#ungetc]
# RIO::{#write}[rdoc-ref:IF::RubyIO#write]
# RIO::{#write!}[rdoc-ref:IF::RubyIO#write!]
#
# Test:
# RIO::{#abs?}[rdoc-ref:IF::Test#abs?]
# RIO::{#absolute?}[rdoc-ref:IF::Test#absolute?]
# RIO::{#atime}[rdoc-ref:IF::Test#atime]
# RIO::{#blockdev?}[rdoc-ref:IF::Test#blockdev?]
# RIO::{#chardev?}[rdoc-ref:IF::Test#chardev?]
# RIO::{#closed?}[rdoc-ref:IF::Test#closed?]
# RIO::{#ctime}[rdoc-ref:IF::Test#ctime]
# RIO::{#dir?}[rdoc-ref:IF::Test#dir?]
# RIO::{#directory?}[rdoc-ref:IF::Test#directory?]
# RIO::{#executable_real?}[rdoc-ref:IF::Test#executable_real?]
# RIO::{#executable?}[rdoc-ref:IF::Test#executable?]
# RIO::{#exist?}[rdoc-ref:IF::Test#exist?]
# RIO::{#file?}[rdoc-ref:IF::Test#file?]
# RIO::{#fnmatch?}[rdoc-ref:IF::Test#fnmatch?]
# RIO::{#ftype}[rdoc-ref:IF::Test#ftype]
# RIO::{#grpowned?}[rdoc-ref:IF::Test#grpowned?]
# RIO::{#lstat}[rdoc-ref:IF::Test#lstat]
# RIO::{#mountpoint?}[rdoc-ref:IF::Test#mountpoint?]
# RIO::{#mtime}[rdoc-ref:IF::Test#mtime]
# RIO::{#open?}[rdoc-ref:IF::Test#open?]
# RIO::{#owned?}[rdoc-ref:IF::Test#owned?]
# RIO::{#pipe?}[rdoc-ref:IF::Test#pipe?]
# RIO::{#readable_real?}[rdoc-ref:IF::Test#readable_real?]
# RIO::{#readable?}[rdoc-ref:IF::Test#readable?]
# RIO::{#root?}[rdoc-ref:IF::Test#root?]
# RIO::{#setgid?}[rdoc-ref:IF::Test#setgid?]
# RIO::{#setuid?}[rdoc-ref:IF::Test#setuid?]
# RIO::{#size}[rdoc-ref:IF::Test#size]
# RIO::{#size?}[rdoc-ref:IF::Test#size?]
# RIO::{#socket?}[rdoc-ref:IF::Test#socket?]
# RIO::{#stat}[rdoc-ref:IF::Test#stat]
# RIO::{#sticky?}[rdoc-ref:IF::Test#sticky?]
# RIO::{#symlink?}[rdoc-ref:IF::Test#symlink?]
# RIO::{#writable_real?}[rdoc-ref:IF::Test#writable_real?]
# RIO::{#writable?}[rdoc-ref:IF::Test#writable?]
# RIO::{#zero?}[rdoc-ref:IF::Test#zero?]
#
#
# Basic:
# RIO::{#==}[link:RIO/Rio.html#method-i-3D-3D]
# RIO::{#===}[link:RIO/Rio.html#method-i-3D-3D-3D]
# RIO::{#=~}[link:RIO/Rio.html#method-i-3D-7E]
# RIO::{#dup}[rdoc-ref:RIO::Rio#dup]
# RIO::{#hash}[rdoc-ref:RIO::Rio#hash]
# RIO::{#inspect}[rdoc-ref:RIO::Rio#inspect]
# RIO::{#length}[rdoc-ref:RIO::Rio#length]
# RIO::{#to_s}[rdoc-ref:RIO::Rio#to_s]
# RIO::{#to_str}[rdoc-ref:RIO::Rio#to_str]
#
# CSV:
# RIO::{#columns}[rdoc-ref:IF::CSV#columns]
# RIO::{#csv}[rdoc-ref:IF::CSV#csv]
# RIO::{#skipcolumns}[rdoc-ref:IF::CSV#skipcolumns]
#
# YAML:
# RIO::{#document}[rdoc-ref:IF::YAML#document]
# RIO::{#documents}[rdoc-ref:IF::YAML#documents]
# RIO::{#dump}[rdoc-ref:IF::YAML#dump]
# RIO::{#getobj}[rdoc-ref:IF::YAML#getobj]
# RIO::{#load}[rdoc-ref:IF::YAML#load]
# RIO::{#object}[rdoc-ref:IF::YAML#object]
# RIO::{#objects}[rdoc-ref:IF::YAML#objects]
# RIO::{#putobj}[rdoc-ref:IF::YAML#putobj]
# RIO::{#putobj!}[rdoc-ref:IF::YAML#putobj!]
# RIO::{#skipdocuments}[rdoc-ref:IF::YAML#skipdocuments]
# RIO::{#skipobjects}[rdoc-ref:IF::YAML#skipobjects]
# RIO::{#yaml}[rdoc-ref:IF::YAML#yaml]
# RIO::{#yaml?}[rdoc-ref:IF::YAML#yaml?]

module INDEX
end
end
end

