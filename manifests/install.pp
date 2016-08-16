class mars::install (
  $djsettings = hiera('localdjango'),
  ) {
  ensure_resource('package', ['git', ], {'ensure' => 'present'})
  include augeas

  file { [ '/var/run/mars', '/var/log/mars', '/etc/mars', '/var/mars']:
    ensure => 'directory',
    group  => 'root',
    mode   => '0774',
  } ->
#!  file { '/etc/mars/requirements.txt':
#!    replace => true,
#!    source => 'puppet:///modules/mars/requirements.txt',
#!  } ->
  vcsrepo { '/opt/mars' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pothiers/mars.git',
    revision => 'master',
  }

  file { '/etc/mars/django_local_settings.py':
    replace => false,
    source  => "${djsettings}",
  } 

  file { [ '/var/www', '/var/www/mars', '/var/www/mars/static']:
    ensure => 'directory',
  }


  yumrepo { 'ius':
    descr      => 'ius - stable',
    baseurl    => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
    enabled    => 1,
    gpgcheck   => 0,
    priority   => 1,
    mirrorlist => absent,
  }
  -> Package<| provider == 'yum' |>

  package{ ['postgresql', 'postgresql-devel', 'expect'] : } ->
  #package { ['python34u-pip']: } ->
  class { 'python':
    #!version    => '34u',
    #!pip        => false,
    version    => '35',
    pip        => true,
    dev        => true,
    gunicorn   => true,
  } ->
  #!file { '/usr/bin/pip':
  #!  ensure => 'link',
  #!  target => '/usr/bin/pip3.4',
  #!} ->
  file { '/usr/local/bin/python3':
    ensure => 'link',
    target => '/usr/bin/python3',
    } ->
    python::pyvenv { '/var/www/project1' :
      ensure       => present,
      systempkgs   => true,
      venv_dir     => '/opt/mars/virtualenvs',
      owner        => 'pothiers',
      group        => 'archive',
    } ->
  python::requirements { '/opt/mars/requirements.txt': } 

  file { '/etc/yum.repos.d/nginx.repo':
    replace => false,
    source => 'puppet:///modules/mars/nginx.repo',
  } ->
  package { ['nginx'] : }


#! yumrepo { 'mars':
#!   descr    => 'mars',
#!   baseurl  => "http://mirrors.sdm.noao.edu/mars",
#!   enabled  => 1,
#!   gpgcheck => 0,
#!   priority => 1,
#!   mirrorlist => absent,
#! }
#! -> Package<| provider == 'yum' |>

  
}
