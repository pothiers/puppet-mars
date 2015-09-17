class mars::install (
  $stamp = strftime("%Y-%m-%d %H:%M:%S")
  ) {
  notify { "Installing MARS module": }
  notice("Installing mars module")
  
  # these are also given by: puppet-sdm
  include epel
  #!package { ['git', ]: }
  ensure_resource('package', ['git', ], {'ensure' => 'present'})

  include augeas

  yumrepo { 'ius':
    descr      => 'ius - stable',
    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
    enabled    => 1,
    gpgcheck   => 0,
    priority   => 1,
    mirrorlist => absent,
  }
  -> Package<| provider == 'yum' |>

#  yumrepo { 'mars':
#    descr    => 'mars',
#    baseurl  => "http://mirrors.sdm.noao.edu/mars",
#    enabled  => 1,
#    gpgcheck => 0,
#    priority => 1,
#    mirrorlist => absent,
#  }
#  -> Package<| provider == 'yum' |>

  
  package { ['python34u-pip']: }
  class { 'python':
    version    => '34u',
    pip        => false,
    dev        => true,
  } 
  file { '/usr/bin/pip':
    ensure => 'link',
    target => '/usr/bin/pip3.4',
  }

#!  python::requirements { '/etc/mars/requirements.txt':
#!    owner  => 'root',
#!  } 
#!  package{ ['mars'] : }
  
  Class['python'] -> Package['python34u-pip'] -> File['/usr/bin/pip']
  #!-> Python::Requirements['/etc/mars/requirements.txt']
  #!-> Package['mars'] 
  #!-> Service['djangod']
  
  }
