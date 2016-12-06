class mars::install (
  $marsvhost = hiera('mars_vhost', 'www.mars.noao.edu'),
  $marsversion = hiera('marsversion', 'master'),
  ) {
  notify{"Loading mars::install.pp; marsversion=${marsversion}":}

  ensure_resource('package', ['git', ], {'ensure' => 'present'})
  include augeas

  user { 'devops' :
    ensure     => 'present',
    comment    => 'For python virtualenv and running mars.',
    managehome => true,
    password   => '$1$Pk1b6yel$tPE2h9vxYE248CoGKfhR41',  # tada"Password"
    system     => true,
  }
  
  class { 'apache': } ->
  apache::vhost { "${marsvhost}":
    port     => '80',
    #!priority => '15',
    docroot  => '/var/www/mars',
  }

  file { '/etc/mars/django_local_settings.py':
    replace => false,
    source  => hiera('localdjango'),
  } 
  file { '/etc/nginx/ngnix.conf':
    replace => false,
    source  => hiera('nginx_conf'),
  } 
  # for nginx
  file { [ '/var/www', '/var/www/mars', '/var/www/static/',
           '/var/www/mars/static']:
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

  file { [ '/var/run/mars', '/var/log/mars', '/etc/mars', '/var/mars']:
    ensure => 'directory',
    mode   => '0777',
  } ->
  vcsrepo { '/opt/mars' :
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/pothiers/mars.git',
    #!revision => 'master',
    revision => "${marsversion}",
    owner    => 'devops',
    group    => 'devops',
    require  => User['devops'],
    notify   =>  [
                  Python::Requirements [ '/opt/mars/requirements.txt'],
                  Exec['start mars'],
                  ],
    } ->
  package{ ['postgresql', 'postgresql-devel', 'expect'] : } ->
  class { 'python' :
    version    => 'python35u',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'absent',  # 'present',
    gunicorn   => 'absent',
    } ->
  file { '/usr/bin/python3':
    ensure => 'link',
    target => '/usr/bin/python3.5',
    } ->
  python::pyvenv  { '/opt/mars/venv':
    version  => '3.5',
    owner    => 'devops',
    group    => 'devops',
    require  => [ User['devops'], ],
  } ->
  python::requirements  { '/opt/mars/requirements.txt':
    virtualenv => '/opt/mars/venv',
    owner    => 'devops',
    group    => 'devops',
    require  => [ User['devops'], ],
  }

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
