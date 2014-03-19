Installing Rockdot.
1. Check out this project and disconnect it from SVN.
2. Download a pimped Ant version from here: http://sounddesignz.com/downloads/apache-ant-1.8.0.zip
3. Unzip into bin/apache-ant-1.8.0
4. Set ANT_HOME in FDT, go to Preferences->Ant->Ant Home...
5. Run the Ant target named "install" in config/install.xml
6. Follow the directions from the Console


Using Rockdot's Project Creator.
Available targets in config/setup.xml:

Projects you can use to start your work.
- project_base (minimal project configuration)
- project_facebook (project layout)

Demos to help you get started.
- demo_3d (away3d and starling)
- demo_feathers (starling and feathers)
- demo_kinect (kinect client on osx)
- demo_mc3d (madcomponents)

Platform support you can add into your project. 
All of Rockdots plugins are supported (amf, i/o, facebook, ...)
- platform_android 
- platform_blackberry (bb10)
- platform_desktop
- platform_html
- platform_ios
- platform_server (Zend PHP Framework)

After creating a project, import it into FDT. Open the /platforms folder.
Any platform has a <platform>_build.xml. Have fun!