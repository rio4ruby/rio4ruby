

/* Provide console simulation for firebug-less environments */
if (!("console" in window) || !("firebug" in console)) {
    var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
    "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

    window.console = {};
    for (var i = 0; i < names.length; ++i)
        window.console[names[i]] = function() {};
};





(function( $ ) {
  TabBody = function(opts) {
    this.options = opts;
    this.open = false;
  };
   
  TabBody.prototype = {
    
  options: {
    speed: 500
  },
  TAB_RE: /tab-[A-Z]$/,

  getWhich: function(elem) {
    if(elem ==  undefined)
      return elem;
    else
      return elem.toString();
  },
  which: function() {
    return this.getWhich($('.tab-selected').closest('.context').attr('id'));
  },
  isOpen: function() {
      //return this.dialog.dialog('isOpen');
    return this.open;
  },
  setTabCookie: function(wh) {
    console.debug("setTabCookie: %s",wh);
    $.cookie('tab',wh,{ path: '/'});
  },
  getTabCookie: function() {
    var val = $.cookie('tab');
    console.debug("getTabCookie: %s",val);
    return val;
  },
  clearTabCookie: function() {
    console.debug("clearTabCookie");
    $.cookie('tab',null,{ path: '/'});
  },
  hide: function(closeButton) {
    var lpw = $('#left-pane').width();
    console.debug("hide(%s) lpw=%d",closeButton,lpw);
    this.clearTabCookie();
    $('.tb_hide_listener').trigger('tb_hide');
    if(!closeButton)
      this.hide_dialog();
    this.open = false;
    //if(!closeButton)
      //this.dialog.dialog('close');
  },
  change: function(wh) {
    console.debug("change(%s)",wh);
    this.setTabCookie(wh);
    $('.tb_change_listener').trigger('tb_change',wh);
  },
  show: function(wh) {
    console.debug("show(%s)",wh);
    this.show_dialog();
    this.open = true;
    $('.tb_show_listener').trigger('tb_show',wh);
  },
  select: function(wh) {
    console.debug("select called with (%s)",wh);
    if(wh == undefined) {
      if(this.isOpen()) 
	this.hide();
    }
    else {
      if(this.isOpen()) {
	if(wh == this.which()) {
	  this.hide();
	}
	else {
	  this.change(wh);
	}
      }
      else {
	this.show(wh);
      }
    }
    console.debug("select exits with tab-cookie:(%s)",$.cookie('tab'));
  },
  link_with_tab: function(el) {
    var tid = this.which();
    if(tid) {
      var href = $(el).attr('href');
      var qu = '?tab=' + tid;
      href = replace_query(href,qu);
      $(this).attr('href',href);
    }
    location = $(this).attr('href');
    return false;  
  },
  get_dialog_width: function() {
    var ck_val = $.cookie('menu-width');
    if(ck_val == undefined) {
      this.save_dialog_width(192);
    }
    return parseInt($.cookie('menu-width'));
  },
  save_dialog_width: function(val) {
    $.cookie('menu-width',val,{ path: '/'});
    return val;
  },

  pix: function(n) {
    return parseInt(n).toString()+'px';
  },
  getml: function(diag,ml) {
  
    var off = diag.offset();
    var newml = diag.outerWidth() + off.left + ml;
    return parseInt(newml).toString()+'px';
  },

  anim_dialog: function(mode,w,extra,dur) {
    var diag = $('#menu-dialog').closest('.ui-dialog');
    var tbody = this;
  
    var newml = tbody.getml(diag,extra);
    console.debug("anim_dialog start: %s w=%d",newml,w);
    $('#right-pane').css('margin-left',newml);

    diag.animate({marginLeft: w},{
      duration: dur,

       complete: function() {
 	var newml = tbody.getml(diag,extra);
 	console.debug("anim_dialog complete: %s",newml);
 	$('#right-pane').css('margin-left',newml);
	tbody.dialog.dialog("close");
       },
       step: function() {
 	var newml = tbody.getml(diag,extra);
 	//console.debug("anim_dialog step: %s",newml);
 	$('#right-pane').css('margin-left',newml);
       }
      
    });

  },
  resize_dialog_bottom_fit: function() {
    var diag = $('#menu-dialog').closest('.ui-dialog');
    var winHeight = $(window).height();
    var diagHeight = diag.outerHeight();
    if(diagHeight > winHeight-20) {
      diag.height(winHeight-2);
    }
    
  },
  resize_dialog_fit: function() {
    var diag = $('#menu-dialog').closest('.ui-dialog');
    var winHeight = $(window).height();
    var diagHeight = diag.outerHeight();
    diag.height(winHeight-2);
  },

  hide_dialog: function() {
    var diag_open = this.dialog.dialog("isOpen");

    if(diag_open) {
      var diag = $('#menu-dialog').closest('.ui-dialog');
      var tbody = this;
      var extra = 0;
      var w = diag.outerWidth();
      var left_width = $('#left-pane').outerWidth();
      var diag_left_to = left_width - w;
      var dur = 200;

      diag.animate({left: diag_left_to},{
	duration: dur,

	complete: function() {
	  var newml = tbody.getml(diag,extra);
 	  console.debug("anim_dialog complete: %s",newml);
 	  $('#right-pane').css('margin-left',newml);
	  tbody.dialog.dialog("close");
	},
	step: function() {
	  var newml = tbody.getml(diag,extra);
 	  //console.debug("anim_dialog step: %s",newml);
 	  $('#right-pane').css('margin-left',newml);
	}
      
      });
    }
    else {
      var newml = $('#left-pane').outerWidth();
      $('#right-pane').css('margin-left',newml);
    }
  },
  show_dialog: function() {
    var diag = $('#menu-dialog').closest('.ui-dialog');
    var tbody = this;
    var w = diag.outerWidth();
    var left_width = $('#left-pane').outerWidth();
    var diag_left_to = left_width - w;
    var dur = 200;

    if(!this.dialog.dialog('isOpen')) {

      this.dialog.dialog('open');
      diag.position({
	  my: 'right top',
	  at: 'right top',
	  of: '#left-pane',
	  collision: 'none',
      });
    }

    var extra = 0;
    var w = 0;

    diag.animate({left: left_width},{
      duration: dur,

       complete: function() {
 	var newml = tbody.getml(diag,extra);
 	console.debug("anim_dialog complete: %s",newml);
 	$('#right-pane').css('margin-left',newml);
	 var winHeight = $(window).height();
	 var diagHeight = diag.outerHeight();
	 if(diagHeight > winHeight) {
	   diag.height(winHeight);
	 }
	 console.debug("diagHeight: %d => %d",diagHeight,diag.height());
       },
       step: function() {
 	var newml = tbody.getml(diag,extra);
 	//console.debug("anim_dialog step: %s",newml);
 	$('#right-pane').css('margin-left',newml);
       }
      
    });
  },
  create_dialog: function(sel,auto_load) {
    // var anim;
    // anim = { effect: 'slide', duration: 2000, queue: false };
    var tbody = this;
    var diag_width = this.get_dialog_width();
    var el = $(sel);
    var left_pane_width = $('#left-pane').outerWidth();
    var left_pos = auto_load ? left_pane_width : left_pane_width - diag_width;
    console.debug("dialog.create auto_load=%s width=%d",auto_load,diag_width);
    var pos = {
      left: left_pos,
      top: 0
    };
    this.dialog = el.dialog({
		    autoOpen: auto_load,
		    title: 'Basic Dialog',
		    position: pos,
		    width: diag_width,
		    height: $('#left-pane').height(), 
		    /* hide: anim, */
		    resizable: true,
		    draggable: false,
		    resizeStop: function(ev,ui) {
		      var dw = tbody.dialog.dialog('option','width');
		      var rightml = $('#right-pane').css('margin-left');
		      console.debug("resizeStop dw=%d right.ml=%d",dw,rightml);

		      var diag = $('#menu-dialog').closest('.ui-dialog');
		      $('#right-pane').css('margin-left',tbody.getml(diag,0));
		      
		      tbody.save_dialog_width(dw);
		      tbody.resize_dialog_bottom_fit();
		      return true;
		    }

    });
    //$(sel).bind('dialogresize', function(ev,ui) {
    //  var diag = $('#menu-dialog').closest('.ui-dialog');
    //  $('#right-pane').css('margin-left',tbody.getml(diag,0));
    //  return true;
    //});
    $(sel).bind('dialogopen', function(ev,ui) {
      console.debug("dialogopen");
      return true;
    });

    $(sel).bind('dialogclose', function(ev,ui) {
      console.debug("dialogclose");
      tbody.hide(true);
    });
    $(sel).closest('.ui-dialog').removeClass('ui-corner-all');
  }

    
    
  };
})( jQuery );


function wh_to_section(wh) {
   var tab_ids = {
     'tab-C':  'classindex-section',
     'tab-M':  'method-list-section',
     'tab-F':  'fileindex-section',
     'tab-I':  'file-list-section',
     'tab-J':  'includes-section',
     'tab-N':  'namespace-list-section'
   };
  return tab_ids[wh];
}
function wh_to_part(wh) {
   var tab_ids = {
     'tab-M':  'part-methods',
     'tab-I':  'part-in_files',
     'tab-J':  'part-modules',
     'tab-N':  'part-namespaces'
   };
  return tab_ids[wh];
}
function section_class(wh) {
  var sect = wh_to_section(wh);
  var sz = $('#'+sect).size();
  var cl = (sz > 0) ? 'enabled' : 'disabled';
  console.debug("%s %s: %d %s",wh,sect,sz,cl);
  return cl;
}
function fix_loaded_links() {
  var filePfx = $('#fp-body .rel-prefix a').attr('href');
  var classPfx = $('#documentation .rel-prefix a').attr('href');
  $('#fp-body a').each(function(i,el) {
    var ohref = $(el).attr('href');
    var nhref = ohref.replace(filePfx,classPfx);
    $(el).attr('href',nhref);
  });
}



function scrollbarWidth() {
    var div = $('<div style="width:50px;height:50px;overflow:hidden;position:absolute;top:-200px;left:-200px;"><div style="height:100px;"></div>');
    // Append our div, do our calculation and then remove it
    $('body').append(div);
    var w1 = $('div', div).innerWidth();
    div.css('overflow-y', 'scroll');
    var w2 = $('div', div).innerWidth();
    $(div).remove();
    return (w1 - w2);
}
function scrollbarHeight() {
    var div = $('<div style="width:50px;height:50px;overflow:hidden;position:absolute;top:-200px;left:-200px;"><div style="width:100px;"></div>');
    // Append our div, do our calculation and then remove it
    $('body').append(div);
    var w1 = $('div', div).innerHeight();
    div.css('overflow-x', 'scroll');
    var w2 = $('div', div).innerHeight();
    $(div).remove();
    return (w1 - w2);
}
function sect_disp(wh) {
  $('.t-body').hide();
  var body_id = wh.replace(/^tab-/,'body-');
  $('#'+body_id).show();
  var section_frag = $('#'+wh_to_section(wh));
  var txt = $('span#ui-dialog-title-menu-dialog').text();
  var section_hdr = section_frag.find('h3.section-header');
  var newtxt = section_hdr.text();
  $('span#ui-dialog-title-menu-dialog').replaceText(txt,newtxt);
  section_hdr.hide();
  console.debug("load_section(%s) complete right-pane.margin-left=%d",wh,$('#right-pane').css('margin-left'));
  
}

function load_section(el,wh) {

  var dest_id = wh.replace('tab-','body-');
  var clsPth = $('#right-doc').attr('title');
  var sz = $('#'+dest_id).find('.section').size();
  console.debug("load_section(%s) dest=%s size=",clsPth,dest_id,sz);
  if( clsPth && sz < 1 ) {
    var prt = wh_to_part(wh);
    var pth = clsPth.replace(/\.html$/,'-' + prt + '.html');
  
    var section_frag = '#'+wh_to_section(wh);
    //var load_arg = pth + " " + section_frag;
    var load_arg = pth;
    $('#'+dest_id).load(load_arg,function() {
	sect_disp(wh);
    });
    
  }
  else {
    sect_disp(wh);
  }

  
}
function load_right_doc(tbody,href) {
  
  //var link = href.replace(/\.html$/,'-part-documentation.html');
  var link = append_to_basename(href,'-part-documentation');
  var load_arg = link + " #right-doc";
  console.debug("class-index click href=%s load_arg=%s",href,load_arg);
  $('#right-pane')
    .empty()
      .html('<img id="spinner"  src="images/spinner2.gif" alt="Loading..."/>')
      .load(load_arg,function() {
	$('#tab-M,#tab-I,#tab-J,#tab-N').removeClass('enabled disabled');
	$('.c-body').empty();

	$('#tab-M').addClass($('#section-idx-methods').attr('class'));
	$('#tab-I').addClass($('#section-idx-in_files').attr('class'));
	$('#tab-J').addClass($('#section-idx-modules').attr('class'));
	$('#tab-N').addClass($('#section-idx-namespaces').attr('class'));

	//var seltab = $tabbody.getTabCookie();
      

	var wh = tbody.which();
	console.debug("LOADED wh=%s",wh);
	if(wh && $('#'+wh).hasClass('enabled'))
	  load_section(null,wh);
	else
	  tbody.hide();

	var frag = get_frag(href);
	if( frag ) {
	  var sel= "a[name='" + frag + "']";
	  console.debug("frag=%s pos=%.o", sel,$(sel).position());
	  $(window).scrollTop($(sel).position().top);
	  //  $(window).scrollTo($(frag));
	  //  location = frag;
  
	}
	$('.class-selected').removeClass('class-selected');
	var lid = href.replace('#'+frag,'');
	var lsel = ".link-list a[href='" + lid + "']";
	$(lsel).parent().addClass('class-selected');
	$(lsel).parent().removeClass('loading');

  });
}



var RE_GENERIC0 = /(?:([^:\/?#]+):)?(?:\/\/([^\/?#]*))?([^?#]*)(?:\?([^#]*))?(?:\#(.*))?/;
var RE_GENERIC = /((?:[^:\/?#]+):)?(\/\/(?:[^\/?#]*))?([^?#]*)(\?(?:[^#]*))?(\#(.*))?/;

function replace_query(url,str) {
  var nurl = url.replace(RE_GENERIC,'$1$2$3'+str+'$5');
  return nurl;
}
function append_to_basename(url,str) {
  var p = RE_GENERIC.exec(url);
  var plen = p[3].length;
  var pth = p[3].substr(0,plen-5) + str + '.html';
  var nurl = (p[1]||"") + (p[2]||"") + pth + (p[4]||"") + (p[5]||"");  
  return nurl;
}
function get_frag(url) {
  var p = RE_GENERIC0.exec(url);
  return p[5];
}


jQuery(document).ready(function() {

  jQuery.ajax({ cache: false});

  var $tabbody = new TabBody();

  $('#tab-tops p').addClass('tb_change_listener');
  $('#tab-tops p').bind('tb_change',function(ev,wh) {
      console.debug("tab-tops:tb_change(%s)",wh);

      var theid = $(this).closest('.context').attr('id');
      var myWhich = $tabbody.getWhich(theid);
      if(myWhich == wh) {
	$(this).addClass('tab-selected');
      }
      else {
	$(this).removeClass('tab-selected');
      }
  });


  $('#tab-tops p').addClass('tb_hide_listener');
  $('#tab-tops p').bind('tb_hide',function(ev) {
    console.debug("tab-tops:tb_hide");
    $(this).removeClass('tab-selected');
  });


  $('#menu-dialog').bind('tb_change',function(ev,wh) {
    console.debug("menu-dialog:tb_change(%s)",wh);
    load_section($(this),wh);
  });
  $('#menu-dialog').bind('tb_show',function(ev,wh) {
    console.debug("menu-dialog:tb_show(%s)",wh);    
    $tabbody.change(wh);
  });


  $('#tab-tops .context').each(function(idx,el) {
    console.debug("el=%.o",el);
    var idt = $(el).attr('id');
    var cl = section_class(idt);
    $(el).addClass(cl);
  });

  
  ///////// TAB CLICK //////////////
  $('#tab-tops .enabled p').live('click',function() {
    var theid = $tabbody.getWhich($(this).closest('.context').attr('id'));
    console.debug('tab selected');
    $tabbody.select(theid,100);
    return false;
  });

  $(".disabled").delegate("a", "click", function(event){
    event.preventDefault();
  });

//   $("tab-tops .disabled").delegate("a", "click", function() { 
//     console.debug("clicked disabled tab");
//     return false; 
//   });

//   $('.modlink').click(function(ev) {
//     ev.stopImmediatePropagation();
//     $('.sel1').toggleClass('sel1');
//     $(this).closest('li').addClass('sel1');
//     return $tabbody.link_with_tab(this);
//   });
  
//   $('.methlink').click(function(ev) {
//     ev.stopImmediatePropagation();
//     return $tabbody.link_with_tab(this);
//   });
  
  var seltab = $tabbody.getTabCookie();
  var ck_val = $.cookie('menu-width');
  if(seltab == undefined && ck_val == undefined) {
    $tabbody.setTabCookie('tab-C');
  }
    

  seltab = $tabbody.getTabCookie();

  if(seltab && $('#'+seltab).hasClass('enabled')) {
    console.debug("selecting tab from cookie (%s)",seltab);
    $tabbody.create_dialog('#menu-dialog',true);
    $tabbody.select(seltab,-1);
  }
  else {
    $tabbody.create_dialog('#menu-dialog',false);
  }

//   var param = $(document).getUrlParam('tab');
//   if(param) {
//     $tabbody.create_dialog('#menu-dialog',true);
//     $('#sliding-panes').toggleClass('menu-closed');
//     $tabbody.select(param,-1);
//   }
//   else {
//     $tabbody.create_dialog('#menu-dialog',false);
//   }

  var hide_dur =   $tabbody.dialog.dialog('option','hide');
  console.info("hide_dur=%.o",hide_dur);
  $tabbody.dialog.dialog('option','show',hide_dur);

  $('.ui-dialog-titlebar-close').click(function(ev) {
    $tabbody.hide();
    ev.stopImmediatePropagation();
    return false;
  });

  $(window).resize(function() {
    $tabbody.resize_dialog_fit();
  });

  $('#documentation .section .section-header').live('click',function(ev) {
    $(this).siblings('.section-body').toggleClass('hidden-section');
  });

  $('.index table tbody tr').click(function() {
    //var href = $(this).find('a').trigger('click');
    var href = $(this).find('a').attr('href');
    if(href) {
      location = href;
    }
    return false;
  });


//   $('#fileindex-section ul li').click(function(ev) {
//     ev.stopImmediatePropagation();
//     var lnk = $(this).find('a');
//     var href = lnk.attr('href');
//     if(href) {
//       var load_args = href + " #fp-body";
//       $('#file-info-section').load(load_args,function() {
// 	$('div#fp-body').click(function(ev) {
// 	  $('#file-info-section').empty();
// 	});
// 	return true;
//       });
//     }
//     location = '#';
//     return false;
//   });
  $('.selectable-file-list ul li').live('click',function(ev) {
    ev.stopImmediatePropagation();
    if( $(this).hasClass('selected') ) {
      $(this).removeClass('selected');
      $('#file-show').empty();
      
    }
    else {
      $('.selectable-file-list ul li').removeClass('selected');
      var lnk = $(this).find('a');
      var href = lnk.attr('href');
      if(href) {
	$(this).addClass('loading');
	var load_args = href + " #fp-body";
	var li_el = this;
	$('#file-show').load(load_args,function() {
	  $(li_el).addClass('selected').removeClass('loading');
	  fix_loaded_links();


	  $('div#fp-body .header .close-link a').click(function(ev) {
	    $(li_el).removeClass('selected');
	    $('#file-show').empty();
	  });
	  return true;
	});
      }
      location = '#';
    }
    return false;
  });
  $('#right-pane a').live('click',function() {
    var href = $(this).attr('href');
    console.debug("clicked %s",href);
    load_right_doc($tabbody,href);
    return false;
  });
  $('#methods-table tbody tr td a').click(function() {
    var href = $(this).attr('href');
    console.debug("methods-table clicked %s",href);
    //var pth = href.replace(/\.html$/,'-part-documentation.html');
    //$(this).attr('href',pth);
    //href = $(this).attr('href');
    load_right_doc($tabbody,href);
    return false;
  });

  $('.class-index').live('click',function() {
    $(this).addClass('loading');
    var href = $(this).find('a').attr('href');
    console.debug(".class-index clicked %s",href);
    load_right_doc($tabbody,href);

    return false;
  });



  load_right_doc($tabbody,'RIO/Doc/SYNOPSIS.html');

  console.debug("Finished Loading");

//  $('#sliding-panes').bind('tb_hide',function(ev,wh) {
//    var lpw = $('#left-pane').width();
//    var diw = $('#menu-dialog').width();;
//    console.debug("sliding-panes:hide lpw=%d diw=%d right-pane animate to %d",lpw,diw,lpw+diw+20);
//    $('#sliding-panes').animate({'margin-left': -(diw+20)},900);
//  });


//    $('#right-pane').addClass('tb_show_listener');
//    $('#right-pane').bind('tb_show',function(ev,wh) {
//    //   var lpw = $('#left-pane').width();
//    //   var diw = $('#menu-dialog').width();
//    //   console.debug("right-pane:show lpw=%d diw=%d right-pane animate to %d",lpw,diw,lpw+diw+20);
//    //   $('#right-pane').animate({'margin-left': lpw+diw+20},100);
//    });

//   $('#right-pane').addClass('tb_hide_listener');
//   $('#right-pane').bind('tb_hide',function(ev) {
//       var lpw = $('#left-pane').width();
//       var diw = $('#menu-dialog').width();;
//       console.debug("right-pane:hide lpw=%d diw=%d right-pane animate to %d",lpw,diw,lpw+diw+20);
//       $('#right-pane').animate({'margin-left': lpw+diw+20},200);
//   });

//   $('#right-pane').addClass('tb_change_listener');
//   $('#right-pane').bind('tb_change',function(ev) {
//       var lpw = $('#left-pane').width();
//       var diw = $('#menu-dialog').width();;
//       console.debug("right-pane:change lpw=%d diw=%d right-pane set to %d",lpw,diw,lpw+diw+20);
//       $('#right-pane').css('margin-left', lpw+diw+20);
//   });

//   $('#right-pane').data('ml',254);

});
