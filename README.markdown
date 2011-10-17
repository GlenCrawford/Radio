Radio
=====

Intro
-----

Radio is a work-in-progress music-player app for use at YouDo (if I can get it going well enough). The idea for "Radio Dooplex" originated at YouDo.

The intention is for music to be pooled into a directory, through which the app will periodically crawl to discover newly-added tracks. The Radio's DJ can then build and maintain a playlist using a custom algorithm.

The interface is kept as simple as possible. Users are shown the upcoming tracks and only two buttons: Play/Pause (toggle between the two), and Veto, which records who vetoed which track and skips to the next track.

All track information (including play counts), track genres, user data and vetos are stored in the database, which can then be used by the DJs to build smarter playlists, based on, for example, which users are logged in, how often a track is vetoed versus how often it is played, et cetera.

It is possible to build your own DJ simply by subclassing the DJ class and implementing one method. That DJ can then be assigned to the Radio as the current DJ, and the player and playlist will tick over automatically. The Random Genre DJ - which cycles through genres randomly, playing an hours worth of random tracks from each - is the default.

Because there is no way I can account for every possible network and speaker setup, I haven't implemented the Player module. Anyone that wants to use Radio should implement the Player module's methods to suit their particular configuration.

Testing
-------

_Everything_ is tested using RSpec. Currently, there are no failures or deprecation warnings.

Installation
------------

Clone the source code from this repository and prepare it like a normal Ruby on Rails app (bundle install, database.yml, et cetera) and then run:

    rake radio:install

Follow the prompts and it will guide you through installation.

Then you'll want to implement the Player module to play the tracks over whatever network and speaker configuration you have.

Screenshot
----------

![Radio](http://i.imgur.com/x8h3Q.jpg)

Background image by [Aaron Shumaker at Flickr](http://www.flickr.com/photos/trushu/524504628/). Image not included in the distribution (you set it to whatever you want during installation).

License
-------

Copyright &copy; 2011 Glen Crawford

This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">
  <img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" />
</a>
