# Installing Rockdot.

1. Clone this project
2. Download my pimped Ant version from here: http://sounddesignz.com/downloads/apache-ant-1.8.0.zip
3. Unzip into bin/apache-ant-1.8.0
4. Set ANT_HOME.
 * In Eclipse/FDT/Flash Builder, go to Preferences->Ant->Ant Home...
5. Run the Ant target named "install" from config/install.xml
6. Follow the directions in the Console!!


# Using Rockdot's Project Creator.

### Now, go to config/setup.xml

## Projects you can use to start your work.
* project_base (minimal project configuration)
* project_facebook (project layout)

## Demos to help you get started.
* demo_3d (away3d and starling)
* demo_feathers (starling and feathers)
* demo_kinect (kinect client on osx)
* demo_mc3d (madcomponents)
* demo_ugc (facebook-enabled user generated content app, including AMF/Zend Backend, Database, Blacklist editor)

## Platform support you can add into your project.
 
### All of Rockdots plugins are supported (amf, i/o, facebook, ...)
* platform_android 
* platform_blackberry (bb10)
* platform_desktop
* platform_html
* platform_ios
* platform_server (Zend PHP Framework)

After creating a project, import it into your IDE. Open the /platforms folder.
Every platform has a <platform>_build.xml. 

## Have fun!