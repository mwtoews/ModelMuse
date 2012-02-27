/* --- For Help & Manual Premium Pack 1.40 --- */
/* --- � 2008-2011 by Tim Green --- */
/* --- All Rights Reserved --- */
// NS-Header and page initialization, general functions for topics without headers
function addEvent(e,d,b,a){if(e.addEventListener){e.addEventListener(d,b,a);return true;}else{if(e.attachEvent){var c=e.attachEvent("on"+d,b);return c;}else{alert("Could not add event!");}}}function trim(a){return a.replace(/^\s+|\s+$/g,"");}function getLink(a){var b="";b=document.location.href.replace(/\#.*$/,"");b=b.replace(/\?.*?$/,"");b=b.replace(/\/(?!.*?\/)/,"/"+a+"?");return b;}function doPermalink(b,f,a,c){var e="";if(f){e=getLink(b);}else{e=a;}if(c==="show"){var d=$("#innerdiv").width()-55;if(d>450){d=450;}$("#plinkBox").css("height","30px");$("#plinkBox").css("width",d+"px").text(e);}else{if(c==="standard"){return e;}}}function PLclick(c,b){switch(c){case"show":doPermalink(b[0],b[1],b[2],c);$("#permalink").css("visibility","visible");break;case"select":$("#plinkBox").select();break;case"close":$("#permalink").css("visibility","hidden");break;case"bookmark":var d=b[3];var a=getLink(b[0]);if(/^https??:\/\//im.test(a)){if(window.sidebar){window.sidebar.addPanel(d,a,"");}else{if(document.all){window.external.AddFavorite(a,d);}else{alert(b[4]);}}}else{alert(b[5]);}break;case"standard":return doPermalink(b[0],b[1],b[2],c);break;}return false;}function writePermalink(f,e,a,d,c){document.write('<p class="help-url"><b>');if(f&&/^https??:\/\//im.test(document.location)){document.write('<a href="javascript:void(0);" onclick="PLclick(\'show\',window.permalinkData);" ');document.write('title="'+e+'">'+a+"</a></b>\n");}else{var b=PLclick("standard",window.permalinkData);document.write(c+'&nbsp;</b><a href="'+b+'" target="_top" title="'+d+'">');document.write(b+"</a>\n");}}function SearchCheck(){var c=window.location.search.lastIndexOf("zoom_highlight")>0;if(!c){var a=document.getElementsByTagName("FONT");if(a.length>0){var b="";for(var d=0;d<a.length;d++){b=a[d].style.cssText;if(b.indexOf("BACKGROUND-COLOR")==0){c=true;break;}}}}return c;}function toggleToggles(){if(HMToggles.length!=null){var a=true;for(var b=0;b<HMToggles.length;b++){if(HMToggles[b].getAttribute("hm.state")=="1"){a=false;break;}}HMToggleExpandAll(a);}}function toggleCheck(d){var c=$(d[0]).parents("table[id^='TOGGLE']");var a=c.size();var e=false;if(a>0){var j,h,f,g;for(var b=0;b<a;b++){j=c[b];h=$(j).attr("id");f="$"+h+"_ICON";g=j.getAttribute("hm.state");if($("img[id='"+f+"']").attr("src")!=null){e=true;}if((g)=="0"||(g==null)){if(!e){HMToggle("toggle",h);}else{HMToggle("toggle",h,f);}}}}}function openTargetToggle(e,b){var a;var d=false;if(b=="menu"){a=$(e[0]).parent("span:has(a.dropdown-toggle)").find("a.dropdown-toggle").attr("href");if(!a){a=$(e[0]).parent("p:has(a.dropdown-toggle)").find("a.dropdown-toggle").attr("href");}}else{a=$(e[0]).parent("p:has(a.dropdown-toggle)");a=$(a).find("a.dropdown-toggle").attr("href");if(!a){a=$(e[0]).parents("table:has(a.dropdown-toggle)")[0];a=$(a).find("a.dropdown-toggle").attr("href");}}var f=false;var c="";if(a){if(a.indexOf("ICON")!=-1){f=true;}a=a.replace(/^.*?\,\'/,"");a=a.replace(/\'.*$/,"");if(f){c="$"+a+"_ICON";}if(!f){HMToggle("toggle",a);return true;}else{HMToggle("toggle",a,c);return true;}}else{return false;}}var intLoc="";function pollLocation(){var a=document.location.hash;if(a.length>0&&intLoc!=a){intLoc=a;toggleJump();}}function toggleJump(){if(location.hash){var b=location.hash.replace(/\#/,"");var a;if($("a[id='"+b+"']").length>0){a=$("a[id='"+b+"']");}else{if($("a[name='"+b+"']").length>0){a=$("a[name='"+b+"']");}else{return false;}}if(HMToggles.length!=null){HMToggleExpandAll(false);}toggleCheck(a);if(($(a[0]).parent("p:has(a.dropdown-toggle)").length>0)||($(a[0]).parent("td").parent("tr:has(a.dropdown-toggle)").length>0)){openTargetToggle(a,"page");}$("#idcontent").scrollTo($(a),300,{offset:-12,axis:"y"});return false;}}function printTopic(a){window.open(a,"","toolbar=0,scrollbars=1,location=1,status=1,menubar=1,titlebar=1,resizable=1");}$(document).ready(function(){var b=/toc=0&printWindow/g;if(b.test(location.search)){$("body").hide();setTimeout(function(){HMToggleExpandAll(true);$("body,html,.nonscroll").css("overflow","visible");$("#idnav,.idnav,.idnav a,#breadcrumbs,#autoTocWrapper,#idheader,#permalink,.popups,.help-url").css("display","none");$('<style media="screen">#printheader {display: block; font-weight: bold; padding: 11px 0px 0px 11px;}</style>').appendTo("head");$("#printtitle").css("fontWeight","bold");$("#idcontent,#innerdiv").css({margin:"0",position:"static",padding:"0"});$("body").show();setTimeout(function(){print();},500);},150);}if(location.href.search("::")>0&&$("a[name]").length>0&&$("a.dropdown-toggle").length>0){setInterval(pollLocation,300);}var a=/msie 6|MSIE 6/.test(navigator.userAgent);var c=document.location.pathname;c=c.replace(/^.*[/\\]|[?#&].*$/,"");$("a[href^='"+c+"#'],a[href^='#']:not(a[href='#']),area[href^='"+c+"#'],area[href^='#']:not(area[href='#'])").click(function(){var d=$(this).attr("href").replace(/.*?\#/,"");var e=$("a[id='"+d+"']");if(!e.length>0){e=$("a[name='"+d+"']");}if(HMToggles.length!=null){HMToggleExpandAll(false);}toggleCheck(e);if(($(e[0]).parent("p:has(a.dropdown-toggle)").length>0)||($(e[0]).parent("td").parent("tr:has(a.dropdown-toggle)").length>0)){openTargetToggle(e,"page");}$("#idcontent").scrollTo($(e),600,{offset:-12,axis:"y"});return false;});});function chromeBugCheck(a){if((a=="block")&&/WebKit|webkit/.test(navigator.userAgent)&&$("#togtoc").attr("alt")){$("#togtoc").css("display","none");}var b="Google Chrome";if((location.href.indexOf("http:")<0)&&(location.href.indexOf("https:")<0)){if((!$("#hmframeset",window.parent.document).attr("cols"))&&(location.search.indexOf("toc=0")<0)){if(!/Chrome|chrome/.test(navigator.userAgent)){b="your web browser";}alert("HELP SYSTEM ALERT:\n\nThis version of "+b+" blocks cross-frame\nreferences in a way that is not compatible with HTML\nstandards. This feature makes "+b+" unable\nto display this WebHelp help system correctly when\nloaded directly from a local computer drive without\na web server.\n\nPlease use a different browser to view this help from\nthis location.\n\nThis version of "+b+" will display the help\ncorrectly when the help is stored on a web server.");}}}