all:	merge-ches cp-ches
nohup:
	nohup make all > ches.log &
cp-ches:
	Scripts/cp-ches.pl 'CHES-TSV/*.tsv' '../ParlaMint-*'
merge-ches:
	rm -f CHES-TSV/*.tsv
	Scripts/merge-ches.pl CHES2ParlaMint-parties.tsv 'Sources-CHES/*.tsv' CHES-TSV

######################VARIABLES
s = java -jar /usr/share/java/saxon.jar
P = parallel --gnu --halt 2
