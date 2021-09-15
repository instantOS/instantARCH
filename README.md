<div align="center">
    <h1>instantARCH</h1>
    <p>the official instantOS installer</p>
    <img width="300" height="300" src="https://raw.githubusercontent.com/instantOS/instantLOGO/main/png/arch.png">
</div>

#

----------

instantARCH is a super lightweight quick & easy to use installer for instantOS.

<p align="center">
  <img src="https://raw.githubusercontent.com/instantOS/instantLOGO/main/screeenshots/instantarch.png">
</p>

## Features

- Ask all user input before installation
- Graphical and command line interface
- Lightweight
- Easy to use
- Netinstall that stays pretty close to Arch

## Usage

instantARCH is preinstalled on all instantOS iso files (duh) and can be launched through the welcome app or the widget in the top right.  
It can also be run as a command line application on a vanilla arch live disk. 
```sh
bash <(curl -L instantos.io/install)
```

## Comparison with other installers

Why did instantOS go for a custom installer instead of just using what's out
there?  To be clear, all of the installers below are fine pieces of software
and I do not want to talk anyone out of using them.  This comparison just
lists the reasons why they aren't used by instantOS and the advantages that
instantARCH has over them that make it fit for the project.

### Architect

Architect might seem similar at first glance but you quickly realize that it is
made for people who would have been capable of installing arch the arch way
anyway. The level of knowledge required is almost the same and has the same
room for error.  It has the possibility of executing a step twice, erasing the
progress of other steps and you can absolutely end up with a non-bootable
system. All of these things would be pretty big flaws for a normal setup wizard
(which architect is not trying to be which makes it unfit for instantOS).

### Calamares

Calamares is probably the project closest to being fit for instantOS.  The user
experience is clear and straight forward, all user input is asked for
**before** the installation and it can well be used even by people without a
lot of experience. It is still not used over instantARCH for several reasons:
The hardware requirements are above those of the OS itself meaning it would
prevent installation on machines that are well capable of running the OS.  It
is also far more complex under the hood, meaning extending it with more
functionality would be a substantial amount of work. Finally only amd64 is
officially supported, porting instantOS to other architectures (which is
planned) would mean leaving the official support of Calamares developers.

