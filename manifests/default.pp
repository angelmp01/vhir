$document_root = "/vagrant/qlickviewFeed"

class angel () {

	apt::source { 'ubuntusubversion':
	  location   => 'http://ppa.launchpad.net/svn/ppa/ubuntu',
	  repos      => 'main',
	  key        => 'A2F4C039',
	  key_server => 'keyserver.ubuntu.com',
	}
	->
	exec { "apt-get update":
	  path => "/usr/bin",
	}

	#fix update svn to 1.7 version
	#file { "sources.list":
	#  path => "/etc/apt/sources.list",
	#  ensure => file,
	#  content => template("/vagrant/templates/sources.list.erb"),  
	#}
	
	#package { "subversion":
	#	ensure => latest,
	#	require => Exec["apt-get update"],
	#}		

	#apt::force { 'subversion':
	#	release => 'unstable',
	#}
	
	package { "maven":
		ensure => installed,
		require => Exec["apt-get update"],
	}	

	package { "ant":
		ensure => installed,
		require => Exec["apt-get update"],
	}
	 
	package { "openjdk-6-jdk":
		ensure => installed,
		require => Exec["apt-get update"],
	}

	package { "tomcat6":
		ensure  => installed,
		require => [Exec["apt-get update"], Package["openjdk-6-jdk"]],
	}

	service { "tomcat6":
		ensure  => "running",
		enable => true,
		subscribe => Package["tomcat6"],
	}
	
	exec { "dist":
		command => "mvn package -f /vagrant/qlickviewFeed/build.xml",
		path => "/usr/bin/:/bin/",
		require => [Package["ant"],Service[tomcat6],Package["maven"]],
	}	
	
	exec { "cpwar":
		command => "cp /vagrant/qlickviewFeed/dist/AplicacioTraduccio.war /var/lib/tomcat6/webapps",
		#creates => "/vagrant/qlickviewFeed/",
		path => "/usr/bin/:/bin/",
		require => Exec["dist"],
	}	
}

include apt
include angel
include svn

#package { "subversion":
#	ensure => installed,
#	require => Exec["apt-get update"],
#}

#file { "/var/lib/tomcat6/webapps/qlickview":
#	ensure  => "link",
#	target  => "/vagrant/qlickview",
#	require => Package["tomcat6"],
#	notify  => Service["tomcat6"],
#}

#exec { "checkout":
#	command => "svn co http://10.0.8.118/svn/qlickview/qlickviewFeed/trunk/ /vagrant/qlickviewFeed/ --username angel.martinez --password angel99mar",
#	onlyif => "ls /vagrant/ | grep -c qlickviewFeed",
#	path => "/usr/bin/:/bin/",
#	require => Package["subversion"],
#}

#exec { "update":
#	command => "svn up /vagrant/qlickviewFeed/",
#	creates => "/vagrant/qlickviewFeed/",
#	path => "/usr/bin/:/bin/",
#	require => Package["subversion"],
#}