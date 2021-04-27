# Personal Knowledge Container
This project, [PersonalKnowledgeContainer], abbreviated as [PKC], provides an executable script ([up.sh]) that installs a MediaWiki-based docker-based [microservice] in a network environment of your choice. After the installation, it can operate on your own machine with or without Internet connection.

## Context
After [microservice] technologies become ubiquitous, it is possible to organize personal knowledge using a personally operated [MediaWiki] services that could work even the computer is not connect to the Internet. This **off-line** capability will enable anyone to enjoy the power of open source software without worrying your data might be leaked to the public. However, to make sure that your own data will always be accessible to you, users of this self-operated service must have a simple procedure to perform data backup and restoration, so that data may continue to work after one switch to a different computer. Moreover, individuals shoud also be able to read their own data even the software for displaying them hasevolved to a new version that doesn't work with data stored with previous versions. This project intend to resolve this challenge by giving everyone the choice to run their own chosen version of MediaWiki software, given that all the images that have proven to work has publicly available images, so that even if the software has been abandoned, one may use [container-virtualization] technologies to continue operate the software.

## Goal
Create a basic set of services, files, and page content that help individuals to operate a MediaWiki website on any machines of their choosing, and allow them to continuously work with their own data set, independent of future changes.

## Success Criteria
1. Allow Individuals to install an instance of MediaWiki service by reading this REAME.md file.
2. Make all textual content, executable software images, installation scripts in the public domain, so that everyone can share and use them at will.
3. Provide instructions to learn about how to use [PKC] in the initial MediaWiki's database, so that people can start learning to use PKC through their own instance of MediaWiki.

# Implementation Process
The following text shows the required resources and action items for [PKC] installation.

## Required Resources
1. A computer that you have access to its "root" or "administrator" previledge.
2. Operatng Systems that support [Docker]: Windows 10, Mac OS X Big Sur 11.2.3 and Linux.
3. Under Windows 10 Environment, some VPN software might interfere with [Docker]'s Windows Subsystem for Linux, a.k.a. [WSL], you will need to remove VPN software before installing [Docker]. In case you don't want to remvoe your VPN software, or your Docker and Bash have compatibility issues, please try to [VirtualBox PKC] solution.
4. Access to the Internet during intallation time. Please try to perform the installation on a network with 10Mbps+ to the Internet. After installation, this system can operated without access to the Internet.

## Installation Procedure
1. Install [Docker], the Installation instructions and downloadable files can be found here: https://docs.docker.com/get-started/
2. Go to a [command line], or so called [terminal] application, move your working directory using the command "**[cd]**" for **change directory**, to a directory in your file system that you keep your working files. For Mac OS X and Linux operating systems, Terminal applications are bundled during installation. For Windows 10, we recommend you to use [Git Bash], when you install [git] for Windows, [Git Bash] is included the installation process.

Assume the directory you keep your working files is called: **Workspace**. Your terminal application should have something like this:

```
<machine_name>:Workspace <user_name>$
```

Download the entire package using [git]. You may copy the instruction as follows:

```
<machine_name>:Workspace <user_name>$ git clone https://github.com/benkoo/PKC.git
```

3. After the [git clone] instruction copied relevant data to your working directory, using the command [cd] to the **PKC** directory that contains the script ([up.sh]), and type: "./[up.sh]" to execute the script.

```
<machine_name>:Workspace <user_name>$ cd PersonalKnowledgeContainer
<machine_name>:PersonalKnowledgeContainer <user_name>$ ./up.sh
```

4. Open a browser: type the following URL to the browser's URL field: http://localhost:9352 or http://127.0.0.1:9352
5. Read the instructions in the [Main Page]. 

## Outcomes Expected
1. Every 30 minutes, all the changes you made to this local instance of MediaWiki will be automatically backed up to the directory's "backup/" sub-directory.
2. The textual content stored in MediaWiki's database can will be stored in an XML file: XLPLATEST.xml
3. All the uploaded files, assuming the file names are accepted by the host operating system, will be dumped to the "backup/MediaFile/" sub-directory.

## Boundary Conditions
1. We do not warrant any reliability, completeness, and accuracy of this installation procedure. **Any action you take upon this information and execute this script is at your own risk**, We will not be liable for any losses and damages in connection to the use of the actions and software prescribed here. 
2. We have only tested on a small number of machines and configurations, your mileage may vary.
3. Do not remove any of the files in the directory with "*backup/*", such as "*docker-compose.yml*" and the "*LocalSettings.php*". These files are the configuration files for [Docker] and [MediaWiki] respectively. Missing them, this system will stops to work.  
4. For the sake of reducing typos, the project has moved from https://github.com/xlp0/PersonalKnowledgeContainer to https://github.com/xlp0/PKC. For the current implementation of Github, these two git repository names point to the same source. When GitHub change this practice, it will change. We recommend you to use the shorter version.


[PersonalKnowledgeContainer]: https://github.com/xlp0/PersonalKnowledgeContainer
[container-virtualization]:https://searchitoperations.techtarget.com/definition/container-containerization-or-container-based-virtualization
[command line]:https://www.osc.edu/supercomputing/unix-cmds
[terminal]: https://www.techopedia.com/definition/28747/mac-terminal-mac-os-x#:~:text=The%20Mac%20Terminal%20is%20a,OS%20X%20versions%20through%20Lion.&text=Terminal%20allows%20users%20to%20modify,graphical%20user%20interface%20(GUI).
[PKC]: https://github.com/xlp0/PersonalKnowledgeContainer
[VirtualBox PKC]: https://github.com/xlp0/VirtualBox_PKC
[cd]:https://www.minitool.com/news/how-to-change-directory-in-cmd.html
[microservice]: https://www.bmc.com/blogs/microservices-architecture/
[Docker]: http://docker.io
[MediaWiki]: https://www.mediawiki.org/wiki/MediaWiki
[Main Page]: http://localhost:9352/index.php/Main_Page
[WSL]: https://docs.docker.com/docker-for-windows/wsl/
[up.sh]:https://github.com/xlp0/PKC/blob/main/up.sh
[git]:https://git-scm.com/
[Git Installation]:https://git-scm.com/
[Git Bash]: https://gitforwindows.org/
[git clone]:https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-clone#:~:text=git%20clone%20is%20a%20Git,copy%20of%20the%20target%20repository.
