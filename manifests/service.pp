class mars::service  (
  $djangoserver = hiera('djangoserver', '/opt/mars/start-mars-production.sh'),
  ) {
  #notice("Loading mars::service.pp")    # output to puppet master
  #notify{ "Loading mars::service.pp": } # output to puppet client
  exec { 'collect status':
    command => "/bin/bash -c 'source /opt/mars/venv/bin/activate; /opt/mars/marssite/manage.py collectstatic'",
    creates => '/opt/mars/marssite/audit/static/audit/screen.css',
    } ->
  exec { 'start mars':
    cwd     => '/opt/mars',
    #command => "/bin/bash -c 'source /opt/mars/venv/bin/activate; /opt/mars/marssite/start-mars.sh'",
    command => "/bin/bash -c ${djangoserver}",
    creates => '/var/log/mars/mars-detail.log',
    #unless  => '/usr/bin/pgrep -f "manage.py runserver"',
    user    => 'devops',
    subscribe => [
      Vcsrepo['/opt/mars'], 
      File['/opt/mars/venv', '/etc/mars/from-hiera.yaml'],
      Python::Requirements['/opt/mars/requirements.txt'],
      ],
  }
}
