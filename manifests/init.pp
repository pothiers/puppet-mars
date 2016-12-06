class mars {
  #notify{ "Loading mars::init.pp": }
  include mars::install
  #! include mars::config
  include mars::service
}
