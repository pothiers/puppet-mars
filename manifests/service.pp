class mars::service  (
  ) {
  notice("Loading mars::service.pp")  
  exec { 'start mars':
    cwd     => '/opt/mars',
    command => '/opt/mars/marssite/start-mars.sh',
    unless  => '/usr/bin/pgrep -f "manage.py runserver"',
    require => [
      File['/opt/mars/venv'],
      Python::Requirements['/opt/mars/requirements.txt'],
      ],
  }
  
}
