# DataScience Dockerfile - README

This Docker file can be used to set up an environment for A Data Science team.

It will set up the following:

* Basic Unix/Linux commands
* ssh client and server
* mail services
* Java and Maven
* Python and some related libraries through Anocanda.
* R and some related packages specified in Rscript file.
* Creats user(s) and sets up their environment (i.e. $PATH)
* and launches services such as ssh when the container loads


You either need to clone this repository or copy and paste the bash script file. If you do copy/paste the bash script, you should uncomment the first section of it where it attemps to clone this repository.

After you have placed this bash script in your home directory, to automatically install docker, run the following command

	bash install-docker.bash 

This will prompt a question about your desired name/tag fot the container. Go ahead and type in your container name and hit enter.
When running the script is finished (it will take a while), it will create the image and also will automatically run and launch the container. To exit without stopping the container press

	ctrl+p
	ctrl+q
and then exit the VM.

Using your user name and the ip-address of the machine (VM), you can now directly log in to your account on the container; in oppose to the traditional way in which you had to first log in to the VM and then, attach to the container.  To do so use below command;

	ssh -p 2222 user-name@ip-address

This will ask for your password which is the password in the dockerfile. Just make sure when you log in for the first time, you change your password with below command to make it secure; otherwise everyone with access to the dockerfile knows your password.
	
	passwd
	
NOTE: For running ssh services and/or Apache web services, you need to make sure these ports on your VM are open and enabled; 2222, 80, 4430



# Activate public host for jupyter notebook on your account
1- *Create a jupyter config file*: with below command

	jupyter notebook --generate-config

2- *Create Password*: Launch python interactively with typing up 

	python

inside python environment type in below commands and create a password for your notebook server. You will need later to type in this password for accessing yout notebook.

	from notebook.auth import passwd
	passwd()

after you type in your desired password, you will get a hashed password like below string. Copy it to your clipboard;

	sha1:67c9e60bb8b6:9ffede0825894254b2e042ea597d771089e11aed'

3- *Update your jupyter notebook config file*: open your config file with a text editor, it should be located at

	/home/YourUserName/.jupyter/jupyter_notebook_config.py

In the file look for "c.NotebookApp.password",uncomment and add your hashed password:

	c.NotebookApp.password = u'sha1:67c9e60bb8b6:9ffede0825894254b2e042ea597d771089e11aed'

In the same file, look for "c.NotebookApp.ip", uncomment and edit it as:

	c.NotebookApp.ip = '*'

In same file look for "c.NotebookApp.port", uncomment and edit it as:

	c.NotebookApp.port =YourDesiredPortNumber    ** By default it is port 8888 **

Save the file and exit.


4- *Access your jupyter notebook on your local machine* by first launching it on your remore host (here it is your account on the container):
	jupyter notebook

on your local machine (personal computer), access a web browser and type in:
	ip-address:PortNumberChosenInStep3

you will be asked for your password.

## NOTE: do not forget to open your chosen port on the vm. Also, when running your container -below command in install-docker.bash- you need to map your chosen port from vm to the same port on the container: 
	sudo docker run --name $TagName -i -t -v ~/data:/home/DS-Production/Archive -p 2222:22 -p 80:80 -p 4430:443 -p ChosenPort:ChosenPort $(sudo docker images -q|head -1)

## NOTE: On some occasions, service cron start fails inside the container or even at the entrypoint. The quick solution in the meantime is to run below command when the container is launched for the first time
	sudo /usr/sbin/cron 
	
