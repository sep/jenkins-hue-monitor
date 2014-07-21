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

* If any builds are failing and none are building, the status is set to "failed" (default: red)
* If any builds are failing and any are building, the light will be "failed and building (default: yellow)
* If all builds are passing and any are building, the light will be "building" (default: blue)
* If all builds are passing and none are building, the light will be "passed" (default: green)
* If all builds are passing, at least one is unstable, and none are building, the light will be "unstable" (default: orange)

### In case you want your own colors...

Colors can be passed as optional command line arguments.  But really, why would you?  The defaults are already objectively correct.

The aforementioned colors are defaults, but you can also customize each one separately.

* `-f` lets you customize the _failed_ status.
* `-w` lets you customize the _failed and building_ status.
* `-b` lets you customize the _building_ status.
* `-p` lets you customize the _passed_ status.
* `-u` lets you customize the _unstable_ status.

The value to pass is the __h__ (hue) part of an [_HSB_](http://colorizer.org/) color, except Hue is expecting a value between 0-65536 instead of 0-360, so scale it (multiply by 65536 and divide by 360).

### OH LOOK. BRIGHTNESS AND SATURATION

You can also pass in arguments for the light's brightness and saturation. We've picked VERY SENSIBLE DEFAULTS ("as high as they will go and no higher") but if you want to tinker with it, you disgusting perfectionist, just add these flags:

* `-s` lets you customize the _saturation_ (with values of 0-255. try something different and it's ON YOUR HEAD)
* `-r` lets you customize the _brightness_ (same as above. don't get cocky)

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
    bundle install &&                               \
        ruby hue_runner.rb                          \
        -j http://jenkins/view/MyView/api/json      \
        -l http://huebridge/api/user/lights/x/state \
        -f 0 -w 12750 -b 46920 -p 25717 -u 6000     \
		-r 255 -s 255
</pre>

This assumes you have Jenkins running at `http://jenkins/` with a view called `MyView` that contains all the projects you want to monitor. Additionally you have the Hue Bridge installed at `http://huebridge/` with a username `user` and a light ID of `x`.

You can certainly configure this differently if you know what you're doing. I didn't know what I was doing.

## You are a hero

Look, let's not get weird about this. I'm just... I'm just a guy, you know?

## License?

BSD, baby.
