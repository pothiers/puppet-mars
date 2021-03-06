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
  file {  '/etc/mars/from-hiera.yaml': 
    ensure  => 'present',
    replace => true,
    content => "---
marsvhost: ${marsvhost}
marsversion: ${marsversion}
",
    group   => 'root',
    mode    => '0774',
  }
  
  
#!  class { 'apache': } ->
#!  apache::vhost { "${marsvhost}":
#!    port     => '80',
#!    #!priority => '15',
#!    docroot  => '/var/www/mars',
#!  }

  file { '/etc/mars/django_local_settings.py':
    replace => true,
    source  => hiera('localdjango'),
  } 
  file { '/etc/mars/django_local_settings_test.py':
    replace => true,
    source  => hiera('localdjangotest', 'puppet:///modules/dmo_hiera/django_settings_local_pat.py'),
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
    notify   => Exec['start mars'],
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
  } -> 
  file { '/etc/mars/search-schema.json':
    replace => true,
    source  => '/opt/mars/marssite/dal/fixtures/search-schema.json' ,
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
