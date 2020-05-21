#!/bin/bash

echo 'synopsis: '$0' [-help]' 1>&2;
echo '          '$0' SRC TGT' 1>&2;
echo '  -help list all supported formats' 1>&2
echo '  SRC   source format' 1>&2;
echo '  TGT   target format' 1>&2;
echo 'read CoNLL data from stdin, write to stdout' 1>&2
echo 'transform from SRC format to TGT format' 1>&2

# NOTE: we expect necessary libraries to be provided by CoNLL-RDF, if that changes, this script may will
# NOTE: this script is slow because it checks dependencies and performs compilations, revise for real applications

if echo $1 | egrep . >&/dev/null; then

	##########
	# config #
	##########
	# adjust to your system

	# set to your CoNLL-RDF home directory
	CONLL_RDF=conll-rdf

	# set to your java execs
	JAVA=java
	JAVAC=javac

	# system requirements:
	# git 
	# rapper (http://librdf.org/raptor/)
	# java

	########
	# init #
	########
	# do not touch

	# setup CoNLL-RDF
	RUN=$CONLL_RDF/run.sh;
	if [ ! -e $RUN ]; then
		mkdir -p $CONLL_RDF >&/dev/null;
		git clone --single-branch https://github.com/acoli-repo/conll-rdf.git $CONLL_RDF
	fi;
	EXTRACT=$RUN' CoNLLStreamExtractor'
	UPDATE=$RUN' CoNLLRDFUpdater'
	FORMAT=$RUN' CoNLLRDFFormatter'
	OWL=$CONLL_RDF/owl/conll.ttl
	chmod u+x $RUN
	chmod u+x $CONLL_RDF/compile.sh; 
	$CONLL_RDF/compile.sh;
		
	FORMATS=`rapper -i turtle $OWL 2>/dev/null | \
		grep '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://ufal.mff.cuni.cz/conll2009-st/task-description.html#Dialect>' | \
		sed s/'>\s\s*<'/'>\t<'/g | cut -f 1 | \
		sed s/'.*#\([^>]*\)>.*'/'\1'/ | sort -u`

	# determines the classpath
	HOME=`echo $0 | sed -e s/'[^\/]*$'//`'.';
	cd $HOME
	HOME=`pwd -P`;
	cd - >&/dev/null;

	TGT=$HOME/bin

	mkdir $TGT >&/dev/null;

	CLASSPATH=$TGT":"`find $CONLL_RDF/lib | perl -pe 's/\n/:/g;' | sed s/':$'//`;
	if [ $OSTYPE = "cygwin" ]; then
		TGT=`cygpath -wa $HOME/bin`;
		CLASSPATH=$TGT;
		for lib in `find $CONLL_RDF/lib`; do
			CLASSPATH=$CLASSPATH';'`cygpath -wa $lib`
		done;
	fi;

	# updates CoNLL-transform files if necessary
	JAVAS=$(
		cd $HOME;
		for java in `find  . | egrep 'java$'`; do
			class=`echo $java | sed -e s/'src\/'/'bin\/'/ -e s/'java$'/'class'/;`
			if [ ! -e $class ]; then
				echo $java;
			else if [ $java -nt $class ]; then
				echo $java;
				fi;
			fi;
		done;
		)

	cd $HOME
		if echo $JAVAS | grep java >/dev/null; then
			$JAVAC -d $TGT -classpath $CLASSPATH $JAVAS;
		fi;
	cd - >&/dev/null

	TRANSFORM=org/acoli/conll/transform/CoNLLTransform

	#####################
	# extended help msg #
	#####################
	# -help flag, instead of processing

	if echo $1 | grep -i '-help' >&/dev/null; then
		echo $FORMATS | wc -w | sed s/'$'/' supported SRC and TGT formats: '/ 1>&2
		for format in $FORMATS; do
			echo '  '$format 1>&2
		done;
		echo 1>&2
	fi;

	##############
	# processing #
	##############
	# cannot be combined with -help

	# check args
	if echo $2 | egrep . >& /dev/null ; then
		if echo $FORMATS | egrep -i $1 | egrep -i $2 >& /dev/null; then
			SRC=$1;
			TGT=$2;

	# check installation
			if [ ! -e $TGT/$TRANSFORM.class ]; then
				echo 'error: compilation failed, did not find '$TRANSFORM' class' 1>&2;
			else

	# transform
				$JAVA -Dfile.encoding=UTF8 -classpath $CLASSPATH $TRANSFORM $SRC $TGT
				#could also add  -Dlog4j.configuration=file:'src/log4j.properties' for another log4j config
			fi;
		fi;
	fi;	
fi;