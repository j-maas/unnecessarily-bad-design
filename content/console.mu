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