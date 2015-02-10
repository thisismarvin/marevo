#
# Copyright (c) 2015, Oleksandr Kyrylchuk, Sergiy Shamov, Oleksandr Khodyrev
# All rights reserved.
# 
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions are met:
#        * Redistributions of source code must retain the above copyright
#          notice, this list of conditions and the following disclaimer.
#       * Redistributions in binary form must reproduce the above copyright
#          notice, this list of conditions and the following disclaimer in the
#          documentation and/or other materials provided with the distribution.
#        * Neither the name of the <organization> nor the
#          names of its contributors may be used to endorse or promote products
#          derived from this software without specific prior written permission.
#    
#    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#    DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
#    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#############################################################################
#                                                                            #
#                                                                            #
#    Installation script for PyQt4 + SIP                                     #
#                                                                            #
#                                                                            #
#    $1 - Project name                                                       #
#    $2 - Base directory                                                     #
#                                                                            #
#    EXAMPLE:                                                                #
#                                                                            #
#    Project name:          myproj                                           #
#    Base directory:        /home/me/work                                    #
#    Full path to project:  /home/me/work/myproj                             #
#                                                                            #
##############################################################################


# SET UP THE COMMON VARIABLES

# Project directory (full path)

PROJDIR=$2/$1

# These variables will be used for getting the exact version of PyQt and SIP

SIP_VERSION=4.16.5
PYQT_VERSION=4.11.3

# Flag for checking the existence of required packages
CHECK=

# FUNCTIONS

function check_exist {
	# Checks the existance of programme/package

	local str="type -p "$1
	
	if [ -z `$str` ]; then
		#echo 'zero'
		CHECK=
	else
		#echo `$str`
		CHECK=1
	fi

}

function run_install {
	# Invokes the installation process for package passed
	#
	# $1 - package name
	# $2 - key (way of installation):
	#	-a	-> apt-get
	#	-p	-> pip
	#

	if [ $2 = "-a" ]; then
		sudo apt-get install -y $1
	elif [ $2 = "-p" ]; then
		echo 'wait.. PIP is not implemented here.'
	else
		echo 'No way: how are you going to install it, dude?'
	fi

}

function check_req {
	# Checking the existence of packages
	#
	# $1 - programme name
	# $2 - package name

local PACK=$2
	if [ -z $PACK ]; then
		PACK=$1
	fi
	check_exist $1
	if [ -z $CHECK ]; then
		echo 'Package '$1' has not been installed yet.'
	run_install $PACK -a
	else
		echo 'Package '$1' is already installed.'
	fi
}

function setup_sip {
	# Download and set up the SIP

	cd $PROJDIR/repo

	wget http://sourceforge.net/projects/pyqt/files/sip/sip-$SIP_VERSION/sip-$SIP_VERSION.tar.gz

	tar -xvf sip-$SIP_VERSION.tar.gz

	cd sip-$SIP_VERSION/
	python configure.py 
	make
	sudo make install
}

function setup_qt {
	# Download and set up PyQt

	cd $PROJDIR/repo

	wget http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-$PYQT_VERSION/PyQt-x11-gpl-$PYQT_VERSION.tar.gz
	tar -xvf PyQt-x11-gpl-$PYQT_VERSION.tar.gz

	cd PyQt-x11-gpl-$PYQT_VERSION/

python configure-ng.py <<!
yes
!

make

sudo make install

}


function main {
	# The main function


# Checking requirements
check_req virtualenv python-virtualenv 
check_req qmake qt4-qmake
check_req python-dev
check_req libqt4-dev

# Fix broken dependencies
sudo dpkg -f install

# Set up the environment

if [ -z `type -p virtualenv` ]; then
	# We haven't installed virtualenv because of some troubles...
	echo '[ERROR] Virtualenv still is not installed. Exit...'
	exit 1
fi

# Create the project directory and go there
mkdir $PROJDIR

cd $PROJDIR

# Create virtual environment

virtualenv .venv
mkdir .repo
cd $PROJDIR/.repo

# Activate the virtual environment

. $PROJDIR/.venv/bin/activate

# Set up SIP and PyQt
setup_sip
setup_qt

# Finishing the installation: tests

python -c "from PyQt4.QtGui import *"

# Exit from the virtual environment
deactivate

# Clear directories with packages downloaded
cd $PROJDIR
sudo rm -rf $PROJDIR/.repo/*
sudo rmdir $PROJDIR/.repo

}

# RUN THE SCRIPT
main $1 $2

