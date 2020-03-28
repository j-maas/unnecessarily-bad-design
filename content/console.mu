---
type: page
title: How to use the console
---

What's the simplest way to interact with a computer? No, not what you're most used to, not moving the mouse and clicking boxes on screen. What's the simplest way to tell a computer what you want?

Write what you want. As text.

That's exactly what the console does. You write what you want and the computer writes back.

|> Heading
    What can I ask for?

To copy a file you tell the computer "copy this file to there." To let it list you all files in a folder you tell it "list everything with all info." To remove a folder, you tell it "remove this folder and everything in it."

Ok, I lied a bit. Unfortunately, computers don't yet reliably understand the way we talk and write normally. But we simply need to structure our questions in a certain manner---meet them halfway. What you really write is `cp thisFile.txt there.txt`{bash}, `ls -l`{bash} and `rm -r thisFolder`{bash}.

The structure is that you call a program and give it arguments that describe how it should do its job. So the copy program, `cp`{bash}, needs to know which file to copy where. `ls`{bash} wants to know whether it should present the files in a compact list or a table with all information. And `rm`{bash} needs to know that it is dealing with a folder and should really delete everything inside.

You'll notice that there is two types of arguments. There were the file names and there was this thing with the dash in front, e.g. `-l`{bash}. Some programs expect their arguments in a specific order. For example, `cp`{bash} wants the file to copy first and then the destination to copy it to. Other times you have to specify what kind of argument you are giving. `ls`{bash} takes many different arguments, for example to also show hidden files, `-a`{bash}. So these arguments have names that typically start with a dash.

Since people are lazy, they try to keep everything short. "Copy" becomes `cp`{bash}, "list" becomes `ls`{bash}, "all files (including hidden ones)" becomes `-a`{bash}. So it might be a bit difficult to guess or even remember how everything was called, exactly. But luckily, the programmers have included a "manual" on how to use their programs. And it's available as a console program, `man`{bash}! If you forget how to use `cp`{bash}, `man cp`{bash} will list you all options that are available.

What does the answer look like? If you're lucky, nothing. Seriously. For example, if `cp`{bash} does its job, it gives no output. Only if it could not copy a file, e.g. because the file you wanted to copy does not actually exist, will it print what the problem was. So don't panic if you don't see a confirmation. Of course, programs like `ls`{bash} are an exception to this. Their job is to print out information to you.

|> Heading
    Moving around files and moving files around

The console was used in a time before displays. It was literally a printer where you typed on a keyboard and it would print out the response line by line. So you couldn't just drag a file to the trash bin to delete it. You couldn't even open a folder and see all the files inside!

Instead, the console is always in a /working directory/. By default it opens your user folder. If the working directory contains a file `readme.txt`{bash}, then you could remove it simply by giving its name, `rm readme.txt`{bash}. This works, because the console looks up file names relative to its working directory.

How do you open the file `findme.txt`{bash} that's inside the folder `hiddenStuff`{bash}? You can tell the console how to get to the file using a /path/. In our example, the path would be `hiddenStuff/findme.txt`{bash}. So you tell the console which folders to go into, separated by slashes, `/`{bash}, and then you give it the file name. If you want to remove a file that is multiple folders away, the command could look like `rm firstFolder/secondFolder/thirdFolder/file.txt`{bash}.

All of these paths are relative to the working directory that the console is currently inside of. So all your images are available, but what if you need to access your USB drive? That is not inside your user folder. How do you access those?

The paths I showed you are relative. But of course every file has a unique path when you start at the first folder, the /root directory/. The `homework.txt`{bash} on your USB drive is available at `/dev/sda1/homework.txt`{bash}. So if you start at the root folder, your USB drive is available inside the `dev`{bash} folder and then inside the `sda1`{bash} folder. Every path that starts with a slash is an absolute path that start at the root directory! Paths that start with a folder or file name are relative paths that start at the working directory.

Relative paths can also be written as `./hiddenStuff/findme.txt`{bash}, because `.`{bash} is a kind of name for the current directory which in the beginning is the working directory! You could do weird stuff like `hiddenStuff/./findme.txt`{bash} which says "From the working directory, go into the `hiddenStuff`{bash} folder, then go into the current folder (you're already in the current folder, duh!) and then there is the file `findme.txt`{bash}."

But there is also a more useful name which is that of the parent directory, called `..`{bash}. So `hiddenStuff/../otherFile.txt`{bash} says "From the working directory, go into `hiddenStuff`{bash}, then go back to its parent folder (which is the working directory where we came from) and then there is the file `otherFile.txt`{bash}." So that path is the same as `findme.txt`{bash} or `./findme.txt`{bash}.

Now it gets interesting because we change the working directory. The program that "changes directory" is `cd`{bash}. So to remove a file in the `hiddenStuff`{bash} folder, you can call `rm hiddenStuff/findme.txt`{bash} or you can go into the folder with `cd hiddenStuff` and then remove the file with `rm findme.txt`. Note that these are now two commands. But if you use `ls` you'll see that it will list different files as before, because you are in a different folder! So if you need with a lot of files from `hiddenStuff`{bash}, then `cd`{bash} is useful because it makes the path shorter. How do you get back? Well, you go to the parent directory with `cd ..`{bash} which in our example takes you back to your user folder.

|> Heading
    Rights and how to make things right

|> Heading
    Not all consoles are created equal