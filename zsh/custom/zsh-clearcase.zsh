# Clearcase Completion!!!
# Last update:  07/21/99  08:44 PM  (Edition: 3)
# http://www.zsh.org/mla/users/1999/msg00566.html

# arrays
ctcmds=(annotate apropos catcr catcs cd checkin checkout checkvob chevent \
	chpool chtype complete_migration cptype describe diff diffcr edcs \
	endview find findmerge getcache getlog help hostinfo ln lock ls \
	lscheckout lsclients lsdo lshistory lslock lspool lsprivate lsregion \
	lsreplica lstype lsview lsvob lsvtree man merge mkattr mkattype \
	mkbranch mkbrtype mkdir mkelem mkeltype mkhlink mkhltype mklabel \
	mklbtype mkpool mkregion mktag mktrigger mktrtype mkview mkvob mount \
	mv protect protectvob pwd pwv quit recoverview reformatview \
	reformatvob register relocate rename reserve rmattr rmbranch rmdo \
	rmelem rmhlink rmlabel rmmerge rmname rmpool rmregion rmtag rmtrigger \
	rmtype rmver rmview rmvob setcache setcs setview shell space \
	startview umount uncheckout unlock unregister unreserve winkin)

# functions
function listlabels { reply=(`cleartool lstype -lbtype -short`); }
function listview { reply=(`cleartool lsview -short`); }
function listview2 { reply=(`cleartool lsview | awk '{print $NF}'`); }
function listvobs { reply=(`cleartool lsvob -short`); }
function listco { reply=(`cleartool lsco -short`); }
#function listco {
# reply=(`( cd $(dirname ${1:-.}); ls -d *(/ND); cleartool lsco -short)`);
#}
function listcs { reply=(`ls ~basic/ClearCase/cs*`); }

# 'W[1,ci|checkin|unco|uncheckout]' -K listco -

compctl -f -x \
'p[1]' -k ctcmds - \
'W[1,ci|checkin] S[-]' -k "(-c -nc -cfile -cq -cqe -nwarn -cr -ptime \
			    -keep -rm -from -identical -cwork)" - \
'W[1,mkdir] S[-]' -k "(-c -nc -cfile -cq -cqe )" - \
'W[1,mkbrtype|mklbtype] S[-]' -k "(-replace -global -ordinary -pbranch \
				   -shared -c -cfile -cq -cqe -nc)" - \
'W[1,co|checkout] S[-]' -k "(-c -nc -reserved -unreserved -out -ndate \
			     -branch -version -nwarn -cfile -cq -cqe -nc)" - \
'W[1,unco|uncheckout] S[-]' -k "(-rm -keep -cwork)" - \
'w[1,catcr] S[-]' -k "(-flat -recurse -short -long -union -makefile \
		       -select -ci -type -element_only -view_only \
		       -ciritcal_only -name -zero -nxname)" - \
'w[1,catcs] S[-]' -k "(-tag)" - \
'w[1,chevent] S[-]' -k "(-c -cq -cfile -cqe -nc -append -insert -replace \
			 -event -invob -pname)" - \
'w[1,diff] S[-]' -k "(-graphical -hstack -vstack -tiny -window -predecessor \
		      -serial_format -options -diff_format -columns)" - \
'w[1,find] S[-]' -k "(-all -visible -nvisible -avobs -name -depth \
		      -recurse -directory -cview -user -group -type \
		      -follow -nxname -element -branch -version \
		      -print -exec -ok)" - \
'w[1,ln] S[-]' -k "(-c -nc -slink -cq -cqe -nc -nco -force)" - \
'w[1,ls] S[-]' -k "(-recurse -directory -short -long -vob_only -view_only \
		    -nxname -visible)" - \
'w[1,lsprivate] S[-]' -k "(-tag -invob -long -short -co -do -other)" - \
'W[1,lsco|lscheckout] S[-]' -k "(-short -long -fmt -cview -brtype -me -user \
				 -recurse -directory -all -avobs \
				 -areplicas)" - \
'w[1,lshistory] S[-]' -k "(-graphical -nopreferences -minor -short -long \
			   -fmt -minor -nco -since -user \
			   -branch -eventid -recurse -directory -all \
			   -avobs)" - \
'W[1,lsview|lsvob] S[-]' -k "(-short -long -host -region -storage -uuid)" - \
'w[1,lsvtree] S[-]' -k "(-graphical -nrecurse -short -branch -nmerge -all \
			 -nco -options)" - \
'w[1,lstype] S[-]' -k "(-eltype -brtype -lbtype -trtype -short -long)" - \
'w[1,man]' -k ctcmds - \
'w[1,mkelem] S[-]' -k "(-c -nc -ci -cqe -cfile -master -nwarn -ptime -nco \
			-eltype)" - \
'w[1,mklabel] S[-]' -k "(-c -nc -cq -cqe -cfile -replace -recurse -config \
			 -version -select -ci -type -name -config)" - \
'w[1,mklabel] p[2]' -X "There are %n labels:" -K listlabels - \
'W[1,mount|umount]' -K listvobs - \
'w[1,protect] S[-]' -k "(-chown -chgrp -chmod -recurse -c -nc -cq -cqe -file \
			 -directory -pname)" - \
'w[1,setview]' -K listview - \
'w[1,rmview]' -K listview2 - \
'w[1,setcs] S[-]' -k "(-current -default -tag)" - \
'w[1,setcs]' -K listcs - \
'c[-1,-user]' -u - \
'c[-1,-chown]' -u - \
'c[-1,-tag]' -K listview - \
-- cleartool ct
