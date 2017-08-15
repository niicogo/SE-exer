node default {
	package {'vim-enhanced':
		ensure => 'installed',
	}

	package {'curl':
		ensure => 'installed',
	}

	package {'git':
		ensure => 'installed',
	}

	#USER
	user {'monitor':
		ensure => 'present',
		managehome => 'true',
		shell => '/bin/bash',
	}

	#Create scripts directory
	file {'/home/monitor/scripts/':
		ensure => 'directory',
	}

	exec {'retrieve_memorycheck':
		command => "/usr/bin/wget -q https://raw.githubusercontent.com/niicogo/SE-exer/master/memory_check.sh -O /home/monitor/scripts/memory_check.sh",
		creates => '/home/monitor/scripts/memory_check.sh',
	}

	#Create src directory
	file {'/home/monitor/src/':
		ensure => 'directory',
	}

	#Create symlink
	file {'/home/monitor/src/my_memory_check.sh':
		ensure => 'link',
		target => '/home/monitor/scripts/memory_check.sh',
	}

	#Create crontab
	cron {'memcheck':
		ensure => 'present',
		command => '/home/monitor/src/my_memory_check.sh',
		user => 'root',
		minute => '10',	
	}	
} #End
