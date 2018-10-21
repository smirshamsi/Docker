### Docker file ###

##################################################
FROM ubuntu:latest
#FROM nickistre/ubuntu-lamp
MAINTAINER Sahar Mirshamsi "sahar.mirshamsi@gmail.com"

############ Set user and Install wget ###########
USER root

RUN apt-get update
RUN apt-get install -y wget

#RUN apt-get install -y apache2
RUN apt-get install -y openssh-client
RUN apt-get install -y openssh-server
RUN apt-get update
RUN apt-get install -y libssl-dev
RUN apt-get install -y libsasl2-dev
RUN apt-get install -y net-tools
RUN apt-get install -y htop
RUN apt-get install -y screen
RUN apt-get install -y curl
RUN apt-get install -y sudo
RUN apt-get install -y git
RUN apt-get install -y bc
RUN apt-get install -y nano
RUN /etc/init.d/ssh start

######### Install Java and related packages ##
RUN  apt-get update
RUN  apt-get install -y default-jdk
RUN  apt-get install -y maven

########### Python Installation ##############
RUN mkdir /conda
RUN chmod 775 /conda
RUN apt-get update
RUN apt-get install -y bzip2
RUN wget https://repo.continuum.io/archive/Anaconda2-4.2.0-Linux-x86_64.sh -O ~/Anaconda.sh
RUN printf '\nyes\n/conda/anaconda2\nyes' |bash ~/Anaconda.sh
#RUN echo 'export PATH=/root/anaconda2/bin:$PATH\n'\
#>> ~/.bashrc

#RUN tail /root/.bashrc
ENV PATH /conda/anaconda2/bin:$PATH
RUN echo $PATH
RUN conda --v
#RUN  apt-get update
#RUN  apt-get install -y python-pymssql

RUN conda install -c anaconda freetds
#RUN conda install -c anaconda pymssql
#RUN conda install -c prometeia pymssql
RUN conda install -c conda-forge pymssql 
#RUN conda install -c ioos folium=0.2.1
RUN pip install utm
RUN pip install folium
######### Install Java and related packages ##
#RUN  apt-get update
#RUN  apt-get install -y default-jdk
#RUN  apt-get install -y maven

############ R and Libraries Installation ########
RUN  apt-get update
RUN  apt-get install -y r-base r-base-dev

RUN cp /etc/R/Rprofile.site ~/.Rprofile
RUN echo 'local({\n\
  r <- getOption("repos")\n\
  r["CRAN"] <- "http://cran.cnr.berkeley.edu/"\n\
  options(repos = r)\n\
})\n'\
>> /etc/R/Rprofile.site

RUN  apt-get update &&  apt-get install -y libgdal-dev libproj-dev
RUN R CMD javareconf
RUN echo 'install.packages("RJDBC")\n\
# Installing "plyr" manually, this package is needed for "scales" package!\n\
system("wget https://launchpad.net/ubuntu/+archive/primary/+files/r-cran-plyr_1.8.1.orig.tar.gz")\n\
wd<-getwd()\n\
install.packages("Rcpp")\n\
install.packages(paste(wd,"/r-cran-plyr_1.8.1.orig.tar.gz",sep=""),repos=NULL)\n\
system("rm r-cran-plyr_1.8.1.orig.tar.gz")\n\
install.packages("scales")\n\
install.packages("RColorBrewer")\n\
install.packages("lubridate")\n\
install.packages("deldir")\n\
install.packages("plotrix")\n\
install.packages("chron")\n\
install.packages("KernSmooth")\n\
install.packages("raster")\n\
install.packages("maps")\n\
install.packages("maptools")\n\
install.packages("dismo")\n\
install.packages("ggmap")\n\
install.packages("jsonlite")\n\
install.packages("openxlsx")\n\
install.packages("rgdal")\n\
install.packages("timeDate")\n\
install.packages("yaml")\n'\
install.packages("mongolite")\n'\
install.packages("slackr")\n'\
install.packages("OpenStreetMap")\n'\
install.packages("spatial")\n'\
install.packages("rgeos")\n'\
install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))\n'\
devtools::install_github('IRkernel/IRkernel')\n'\
IRkernel::installspec(user = FALSE)\n'\
>> ~/install_script.R

RUN Rscript ~/install_script.R
RUN rm ~/install_script.R

########## MongoDB Installation ##############
RUN  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" |  tee /etc/apt/sources.list.d/mongodb-org-3.0.list
RUN  apt-get update
RUN  apt-get install -y mongodb-org
#RUN  service mongodb start

######### Install Mail Services ##############
RUN  apt-get update
RUN DEBIAN_FRONTEND=noninteractive  apt-get install -y mailutils
RUN grep -q "^message_size_limit=" /etc/postfix/main.cf && sed "s/^message_size_limit=.*/message_size_limit=0/" -i /etc/postfix/main.cf || sed "$ a\message_size_limit=0" -i /etc/postfix/main.cf
#RUN reload /etc/postfix/main.cf

######### Install SVN (for Feta) #############
RUN  apt-get update
RUN  apt-get install -y subversion

######### Install vim ########################
RUN apt-get update
RUN apt-get install -y vim

######### Install Cron #######################
RUN apt-get update
RUN apt-get install -y cron

######### Install mssql ######################
RUN apt-get install apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list
RUN apt-get update
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mssql-tools

######### Create user and adjust settings ####
USER root
RUN useradd -ms /bin/bash Sahar
RUN echo 'Sahar:123456'|chpasswd
RUN adduser Sahar sudo

USER Sahar
RUN echo 'export PATH=/conda/anaconda2/bin:$PATH\n'\ >> ~/.bashrc

######## Set Directory for Docker ############
WORKDIR /home

######## Start Services ######################
USER root
RUN echo '/etc/init.d/ssh start\n' >> /service_start.sh

ENTRYPOINT service ssh restart && service cron restart && service apache2 restart && service postfix start && bash
