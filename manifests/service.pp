class mars::service  (
  ) {
  notice("Loading mars::service.pp")    # output to puppet master
  notify{ "Loading mars::service.pp": } # output to puppet client
  exec { 'start mars':
    cwd     => '/opt/mars',
    command => "/bin/bash -c 'source /opt/mars/venv/bin/activate; /opt/mars/marssite/start-mars.sh'",
    unless  => '/usr/bin/pgrep -f "manage.py runserver"',
    user    => 'devops',
    subscribe => [
      Vcsrepo['/opt/mars'], 
      File['/opt/mars/venv', '/etc/mars/from-hiera.yaml'],
      Python::Requirements['/opt/mars/requirements.txt'],
      ],
  }
  
}
