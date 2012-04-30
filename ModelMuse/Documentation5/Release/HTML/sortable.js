/* Table sorting code based on scripts by Stuart Langridge 
http://www.kryogenix.org/code/browser/sorttable/
and Joost de Valk http://www.joostdevalk.nl/code/sortable-table/
Original code in these scripts copyright (c) 1997-2008 by Stuart 
Langridge and Joost de Valk and released under the MIT License.

Version 2.1 modifications for Help & Manual 5 Premium Pack 1.40
Copyright (c) 2009 by Tim Green

Modified and extended for use in Help & Manual by Tim Green. This
version is a complete rewrite for use in Help & Manual with a large
number of major changes and new features and it will not work outside
of Help & Manual projects. For use in your own scripts see the original 
versions on Stuart Langridge's and Joost de Valk's websites. */
addEvent(window,"load",sortables_init);var SORT_COLUMN_INDEX;var thead=false;var altTables=new Array();var sortVars=initSortVars();var sortID=sortVars.sortID;var europeandate=sortVars.europeandate;var germanNumbers=sortVars.germanNumbers;var image_path=sortVars.imagePath;var image_up=sortVars.image_up;var image_down=sortVars.image_down;var image_none=sortVars.image_none;var image_empty=sortVars.image_empty;var sort_tip=sortVars.sort_tip;var bottomrow=sortVars.bottomrow;var sortablecol=sortVars.sortablecol;var defaultsort=sortVars.defaultsort;var defaultsortD=sortVars.defaultsortD;var customicons=sortVars.customicons;var noalternate=sortVars.noalternate;function getCssAttrib(b,a){var c;var f;b="."+b;if(document.styleSheets[0]["rules"]){c="rules";}else{if(document.styleSheets[0]["cssRules"]){c="cssRules";}else{return false;}}for(var d=0;d<document.styleSheets.length;d++){for(var e=0;e<document.styleSheets[d][c].length;e++){if(document.styleSheets[d][c][e].selectorText==b){if(document.styleSheets[d][c][e].style[a]){f=document.styleSheets[d][c][e].style[a];return f;}}}}return false;}function ts_getInnerText(d){if(typeof d=="string"){return d;}if(typeof d=="undefined"){return d;}if(d.innerText){return d.innerText;}var e="";var c=d.childNodes;var a=c.length;for(var b=0;b<a;b++){switch(c[b].nodeType){case 1:e+=ts_getInnerText(c[b]);break;case 3:e+=c[b].nodeValue;break;}}return e;}function sortables_init(){if(!document.getElementsByTagName){return;}tbls=document.getElementsByTagName("table");for(ti=0;ti<tbls.length;ti++){thisTbl=tbls[ti];if(((" "+thisTbl.id+" ").indexOf("_srt_")!=-1)&&(thisTbl.id)){ts_makeSortable(thisTbl);}}}function hm_TagCheck(f,e){var d=f.getElementsByTagName("a");var c=/-(.*?)_/;var g="";if(d[0]){for(i=0;i<d.length;i++){if((d[i].name.indexOf(e)!=-1)||(d[i].id.indexOf(e)!=-1)){if(e==customicons){if(d[i].id){g=c.exec(d[i].id)[1]+"_";}else{g=c.exec(d[i].name)[1]+"_";}var h=new Image();h.src=image_path+g+image_up;var a=h.width;var b=h.height;if((a==0)||(a+b==58)){g="";}return g;}return true;}}}else{return false;}}function ts_makeSortable(s){var l=s.id;var v="";var z=s.rows.length-1;var d=false;if(s.rows&&s.rows.length>0){if(s.tHead&&s.tHead.rows.length>0){var a=s.tHead.rows[s.tHead.rows.length-1];thead=true;}else{var a=s.rows[0];}}var h=s.rows[0].getElementsByTagName("th");var b=s.rows[1].getElementsByTagName("th");if(!a||!h[0]){alert("Error! Sortable table with ID "+l+" has no valid header row!\nSortable tables must have 1 and only 1 header row.");return;}else{if(b[0]){alert("Error! Sortable table with ID "+l+" has more than 1 header row!\nSortable tables must have 1 and only 1 header row.");return;}}altTables[l+"alternate"]=true;for(var A=0;A<a.cells.length;A++){var f=a.cells[A];var u=ts_getInnerText(f);var g=f.innerHTML;u=trim(u);var o=new RegExp("<span.*?>.*</span>","i");var m=o.exec(g);if(m){u=m;}var w=f.getElementsByTagName("p")[0];var e,q,B;var c=s.cellPadding;if(w){var r=w.className;if(r){B=getCssAttrib(r,"textAlign");}B=w.style.textAlign;if(B.length>0){f.align=B;}if(w.style.margin){e=w.style.marginBottom;q=w.style.marginTop;}else{if(r&&!w.style.margin){e=getCssAttrib(r,"marginBottom");q=getCssAttrib(r,"marginTop");}else{e="0px";q="0px";}}if(!e){e="0px";}if(!q){q="0px";}e=parseInt(c)+parseInt(e);e=e+"px";f.style.paddingBottom=e;q=parseInt(c)+parseInt(q);q=q+"px";f.style.paddingTop=q;}if(hm_TagCheck(f,noalternate)&&altTables[l+"alternate"]){altTables[l+"alternate"]=false;}if(altTables[l+"alternate"]){altTables[l+"evenRowColor"]=s.rows[2].cells[0].style.backgroundColor;if(!altTables[l+"evenRowColor"]){altTables[l+"evenRowColor"]="transparent";}altTables[l+"oddRowColor"]=s.rows[1].cells[0].style.backgroundColor;if(!altTables[l+"oddRowColor"]){altTables[l+"oddRowColor"]="transparent";}if(s.style.backgroundColor){altTables[l+"oddRowColor"]=s.style.backgroundColor;}altTables[l+"lastRowColor"]=s.rows[z].cells[0].style.backgroundColor;if(!altTables[l+"lastRowColor"]){altTables[l+"lastRowColor"]="transparent";}if(altTables[l+"evenRowColor"]!=altTables[l+"oddRowColor"]){altTables[l+"alternate"]=true;}else{altTables[l+"alternate"]=false;}}if(!altTables[l+"iconprefix"]){if(hm_TagCheck(f,customicons)){altTables[l+"iconprefix"]=hm_TagCheck(f,customicons);}else{if(altTables[l+"iconprefix"]!=""){altTables[l+"iconprefix"]="";}}v=altTables[l+"iconprefix"];}if(hm_TagCheck(f,sortablecol)){f.className="sortablecol";}var z=s.rows.length-1;if(hm_TagCheck(f,bottomrow)){s.rows[z].className="sortbottom";}if((hm_TagCheck(f,defaultsort))||(hm_TagCheck(f,defaultsortD))){f.className="defaultsort";if(hm_TagCheck(f,defaultsortD)){f.setAttribute("hm.descend","1");}var x=A;}if((f.className=="sortablecol")||(f.className.indexOf("sortablecol")!=-1)||(f.className=="defaultsort")||(f.className.indexOf("defaultsort")!=-1)){d=true;if((f.className=="defaultsort")||(f.className.indexOf("defaultsort")!=-1)){f.innerHTML='<a href="#" class="sortheader" id="defaultsort'+l+'" title="'+sort_tip+'" onclick="ts_resortTable(this, '+A+');return false;">'+u+'<span class="sortarrow"><img src="'+image_path+v+image_none+'" title="'+sort_tip+'" alt="&darr;"/>&nbsp;</span></a>';}else{f.innerHTML='<a href="#" class="sortheader" title="'+sort_tip+'" onclick="ts_resortTable(this, '+A+');return false;">'+u+'<span class="sortarrow">&nbsp;<img src="'+image_path+v+image_none+'" title="'+sort_tip+'" alt="&darr;"/>&nbsp;</span></a>';}}else{var n=new Image();n.src=image_path+v+image_none;var p=n.width;var y=n.height;f.innerHTML=u+'&nbsp;<img src="'+image_path+v+image_empty+'" width="'+p+'" height="'+y+'"/>&nbsp;&nbsp;';}}if(!d){alert("Error! Sortable table with ID: "+l+" has no sortable columns.\nSortable tables must have at least one sortable column.");return;}if(altTables[l+"alternate"]){alternate(s);}var C=document.getElementById("defaultsort"+l);if(C){ts_resortTable(C,x);if(C.parentNode.getAttribute("hm.descend")=="1"){ts_resortTable(C,x);}}}function ts_resortTable(h,p){var r;var o=h.childNodes.length;for(var u=0;u<h.childNodes.length;u++){if(h.childNodes[u].tagName&&h.childNodes[u].tagName.toLowerCase()=="span"){r=h.childNodes[u];}}var a=ts_getInnerText(r);var b=h.parentNode;var c=p||b.cellIndex;var s=getParent(b,"TABLE");var l=s.id;var e=altTables[l+"iconprefix"];if(s.rows.length<=1){return;}var n="";var f=1;while(n==""&&f<s.tBodies[0].rows.length){var n=ts_getInnerText(s.tBodies[0].rows[f].cells[c]);n=trim(n);if(n.substr(0,4)=="<!--"||n.length==0){n="";}f++;}if(n==""){return;}sortfn=ts_sort_caseinsensitive;if(((n.match(/^(?=\d)(?:(?:(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})|(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))|(?:(?:0?[1-9])|(?:1[0-2]))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{2}))($|\ (?=\d)))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/))&&(!europeandate))||((n.match(/^((((0?[1-9]|[12]\d|3[01])[\.\-\/](0?[13578]|1[02])[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|((0?[1-9]|[12]\d|30)[\.\-\/](0?[13456789]|1[012])[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|((0?[1-9]|1\d|2[0-8])[\.\-\/]0?2[\.\-\/]((1[6-9]|[2-9]\d)?\d{2}))|(29[\.\-\/]0?2[\.\-\/]((1[6-9]|[2-9]\d)?(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)|00)))|(((0[1-9]|[12]\d|3[01])(0[13578]|1[02])((1[6-9]|[2-9]\d)?\d{2}))|((0[1-9]|[12]\d|30)(0[13456789]|1[012])((1[6-9]|[2-9]\d)?\d{2}))|((0[1-9]|1\d|2[0-8])02((1[6-9]|[2-9]\d)?\d{2}))|(2902((1[6-9]|[2-9]\d)?(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)|00))))$/))&&(europeandate))){sortfn=ts_sort_date;}var m=new RegExp(/^[^\w]{0,3}([\d.,]+)[^\w]{0,3}$/);if(n.match(m)){sortfn=ts_sort_numeric;}SORT_COLUMN_INDEX=c;var d=new Array();var g=new Array();for(k=0;k<s.tBodies.length;k++){for(f=0;f<s.tBodies[k].rows[0].length;f++){d[f]=s.tBodies[k].rows[0][f];}}for(k=0;k<s.tBodies.length;k++){if(!thead){for(j=1;j<s.tBodies[k].rows.length;j++){g[j-1]=s.tBodies[k].rows[j];}}else{for(j=0;j<s.tBodies[k].rows.length;j++){g[j]=s.tBodies[k].rows[j];}}}g.sort(sortfn);if(r.getAttribute("sortdir")=="down"){ARROW='&nbsp;<img src="'+image_path+e+image_down+'" title="'+sort_tip+'" alt="&darr;"/>&nbsp;';g.reverse();r.setAttribute("sortdir","up");}else{ARROW='&nbsp;<img src="'+image_path+e+image_up+'" title="'+sort_tip+'" alt="&uarr;"/>&nbsp;';r.setAttribute("sortdir","down");}for(f=0;f<g.length;f++){if(!g[f].className||(g[f].className&&(g[f].className.indexOf("sortbottom")==-1))){s.tBodies[0].appendChild(g[f]);}}for(f=0;f<g.length;f++){if(g[f].className&&(g[f].className.indexOf("sortbottom")!=-1)){s.tBodies[0].appendChild(g[f]);}}var q=document.getElementsByTagName("span");for(var u=0;u<q.length;u++){if(q[u].className=="sortarrow"){if(getParent(q[u],"table")==getParent(h,"table")){q[u].innerHTML='&nbsp;<img src="'+image_path+e+image_none+'" title="'+sort_tip+'" alt="&Dagger;" />&nbsp;';}}}r.innerHTML=ARROW;if(altTables[l+"alternate"]){alternate(s);}}function getParent(b,a){if(b==null){return null;}else{if(b.nodeType==1&&b.tagName.toLowerCase()==a.toLowerCase()){return b;}else{return getParent(b.parentNode,a);}}}function sort_date(a){dt="00000000";a=trim(a);a=date8(a);if(a.length==8){yr=a.substr(6,2);if(parseInt(yr)<50){yr="20"+yr;}else{yr="19"+yr;}}else{yr=a.substr(6,4);}if(europeandate==true){dt=yr+a.substr(3,2)+a.substr(0,2);return dt;}else{dt=yr+a.substr(0,2)+a.substr(3,2);return dt;}return dt;}function date8(b){b=b.replace(/^(\d[\.\/-])/,"0$1");b=b.replace(/[\.\/-](\d)(?!\d)/,"/0$1");return b;}function ts_sort_date(d,c){dt1=sort_date(ts_getInnerText(d.cells[SORT_COLUMN_INDEX]));dt1=trim(dt1);dt2=sort_date(ts_getInnerText(c.cells[SORT_COLUMN_INDEX]));dt2=trim(dt2);if(dt1==dt2){return 0;}if(dt1<dt2){return -1;}return 1;}function ts_sort_numeric(d,c){var e=ts_getInnerText(d.cells[SORT_COLUMN_INDEX]);e=clean_num(e);var f=ts_getInnerText(c.cells[SORT_COLUMN_INDEX]);f=clean_num(f);return compare_numeric(e,f);}function compare_numeric(d,c){var d=parseFloat(d);d=(isNaN(d)?0:d);var c=parseFloat(c);c=(isNaN(c)?0:c);return d-c;}function ts_sort_caseinsensitive(d,c){aa=ts_getInnerText(d.cells[SORT_COLUMN_INDEX]).toLowerCase();bb=ts_getInnerText(c.cells[SORT_COLUMN_INDEX]).toLowerCase();if(aa==bb){return 0;}if(aa<bb){return -1;}return 1;}function ts_sort_default(d,c){aa=ts_getInnerText(d.cells[SORT_COLUMN_INDEX]);bb=ts_getInnerText(c.cells[SORT_COLUMN_INDEX]);if(aa==bb){return 0;}if(aa<bb){return -1;}return 1;}function clean_num(b){var a=new RegExp(/[^-?0-9.]/g);if(germanNumbers){a=new RegExp(/[^-?0-9,]/g);}b=b.replace(a,"");return b;}function alternate(g){var e=g.id;var d=g.getElementsByTagName("tbody");var h=g.getElementsByTagName("td");for(var c=0;c<h.length;c++){h[c].style.backgroundColor="";}for(var c=0;c<d.length;c++){var f=d[c].getElementsByTagName("tr");for(var b=1;b<f.length;b++){if(((b%2)==0)){if(!(f[b].className.indexOf("odd")==-1)){f[b].className=f[b].className.replace("odd","even");}else{if(f[b].className.indexOf("even")==-1){f[b].className+=" even";}}}else{if(!(f[b].className.indexOf("even")==-1)){f[b].className=f[b].className.replace("even","odd");}else{if(f[b].className.indexOf("odd")==-1){f[b].className+=" odd";}}}}}var a;for(var c=1;c<f.length;c++){for(var b=0;b<f[c].cells.length;b++){f[c].cells[b].removeAttribute("bgColor");}if(f[c].className.indexOf("even")!=-1){a=altTables[e+"evenRowColor"];}if(f[c].className.indexOf("odd")!=-1){a=altTables[e+"oddRowColor"];}if(f[c].className.indexOf("sortbottom")!=-1){a=altTables[e+"lastRowColor"];}f[c].style.backgroundColor=a;}}