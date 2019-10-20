#!/bin/bash
#set -x

file1="${1}"
file2="${2}"

mawk -v file1_name="${1}" -v file2_name="${2}" 'BEGIN {

	#Printing the header and file names.
	#css is default now.
	#had to add funtinality for custom css.
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
    	#Initializing line counter variables to 0.
	file1_lc=0;
	file2_lc=0;
	#This is used to initialize an empty array.
	#This is needed for compatibility with mawk.
	#Gawk is pretty nice to these.
	split("", del_arr);
	mod_index=0;
}

#Convert a caertain string chars with certain html chars.
function str2htm(str_to_replace) {
	gsub("\\&","\\&amp",str_to_replace);
	gsub("<","\\&lt",str_to_replace);
	gsub(">","\\&gt",str_to_replace);
	gsub("  ","\\&nbsp",str_to_replace);
	sub("^ ","\\&nbsp",str_to_replace);
	return str_to_replace;
}

#writing file lines as html formatted output with chnge type marked
#allowed type args - "modified", "added", "removed" and "normal"
function writeLine(linenum1,line1,linenum2,line2,type1,type2) {
	print "\t<tr>";
	print "\t\t<td class=\"linenum\">" linenum1 "</td>";
	print "\t\t<td class=\"" type1 "\">" line1 "</td>";
	print "\t\t<td width=\"16\">&nbsp;</td>";
	print "\t\t<td class=\"linenum\">" linenum2 "</td>";
	print "\t\t<td class=\"" type2 "\">" line2 "</td>";
	print "\t</tr>";
}

#diff line input is labelled as "marker line_input" where,
#marker can be +, - and *.

#Saving the html_str in del_arr.
#This is because only when next block after deletion comes,
#we can decide if the current block is deletion or modified.
#The length should be tracked manually in mawk. gawk offers
#a way to find length, but we use mawk way to have compatibility
/^\-/{ 
	diff_str=substr($0,2);
	html_str=str2htm(diff_str);
	del_arr[array_len] = html_str;
	array_len++;
}

#We first write the del_arr output, and then write the normal output.
/^\*/{
	diff_str=substr($0,2);
	html_str=str2htm(diff_str);
	if (array_len > 0) {
		for (del_index in del_arr) {
			writeLine(file1_lc++,del_arr[del_index],"&nbsp;","&nbsp;","removed","removed");
			delete del_arr[del_index];
		}
		array_len=0;
	}
	writeLine(file1_lc++,html_str,file2_lc++,html_str,"normal","normal");
}

#When we encounter a added block, if del_arr is not empty, we write 
#both  together as modified block. Else, if del_arr is empty, then
#write the line input as added block.
/^\+/{ 
	diff_str=substr($0,2);
	html_str=str2htm(diff_str);
	if (array_len > 0) {		
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
