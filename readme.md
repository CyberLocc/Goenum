Credit to this mostly goes to TCM Security and "Sumrecon". As this started via the Practial Ethical Hacking course tutorial on how to make something like this.

I was not a fan of a few aspects of his methodology, such as his directory structures, and in general how some of the things were done I felt could be slightly optimized. 

Another big thing I wanted to do, was either install the tools had they not been, or at least run a verifaction if they were or not. I blow up VMs alot, and as such this is handy to get a running of what is missing, to completely run the tool. At first I went with full installs, but alot of these tools installs can be finnicky and need troubleshooting, also it was slowing the script down doing it like that. So at this time, it only verifies whether the tools are installed or not, and suggests the method of install. 

Another big change at this time, is the commenting of Amass, in TCMs method Amass is commented out. With the expectation of uncommenting should you want to use it. I felt it would be easier to just add a prompt to toggle Amass usage or not. 

Following the same user friendly Prompt idealogy I wanted the ability to be prompted for the domain, should you forget to enter it iniatially. So it will now accept the argument when ran, or prompt for it afterwords. 

I of course had to add Ascii art, because who doesnt love some Ascii art. 


This is not a Finished Project, and more work to be done! Coming Soon! 
