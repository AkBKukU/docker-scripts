# Semantic Wiki Setup

Semantic wiki is a nightmare to install and it CANNOT be done at once with a never used Mediawiki instance. You will always have to "upgrade" an existing Mediawiki site to Semantic Wiki. This DockerFile and docker compose script provides the means to both make a new wiki for use with SMW and import an existing wiki and upgrade it as needed to work with SMW.  

## Compose vs. Composer

Before we get started I want to call attention to a confusing naming conflict. We are using a Docker Compose YML script to launch the `mediawiki` image with its SQL server dependancy fullfilled by `mariadb`. Internally Mediawiki also uses a PHP package manager called Composer. This causes a lack of distinction when talking about the compose script and composer files. To make this more clear I will only refer to these by the long names of "Docker Compose" and "PHP Composer" everywhere needed.
  
## Initial Setup  
  
Create a folder for files to be stored for the wiki.  
  
In the `.env` file set the following:  
  
- `BIND_DIR` **:** Path of the wiki folder.  
- `MYSQL_DATABASE` & `MYSQL_USER` & `MYSQL_PASSWORD` **:** SQL database login info
  
Keep in mind the hostname for the SQL server is `database`  
  
I will also note here that there are two `OVERRIDE` values in `.env` that are set to `/tmp` by default. These change the path of the volume in the container to prevent creating an empty folder where the files don't yet exist. Leave them set to that until the appropriate stage of the setup process covered below.
 
### Starting a New Wiki

Launching the docker compose script without any prior setup will start with a plain Mediawiki server that requires configuration. You can go through the full setup process as normal and download the `LocalSettings.php` file it gives you at the end. Delete the `LocalSettings.php` folder in your `BIND_DIR` and place the file there, set `LOCALSETTINGS_OVERRIDE` in `.env` to be blank, and restart the docker compose script.   
  
It will detect the `LocalSettings.php` file on boot and convert it to a Semantic Mediawiki install automatically.
  
### Importing an Existing Wiki

In the folder you set as `BIND_DIR` create a folder named `.sql_init`. Put a dump of your existing SQL database as a `*.sql` file. Also put any custom extensions you may have in an `extensions` folder in `BIND_DIR`. Copy your `LocalSettings.php` and `images` folder in `BIND_DIR` as well. Lastly set `LOCALSETTINGS_OVERRIDE` in `.env` to be blank.  
  
Edit your `LocalSettings.php` file with the following changes:  
    
- Add this line `$wgExtensionDirectory = '/var/www/html/extensions-custom';` and move your custom extension loads after it.  
- Add the following before the custom extensions:  

        wfLoadExtension( 'SemanticMediaWiki' );
        enableSemantics( 'LOCALHOST' );

Start the docker compose script now and it will import your database, download SemanticMediaWiki, and upgrade your database. 

## Maintenance
  
### Adding PHP Composer Requirements  
If you want PHP Composer to be able to install more modules you will first need to get a copy of your current `composer.local.json` file within the mediawiki container. This can be done following command in the folder with the docker compose script:

`docker-compose -f mediawiki-smw.yml exec mediawiki cat composer.local.json`  
  
Save the output of that to a file named `composer.local.json` in your `BIND_DIR`. You will need to delete a folder that was made there as a place holder to do this. Shut down the docker compose script and in your `.env` file set `COMPOSER_OVERRIDE` to be blank. Bring up the docker compose script again and you should now be running off of your volume exported `composer.local.json` file and can add new requirements as needed.