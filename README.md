# diff2html
A script that employs awk and bash to html output of diff between 2 files quickly*.

This aims to generates output similar to EugenDueck's script but in a faster way. (https://github.com/EugenDueck/diff2html/blob/master/diff2html)
But for diff of 67,000 line file, it took 12 min 40 sec, whereas diff took a fraction of second. That's why I thought there is something fishy about the script, however clean implementation seems to be.

## TL;DR
Using shell script for this task makes the script very slow for any non trivial files exceeding 10000 loc. I needed something like this and when I used EugenDueck's script I noticed the inherent vice. And, when I used awk for this it resulted in more succint and readable script. Also for the big file I mentioned processing time reduced from 12 min 40 sec to 0.2 sec!

## Confession:
I am just a passerby in scripting world and I don't claim any correctness of my opinions. This is the impression I got when I worked throgh this problems and it would really helpful for me if anybody could give some insights on these kind of scripts. thanks in advance.
Also this script, the core funtionality of the mentioned script. And, other things are to be to be added. Please feel free to give any suggestions.

## How it works:
* To meke it easy for awk to process diff as single input we are labeling the input(+ - added, - - delete, * - same) by this:
 ```
 diff --unchanged-line-format='* %L' --new-line-format='+ %L' --old-line-format='- %L' file1 file2
 ```
* Then we read each line and act based on labels we have.
* For deletion we don't immediately write it to output, if we encounter addition after deletion block, we write the addition block as modified. Else, we write the whole deletion block's html output and then proceed for the currrent input.

That's it. Nice??

## Rant:
But, however good the script itself is shell is hardly a tool for such heavy lifing. 

Python is nice glue language, it's like a very handy catapult with limited range and accuracy. But, languages like awk is so powerful but for limited problems.

It's like a super precise sniper that is pointing to a specific target, all you have to do is to pull the trigger. The caveat is that it is a gun that is cemented to point a particular target marked 'X' by language designer, and all the nice things it has leave you wondering how nice it would be if all problems would just knowingly come around and in stand in place marked 'X'.
