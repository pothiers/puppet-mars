class mars::install {
  #! notify { "Installing MARS module": }
  
  # these are also given by: puppet-sdm
  #!include epel
  #!package { ['git', ]: }
  ensure_resource('package', ['git', ], {'ensure' => 'present'})

  include augeas

  file { [ '/var/run/mars', '/var/log/mars', '/etc/mars', '/var/mars']:
    ensure => 'directory',
    group  => 'root',
    mode   => '0774',
  } ->
  file { '/etc/mars/requirements.txt':
    replace => true,
    source => 'puppet:///modules/mars/requirements.txt',
  } ->
  vcsrepo { '/opt/mars' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pothiers/mars.git',
    revision => 'master',
  }

  file { [ '/var/www', '/var/www/mars', '/var/www/mars/static']:
    ensure => 'directory',
  }

#!  file { '/etc/init.d/marssvc':
#!    source => 'puppet:///modules/mars/marssvc',
#!    mode   => '0777',
#!  }
  

  yumrepo { 'ius':
    descr      => 'ius - stable',
    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
    enabled    => 1,
    gpgcheck   => 0,
    priority   => 1,
    mirrorlist => absent,
  }
  -> Package<| provider == 'yum' |>

#! yumrepo { 'mars':
#!   descr    => 'mars',
#!   baseurl  => "http://mirrors.sdm.noao.edu/mars",
#!   enabled  => 1,
#!   gpgcheck => 0,
#!   priority => 1,
#!   mirrorlist => absent,
#! }
#! -> Package<| provider == 'yum' |>

  
  package { ['python34u-pip']: } ->
  class { 'python':
    version    => '34u',
    pip        => false,
    dev        => true,
  } ->
  file { '/usr/bin/pip':
    ensure => 'link',
    target => '/usr/bin/pip3.4',
  } ->
  package{ ['postgresql', 'postgresql-devel', 'mars', 'expect',
            'python-matplotlib'] : } ->
  python::requirements { '/etc/mars/requirements.txt':
    owner  => 'root',
  } 
  

  file { '/etc/yum.repos.d/nginx.repo':
    replace => false,
    source => 'puppet:///modules/mars/nginx.repo',
  } ->
  package { ['nginx'] : }
}
