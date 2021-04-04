# PersonalKnowledgeContainer
This project, [Personal Knowledge Container], abbreviated as [PKC] provides an executable script that installs a MediaWiki-based Knowledge Container for small organizations.

## Context
After [microservice] technologies become ubiquitous, it is possible to organize personal knowledge using a personally operated [MediaWiki] services that could work even the computer is not connect to the Internet. This ````off-line```` capability will enable anyone to enjoy the power of open source software without worrying your data might be leaked to the public. However, to make sure that your own data is reliable enough, users of this self-operated service might have a simple procedure to perform data backup and restoration. Moreover, individuals shoud laos be able to read their own data even the software for displaying them hasevolved to a new version that doesn't work with data stored with previous versions. This project intend to resolve this challenge by giving everyone the choice to run their own chosen version of MediaWiki software, given that all the images that have proven to work has publicly available images, so that even if the software has been abandoned, one may use [[container-virtualization]] technologies to continue operate the software.

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
3. Under Windows 10 Environment, some VPN software might interfere with [Docker]'s Windows Subsystem for Linux, a.k.a. [WSL], you will need to remove VPN software before installing [Docker].
4. Access to the Internet during intallation time. Please try to perform the installation on a network with 10Mbps+ to the Internet. After installation, this system can operated without access to the Internet.

## Installation Procedure
1. Install [Docker], the Installation instructions and downloadable files can be found here: https://docs.docker.com/get-started/
2. Download the following script: [up.sh]. Ideally, you should just [git] clone this project. To download [git], go to [Git Installation]. 
3. Go to a Terminal application, change directory ([cd]) to a directory in your file system that you keep your working files. For Mac OS X and Linux operating systems, Terminal applications are bundled during installation. For Windows 10, we recommend you to use [Git Bash], when you install [git] for Windows, [Git Bash] is included the installation process.
4. Go to the directory that contains this script ([up.sh]), and type: "./[up.sh]" to execute the script.
5. Open a browser: type the following URL to the browser's URL field: http://localhost:9352 or http://127.0.0.1:9352
6. Read the instructions in the [Main Page]. 

## Outcomes Expected
1. Every 30 minutes, all the changes you made to this local instance of MediaWiki will be automatically backed up to the directory's "backup/" sub-directory.
2. The textual content stored in MediaWiki's database can will be stored in an XML file: XLPLATEST.xml
3. All the uploaded files, assuming the file names are accepted by the host operating system, will be dumped to the "backup/MediaFile/" sub-directory.

## Boundary Conditions
1. We do not warrant any reliability, completeness, and accuracy of this installation procedure. **Any action you take upon this information and execute this script is at your own risk**, We will not be liable for any losses and damages in connection to the use of the actions and software prescribed here. 
2. We have only tested on a small number of machines and configurations, your mileage may vary.
3. Do not remove any of the files in the directory with "*backup/*", such as "*docker-compose.yml*" and the "*LocalSettings.php*". These files are the configuration files for [Docker] and [MediaWiki] respectively. Missing them, this system will stops to work.  


[Personal Knowledge Container]: https://github.com/benkoo/PersonalKnowledgeContainer/edit/main/README.md
[PKC]: https://github.com/benkoo/PersonalKnowledgeContainer/edit/main/README.md
[microservice]: https://www.bmc.com/blogs/microservices-architecture/
[Docker]: http://docker.io
[MediaWiki]: https://www.mediawiki.org/wiki/MediaWiki
[Main Page]: http://localhost:9352/index.php/Main_Page
[WSL]: https://docs.docker.com/docker-for-windows/wsl/
[up.sh]:https://github.com/benkoo/PersonalKnowledgeContainer/blob/main/up.sh
[git]:https://git-scm.com/
[Git Installation]:https://git-scm.com/
[Git Bash]: https://gitforwindows.org/
