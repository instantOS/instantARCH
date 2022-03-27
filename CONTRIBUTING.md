## Contributing to instantARCH

Before implementing a feature make sure the feature is actually wanted. 
You can do this by discussing it on our Discord or any of the other methods mentioned on the
[support site](https://instantos.github.io/instantos.github.io/support)

Any change to instantARCH should meet the following requirements. 

It should be available in both the CLI and the GUI version.
A good starting point for that is the imenu script which creates menus that adapt to running in either GUI or CLI mode. 

It should keep the installer usable for people with little technical knowledge. 
instantARCH is meant to provide a similar experience to installers Calamares or Ubuntu's Ubiquity installer. 
Any features that require more technical skill to understand and use should not require mandatory user input during installation.
Anything like that is an unavoidable obstacle for casual users. 
That said, any addition to instantARCH is more than welcome, all that means is that complex functionality should be put in an "advanced options" menu of some sort. 

Anything requiring user input should be asked before installation. 
This works by putting it in the ask.sh script and saving the result with the iroot utility. 
and later reading it out during installation. 
You should be able to answer all questions before installation and then letting the computer sit for a while. 
There's nothing more frustrating than letting your computer with german internet sit for an entire night to discover that it stopped at some confirmation prompt you didn't anticipate. 

## Stability

Because instantARCH is the onboarding process for instantOS, breaking it makes
the entire rest inaccessible for new or reinstalling users, so it is crucial to
keep uptime as high as possible. Before contributing any changes in
functionality or architecture make sure you did at least one test installation
to check that it doesn't prevent installing instantOS from working. If that is
not possible for you or the feature might require some more testing, PR to the
testing branch instead of main. The testing branch will not be distributed to
the iso automatically and is safe to break as it is opt-in through the
development tools. 

## Getting started with instantARCH development

instantARCH uses different modules for different stages of the installation. 
This allows for reordering them and potentially reusing them or making some of them optional (like the uefi grub module)
The central installer script asks all questions using ask.sh first and then saves the answers using the iroot utility. 
Then it calls all the modules that read out the answers during installation. 
It is important to distinguish between escript modules that run in the installation medium and chrootscript modules
that get executed inside the (unfinished) installation. 
