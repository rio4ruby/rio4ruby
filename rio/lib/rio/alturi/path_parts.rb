module Alt
  module URI
    module Ops
      module PathParts
        def dirname
          dn = self.path[*_dn_pos(self.path)]
          dn.empty? ? "." : dn
        end
        def basename(exnam=nil)
          self.path[*_bn_pos(self.path,exnam)]
        end
        def filename
          self.path[*_fn_pos(self.path)]
        end
        def extname
          self.path[*_en_pos(self.path)]
        end
        def dirname=(val)
          pth = self.path
          pth = "./" + pth if dirname == "."
          pth[*_dn_pos(pth)] = val
          self.path = pth.squeeze("/")
          dirname
        end
        def basename=(val)
          pth = self.path
          pth[*_bn_pos(pth)] = val
          self.path = pth
          basename
        end
        def filename=(val)
          pth = self.path
          pth[*_fn_pos(pth)] = val
          self.path = pth.squeeze("/")
          filename
        end
        def extname=(val)
          pth = self.path
          pth[*_en_pos(pth)] = val
          self.path = pth
          extname
        end

        private

        def _en_pos(path)
          en = ::File.extname(path)
          [path.rindex(en),en.length]
        end
        def _bn_pos(path,exnam=nil)
          en_start,en_len = _en_pos(path)
          exnam ||= path[en_start,en_len]
          bn = ::File.basename(path,exnam)
          [path.rindex(bn,en_start),bn.length]
        end
        def _fn_pos(path)
          fn = ::File.basename(path,"")
          [path.rindex(fn),fn.length]
        end
        def _dn_pos(path)
          dn = ::File.dirname(path)
          dn_start = path.index(dn)
          dn_start.nil? ? [0,0] : [dn_start,dn.length]
        end


      end
    end
  end
end