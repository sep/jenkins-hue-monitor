# Jenkins Hue Build Monitor

Hey, you. Psst. You like colorful lights?

It doesn't matter what you answered. The correct answer is "yes! How can I get these colorful lights to indicate the state of my continuous integration server?"

Well, you've seen those [Philips Hue](http://www.meethue.com/) lights, right? Well, they have a [REST API](http://developers.meethue.com/gettingstarted.html) that allows you do to awesome light-based things.

THINGS LIKE MAKE AN EASY BUILD MONITOR. CAPSLOCK.

## Build Monitor? What's that?

Imagine a world where all your builds are running continuously on [Jenkins](http://jenkins-ci.org/) somewhere, and instead of turning your head or loading a website like a chump you can simply glance at the ambient light put out by the Philips Hue bulb and know instantly the state of your builds based on the color of the lightbulb.

THAT WORLD IS CALLED ~~FRANCE~~ THIS WORLD.

## Colors, you say?

Yes, colors. Or "colours" if you're a non-American English speaker, which I toutally respect.

## Wait, isn't there a Jenkins Plugin for this already?

Yeah. There's a very nice plugin called [hue-light-plugin](https://github.com/jenkinsci/hue-light-plugin), but it only displays the status of a single project.

This script will aggregate multiple projects (that are united under a single view) and update the color based on the following rules:

* If any builds are failing and none are building, the light will be **red**
* If any builds are failing and any are building, the light will be **yellow**
* If all builds are passing and any are building, the light will be **blue**
* If all builds are passing and none are building, the light will be **green**

It has been brought to my attention that this is a stupid color scheme. You're right.

### In case you want stupid colors...

Colors can be passed as command line arguments.

The aforementioned colors are defaults, but you can also customize each one separately.

* `-f` lets you customize _failed_ status.
* `-w` lets you customize _failed and building_ status.
* `-b` lets you customize _building_ status.
* `-p` lets you customize _passed_ status.

The value to pass is the __h__ (hue) part of an [_HSB_](http://colorizer.org/) color.

## You had me at "Hue". How does this work?

There are a few prerequisites for E-Z Mode:

* You should probably have Jenkins installed
* You should probably be building things within your Jenkins installation
* The projects you want to monitor should be collected into a View
* You need to be running builds on some kind of Unix
* You need to have Ruby installed, preferably some recent version (2.0-ish)

The instructions below assume you're using RVM in Linux and have Ruby 2.0 installed (and Bundler).

1. Create a new Job in Jenkins
2. Point the repository to this project
3. Under "Build Triggers":
  * Check "Build periodically"
  * Set the Schedule to "* * * * \*"
  * Check "Poll SCM"
  * Set the Schedule to "* * * * *"
4. Create a Build Step for "Execute shell" and enter the following text:

<pre>
    #!/bin/bash
    
    . "$HOME/.rvm/scripts/rvm"
    bundle install &&                           \
	ruby hue_runner.rb                          \
	-j http://jenkins/view/MyView/api/json      \
	-l http://huebridge/api/user/lights/x/state \
        -f 0 -w 12750 -b 46920 -p 25717
</pre>

This assumes you have Jenkins running at `http://jenkins/` with a view called `MyView` that contains all the projects you want to monitor. Additionally you have the Hue Bridge installed at `http://huebrige/` with a username `user` and a light ID of `x`.

You can certainly configure this differently if you know what you're doing. I didn't know what I was doing.

## You are a hero

Look, let's not get weird about this. I'm just... I'm just a guy, you know?

## License?

BSD, baby.
