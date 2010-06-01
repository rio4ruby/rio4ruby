
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
		    height: $('#left-pane').height() - scrollbarWidth(), 
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

function load_section(el,wh) {

  var section_frag = $('#'+wh_to_section(wh));
  $('#menu-dialog .section').hide();
  section_frag.show();
  var txt = $('span#ui-dialog-title-menu-dialog').text();
  var section_hdr = section_frag.find('h3.section-header');
  var newtxt = section_hdr.text();
  $('span#ui-dialog-title-menu-dialog').replaceText(txt,newtxt);
  section_hdr.hide();
  console.debug("load_section(%s) complete right-pane.margin-left=%d",wh,$('#right-pane').css('margin-left'));
}
var RE_GENERIC0 = /(?:([^:\/?#]+):)?(?:\/\/([^\/?#]*))?([^?#]*)(?:\?([^#]*))?(?:\#(.*))?/;
var RE_GENERIC = /((?:[^:\/?#]+):)?(\/\/(?:[^\/?#]*))?([^?#]*)(\?(?:[^#]*))?(\#(.*))?/;

function replace_query(url,str) {
    var nurl = url.replace(RE_GENERIC,'$1$2$3'+str+'$5');
  return nurl;
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


  
  ///////// TAB CLICK //////////////
  $('#tab-tops p').click(function() {
    var theid = $tabbody.getWhich($(this).closest('.context').attr('id'));
    console.debug('tab selected');
    $tabbody.select(theid,100);
    return false;
  });

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
  if(seltab) {
    console.debug("selecting tab from cookie (%s)",seltab);
    $tabbody.create_dialog('#menu-dialog',true);
    $('#sliding-panes').toggleClass('menu-closed');
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
    //$('#log').append('<div>Handler for .resize() called.</div>');
  });

  $('#documentation .section .section-header').click(function(ev) {
    $(this).siblings('.section-body').toggleClass('hidden-section');
  });

  $('#fileindex-section ul li').click(function(ev) {
    ev.stopImmediatePropagation();
    var lnk = $(this).find('a');
    var href = lnk.attr('href');
    if(href) {
      var load_args = href + " #fp-body";
      $('#file-info-section').load(load_args,function() {
	$('div#fp-body').click(function(ev) {
	  $('#file-info-section').empty();
	});
	return true;
      });
    }
    location = '#';
    return false;
  });
  $('#file-list-section ul li').click(function(ev) {
    ev.stopImmediatePropagation();
    var lnk = $(this).find('a');
    var href = lnk.attr('href');
    if(href) {
      var load_args = href + " #fp-body";
      $('#file-info-section').load(load_args,function() {
	$('div#fp-body').click(function(ev) {
	  $('#file-info-section').empty();
	});
	return true;
      });
    }
    location = '#';
    return false;
  });
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
