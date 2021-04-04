# PersonalKnowledgeContainer
This project, [[Personal Knowledge Container]], abbreviated as [[PKC]] provides an executable script that installs a MediaWiki-based Knowledge Container for small organizations.

## Context
After [[microservice]] technologies become ubiquitous, it is possible to organize personal knowledge using locally operated [[MediaWiki]] services. The main challenge in using this Web-based tools is how data can be backed-up and restored, so that individuals can always get to their own content data even the software for displaying them has updated or evolved to a point that introduces incompatibility. This project intend to resolve this challenge by giving everyone the choice to run their own chosen version of MediaWiki software, given that all the images that have proven to work has publicly available images, so that even if the software has been abandoned, one may use [[container-virtualization]] technologies to continue operate the software.

## Goal
Create a basic set of services, files, and page content that help individuals to operate a MediaWiki website on any machines of their choosing, and allow them to continuously work with their own data set, independent of future changes.

## Success Criteria
1. Allow Individuals to install an instance of MediaWiki service by reading this REAME.md file.
2. Make all textual content, executable software images, installation scripts in the public domain, so that everyone can share and use them at will.
3. Provide instructions to learn about how to use [[PKC]] in the initial MediaWiki's database, so that people can start learning to use PKC through their own instance of MediaWiki.

# Implementation Process
The following text shows the required resources and action items for [[PKC]] installation.

## Required Resources
1. A computer that you have access to its "root" or "administrator" previledge.
2. Operatng Systems that support Docker: Windows 10, Mac OS X Big Sur 11.2.3 and Linux.
3. Access to the Internet during intallation time. We you perform the installation on a network with 10Mbps+ to the Internet. After installation, this system can operated without access to the Internet.

## Installation Procedure
1. Install Docker, the Installation instructions and downloadable files can be found here: [[https://docs.docker.com/get-started/]]
2. Download the following script:
3. Go to the directory that contains this script (up.sh), and type: "./up.sh" to execute the script.
4. Open a browser: type the following URL to the browser's URL field: http://localhost:8080 or http://127.0.0.1:8080
5. Read the instructions in the Main Page.

## Outcomes Expected
1. Every 30 minutes, all the changes you made to this local instance of MediaWiki will be automatically backed up to the directory's "backup" directory.
2. The textual content stored in MediaWiki's database can will be stored in an XML file: XLPLATEST.xml
3. All the uploaded files, assuming the file names are accepted by the host operating system, will be dumped to the "backup/MediaFile" directory.

## Boundary Conditions
1. We have only tested on a small number of machines and configurations, your milage may vary.
2. We do not warrant any reliability, completeness, and accuracy of this installation procedure.''''Any action you take upon this information is script is at your own risk,'''' We will not be liable for any losses and damages in connection to the use of the software prescribed here. 


[[microservice]] https://www.bmc.com/blogs/microservices-architecture/
[[MediaWiki]] https://www.mediawiki.org/wiki/MediaWiki
