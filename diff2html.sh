#!/bin/bash
#set -x

file1="${1}"
file2="${2}"

mawk -v file1_name="${1}" -v file2_name="${2}" 'BEGIN {

	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\
 \"http://www.w3.org/TR/REC-html40/loose.dtd\">\
<html>\
	<head>\
    		<title>Differences between";
	print file1_name;
	print " and ";
	print file2_name;
	print "</title>\
	       <style>\
			TABLE { border-collapse: collapse; border-spacing: 0px; }\
			TD.linenum { color: #909090; \
			   text-align: right;\
			   vertical-align: top;\
			   font-weight: bold;\
			   border-right: 1px solid black;\
			   border-left: 1px solid black; }\
			TD.added { background-color: #DDDDFF; }\
			TD.modified { background-color: #BBFFBB; }\
			TD.removed { background-color: #FFCCCC; }\
			TD.normal { background-color: #FFFFE1; }\
		</style>\
	</head>\
</body>";
	print "<table>\
    <tr>\
        <th>&nbsp;</th>\
        <th width=\"45%\"><strong><big>",file1_name,"</big></strong></th>\
        <th>&nbsp;</th>\
        <th>&nbsp;</th>\
        <th width=\"45%\"><strong><big>",file2_name,"</big></strong></th>\
    </tr>";
	file1_lc=0;
	file2_lc=0;
	diff_line_lc=0;
	split("", del_arr);
	mod_index=0;
	}


function transformStr(str_to_replace) {
	gsub("\\&","\\&amp",str_to_replace);
	gsub("<","\\&lt",str_to_replace);
	gsub(">","\\&gt",str_to_replace);
	gsub("  ","\\&nbsp",str_to_replace);
	sub("^ ","\\&nbsp",str_to_replace);
	return str_to_replace;
}

function writeLine(linenum1,line1,linenum2,line2,type1,type2) {
	print "\t<tr>";
	print "\t\t<td class=\"linenum\">" linenum1 "</td>";
	print "\t\t<td class=\"" type1 "\">" line1 "</td>";
	print "\t\t<td width=\"16\">&nbsp;</td>";
	print "\t\t<td class=\"linenum\">" linenum2 "</td>";
	print "\t\t<td class=\"" type2 "\">" line2 "</td>";
	print "\t</tr>";
}

/^\-/{ 
	diff_str=substr($0,2);
	html_str=transformStr(diff_str);
	del_arr[array_len] = html_str;
	array_len++;
}

/^\*/{
	diff_str=substr($0,2);
	html_str=transformStr(diff_str);
	if (array_len > 0) {
		for (del_index in del_arr) {
			writeLine(file1_lc++,del_arr[del_index],"&nbsp;","&nbsp;","removed","removed");
			delete del_arr[del_index];
		}
		array_len=0;
	}
	writeLine(file1_lc++,html_str,file2_lc++,html_str,"normal","normal");
}

/^\+/{ 
	diff_str=substr($0,2);
	html_str=transformStr(diff_str);
	if (array_len > 0) {		
		#print array_len;
		#print "-" del_arr[array_len] "|" html_str;
		writeLine(file1_lc++,del_arr[mod_index],file2_lc++,html_str,"modified","modified");
		mod_index++;
		array_len--;
		if (array_len == 0) {
			delete del_arr;
			mod_index = 0;
		}
	} else {
		writeLine("&nbsp;","&nbsp;",file2_lc++,html_str,"added","added");
	}
}

END {

	print "		</table>\
		<hr/>\
    </body>\
    </html>";
}'  <(diff --unchanged-line-format='* %L' --new-line-format='+ %L' --old-line-format='- %L' $file1 $file2);
