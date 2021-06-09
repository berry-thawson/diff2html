# diff2html
A script that employs awk and bash to html output of diff between 2 files quickly*.

This aims to generates output similar to EugenDueck's script but in a faster way. (https://github.com/EugenDueck/diff2html/blob/master/diff2html)

Update :

The reference project is not hosted on the github anymore. But, there is an archived version available from wayback machine (http://web.archive.org/web/20180612205114/https://github.com/EugenDueck/diff2html).

And also, it is hosted in sourceforge too(https://sourceforge.net/projects/diff2html/).

But for diff of 67,000 line file, it took 12 min 40 sec, whereas diff took a fraction of second. That's why I thought there is something fishy about the script, however clean implementation seems to be.

## Requirements:
This script employs awk and I checked it against gawk 4.1.3 and mawk 1.3.3. These were the versions I encountered in many systems. Please suggest if there are any other variants that needs to be supported.

## Usage:
Just make the script executable and run it like this
```
diff2html.sh /path/to/file1.txt /path/to/file2.txt
```

## How it works:
* To make it easy for awk to process diff as single input we are labeling the input(+ - added, - - delete, * - same) by this:
 ```
 diff --unchanged-line-format='* %L' --new-line-format='+ %L' --old-line-format='- %L' file1 file2
 ```
* Then we read each line and act based on labels we have.
* For deletion we don't immediately write it to output, if we encounter addition after deletion block, we write both addition and deletion block together as modified. Else, we write the whole deletion block's html output and then proceed for the currrent input (i.e. unchanged input).

That's it.
Please refer the script itself for further details. It is commented in detail and the script itself should be simple enough. Please reach out if anything is wrong.

## TL;DR
Using shell script for this task makes the script very slow for any non trivial files exceeding 10000 loc. I needed something like this and when I used EugenDueck's script I noticed the inherent vice.  Also, there were some bugs in the the formatted output. And, when I used awk for this it resulted in more succint and readable script. Also for the big file I mentioned processing time reduced from 12 min 40 sec to 0.2 sec!

## Confession:
I am just a passerby in scripting world and I don't claim any correctness of my opinions. This is the impression I got when I worked through this problems and it would really helpful for me if anybody could give some insights on these kind of scripts. Thanks in advance.
Also this script, the replicates the core funtionality of the mentioned script but by different means. Other things are to be to be added. Please feel free to give any suggestions.

## Rant:
But, however good the script itself is shell is hardly a tool for such heavy lifing. 

Python is nice glue language, it's like a very handy catapult with limited range and accuracy. But, languages like awk is so powerful but for limited problems.

It's like a super precise sniper that is pointing to a specific target, all you have to do is to pull the trigger. The caveat is that it is a gun that is cemented to point a particular target marked 'X' by language designer, and all the nice things it has leave you wondering how nice it would be if all problems would just knowingly come around and in stand in place marked 'X'. I think this problem can be persuaded in such a way, there we have the script.
