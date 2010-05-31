# -*- coding: utf-8 -*-
      def test_check_paths
        $datadir ||= rio("../../data")
        r = rio($datadir,'filelist.txt').enc('UTF-8').chomp

        paths = r.map{|el| el.sub(%r{^/loc},'')}
        lines = rio($datadir,'linklist.txt').chomp[]
        urls = lines.map{|el| Alt::URI.parse(el) }
        #upaths = urls.map{|u| u.path.force_encoding("UTF-8")}
        upaths = urls.map{|u| u.path}
        assert_equal(paths,upaths)
      end

      def test_enc
        ustr = "http://localhost/mp3/J.%20S.%20Bach%20-%20Orgelwerke%20-%20Karl%20Richter/35%20-%20Sei%20gegr%c3%bc%c3%9fet,%20Jesu%20g%c3%bctig%20-%20BWV%20768.flac"
        pstr = "/mp3/J. S. Bach - Orgelwerke - Karl Richter/35 - Sei gegrüßet, Jesu gütig - BWV 768.flac"
        r = rio(ustr)
        pth = r.path
        assert_equal(r.rl.fs.encoding,pth.encoding)
        assert_equal(pstr,pth)
      end

      def test_check_read_dir
        #p __ENCODING__
        rootdir = rio('/loc/mp3/')
        rootenc = rootdir.rl.fs.encoding
        rootdir.dirs do |ent|
          assert_equal(rootenc,ent.path.encoding)
        end
      end
